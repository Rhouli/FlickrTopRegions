//
//  PhotographersCDTVC.m
//  Photomania
//
//  Created by CS193p Instructor on 5/13/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//

#import "RegionsCDTVC.h"
#import "RegionPhotosCDTVC.h"
#import "Region.h"

#define NUMBER_OF_REGIONS_TO_DISPLAY 50

@implementation RegionsCDTVC

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    [self setupFetchedResultsController];
}

- (void)setupFetchedResultsController
{
    if (self.managedObjectContext) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
        request.predicate = nil; // this means ALL Photographers
        
        NSSortDescriptor *photographers = [NSSortDescriptor sortDescriptorWithKey:@"photographersNum"
                                                                  ascending:NO ];
        
        NSSortDescriptor *name = [NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                  ascending:YES
                                                                selector:@selector(localizedStandardCompare:)];
        request.sortDescriptors = @[photographers, name];
        [request setFetchLimit:NUMBER_OF_REGIONS_TO_DISPLAY];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:self.managedObjectContext
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
    } else {
        self.fetchedResultsController = nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Region"];
    
    Region *region = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = region.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ photographers", region.photographersNum];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id detailVC = [self.splitViewController.viewControllers lastObject];
    if ([detailVC isKindOfClass:[UINavigationController class]]) {
        detailVC = [((UINavigationController *)detailVC).viewControllers firstObject];
    }
    if ([detailVC isKindOfClass:[RegionPhotosCDTVC class]]) {
                Region *region = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self prepareRegionPhotosCDTV:detailVC toListImagesWithRegion:region];
    }
}

#pragma mark - Navigation

- (void)prepareRegionPhotosCDTV:(RegionPhotosCDTVC *)ctvc
               toListImagesWithRegion:(Region *)region {
    ctvc.regionName = region.name;
    ctvc.managedObjectContext = self.managedObjectContext;
}


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"List Photos"]) {
                if ([segue.destinationViewController isKindOfClass:[RegionPhotosCDTVC class]]) {
                    Region *region = [self.fetchedResultsController objectAtIndexPath:indexPath];
                    [self prepareRegionPhotosCDTV:segue.destinationViewController toListImagesWithRegion:region];
                }
            }
        }
    }
}

@end
