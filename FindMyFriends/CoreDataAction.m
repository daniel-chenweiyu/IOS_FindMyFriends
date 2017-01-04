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
}

- (CoreDataManager*)coreDataManagerSettingWithEntityName:(NSString*) entityName {
    if (dataManager == nil) {
        dataManager = [CoreDataManager sharedInstance];
    }
    if ([entityName isEqual:@"Friends"]) {
        [dataManager prepareWithModel:@"FindMyFriends" dbFileName:@"FindMyFriends.sqlite" dbFilePathURL:nil sortKey:@"friendName" entityName:@"Friends"];
    } else if ([entityName isEqual:@"Event"]) {
        [dataManager prepareWithModel:@"FindMyFriends" dbFileName:@"FindMyFriends.sqlite" dbFilePathURL:nil sortKey:@"id" entityName:@"Event"];
    } else if ([entityName isEqual:@"LocationRecord"]) {
        [dataManager prepareWithModel:@"FindMyFriends" dbFileName:@"FindMyFriends.sqlite" dbFilePathURL:nil sortKey:@"timeLog" entityName:@"LocationRecord"];
    }
    return dataManager;
}


- (void)editWithDefault:(NSManagedObject*)defaultPerson dataDictionary:(NSMutableDictionary*)dictionary entityName:(NSString*) entityName completion:(EditCompletion) done {
    NSManagedObject *finalPerson = defaultPerson;
    // Create new one if necessary
    if(finalPerson == nil) {
        finalPerson = [dataManager createItem];
        //        [finalPerson setValue:[NSDate date] forKey:@"createDate"];
    }
    if ([entityName isEqual:@"Friends"]) {
        NSNumber * friendId = [NSNumber numberWithInt:[dictionary[@"id"] intValue]];
        [finalPerson setValue:friendId forKey:@"id"];
        [finalPerson setValue:dictionary[@"friendName"] forKey:@"friendName"];
        [finalPerson setValue:dictionary[@"lat"] forKey:@"lat"];
        [finalPerson setValue:dictionary[@"lon"] forKey:@"lon"];
        [finalPerson setValue:dictionary[@"lastUpdateDateTime"] forKey:@"lastUpdateDateTime"];
    } else if ([entityName isEqual:@"Event"]) {

    } else if ([entityName isEqual:@"LocationRecord"]) {

    }

    
    done(true,finalPerson);
    
}
@end
