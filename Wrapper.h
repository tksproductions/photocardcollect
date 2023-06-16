// Wrapper.h

#include <Foundation/Foundation.h>
#include <UIKit/UIKit.h>

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __cplusplus
    #import <opencv2/opencv.hpp>
#endif

NSArray<UIImage *> *extractPhotos(UIImage *inputImage);
NSArray<NSValue *> *extractRectsObjC(UIImage *inputImage);

#ifdef __cplusplus
}
std::vector<UIImage *> extractPhotosCpp(UIImage *inputImage);
std::vector<cv::Rect> extractRectsCpp(UIImage *inputImage);
#endif
