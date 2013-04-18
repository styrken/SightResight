//
//  ViewController.m
//  SightResight
//
//  Created by Rasmus Styrk on 02/04/13.
//  Copyright (c) 2013 Appværk. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
#import "ViewController.h"
#import "AGImagePickerController.h"
#import "AVPhotoController.h"
#import "AVPhoto.h"

#define IMAGE_PICKER_TAG_LEFT 1
#define IMAGE_PICKER_TAG_RIGHT 2

enum {
    ScreenViewVertical,
    ScreenViewSingle,
    ScreenViewAlpha
};
typedef int ScreenViewType;

@interface ViewController ()
@property (nonatomic, strong) AVPhotoController *photoController1;
@property (nonatomic, strong) AVPhotoController *photoController2;
@property (nonatomic, strong) UISlider *opacitySlider;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

	//self.navigationItem.title = @"Sight Resight";
    self.navigationController.toolbar.tintColor = [UIColor colorWithRed:4.0f/255.0f green:37.0f/255.0f blue:74.0f/255.0f alpha:1.0];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Default-Landscape~ipad.png"]];

    // Cool splashscreen
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

    // Slider for changing opacity
    self.opacitySlider = [[UISlider alloc] initWithFrame:CGRectMake((self.view.frame.size.width/2)-100, 10, 200, 20)];
    self.opacitySlider.maximumValue = 1.0;
    self.opacitySlider.minimumValue = 0.0;
    self.opacitySlider.value = 0.8;
    [self.opacitySlider addTarget:self action:@selector(setOpacity:) forControlEvents:UIControlEventValueChanged];
    [self.navigationController.toolbar addSubview:self.opacitySlider];

    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:NSLocalizedString(@"Side by side", @"Side by side title"), NSLocalizedString(@"Gallery", @"Gallery title"), NSLocalizedString(@"Overlay", @"Overlay title"), nil]];
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    segmentedControl.selectedSegmentIndex = 0;
    [segmentedControl addTarget:self action:@selector(changeView:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = segmentedControl;

    // Setup photocontrollers
    self.photoController1 = [[AVPhotoController alloc] initWithFrame:CGRectZero];
    self.photoController2 = [[AVPhotoController alloc] initWithFrame:CGRectZero];

    [self.view addSubview:self.photoController1];
    [self.view addSubview:self.photoController2];

    [self setScreenView:ScreenViewVertical];
}

- (void) setScreenView:(ScreenViewType)screenView
{
    // Disable 'drag' mode that might have been put to YES in AlphaView
    [self.photoController1.photos enumerateObjectsUsingBlock:^(AVPhoto *obj, NSUInteger idx, BOOL *stop) {
        [obj setDraggingEnabled:NO];
    }];

    [self.photoController2.photos enumerateObjectsUsingBlock:^(AVPhoto *obj, NSUInteger idx, BOOL *stop) {
        [obj setDraggingEnabled:NO];
    }];

    switch (screenView)
    {
        case ScreenViewVertical:
        {
            self.navigationController.toolbarHidden = YES;

            CGFloat halfWidth = self.view.frame.size.width / 2;
            CGRect halfSize = CGRectMake(0, 0, halfWidth, self.view.frame.size.height);
            self.photoController1.frame = halfSize;
            halfSize.origin.x += halfWidth;
            self.photoController2.frame = halfSize;
            self.photoController2.layer.opacity = 1;

            self.photoController1.hidden = NO;
            self.photoController2.hidden = NO;

            break;
        }
        case ScreenViewSingle:
        {
            self.navigationController.toolbarHidden = YES;

            CGRect fullSize = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            self.photoController2.frame = fullSize;
            self.photoController2.layer.opacity = 1;

            self.photoController1.hidden = YES;
            self.photoController2.hidden = NO;

            break;
        }
        case ScreenViewAlpha:
        {
            // Enable 'drag' mode
            [self.photoController1.photos enumerateObjectsUsingBlock:^(AVPhoto *obj, NSUInteger idx, BOOL *stop) {
                [obj setDraggingEnabled:YES];
            }];

            [self.photoController2.photos enumerateObjectsUsingBlock:^(AVPhoto *obj, NSUInteger idx, BOOL *stop) {
                [obj setDraggingEnabled:YES];
            }];

            self.navigationController.toolbarHidden = NO;

            CGRect fullSize = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            self.photoController1.frame = fullSize;
            self.photoController2.frame = fullSize;
            self.photoController2.layer.opacity = self.opacitySlider.value;

            self.photoController1.hidden = NO;
            self.photoController2.hidden = NO;

            break;
        }
    }
}

- (void) changeView:(UISegmentedControl *)control
{
    switch (control.selectedSegmentIndex)
    {
        case 0: // Side by side
            [self setScreenView:ScreenViewVertical];
            break;

        case 1: // Gallery mode
            [self setScreenView:ScreenViewSingle];
            break;

        case 2: // Overlay
            [self setScreenView:ScreenViewAlpha];
            break;
    }
}

- (void) setOpacity:(UISlider*)sender
{
    self.photoController2.layer.opacity = sender.value;
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

        if(pos == IMAGE_PICKER_TAG_RIGHT)
            photo.captionRightSide = YES;

        [photos addObject:photo];
    }];

    AVPhoto *photo = [[AVPhoto alloc] init];
    photo.imagePath = @"finalImage.png";
    photo.caption = @"End of gallery";

    if(pos == IMAGE_PICKER_TAG_RIGHT)
        photo.captionRightSide = YES;

    photo.zoomDiasbled = YES;

	[photos addObject:photo];

    if(pos == IMAGE_PICKER_TAG_LEFT)
        [self.photoController1 loadPhotos:photos];
    else
        [self.photoController2 loadPhotos:photos];
}

@end
