//
// Created by rts on 07/04/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "AVPhotoView.h"
#import "AVPhoto.h"

@interface AVPhotoView () <UIScrollViewDelegate>
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, assign) BOOL isLoaded;
@property (nonatomic, assign) BOOL isAborted;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *captionView;
@property (nonatomic, strong) UILabel *captionLabel;
@property (nonatomic, assign) CGPoint captionViewCenter;
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
        self.photo = nil;
        self.delegate = self;

        // Spinner
        self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [self.spinner setHidesWhenStopped:YES];
        self.spinner.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        [self addSubview:self.spinner];

        // Tap gestures
        UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDoubleTapped:)];
        doubleTapRecognizer.numberOfTapsRequired = 2;
        doubleTapRecognizer.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:doubleTapRecognizer];

        UITapGestureRecognizer *twoFingerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTwoFingerTapped:)];
        twoFingerTapRecognizer.numberOfTapsRequired = 1;
        twoFingerTapRecognizer.numberOfTouchesRequired = 2;
        [self addGestureRecognizer:twoFingerTapRecognizer];

        // Add caption view
        self.captionView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-80, self.frame.size.width, 40)];
        [self.captionView setBackgroundColor:[UIColor blackColor]];

        self.captionView.layer.opacity = 0.8;

        self.captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.captionView.frame.size.width-10, self.captionView.frame.size.height)];
        self.captionLabel.font = [UIFont boldSystemFontOfSize:16];
        self.captionLabel.textColor = [UIColor whiteColor];
        self.captionLabel.backgroundColor = [UIColor clearColor];

        [self.captionView addSubview:self.captionLabel];
        [self addSubview:self.captionView];
        self.captionLabel.text = @"Loading ...";
        self.captionViewCenter = self.captionView.center;
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

        NSLog(@"Photo: %@", self.photo);

        if(self.photo.imagePath.length > 0)
        {
            NSURL *url = [NSURL URLWithString:self.photo.imagePath];
            if ([[url scheme] isEqualToString:@"file"] || [url scheme] == NULL)
            {
				UIImage *image = [UIImage imageNamed:self.photo.imagePath];

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
    [self.captionLabel setText:self.photo.caption];

    self.imageView = [[UIImageView alloc] initWithImage:image];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    //[self addSubview:self.imageView];
    [self insertSubview:self.imageView belowSubview:self.captionView];

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

- (void) fixCaptionView
{
    CGPoint newCenter = self.captionViewCenter;

    newCenter.x += self.contentOffset.x;
    newCenter.y += self.contentOffset.y;

    self.captionView.center = newCenter;
}

- (void) displayError
{
    [self.spinner stopAnimating];
    self.isLoaded = NO;

    UIAlertView *alert =[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Unable to load image", @"Title for when loading of image fails")
                                                   message:NSLocalizedString(@"We were unable to load the image. Please try again", @"Message explaining why image could not be loaded")
                                                  delegate:nil cancelButtonTitle:NSLocalizedString(@"Okay", @"Okay button when unable to load image") otherButtonTitles:nil];
    [alert show];
}

#pragma mark - Touch events

- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer
{
    if(self.photo.zoomDiasbled)
        return;

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
    if(self.photo.zoomDiasbled)
        return;

    CGFloat newZoomScale = self.zoomScale / 1.5f;
    newZoomScale = MAX(newZoomScale, self.minimumZoomScale);
    [self setZoomScale:newZoomScale animated:YES];
}

#pragma mark - ScrollView Delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if(self.photo.zoomDiasbled)
        return nil;

    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self centerScrollViewContents];
    [self fixCaptionView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self fixCaptionView];
}

@end
