//
// Created by rts on 07/04/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


/**
* AV Photo View
*
* The AV Photoview class is responseble for showing an image that is zoomable etc.
* It lazy-loads images so you need to call loadImage and unloadImage to manage memory
*
*/
@interface AVPhotoView : UIScrollView

/**
* Path to image
*
* Either web or file path
*/
@property (nonatomic, copy) NSString *imagePath;

/**
* Caption
*
* A caption for the image
*/
@property (nonatomic, copy) NSString *caption;

/**
* Load image
*
* Loads the image. While loading a spinner is shown
*/
- (void) loadImage;

/**
* Unload image
*
* Unloads the image
*/
- (void) unloadImage;

@end