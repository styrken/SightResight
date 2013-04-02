//
//  ViewController.m
//  SightResight
//
//  Created by Rasmus Styrk on 02/04/13.
//  Copyright (c) 2013 Appværk. All rights reserved.
//

#import "ViewController.h"

#import <AssetsLibrary/AssetsLibrary.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.


	ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];

	[lib enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {

		ALAssetsGroup *g = group;

		[g enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {

			NSLog(@"Assets: %@", result);

		}];

	} failureBlock:^(NSError *error) {


	}];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
