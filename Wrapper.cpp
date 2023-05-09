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
    NSUInteger bytesPerRow = CGImageGetBytesPerRow(image.CGImage);

    int type = static_cast<int>(CGImageGetBitsPerPixel(image.CGImage)) / static_cast<int>(CGImageGetBitsPerComponent(image.CGImage));
    cv::Mat cvMat;
    if (type == 1) {
        cvMat.create(rows, cols, CV_8UC1);
    } else if (type == 3) {
        cvMat.create(rows, cols, CV_8UC3);
    } else if (type == 4) {
        cvMat.create(rows, cols, CV_8UC4);
    } else {
        throw std::runtime_error("Unsupported image type");
    }

    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data, cols, rows, 8, bytesPerRow, colorSpace, static_cast<uint32_t>(kCGImageAlphaNoneSkipLast) | static_cast<uint32_t>(kCGBitmapByteOrderDefault));
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    if (type == 4) {
        cv::cvtColor(cvMat, cvMat, cv::COLOR_RGBA2BGRA);
    } else {
        cv::cvtColor(cvMat, cvMat, cv::COLOR_RGBA2BGR);
    }


    return cvMat;
}

UIImage *CVMatToUIImage(const cv::Mat &cvMat) {
    cv::Mat tempMat;
    CGColorSpaceRef colorSpace;
    size_t bytesPerRow;
    CGBitmapInfo bitmapInfo;

    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
        tempMat = cvMat;
        bitmapInfo = kCGImageAlphaNone;
    } else if (cvMat.channels() == 3) {
        colorSpace = CGColorSpaceCreateDeviceRGB();
        cv::cvtColor(cvMat, tempMat, cv::COLOR_BGR2RGB);
        bitmapInfo = kCGImageAlphaNone;
    } else if (cvMat.channels() == 4) {
        colorSpace = CGColorSpaceCreateDeviceRGB();
        cv::cvtColor(cvMat, tempMat, cv::COLOR_BGRA2RGBA);
        bitmapInfo = kCGImageAlphaPremultipliedLast;
    } else {
        throw std::runtime_error("Unsupported image type");
    }

    cv::flip(tempMat, tempMat, 0);

    bytesPerRow = tempMat.cols * tempMat.elemSize();
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, tempMat.data, tempMat.elemSize() * tempMat.total(), NULL);
    CGImageRef imageRef = CGImageCreate(tempMat.cols, tempMat.rows, 8, 8 * tempMat.elemSize(), bytesPerRow, colorSpace, bitmapInfo | kCGBitmapByteOrderDefault, provider, NULL, false, kCGRenderingIntentDefault);

    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(tempMat.cols, tempMat.rows)];
    UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull context) {
        CGContextDrawImage(context.CGContext, CGRectMake(0, 0, tempMat.cols, tempMat.rows), imageRef);
    }];

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
        @autoreleasepool {
            UIImage *uiImage = CVMatToUIImage(mat);
            UIImage *copiedImage = [UIImage imageWithCGImage:uiImage.CGImage scale:1.0 orientation:uiImage.imageOrientation];
            extractedUIImages.push_back(copiedImage);
        }
    }

    return extractedUIImages;
}
