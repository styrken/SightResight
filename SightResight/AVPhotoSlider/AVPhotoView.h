//
// Created by rts on 07/04/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@class AVPhoto;


/**
* AV Photo View
*
* The AV PhotoView class is responsible for showing an image that is zoomable etc.
* It lazy-loads images so you need to call loadImage and unloadImage to manage memory.
*
* Supports loading images from filesystem, the asset library (use the asset URL) or over the internet. While loading the image
* a spinner is shown.
*/
@interface AVPhotoView : UIScrollView

/**
* Init with frame, photo
*
* Inits the AVPhotoView at frame and sets its photo object. Should be used most times. Photo loading
* does not happen automaticly. You need to call loadPhoto to start any loading.
*/
- (id) initWithFrame:(CGRect)frame photo:(AVPhoto *)photo;

/**
* AV Photo
*
* Object holding photo info
*/
@property (nonatomic, strong) AVPhoto *photo;

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