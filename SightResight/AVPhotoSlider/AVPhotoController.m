//
// Created by rts on 07/04/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "AVPhotoController.h"
#import "AVPhotoView.h"
#import "AVPhoto.h"

@interface AVPhotoController () <UIScrollViewDelegate>
@property (nonatomic, strong) NSArray *photos;
@property (nonatomic, strong) NSMutableArray *photoViews;
@end

@implementation AVPhotoController

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if(self)
    {
        self.delegate = self;
        self.pagingEnabled = YES;
        self.photoViews = [[NSMutableArray alloc] init];
    }

    return self;
}

- (void) loadPhotos:(NSArray*)photos
{
    self.photos = photos;

    if(self.photos.count > 0)
        [self setupScrollView];
}

- (void) setupScrollView
{
    // Reset all stuff
    [self.photoViews enumerateObjectsUsingBlock:^(AVPhotoView *obj, NSUInteger idx, BOOL *stop) {
        [obj unloadImage];
        [obj removeFromSuperview];
    }];

    [self.photoViews removeAllObjects];

    // Create new frame for photos
    CGRect photoFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    CGFloat photoWith = photoFrame.size.width;

    for(AVPhoto *photo in self.photos)
    {
        // Create the photo and add it to view
        AVPhotoView *photoview = [[AVPhotoView  alloc] initWithFrame:photoFrame];
        photoview.photo = photo;
        [self addSubview:photoview];

        // Save if for later user
        [self.photoViews addObject:photoview];

        // Add with to origin for next image
        photoFrame.origin.x += photoWith;
    }

    // Set the total contentsize
    self.contentSize = CGSizeMake((photoWith * self.photoViews.count), photoFrame.size.height);
	self.contentOffset = CGPointMake(0, 0);

    // Bit hacky.. bit it will invoke showing of first page
    [self scrollViewDidEndDecelerating:self];
}

#pragma mark - ScrollView Delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    int currentPage = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    int nextPage = currentPage + 1;

    // Load current page
    AVPhotoView *currentPhoto = [self.photoViews objectAtIndex:currentPage];
    [currentPhoto loadImage];

    // Load next page
    if(nextPage < self.photoViews.count)
    {
        AVPhotoView *photo = [self.photoViews objectAtIndex:nextPage];
        [photo loadImage];
    }

    // Calculate page threshold
    int minPage = currentPage-2;
    int maxPage = currentPage+2;

    // Unload pages according to threshold to release some memory
    [self.photoViews enumerateObjectsUsingBlock:^(AVPhotoView *obj, NSUInteger idx, BOOL *stop) {

        int page = idx;

        if(page > maxPage)
        {
            [obj unloadImage];
        }
        else if(page < minPage)
        {
            [obj unloadImage];
        }
    }];
}

@end