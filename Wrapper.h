// Wrapper.h

#include <Foundation/Foundation.h>
#include <UIKit/UIKit.h>

#ifdef __cplusplus
#import <opencv2/opencv.hpp>
extern "C" {
#endif

NSArray<UIImage *> *extractPhotos(UIImage *inputImage);

#ifdef __cplusplus
}
std::vector<UIImage *> extractPhotosCpp(UIImage *inputImage);
#endif
