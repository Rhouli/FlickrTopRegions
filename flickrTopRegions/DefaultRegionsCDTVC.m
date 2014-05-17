//
//  DefaultPhotographersCDTVC.m
//  Photomania
//
//  Created by CS193p Instructor on 5/15/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//

#import "DefaultRegionsCDTVC.h"
#import "FlickrDatabase.h"

@implementation DefaultRegionsCDTVC

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
