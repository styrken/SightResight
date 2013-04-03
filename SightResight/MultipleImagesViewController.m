//
//  MultipleImagesViewController.m
//  SightResight
//
//  Created by Rasmus Styrk on 02/04/13.
//  Copyright (c) 2013 Appværk. All rights reserved.
//

#import "MultipleImagesViewController.h"

#import <AssetsLibrary/AssetsLibrary.h>

@interface MultipleImagesViewController ()
@property (nonatomic, retain) NSArray *imageAssets;
@end

@implementation MultipleImagesViewController

- (id) initWithImageAssets:(NSArray *)images
{
    self = [super init];
    
    if(self)
    {
        self.imageAssets = images;
        self.scrubberIsEnabled = NO;
        self.hidesChromeWhenScrolling = NO;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfImagesInAlbumView:(PTImageAlbumView *)imageAlbumView
{
    return [self.imageAssets count];
}

- (NSString *)imageAlbumView:(PTImageAlbumView *)imageAlbumView sourceForImageAtIndex:(NSInteger)index
{
    ALAsset *asset = [self.imageAssets objectAtIndex:index];
    
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"temp%i.png", index]];
    
    UIImage *currentImage = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullResolutionImage]];
    NSData *currentImageData = UIImagePNGRepresentation(currentImage);
    [currentImageData writeToFile:filePath atomically:YES];
    
    return filePath;
}

- (NSString*) imageAlbumView:(PTImageAlbumView *)imageAlbumView sourceForThumbnailImageAtIndex:(NSInteger)index
{
    return nil;
}

- (CGSize)imageAlbumView:(PTImageAlbumView *)imageAlbumView sizeForImageAtIndex:(NSInteger)index
{
    ALAsset *asset = [self.imageAssets objectAtIndex:index];
    return asset.defaultRepresentation.dimensions;
}

- (NSString *)imageAlbumView:(PTImageAlbumView *)imageAlbumView captionForImageAtIndex:(NSInteger)index
{
    ALAsset *asset = [self.imageAssets objectAtIndex:index];
    return asset.defaultRepresentation.filename;
}

@end
