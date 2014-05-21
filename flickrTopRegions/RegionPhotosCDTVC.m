//
//  RegionPhotosCDTV.m
//  Photomania
//
//  Created by Ryan on 5/16/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//

#import "RegionPhotosCDTVC.h"
#import "ImageViewController.h"
#import "Photo.h"
#import "FlickrDatabase.h"
#import "DatabaseHelper.h"

@interface RegionPhotosCDTVC ()
@property UIActivityIndicatorView* spinner;
@end

@implementation RegionPhotosCDTVC


- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    [self setupFetchedResultsController];
}

- (void)setupFetchedResultsController
{
    if (self.managedObjectContext) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        request.predicate = [NSPredicate predicateWithFormat:@"whereTaken.name = %@", self.regionName];
        
        NSSortDescriptor *name = [NSSortDescriptor sortDescriptorWithKey:@"title"
                                                               ascending:YES
                                                                selector:@selector(localizedStandardCompare:)];
        request.sortDescriptors = @[name];
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
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Region Photo"];
    
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = photo.title;
    cell.detailTextLabel.text = photo.subtitle;
    
    if (!photo.thumbnailData){
        [DatabaseHelper fetchThumbnailData:photo forCell:cell withIndexPath:indexPath withContext:self.managedObjectContext];
    } else {
        cell.imageView.image = [UIImage imageWithData:photo.thumbnailData];
    }

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
