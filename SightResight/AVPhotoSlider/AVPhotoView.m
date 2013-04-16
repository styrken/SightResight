//
// Created by rts on 07/04/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <AssetsLibrary/AssetsLibrary.h>
#import "AVPhotoView.h"

@interface AVPhotoView () <UIScrollViewDelegate>
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, assign) BOOL isLoaded;
@property (nonatomic, assign) BOOL isAborted;
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation AVPhotoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.isLoaded = NO;
        self.isAborted = NO;
        self.imageView = nil;
        self.delegate = self;

        self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self.spinner setHidesWhenStopped:YES];
        self.spinner.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        [self addSubview:self.spinner];

        UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDoubleTapped:)];
        doubleTapRecognizer.numberOfTapsRequired = 2;
        doubleTapRecognizer.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:doubleTapRecognizer];

        UITapGestureRecognizer *twoFingerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTwoFingerTapped:)];
        twoFingerTapRecognizer.numberOfTapsRequired = 1;
        twoFingerTapRecognizer.numberOfTouchesRequired = 2;
        [self addGestureRecognizer:twoFingerTapRecognizer];
    }

    return self;
}

- (void)loadImage
{
    self.isAborted = NO;

    // Either loaded or is being loaded
    if(!self.isLoaded)
    {
        self.isLoaded = YES;
        [self.spinner startAnimating];

        if(self.imagePath.length > 0)
        {
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
            dispatch_async(queue, ^{

                NSURL *url = [NSURL URLWithString:self.imagePath];
                if ([[url scheme] isEqualToString:@"file"])
                {
                    UIImage *image = [UIImage imageNamed:self.imagePath];

                    if(image)
                        [self setImage:image];
                    else
                        [self displayError];
                }
                else if ([[url scheme] isEqualToString:@"assets-library"])
                {
                    // Load from assets
                    ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
                    [assetslibrary assetForURL:url
                                   resultBlock:^(ALAsset *asset){
                                       ALAssetRepresentation *rep = [asset defaultRepresentation];
                                       CGImageRef iref = [rep fullScreenImage];
                                       if (iref)
                                       {
                                           UIImage *image = [UIImage imageWithCGImage:iref];
                                           [self setImage:image];
                                       }
                                       else
                                           [self displayError];
                                   }
                                  failureBlock:^(NSError *error) {
                                      [self displayError];
                                  }];
                }
                else
                {
                    // Load via NSURLConnection instead
                }
            });
        }
        else
        {
            [self displayError];
        }
    }
}

- (void)unloadImage
{
    self.isAborted = YES;
    self.isLoaded = NO;

    if(self.imageView)
    {
        [self.imageView removeFromSuperview];
        self.imageView = nil;
    }
}

#pragma mark -

- (void) setImage:(UIImage*)image
{
    if(self.isAborted)
        return;

    if(self.imageView)
    {
        [self.imageView removeFromSuperview];
        self.imageView = nil;
    }

    [self.spinner stopAnimating];

    self.imageView = [[UIImageView alloc] initWithImage:image];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.imageView];

    [self calculateScaling];
    [self centerScrollViewContents];
}

- (void) calculateScaling
{
    self.contentSize = self.imageView.frame.size;

    CGRect scrollViewFrame = self.frame;
    CGFloat scaleWidth = scrollViewFrame.size.width / self.contentSize.width;
    CGFloat scaleHeight = scrollViewFrame.size.height / self.contentSize.height;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);

    self.minimumZoomScale = minScale;
    self.maximumZoomScale = 1.0f;
    self.zoomScale = minScale;
}

- (void) centerScrollViewContents
{
    CGSize boundsSize = self.bounds.size;
    CGRect contentsFrame = self.imageView.frame;

    if (contentsFrame.size.width < boundsSize.width)
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    else
        contentsFrame.origin.x = 0.0f;

    if (contentsFrame.size.height < boundsSize.height)
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    else
        contentsFrame.origin.y = 0.0f;

    self.imageView.frame = contentsFrame;
}

- (void) displayError
{
    [self.spinner stopAnimating];
    self.isLoaded = NO;

    UIAlertView *alert =[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Unable to load image", @"Title for when loading of image fails")
                                                   message:NSLocalizedString(@"We were unable to load the image. Please try again later", @"Message explaining why image could not be loaded")
                                                  delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [alert show];
}

#pragma mark - Touch events

- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer
{
    CGPoint pointInView = [recognizer locationInView:self.imageView];

    CGFloat newZoomScale = self.zoomScale * 1.5f;
    newZoomScale = MIN(newZoomScale, self.maximumZoomScale);

    CGSize scrollViewSize = self.bounds.size;

    CGFloat w = scrollViewSize.width / newZoomScale;
    CGFloat h = scrollViewSize.height / newZoomScale;
    CGFloat x = pointInView.x - (w / 2.0f);
    CGFloat y = pointInView.y - (h / 2.0f);

    CGRect rectToZoomTo = CGRectMake(x, y, w, h);

    [self zoomToRect:rectToZoomTo animated:YES];
}

- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer*)recognizer
{
    CGFloat newZoomScale = self.zoomScale / 1.5f;
    newZoomScale = MAX(newZoomScale, self.minimumZoomScale);
    [self setZoomScale:newZoomScale animated:YES];
}

#pragma mark - ScrollView Delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self centerScrollViewContents];
}


@end
