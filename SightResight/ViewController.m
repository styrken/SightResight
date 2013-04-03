//
//  ViewController.m
//  SightResight
//
//  Created by Rasmus Styrk on 02/04/13.
//  Copyright (c) 2013 Appværk. All rights reserved.
//

#import "ViewController.h"
#import "AGImagePickerController.h"
#import "MultipleImagesViewController.h"

#define IMAGE_PICKER_TAG_LEFT 1
#define IMAGE_PICKER_TAG_RIGHT 2

@interface ViewController ()
@property (nonatomic, strong) MultipleImagesViewController *imageViewer1;
@property (nonatomic, strong) MultipleImagesViewController *imageViewer2;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
	self.navigationItem.title = @"Sight Resight";
	
	// Set buttons
	UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Select images" style:UIBarButtonItemStyleBordered target:self action:@selector(selectImages:)];
	item.tag = IMAGE_PICKER_TAG_LEFT;
	self.navigationItem.leftBarButtonItem = item;
    
	item = [[UIBarButtonItem alloc] initWithTitle:@"Select images" style:UIBarButtonItemStyleBordered target:self action:@selector(selectImages:)];
	item.tag = IMAGE_PICKER_TAG_RIGHT;
	self.navigationItem.rightBarButtonItem = item;
        
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"sightresightSplash.png"]];
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
    
    MultipleImagesViewController *imageViewer = pos == IMAGE_PICKER_TAG_LEFT ? self.imageViewer1 : self.imageViewer2;
       
    if(imageViewer != nil)
    {
        if(imageViewer.view)
        {
            [imageViewer.view removeFromSuperview];
            imageViewer = nil;
        }
    }
    
    CGRect newFrame = self.view.bounds;
    newFrame.size.width /= 2;
    newFrame.origin.x = 0;
    newFrame.origin.y = 0;
    
    if(pos == IMAGE_PICKER_TAG_RIGHT)
        newFrame.origin.x = newFrame.size.width;
        
    imageViewer = [[MultipleImagesViewController alloc] initWithImageAssets:assets];
    imageViewer.view.frame = newFrame;
    [self.view addSubview:imageViewer.view];
    
    if(pos == IMAGE_PICKER_TAG_LEFT)
        self.imageViewer1 = imageViewer;
    else
        self.imageViewer2 = imageViewer;
}

@end
