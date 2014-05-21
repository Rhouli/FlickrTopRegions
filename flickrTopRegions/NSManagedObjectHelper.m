//
//  NSManagedObjectHelper.m
//  flickrTopRegions
//
//  Created by Ryan on 5/20/14.
//  Copyright (c) 2014 Ryan Houlihan. All rights reserved.
//

#import "NSManagedObjectHelper.h"
#import "FlickrDatabase.h"

@implementation NSManagedObjectHelper

+ (void)saveDataInContext:(void(^)(NSManagedObjectContext *context))saveBlock
{
	NSManagedObjectContext *context = [[FlickrDatabase sharedDefaultFlickrDatabase] managedObjectContext];			//step 1
	[context setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];				//step 2
	[defaultContext setMergePolicy:NSMergeObjectByPropertyStoreTrumpMergePolicy];
	[defaultContext observeContext:context];						//step 3
    
	block(context);										//step 4
	if ([context hasChanges])								//step 5
	{
		[context save];  //MagicalRecord will dump errors to the console with this save method
	}
}

+ (void)saveDataInBackgroundWithContext:(void(^)(NSManagedObjectContext *context))saveBlock
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
		[self saveDataInContext:saveBlock];
	});
}


@end
