//
// Created by rts on 07/04/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "AVPhotoController.h"
#import "AVPhotoView.h"
#import "AVPhoto.h"

@interface AVPhotoController () <UIScrollViewDelegate>
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
        self.photos = [NSArray array];

        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }

    return self;
}

- (void) loadPhotos:(NSArray*)photos
{
    self.photos = photos;

    if(self.photos.count > 0)
        [self setupScrollView:0];
}

- (void) setupScrollView:(int)page
{
    // Safety guard if called from setFrame to early
    if(self.photos.count == 0)
        return;

    // Reset all stuff
    [self.photoViews enumerateObjectsUsingBlock:^(AVPhotoView *obj, NSUInteger idx, BOOL *stop) {
        [obj unloadImage];
        [obj removeFromSuperview];
    }];

    [self.photoViews removeAllObjects];

    // Create new frame for photos
    CGRect photoFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    CGFloat photoWidth = photoFrame.size.width;

    for(AVPhoto *photo in self.photos)
    {
        // Create the photo and add it to view
        AVPhotoView *photoview = [[AVPhotoView  alloc] initWithFrame:photoFrame photo:photo];
        [self addSubview:photoview];

        // Save it for later use
        [self.photoViews addObject:photoview];

        // Add width to origin for next image
        photoFrame.origin.x += photoWidth;
    }

    // Set the total contentsize
    self.contentSize = CGSizeMake((photoWidth * self.photoViews.count), photoFrame.size.height);
    self.contentOffset = CGPointMake(page*photoWidth, 0);

    // Bit hacky.. bit it will invoke showing of current page
    [self scrollViewDidEndDecelerating:self];
}

// I needed to override setFrame to handle changing of the frame on the fly correctly
// Feel free to make this in a better way if you got time :-)
- (void)setFrame:(CGRect)frame
{
    CGFloat pageWidth = self.frame.size.width;
    int currentPage = floor((self.contentOffset.x - pageWidth / 2) / pageWidth) + 1;

    [super setFrame:frame];

    // Bit hacky to setup the view again but it works better than the old code below,
    // trying to set frames on all views etc. There is a lot of views to take care of.
    [self setupScrollView:currentPage];

    /*
    Old code
    __block CGRect photoFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    CGFloat photoWith = photoFrame.size.width;
    [self.photoViews enumerateObjectsUsingBlock:^(AVPhotoView * obj, NSUInteger idx, BOOL *stop) {
        [obj setFrame:photoFrame];
        [obj unloadImage];

        if(idx == currentPage)
            [obj loadImage];

        photoFrame.origin.x += photoWith;
    }];

    self.contentSize = CGSizeMake((photoWith * self.photoViews.count), photoFrame.size.height);
    self.contentOffset = CGPointMake(currentPage*photoWith, 0); */
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
