//
//  RecentlyViewed+Create.h
//  flickrTopRegions
//
//  Created by Ryan on 5/20/14.
//  Copyright (c) 2014 Ryan Houlihan. All rights reserved.
//

#import "RecentlyViewed.h"

@interface RecentlyViewed (Create)

+ (RecentlyViewed *)RecentlyViewedWithUnique:(NSString *)unique
    inManagedObjectContext:(NSManagedObjectContext *)context;

@end
