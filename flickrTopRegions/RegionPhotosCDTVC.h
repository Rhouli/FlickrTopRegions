//
//  RegionPhotosCDTV.h
//  Photomania
//
//  Created by Ryan on 5/16/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//

#import "CoreDataTableViewController.h"
#import "Region.h"
#import "Photo.h"

@interface RegionPhotosCDTVC : CoreDataTableViewController
    
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) NSString* regionName;

@end
