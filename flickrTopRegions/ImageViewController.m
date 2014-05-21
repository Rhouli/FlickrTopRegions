//
//  ImageViewController.m
//  flickerTopPlaces
//
//  Created by Ryan on 5/8/14.
//  Copyright (c) 2014 Ryan Houlihan. All rights reserved.
//

#import "ImageViewController.h"
#define WIDTH_OF_MASTER_VIEW 320
#define IS_PHONE UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone

@interface ImageViewController () <UIScrollViewDelegate, UISplitViewControllerDelegate>
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage *image;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic) NSUInteger lastRotation;
@end

@implementation ImageViewController

#pragma mark - View Controller Lifecycle

// add the UIImageView to the MVC's View
- (void)awakeFromNib {
    self.splitViewController.delegate = self;
    // see UISplitViewControllerDelegate methods below
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.scrollView addSubview:self.imageView];
    [self getCachedImage];
}

#pragma mark - Properties

// lazy instantiation

- (UIImageView *)imageView {
    if (!_imageView) _imageView = [[UIImageView alloc] init];
    return _imageView;
}

// image property does not use an _image instance variable
// instead it just reports/sets the image in the imageView property
// thus we don't need @synthesize even though we implement both setter and getter

- (UIImage *)image {
    return self.imageView.image;
}

- (void)setImage:(UIImage *)image {
    self.imageView.image = image; // does not change the frame of the UIImageView
    self.imageView.contentMode = UIViewContentModeScaleAspectFit; // You could also try UIViewContentModeCenter
   // [self.imageView sizeToFit];   // update the frame of the UIImageView
    [self resizeImageToFitScreen];
    
    // self.scrollView could be nil on the next line if outlet-setting has not happened yet
    self.scrollView.contentSize = self.image ? self.image.size : CGSizeZero;

    [self.spinner stopAnimating];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self resizeImageToFitScreen];
}

- (void)resizeImageToFitScreen {
    CGSize sizeOfScreen = [[UIScreen mainScreen] bounds].size;
    
    NSUInteger statusNavBarHeight = self.navigationController.navigationBar.frame.size.height+self.navigationController.navigationBar.frame.origin.y;
    NSUInteger width;
    NSUInteger height;
    
    CGPoint center;
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if(orientation == 0){
        //Default orientation
        width = sizeOfScreen.width;
        height = sizeOfScreen.height - statusNavBarHeight;

        center.x = width/2;
        center.y = height/2;
    } else if(orientation == UIInterfaceOrientationPortrait){
        //Do something if the orientation is in Portrait
        width = sizeOfScreen.width;
        height = sizeOfScreen.height - statusNavBarHeight;

        center.x = width/2;
        center.y = height/2;
    } else if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight){
        //Do something if left or right
        if(!IS_PHONE)
            width = sizeOfScreen.height - WIDTH_OF_MASTER_VIEW;
        else
            width = sizeOfScreen.height;
        height = sizeOfScreen.width - statusNavBarHeight;
        
        center.x = width/2;
        center.y = height/2;
    }
    self.imageView.frame = CGRectMake(0, 0, width, height);
    self.imageView.center = center;
}

- (void)setScrollView:(UIScrollView *)scrollView {
    _scrollView = scrollView;
    
    // next three lines are necessary for zooming
    _scrollView.minimumZoomScale = 0.2;
    _scrollView.maximumZoomScale = 2.0;
    _scrollView.delegate = self;

    // next line is necessary in case self.image gets set before self.scrollView does
    // for example, prepareForSegue:sender: is called before outlet-setting phase
    self.scrollView.contentSize = self.image ? self.image.size : CGSizeZero;
}

#pragma mark - UIScrollViewDelegate

// mandatory zooming method in UIScrollViewDelegate protocol

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

#pragma mark - Setting the Image from the Image's URL

- (void)setImageURL:(NSURL *)imageURL {
    _imageURL = imageURL;
   [self getCachedImage];
}

- (void) cacheImage {
    NSArray *cach = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cache = [cach objectAtIndex:0];
    NSString* filePath = [cache stringByAppendingPathComponent:self.uniqueID];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:filePath])
        [self startDownloadingImage:filePath];
}

- (void) getCachedImage {
    NSArray *cach = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cache = [cach objectAtIndex:0];
    NSString *filePath = [cache stringByAppendingPathComponent:self.uniqueID];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        self.image = [UIImage imageWithContentsOfFile:filePath];
    } else {
        [self cacheImage];
        self.spinner.hidden = NO;
        self.image = [UIImage imageWithContentsOfFile:filePath];
    }
}

- (void)startDownloadingImage:(NSString*)filePath {
    self.image = nil;

    if (self.imageURL) {
        NSURLRequest *request = [NSURLRequest requestWithURL:self.imageURL];
        
        // another configuration option is backgroundSessionConfiguration (multitasking API required though)
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        
        // create the session without specifying a queue to run completion handler on (thus, not main queue)
        // we also don't specify a delegate (since completion handler is all we need)
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];

        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
            completionHandler:^(NSURL *localfile, NSURLResponse *response, NSError *error) {
                // this handler is not executing on the main queue, so we can't do UI directly here
                if (!error) {
                    if ([request.URL isEqual:self.imageURL]) {
                        // UIImage is an exception to the "can't do UI here"
                        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:localfile]];
                        // but calling "self.image =" is definitely not an exception to that!
                        // so we must dispatch this back to the main queue
                        // add file to cache storage
                        if([[self.imageURL absoluteString] rangeOfString: @".png" options:NSCaseInsensitiveSearch].location != NSNotFound){
                            [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
                        } else if([[self.imageURL absoluteString] rangeOfString: @".jpg" options:NSCaseInsensitiveSearch].location != NSNotFound ||
                                  [[self.imageURL absoluteString] rangeOfString: @".jpeg" options:NSCaseInsensitiveSearch].location != NSNotFound){
                            [UIImageJPEGRepresentation(image, 100) writeToFile:filePath atomically:YES];
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.image = image;
                        });
                    }
                }
        }];
        [task resume]; // don't forget that all NSURLSession tasks start out suspended!
    }
}

#pragma mark - UISplitViewControllerDelegate

- (BOOL)splitViewController:(UISplitViewController *)svc
   shouldHideViewController:(UIViewController *)vc
              inOrientation:(UIInterfaceOrientation)orientation {
    return UIInterfaceOrientationIsPortrait(orientation);
}

- (void)splitViewController:(UISplitViewController *)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)pc {
    self.navigationItem.leftBarButtonItem = barButtonItem;
    barButtonItem.title = aViewController.title;
}

- (void)splitViewController:(UISplitViewController *)svc
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    self.navigationItem.leftBarButtonItem = nil;
}

#pragma mark - Gesture Controls

- (IBAction)tapImage:(id)sender {
    self.imageView.transform = CGAffineTransformIdentity;
    [self resizeImageToFitScreen];
}

- (IBAction)rotateImage:(id)sender {
    
    if([(UIRotationGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        self.lastRotation = 0.0;
        return;
    }
    
    CGFloat rotation = 0.0 - (self.lastRotation - [(UIRotationGestureRecognizer*)sender rotation]/10);
    
    CGAffineTransform currentTransform = self.imageView.transform;
    CGAffineTransform newTransform = CGAffineTransformRotate(currentTransform,rotation);
    
    [self.imageView setTransform:newTransform];
    
    self.lastRotation = [(UIRotationGestureRecognizer*)sender rotation]/10;
    //[self showOverlayWithFrame:self.imageView.frame];
}

@end
