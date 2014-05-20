//
//  Photo+Flickr.m
//  Photomania
//
//  Created by CS193p Instructor on 5/13/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//

#import "Photo+Flickr.h"
#import "FlickrFetcher.h"
#import "FlickrDatabase.h"
#import "Photographer+Create.h"
#import "Region+Create.h"

@implementation Photo (Flickr)

+ (Photo *)newPhotoWithFlickrInfo:(NSDictionary *)photoDictionary
        inManagedObjectContext:(NSManagedObjectContext *)context {
    Photo *photo = nil;
    NSString *unique = [photoDictionary valueForKeyPath:FLICKR_PHOTO_ID];
    
    photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo"
                                          inManagedObjectContext:context];
    photo.unique = unique;
    photo.title = [photoDictionary valueForKeyPath:FLICKR_PHOTO_TITLE];
    if(photo.title == NULL || [photo.title isEqualToString:@""])
        photo.title = @"Unkown";
    photo.subtitle = [photoDictionary valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
    photo.imageURL = [[FlickrFetcher URLforPhoto:photoDictionary
                                          format:FlickrPhotoFormatLarge] absoluteString];
    
    photo.thumbnailURL = [[FlickrFetcher URLforPhoto:photoDictionary
                                              format:FlickrPhotoFormatSquare] absoluteString];
    
    NSString *photographerName = [photoDictionary valueForKeyPath:FLICKR_PHOTO_OWNER];
    photo.whoTook = [Photographer photographerWithName:photographerName
                                inManagedObjectContext:context];
    [self fetchRegionInfo:[photoDictionary valueForKeyPath:FLICKR_PHOTO_PLACE_ID]
                withPhoto:photo inManagedObjectContext:context];

    return photo;
}

/*
+ (void) fetchRegionInfo:(NSString*)placeID withPhoto:(Photo *)photo inManagedObjectContext:(NSManagedObjectContext *)context{
    NSURL *url = [FlickrFetcher URLforInformationAboutPlace:(id)placeID];
    dispatch_queue_t fetchQueue = dispatch_queue_create("FlickrDatabase fetch", NULL);
    dispatch_async(fetchQueue, ^{
        if (url) {
            UIApplication *application = [UIApplication sharedApplication];
            application.networkActivityIndicatorVisible = YES;
            NSData *jsonResults = [NSData dataWithContentsOfURL:url];
            application.networkActivityIndicatorVisible = NO;
            if (jsonResults) {
                NSError *error;
                NSDictionary *place = [NSJSONSerialization JSONObjectWithData:jsonResults
                                                                                    options:0
                                                                                      error:&error];
                // create a new context
                //FlickrDatabase *flickrdb = [FlickrDatabase sharedDefaultFlickrDatabase];
                NSManagedObjectContext *newContext = [[NSManagedObjectContext alloc] init];

                [newContext setPersistentStoreCoordinator:[context persistentStoreCoordinator]];
                
                // Fetch and update photo thumbnail data
                NSError *errorC = nil;
                Photo* newPhoto = nil;
                NSFetchRequest * request = [[NSFetchRequest alloc] init];
                [request setEntity:[NSEntityDescription entityForName:@"Photo" inManagedObjectContext:newContext]];
                [request setPredicate:[NSPredicate predicateWithFormat:@"unique=%@",photo.unique]];
                
                NSString *regionName = [FlickrFetcher extractRegionNameFromPlaceInformation:place];
                
                newPhoto.whereTaken = [Region regionWithName:regionName withPhotographer:photo.whoTook inManagedObjectContext:newContext];
                
                // Save to store
                errorC = nil;
                
                if (![newContext save:nil]) {
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                });
            }
        }
    });
}
*/

+ (void) fetchRegionInfo:(NSString*)placeID withPhoto:(Photo *)photo inManagedObjectContext:(NSManagedObjectContext *)context{
    NSURL *url = [FlickrFetcher URLforInformationAboutPlace:(id)placeID];
    dispatch_queue_t fetchQueue = dispatch_queue_create("FlickrDatabase fetch", NULL);
    dispatch_async(fetchQueue, ^{
        if (url) {
            UIApplication *application = [UIApplication sharedApplication];
            application.networkActivityIndicatorVisible = YES;
            NSData *jsonResults = [NSData dataWithContentsOfURL:url];
            application.networkActivityIndicatorVisible = NO;
            if (jsonResults) {
                NSError *error;
                NSDictionary *place = [NSJSONSerialization JSONObjectWithData:jsonResults
                                                                                    options:0
                                                                                      error:&error];
                NSString *regionName = [FlickrFetcher extractRegionNameFromPlaceInformation:place];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    photo.whereTaken = [Region regionWithName:regionName withPhotographer:photo.whoTook inManagedObjectContext:context];
                });
            }
        }
    });
}

@end