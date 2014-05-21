//
//  RecentlyViewed.h
//  flickrTopRegions
//
//  Created by Ryan on 5/20/14.
//  Copyright (c) 2014 Ryan Houlihan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo;

@interface RecentlyViewed : NSManagedObject

@property (nonatomic, retain) NSString * unique;
@property (nonatomic, retain) NSSet *photos;
@end

@interface RecentlyViewed (CoreDataGeneratedAccessors)

- (void)addPhotosObject:(Photo *)value;
- (void)removePhotosObject:(Photo *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;

@end
