// Wrapper.cpp

#include "Wrapper.h"
#include <opencv2/opencv.hpp>
#include <vector>

std::vector<cv::Mat> extract_photos(cv::Mat input_image, std::pair<float, float> aspect_ratio = {5.5, 8.5}, int min_size = 50) {
    cv::Mat gray;
    cv::cvtColor(input_image, gray, cv::COLOR_BGR2GRAY);

    cv::Mat threshold;
    cv::threshold(gray, threshold, 0, 255, cv::THRESH_BINARY_INV + cv::THRESH_OTSU);

    std::vector<std::vector<cv::Point>> contours;
    cv::findContours(threshold, contours, cv::RETR_EXTERNAL, cv::CHAIN_APPROX_SIMPLE);

    std::vector<cv::Mat> extracted_photos;
    int idx = 0;

    for (const auto& cnt : contours) {
        cv::Rect rect = cv::boundingRect(cnt);
        int x = rect.x;
        int y = rect.y;
        int w = rect.width;
        int h = rect.height;
        float ratio = static_cast<float>(w) / static_cast<float>(h);

        if (aspect_ratio.first / aspect_ratio.second * 0.8 <= ratio && ratio <= aspect_ratio.first / aspect_ratio.second * 1.2 && w >= min_size && h >= min_size) {
            idx++;
            cv::Mat photo = input_image(cv::Rect(x, y, w, h));
            extracted_photos.push_back(photo);
        }
    }

    return extracted_photos;
}

cv::Mat UIImageToCVMat(UIImage *image) {
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;

    cv::Mat cvMat(rows, cols, CV_8UC4);
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data, cols, rows, 8, cvMat.step[0], colorSpace, kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault);
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    cv::cvtColor(cvMat, cvMat, cv::COLOR_RGBA2BGR);

    return cvMat;
}

UIImage *CVMatToUIImage(const cv::Mat &cvMat) {
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize() * cvMat.total()];
    CGColorSpaceRef colorSpace;

    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
        cv::cvtColor(cvMat, cvMat, cv::COLOR_BGR2RGBA);
    }

    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    CGImageRef imageRef = CGImageCreate(cvMat.cols, cvMat.rows, 8, 8 * cvMat.elemSize(), cvMat.step[0], colorSpace, kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault, provider, NULL, false, kCGRenderingIntentDefault);
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);

    return image;
}

std::vector<UIImage *> extractPhotosCpp(UIImage *inputImage) {
    cv::Mat inputMat = UIImageToCVMat(inputImage);
    std::vector<cv::Mat> extractedMats = extract_photos(inputMat);
    std::vector<UIImage *> extractedUIImages;

    for (const auto &mat : extractedMats) {
        UIImage *uiImage = CVMatToUIImage(mat);
        extractedUIImages.push_back(uiImage);
    }

    return extractedUIImages;
}
