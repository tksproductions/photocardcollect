// Wrapper.mm

#include "Wrapper.h"

NSArray<UIImage *> *extractPhotos(UIImage *inputImage) {
    std::vector<UIImage *> uiImageArray = extractPhotosCpp(inputImage);
    NSMutableArray<UIImage *> *result = [NSMutableArray arrayWithCapacity:uiImageArray.size()];

    for (UIImage *image : uiImageArray) {
        [result addObject:image];
    }

    return result;
}
