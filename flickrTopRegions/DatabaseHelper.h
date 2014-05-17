//
//  FetchHelper.h
//  flickrTopRegions
//
//  Created by Ryan on 5/17/14.
//  Copyright (c) 2014 Ryan Houlihan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Photo.h"

@interface DatabaseHelper : NSObject

+ (void)fetchThumbnailData:(Photo*)photo forCell:(UITableViewCell*)cell withIndexPath:(NSIndexPath *)indexPath;
+ (void)justViewed:(Photo*)photo;

@end
