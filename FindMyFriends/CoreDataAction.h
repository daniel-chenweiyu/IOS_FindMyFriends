//
//  CoreDataAction.h
//  FindMyFriends
//
//  Created by Daniel on 2017/1/4.
//  Copyright © 2017年 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewController.h"
#import "CoreDataManagerForEvent.h"

@interface CoreDataAction : NSObject
typedef void (^EditCompletion)(bool success,NSManagedObject *result);
- (CoreDataManager*)coreDataManagerSettingWithEntityName:(NSString*) entityName;
- (CoreDataManagerForEvent*)coreDataManagerForEventSettingWithEntityName:(NSString*) entityName;
- (void)editWithDefault:(NSManagedObject*)defaultPerson dataDictionary:(NSMutableDictionary*)dictionary entityName:(NSString*) entityName completion:(EditCompletion) done;
@end
