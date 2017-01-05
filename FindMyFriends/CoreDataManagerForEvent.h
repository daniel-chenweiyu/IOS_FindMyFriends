//
//  CoreDataManagerForEvent.h
//  FindMyFriends
//
//  Created by Daniel on 2017/1/5.
//  Copyright © 2017年 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef void (^SaveCompletion)(BOOL success);

@interface CoreDataManagerForEvent : NSObject
+ (instancetype) sharedInstance;

- (void) prepareWithModel:(NSString*) model dbFileName:(NSString*)dbFileName dbFilePathURL:(NSURL*) dbFilePathURL sortKey:(NSString*) sortKey entityName:(NSString*) entityName;

- (void) saveContextWithCompletion:(SaveCompletion)done;

- (NSInteger) count;
- (NSManagedObject*) createItem;
- (void) deleteItem:(NSManagedObject*) item;
- (NSManagedObject*) getByIndex:(NSInteger) index;
- (NSArray*) searchFor:(NSString*) keyword withField:(NSString*) field;

@end
