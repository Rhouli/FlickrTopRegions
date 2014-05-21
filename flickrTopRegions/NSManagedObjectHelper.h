//
//  NSManagedObjectHelper.h
//  flickrTopRegions
//
//  Created by Ryan on 5/20/14.
//  Copyright (c) 2014 Ryan Houlihan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSManagedObjectHelper : NSObject

+ (void)saveDataInContext:(void(^)(NSManagedObjectContext *context))saveBlock;

+ (void)saveDataInBackgroundWithContext:(void(^)(NSManagedObjectContext *context))saveBlock;

@end
