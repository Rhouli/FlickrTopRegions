//
//  Region+Create.m
//  Photomania
//
//  Created by Ryan on 5/15/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//

#import "Region+Create.h"
#import "Photographer+Create.h"
@implementation Region (Create)

+ (Region *)regionWithName:(NSString *)name withPhotographer:(Photographer *)photographer
                inManagedObjectContext:(NSManagedObjectContext *)context
{
    Region *region = nil;
    
    if ([name length]) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
        request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
        
        NSError *error;
        NSArray *matches = [context executeFetchRequest:request error:&error];
        
        if (error || !matches || ([matches count] > 1)) {
            // handle error
        } else if (![matches count]) {
            region = [NSEntityDescription insertNewObjectForEntityForName:@"Region"
                                                         inManagedObjectContext:context];
            region.name = name;
        } else {
            region = [matches lastObject];
        }
    }
    
    [region addPhotographersObject:photographer];
    region.photographersNum = [NSNumber numberWithInteger:[region.photographers count]];

    return region;
}

@end
