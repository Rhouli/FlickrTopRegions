//
//  RecentlyViewed+Create.m
//  flickrTopRegions
//
//  Created by Ryan on 5/20/14.
//  Copyright (c) 2014 Ryan Houlihan. All rights reserved.
//

#import "RecentlyViewed+Create.h"

@implementation RecentlyViewed (Create)

+ (RecentlyViewed *)RecentlyViewedWithUnique:(NSString *)unique
                      inManagedObjectContext:(NSManagedObjectContext *)context {
    RecentlyViewed *recentlyViewed = nil;
    
    if ([unique length]) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"RecentlyViewed"];
        request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", unique];
        
        NSError *error;
        NSArray *matches = [context executeFetchRequest:request error:&error];
        
        if (error || !matches || ([matches count] > 1)) {
            // handle error
        } else if (![matches count]) {
            recentlyViewed = [NSEntityDescription insertNewObjectForEntityForName:@"RecentlyViewed"
                                                         inManagedObjectContext:context];
            recentlyViewed.unique = unique;
        } else {
            recentlyViewed = [matches lastObject];
        }
    }
    
    return recentlyViewed;
}

@end
