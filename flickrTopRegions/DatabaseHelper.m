//
//  FetchHelper.m
//  flickrTopRegions
//
//  Created by Ryan on 5/17/14.
//  Copyright (c) 2014 Ryan Houlihan. All rights reserved.
//

#import "DatabaseHelper.h"
#import "Photo.h"
#import "FlickrDatabase.h"

@implementation DatabaseHelper
/*
+ (void)fetchThumbnailData:(Photo*)photo forCell:(UITableViewCell*)cell withIndexPath:(NSIndexPath *)indexPath withContext:(NSManagedObjectContext*)context {
    NSURL *url = [NSURL URLWithString:photo.thumbnailURL];
    dispatch_queue_t fetchQueue = dispatch_queue_create("FlickrDatabase fetch", NULL);
    dispatch_async(fetchQueue, ^{
        if (url) {
            UIApplication *application = [UIApplication sharedApplication];
            application.networkActivityIndicatorVisible = YES;
            NSData *data = [NSData dataWithContentsOfURL:url];
            application.networkActivityIndicatorVisible = NO;
            if (data) {
                // Fetch and update photo thumbnail data
                dispatch_async(dispatch_get_main_queue(), ^{
                    [context performBlock:^{
                   //     photo.thumbnailData = data;
                    }];
                    
                    cell.imageView.image = [UIImage imageWithData:data];
                    [cell setNeedsLayout];
                });
            }
        }
    });
}*/


+ (void)fetchThumbnailData:(Photo*)photo forCell:(UITableViewCell*)cell withIndexPath:(NSIndexPath *)indexPath withContext:(NSManagedObjectContext*)mainContext {
    NSURL *url = [NSURL URLWithString:photo.thumbnailURL];
    dispatch_queue_t fetchQueue = dispatch_queue_create("FlickrDatabase fetch", NULL);

    dispatch_async(fetchQueue, ^{
        if (url) {
            UIApplication *application = [UIApplication sharedApplication];
            application.networkActivityIndicatorVisible = YES;
            NSData *data = [NSData dataWithContentsOfURL:url];
            application.networkActivityIndicatorVisible = NO;
            if (data) {
                // create a new context
                FlickrDatabase *flickrdb = [FlickrDatabase sharedDefaultFlickrDatabase];
                NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
                [context setPersistentStoreCoordinator:flickrdb.managedObjectContext.persistentStoreCoordinator];
                
                // Fetch and update photo thumbnail data
                Photo* newPhoto = [self getPhotoWithUniqueID:photo.unique withContext:context];
                
                newPhoto.thumbnailData = data;
                
                // Save to store
                if (![context save:nil]) {
                    // error handler
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.imageView.image = [UIImage imageWithData:data];
                    [cell setNeedsLayout];
                });
            }
        }
    });
}


+ (void)justViewed:(Photo*)photo {
    dispatch_queue_t fetchQueue = dispatch_queue_create("update lastViewed attribute", NULL);
    
    dispatch_async(fetchQueue, ^{
        // create a new context
        FlickrDatabase *flickrdb = [FlickrDatabase sharedDefaultFlickrDatabase];
        NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
        [context setPersistentStoreCoordinator:flickrdb.managedObjectContext.persistentStoreCoordinator];
        
        // Fetch and update photo thumbnail data
        NSError *error = nil;
        Photo* newPhoto = [self getPhotoWithUniqueID:photo.unique withContext:context];
        
        newPhoto.lastViewed = [NSDate date];
        
        // Save to store
        error = nil;
        if (![context save:nil]) {
            // error
        }
    });
}

+ (Photo *)getPhotoWithUniqueID:(NSString *)unique withContext:(NSManagedObjectContext *)context {
    Photo* newPhoto = nil;
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Photo" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"unique=%@",unique]];
    
    newPhoto = [[context executeFetchRequest:request error:nil] lastObject];

    return newPhoto;
}
@end
