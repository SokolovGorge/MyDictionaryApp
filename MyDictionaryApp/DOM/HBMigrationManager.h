//
//  HBMigrationManager.h
//  CoreDataMigration
//
//  Created by Соколов Георгий on 28.12.2017.
//  Copyright © 2017 Соколов Георгий. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class HBMigrationManager;

@protocol HBMigrationManagerDelegate <NSObject>

@optional
- (void)migrationManager:(HBMigrationManager *)migrationManager migrationProgress:(float)migrationProgress;
- (NSArray *)migrationManager:(HBMigrationManager *)migrationManager mappingModelsForSourceModel:(NSManagedObjectModel *)sourceModel;

@end


@interface HBMigrationManager : NSObject

@property (nonatomic, weak) id<HBMigrationManagerDelegate> delegate;

- (BOOL)progressivelyMigrateURL:(NSURL *)sourceStoreURL
                         ofType:(NSString *)type
                        toModel:(NSManagedObjectModel *)finalModel
                          error:(NSError **)error;


@end
