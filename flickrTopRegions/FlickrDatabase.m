//
//  FlickrDatabase.m
//  Photomania
//
//  Created by CS193p Instructor on 5/13/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//

#import "FlickrDatabase.h"
#import "FlickrFetcher.h"
#import "Photo+Flickr.h"

@interface FlickrDatabase()
@property (nonatomic, readwrite, strong) NSManagedObjectContext *managedObjectContext;
@end

@implementation FlickrDatabase

+ (FlickrDatabase *)sharedDefaultFlickrDatabase
{
    return [self sharedFlickrDatabaseWithName:@"FlickrDatabase_DEFAULT"];
}

+ (FlickrDatabase *)sharedFlickrDatabaseWithName:(NSString *)name
{
    static NSMutableDictionary *databases = nil;
    if (!databases) databases = [[NSMutableDictionary alloc] init];
    
    FlickrDatabase *database = nil;
    
    if ([name length]) {
        database = databases[name];
        if (!database) {
            database = [[self alloc] initWithName:name];
            databases[name] = database;
        }
    }
    
    return database;
}

- (instancetype)initWithName:(NSString *)name
{
    self = [super init];
    if (self) {
        if ([name length]) {
            NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                 inDomains:NSUserDomainMask] firstObject];
            url = [url URLByAppendingPathComponent:name];
            UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:url];
            if ([[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
                [document openWithCompletionHandler:^(BOOL success) {
                    if (success) self.managedObjectContext = document.managedObjectContext;
                }];
            } else {
                [document saveToURL:url
                   forSaveOperation:UIDocumentSaveForCreating
                  completionHandler:^(BOOL success) {
                      if (success) {
                          self.managedObjectContext = document.managedObjectContext;
                          [self fetch];
                      }
                      
                  }];
            }
        } else {
            self = nil;
        }
    }
    return self;
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    [[NSNotificationCenter defaultCenter] postNotificationName:FlickrDatabaseAvailable
                                                        object:self];
}

- (void)fetch
{
    [self fetchWithCompletionHandler:nil];
}

- (void)fetchWithCompletionHandler:(void (^)(BOOL success))completionHandler
{
    if (self.managedObjectContext) {
        dispatch_queue_t fetchQueue = dispatch_queue_create("FlickrDatabase fetch", NULL);
        dispatch_async(fetchQueue, ^{
            BOOL failure = YES;
            NSURL *url = [FlickrFetcher URLforRecentGeoreferencedPhotos];
            if (url) {
                UIApplication *application = [UIApplication sharedApplication];
                application.networkActivityIndicatorVisible = YES;
                NSData *jsonResults = [NSData dataWithContentsOfURL:url];
                application.networkActivityIndicatorVisible = NO;
                if (jsonResults) {
                    NSError *error;
                    NSDictionary *propertyListResults = [NSJSONSerialization JSONObjectWithData:jsonResults
                                                                                        options:0
                                                                                          error:&error];
                    if (!error) {
                        NSArray *photos = [propertyListResults valueForKeyPath:FLICKR_RESULTS_PHOTOS];
                        if (photos) {
                            failure = NO;
                            [self.managedObjectContext performBlock:^{
                                // load up the Core Data database
                                for (NSDictionary *photoDictionary in photos) {
                                    [Photo photoWithFlickrInfo:photoDictionary
                                        inManagedObjectContext:self.managedObjectContext];
                                }
                                if (completionHandler) dispatch_async(dispatch_get_main_queue(), ^{
                                    completionHandler(YES);
                                });
                            }];
                        }
                    }
                }
            }
            if (failure && completionHandler) dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(NO);
            });
        });
    } else {
        if (completionHandler) dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(NO);
        });
    }
}

@end
