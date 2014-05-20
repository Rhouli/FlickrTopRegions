//
//  ImageViewController.h
//  flickerTopPlaces
//
//  Created by Ryan on 5/8/14.
//  Copyright (c) 2014 Ryan Houlihan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageViewController : UIViewController

// Model for this MVC ... URL of an image to display
@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, strong) NSString* uniqueID;
@property BOOL animating;
@end
