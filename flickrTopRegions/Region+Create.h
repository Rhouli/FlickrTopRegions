//
//  Region+Create.h
//  Photomania
//
//  Created by Ryan on 5/15/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//

#import "Region.h"

@interface Region (Create)

+ (Region *)regionWithName:(NSString *)name withPhotographer:(Photographer *)photographer
       inManagedObjectContext:(NSManagedObjectContext *)context;
@end
