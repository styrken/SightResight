//
// Created by Rasmus Styrk on 18/04/13.
// Copyright (c) 2013 Appværk. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface AVPhoto : NSObject

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
* Zoom disabled
*
* If zoom should be disabled
*/
@property (nonatomic, assign) BOOL zoomDiasbled;

/*
 * Set to true if caption should be in the right side of the page
 *
 */
@property (nonatomic, assign) BOOL captionRightSide;

@end