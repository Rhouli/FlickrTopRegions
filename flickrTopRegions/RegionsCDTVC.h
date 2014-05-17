//
//  PhotographersCDTVC.h
//  Photomania
//
//  Created by CS193p Instructor on 5/13/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//

#import "CoreDataTableViewController.h"

@interface RegionsCDTVC : CoreDataTableViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
