//
// Created by Rasmus Styrk on 18/04/13.
// Copyright (c) 2013 Appværk. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "AVPhoto.h"


@implementation AVPhoto

- (id) init
{
    self = [super init];
    if(self)
    {
        self.zoomDiasbled = NO;
        self.caption = @"";
        self.imagePath = @"";
        self.captionRightSide = NO;
    }

    return self;
}

@end