//
//  DefaultRecentleyViewedCDTV.m
//  flickrTopRegions
//
//  Created by Ryan on 5/16/14.
//  Copyright (c) 2014 Ryan Houlihan. All rights reserved.
//

#import "DefaultRecentlyViewedCDTVC.h"
#import "FlickrDatabase.h"

@implementation DefaultRecentlyViewedCDTVC

- (IBAction)refresh
{
    [self.refreshControl beginRefreshing];
    [[FlickrDatabase sharedDefaultFlickrDatabase] fetchWithCompletionHandler:^(BOOL success) {
        [self.refreshControl endRefreshing];
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    FlickrDatabase *flickrdb = [FlickrDatabase sharedDefaultFlickrDatabase];
    if (flickrdb.managedObjectContext) {
        self.managedObjectContext = flickrdb.managedObjectContext;
    } else {
        id observer = [[NSNotificationCenter defaultCenter] addObserverForName:FlickrDatabaseAvailable
                                                                        object:flickrdb
                                                                         queue:[NSOperationQueue mainQueue]
                                                                    usingBlock:^(NSNotification *note) {
                                                                        self.managedObjectContext = flickrdb.managedObjectContext;
                                                                        [[NSNotificationCenter defaultCenter] removeObserver:observer];
                                                                    }];
    }
}

@end
