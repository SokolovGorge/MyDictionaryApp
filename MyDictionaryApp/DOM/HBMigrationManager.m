//
//  HBMigrationManager.m
//  CoreDataMigration
//
//  Created by Соколов Георгий on 28.12.2017.
//  Copyright © 2017 Соколов Георгий. All rights reserved.
//

#import "HBMigrationManager.h"
#import <UIKit/UIKit.h>

#define kAppErrorDomain  @"AppError"

@interface HBMigrationManager()

@property (strong, nonatomic) NSMutableArray<NSString *> *doneModelPaths;

@end

@implementation HBMigrationManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.doneModelPaths = [NSMutableArray array];
    }
    return self;
}



- (BOOL)progressivelyMigrateURL:(NSURL *)sourceStoreURL
                         ofType:(NSString *)type
                        toModel:(NSManagedObjectModel *)finalModel
                          error:(NSError **)error
{
    NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:type
                                                                                              URL:sourceStoreURL
                                                                                          options:nil
                                                                                            error:error];
    if (!sourceMetadata) {
        return NO;
    }
    if ([finalModel isConfiguration:nil
        compatibleWithStoreMetadata:sourceMetadata]) {
        if (NULL != error) {
            *error = nil;
        }
        return YES;
    }
    NSManagedObjectModel *sourceModel = [self sourceModelForSourceMetadata:sourceMetadata];
    NSManagedObjectModel *destinationModel = nil;
    NSMappingModel *mappingModel = nil;
    NSString *modelName = nil;
    if (![self getDestinationModel:&destinationModel
                      mappingModel:&mappingModel
                         modelName:&modelName
                    forSourceModel:sourceModel
                             error:error]) {
        return NO;
    }
    
    NSArray *mappingModels = @[mappingModel];
    if ([self.delegate respondsToSelector:@selector(migrationManager:mappingModelsForSourceModel:)]) {
        NSArray *explicitMappingModels = [self.delegate migrationManager:self mappingModelsForSourceModel:sourceModel];
        if (0 < explicitMappingModels.count) {
            mappingModels = explicitMappingModels;
        }
    }
    NSURL *destinationStoreURL = [self destinationStoreURLWithSourceStoreURL:sourceStoreURL
                                                                   modelName:modelName];
    NSMigrationManager *manager = [[NSMigrationManager alloc] initWithSourceModel:sourceModel
                                                                 destinationModel:destinationModel];
    [manager addObserver:self
              forKeyPath:@"migrationProgress"
                 options:NSKeyValueObservingOptionNew
                 context:nil];
    BOOL didMigrate = NO;
    for (NSMappingModel *mappingModel in mappingModels) {
        didMigrate = [manager migrateStoreFromURL:sourceStoreURL
                                             type:type
                                          options:nil
                                 withMappingModel:mappingModel
                                 toDestinationURL:destinationStoreURL
                                  destinationType:type
                               destinationOptions:nil
                                            error:error];
    }
    [manager removeObserver:self
                 forKeyPath:@"migrationProgress"];
    if (!didMigrate) {
        return NO;
    }
    // Migration was successful, move the files around to preserve the source in case things go bad
    if (![self backupSourceStoreAtURL:sourceStoreURL
          movingDestinationStoreAtURL:destinationStoreURL
                                error:error]) {
        return NO;
    }
    // We may not be at the "current" model yet, so recurse
    return [self progressivelyMigrateURL:sourceStoreURL
                                  ofType:type
                                 toModel:finalModel
                                   error:error];
}

- (NSArray *)modelPaths
{
    //Find all of the mom and momd files in the Resources directory
    NSMutableArray *modelPaths = [NSMutableArray array];
    NSArray *momdArray = [[NSBundle mainBundle] pathsForResourcesOfType:@"momd"
                                                            inDirectory:nil];
    for (NSString *momdPath in momdArray) {
        NSString *resourceSubpath = [momdPath lastPathComponent];
        NSArray *array = [[NSBundle mainBundle] pathsForResourcesOfType:@"mom"
                                                            inDirectory:resourceSubpath];
        [modelPaths addObjectsFromArray:array];
    }
    NSArray *otherModels = [[NSBundle mainBundle] pathsForResourcesOfType:@"mom"
                                                              inDirectory:nil];
    [modelPaths addObjectsFromArray:otherModels];
    
    [modelPaths sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSString *st1 = (NSString *)obj1;
        NSString *st2 = (NSString *)obj2;
        return [st1 compare:st2];
    }];
    return modelPaths;
}

- (NSManagedObjectModel *)sourceModelForSourceMetadata:(NSDictionary *)sourceMetadata
{
    return [NSManagedObjectModel mergedModelFromBundles:@[[NSBundle mainBundle]]
                                       forStoreMetadata:sourceMetadata];
}

- (BOOL)getDestinationModel:(NSManagedObjectModel **)destinationModel
               mappingModel:(NSMappingModel **)mappingModel
                  modelName:(NSString **)modelName
             forSourceModel:(NSManagedObjectModel *)sourceModel
                      error:(NSError **)error
{
    NSArray *modelPaths = [self modelPaths];
    if (!modelPaths.count) {
        //Throw an error if there are no models
        if (NULL != error) {
            *error = [NSError errorWithDomain:kAppErrorDomain
                                         code:8001
                                     userInfo:@{ NSLocalizedDescriptionKey : @"No models found!" }];
        }
        return NO;
    }
    
    //See if we can find a matching destination model
    NSManagedObjectModel *model = nil;
    NSMappingModel *mapping = nil;
    NSString *modelPath = nil;
    
    for (modelPath in modelPaths) {
        //пропускаем - если мапа уже отработала
        // это затычка на тот вариант, когда выбирается неправильная мапа
        if ([self.doneModelPaths containsObject:modelPath]) {
            continue;
        }
        model = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:modelPath]];
        mapping = [NSMappingModel mappingModelFromBundles:@[[NSBundle mainBundle]]
                                           forSourceModel:sourceModel
                                         destinationModel:model];
        //If we found a mapping model then proceed
        if (mapping) {
            [self.doneModelPaths addObject:modelPath];
            break;
        }
    }
    
    //We have tested every model, if nil here we failed
    if (!mapping) {
        if (NULL != error) {
            *error = [NSError errorWithDomain:kAppErrorDomain
                                         code:8001
                                     userInfo:@{ NSLocalizedDescriptionKey : @"No mapping model found in bundle" }];
        }
//        [BLCoreDataManager getInstance].migrationFailed = YES;
        return NO;
    } else {
        *destinationModel = model;
        *mappingModel = mapping;
        *modelName = modelPath.lastPathComponent.stringByDeletingPathExtension;
    }
    return YES;
}

- (NSURL *)destinationStoreURLWithSourceStoreURL:(NSURL *)sourceStoreURL
                                       modelName:(NSString *)modelName
{
    // We have a mapping model, time to migrate
    NSString *storeExtension = sourceStoreURL.path.pathExtension;
    NSString *storePath = sourceStoreURL.path.stringByDeletingPathExtension;
    // Build a path to write the new store
    storePath = [NSString stringWithFormat:@"%@.%@.%@", storePath, modelName, storeExtension];
    return [NSURL fileURLWithPath:storePath];
}

- (BOOL)backupSourceStoreAtURL:(NSURL *)sourceStoreURL
   movingDestinationStoreAtURL:(NSURL *)destinationStoreURL
                         error:(NSError **)error
{
    NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString];
    NSString *backupPath = [NSTemporaryDirectory() stringByAppendingPathComponent:guid];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager moveItemAtPath:sourceStoreURL.path
                              toPath:backupPath
                               error:error]) {
        //Failed to copy the file
        return NO;
    }
    //Move the destination to the source path
    if (![fileManager moveItemAtPath:destinationStoreURL.path
                              toPath:sourceStoreURL.path
                               error:error]) {
        //Try to back out the source move first, no point in checking it for errors
        [fileManager moveItemAtPath:backupPath
                             toPath:sourceStoreURL.path
                              error:nil];
        return NO;
    }
    return YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"migrationProgress"]) {
        NSLog(@"progress: %f", [object migrationProgress]);
        if ([self.delegate respondsToSelector:@selector(migrationManager:migrationProgress:)]) {
            [self.delegate migrationManager:self migrationProgress:[(NSMigrationManager *)object migrationProgress]];
        }
    } else {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}


@end
