//
//  CoreDataAction.m
//  FindMyFriends
//
//  Created by Daniel on 2017/1/4.
//  Copyright © 2017年 Daniel. All rights reserved.
//

#import "CoreDataAction.h"


@implementation CoreDataAction {
    CoreDataManager * dataManager;
    CoreDataManagerForEvent * dataManagerForEvent;
}

- (CoreDataManager*)coreDataManagerSettingWithEntityName:(NSString*) entityName {
    
    if (dataManager == nil) {
        dataManager = [CoreDataManager sharedInstance];
    }
    if ([entityName isEqual:@"Friends"]) {
        [dataManager prepareWithModel:@"FindMyFriends" dbFileName:@"FindMyFriends.sqlite" dbFilePathURL:nil sortKey:@"friendName" entityName:@"Friends"];
    }
    return dataManager;
}

- (CoreDataManagerForEvent*)coreDataManagerForEventSettingWithEntityName:(NSString*) entityName {
    
    if (dataManagerForEvent == nil) {
        dataManagerForEvent = [CoreDataManagerForEvent sharedInstance];
    }
    if ([entityName isEqual:@"Event"]) {
        [dataManagerForEvent prepareWithModel:@"FindMyFriends" dbFileName:@"FindMyFriends.sqlite" dbFilePathURL:nil sortKey:@"id" entityName:@"Event"];
    }
    return dataManagerForEvent;
}


- (void)editWithDefault:(NSManagedObject*)defaultPerson dataDictionary:(NSMutableDictionary*)dictionary entityName:(NSString*) entityName completion:(EditCompletion) done {
    NSManagedObject *finalPerson = defaultPerson;
    if ([entityName isEqual:@"Friends"]) {
        // Create new one if necessary
        if(finalPerson == nil) {
            finalPerson = [dataManager createItem];
        }
        NSNumber * friendId = [NSNumber numberWithInt:[dictionary[@"id"] intValue]];
        [finalPerson setValue:friendId forKey:@"id"];
        [finalPerson setValue:dictionary[@"friendName"] forKey:@"friendName"];
        [finalPerson setValue:dictionary[@"lat"] forKey:@"lat"];
        [finalPerson setValue:dictionary[@"lon"] forKey:@"lon"];
        [finalPerson setValue:dictionary[@"lastUpdateDateTime"] forKey:@"lastUpdateDateTime"];
    } else if ([entityName isEqual:@"Event"]) {
        // Create new one if necessary
        if(finalPerson == nil) {
            finalPerson = [dataManagerForEvent createItem];
        }
        [finalPerson setValue:dictionary[@"id"] forKey:@"id"];
        [finalPerson setValue:dictionary[@"userName"] forKey:@"userName"];
        [finalPerson setValue:dictionary[@"title"] forKey:@"title"];
        [finalPerson setValue:dictionary[@"descripe"] forKey:@"descripe"];
        [finalPerson setValue:dictionary[@"startTime"] forKey:@"startTime"];
        [finalPerson setValue:dictionary[@"endTime"] forKey:@"endTime"];
        [finalPerson setValue:dictionary[@"locations"] forKey:@"locations"];
        [finalPerson setValue:dictionary[@"totalMile"] forKey:@"totalMile"];
        [finalPerson setValue:dictionary[@"spanTime"] forKey:@"spanTime"];
    }
    done(true,finalPerson);
}
@end
