//
//  ViewController.m
//  SightResight
//
//  Created by Rasmus Styrk on 02/04/13.
//  Copyright (c) 2013 Appværk. All rights reserved.
//

#import "ViewController.h"
#import "AGImagePickerController.h"
#import "AVPhotoController.h"
#import "AVPhoto.h"

#define IMAGE_PICKER_TAG_LEFT 1
#define IMAGE_PICKER_TAG_RIGHT 2

@interface ViewController ()
@property (nonatomic, strong) AVPhotoController *photoController1;
@property (nonatomic, strong) AVPhotoController *photoController2;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.navigationItem.title = @"Sight Resight";
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Default-Landscape~ipad.png"]];

    UIImageView *splashView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default-Landscape~ipad.png"]];
    [self.navigationController.view addSubview:splashView];

    [UIView animateWithDuration:1.0 animations:^{
        splashView.alpha = 0.0;
    }];

    // Set buttons
	UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Select images" style:UIBarButtonItemStyleBordered target:self action:@selector(selectImages:)];
	item.tag = IMAGE_PICKER_TAG_LEFT;
	self.navigationItem.leftBarButtonItem = item;
    
	item = [[UIBarButtonItem alloc] initWithTitle:@"Select images" style:UIBarButtonItemStyleBordered target:self action:@selector(selectImages:)];
	item.tag = IMAGE_PICKER_TAG_RIGHT;
	self.navigationItem.rightBarButtonItem = item;
        
    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"sightresightSplash.png"]];

    CGFloat halfWidth = self.view.frame.size.width / 2;
    CGRect halfSize = CGRectMake(0, 0, halfWidth, self.view.frame.size.height);

    self.photoController1 = [[AVPhotoController alloc] initWithFrame:halfSize];

    halfSize.origin.x += halfWidth;
    self.photoController2 = [[AVPhotoController alloc] initWithFrame:halfSize];

    [self.view addSubview:self.photoController1];
    [self.view addSubview:self.photoController2];
}

- (IBAction)selectImages:(id)sender
{
    UIBarButtonItem *item = (UIBarButtonItem*) sender;
    
    AGImagePickerController *imagePickerController = [[AGImagePickerController alloc] initWithFailureBlock:^(NSError *error) {
            // Wait for the view controller to show first and hide it after that
            double delayInSeconds = 0.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self dismissViewControllerAnimated:YES completion:nil];
            });
        
    } andSuccessBlock:^(NSArray *info) {
        [self dismissViewControllerAnimated:YES completion:^{
            [self addImageViewerWithAssets:info atPosition:item.tag];
        }];
    }];
    
    imagePickerController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void) addImageViewerWithAssets:(NSArray*)assets atPosition:(int)pos
{
    self.view.backgroundColor = [UIColor blackColor];

    __block NSMutableArray *photos = [[NSMutableArray alloc] initWithCapacity:assets.count];

    [assets enumerateObjectsUsingBlock:^(ALAsset * obj, NSUInteger idx, BOOL *stop) {

        AVPhoto *photo = [[AVPhoto alloc] init];

        photo.imagePath = obj.defaultRepresentation.url.absoluteString;
        photo.caption = obj.defaultRepresentation.filename;

        [photos addObject:photo];
    }];

    AVPhoto *photo = [[AVPhoto alloc] init];
    photo.imagePath = @"finalImage.png";
    photo.caption = @"End of gallery";
    photo.zoomDiasbled = YES;

	[photos addObject:photo];

    if(pos == IMAGE_PICKER_TAG_LEFT)
        [self.photoController1 loadPhotos:photos];
    else
        [self.photoController2 loadPhotos:photos];
}

@end
