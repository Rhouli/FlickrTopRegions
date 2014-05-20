//
//  RecentleyViewedCDTV.m
//  flickrTopRegions
//
//  Created by Ryan on 5/16/14.
//  Copyright (c) 2014 Ryan Houlihan. All rights reserved.
//

#import "RecentlyViewedCDTVC.h"
#import "ImageViewController.h"
#import "FlickrDatabase.h"
#import "Photo.h"
#import "DatabaseHelper.h"

#define NUMBER_OF_RECENT_PHOTOS_TO_DISPLAY 20

@implementation RecentlyViewedCDTVC

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    [self setupFetchedResultsController];
}

- (void)setupFetchedResultsController
{
    if (self.managedObjectContext) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        request.predicate = [NSPredicate predicateWithFormat:@"lastViewed != nil"];
        
        NSSortDescriptor *name = [NSSortDescriptor sortDescriptorWithKey:@"lastViewed"
                                                               ascending:NO
                                                                selector:@selector(localizedStandardCompare:)];
        request.sortDescriptors = @[name];
        [request setFetchLimit:NUMBER_OF_RECENT_PHOTOS_TO_DISPLAY];
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:self.managedObjectContext
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
    } else {
        self.fetchedResultsController = nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Recent Photo"];
    
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = photo.title;
    cell.detailTextLabel.text = photo.subtitle;
    
    if (!photo.thumbnailData)
        [DatabaseHelper fetchThumbnailData:photo forCell:cell withIndexPath:indexPath withContext:self.managedObjectContext];
    else
        cell.imageView.image = [UIImage imageWithData:photo.thumbnailData];

    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id detailVC = [self.splitViewController.viewControllers lastObject];
    if ([detailVC isKindOfClass:[UINavigationController class]]) {
        detailVC = [((UINavigationController *)detailVC).viewControllers firstObject];
    }
    if ([detailVC isKindOfClass:[ImageViewController class]]) {
        Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self prepareImageViewController:detailVC toDisplayPhoto:photo];
    }
}

#pragma mark - Navigation

- (void)prepareImageViewController:(ImageViewController *)ivc
                    toDisplayPhoto:(Photo *)photo {

    ivc.title = photo.title;
    ivc.uniqueID = photo.unique;
    ivc.imageURL = [NSURL URLWithString:photo.imageURL];
    
    [DatabaseHelper justViewed:photo];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Display Photo"]) {
                if ([segue.destinationViewController isKindOfClass:[ImageViewController class]]) {
                    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
                    [self prepareImageViewController:segue.destinationViewController
                                      toDisplayPhoto:photo
                     ];
                }
            }
        }
    }
}

@end
