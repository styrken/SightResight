//
// Created by rts on 07/04/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

/**
* AV Photo controller
*
* The photo controller is NOT a view-controller. It is a subclass of UIScrollView. If you want to use the AVPhotoSlider in a navigation controller
* you should create your own UIViewController and add the AVPhotoController (this class!) as a subview.
*
* The photo controller takes care of placing, loading and un-loading of AVPhotoViews. When a AVPhotoView is 2 slides away from current
* slide it is unloaded to save memory.
*/
@interface AVPhotoController : UIScrollView

/**
* Load Photos
*
* Loads photos. All photos must be of class AVPhoto.
*/
- (void) loadPhotos:(NSArray*)photos;

/**
* Photos
*
* Holds all photo objects
*/
@property (nonatomic, strong) NSArray *photos;

@end