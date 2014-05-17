//
//  Photographer.h
//  flickrTopRegions
//
//  Created by Ryan on 5/17/14.
//  Copyright (c) 2014 Ryan Houlihan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo, Region;

@interface Photographer : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *photos;
@property (nonatomic, retain) NSSet *places;
@end

@interface Photographer (CoreDataGeneratedAccessors)

- (void)addPhotosObject:(Photo *)value;
- (void)removePhotosObject:(Photo *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;

- (void)addPlacesObject:(Region *)value;
- (void)removePlacesObject:(Region *)value;
- (void)addPlaces:(NSSet *)values;
- (void)removePlaces:(NSSet *)values;

@end
