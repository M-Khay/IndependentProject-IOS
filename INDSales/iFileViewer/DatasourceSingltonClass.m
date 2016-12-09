//
//  DatasourceSingltonClass.m
//  iDocViewer
//
//  Created by Krishna on 19/11/16.

//

#import "DatasourceSingltonClass.h"

@implementation DatasourceSingltonClass
@synthesize CommonDirectoryPath, favViewStyle;
@synthesize collectionViewObj,coverFlowViewObj;
@synthesize FavCommonDirectoryPath;
@synthesize viewControllerTag;
@synthesize fileLockTag;
@synthesize sharedDataSource;
@synthesize favSharedDataSource;
@synthesize collectionViewEditFlag;
@synthesize arrOfFavFiles;
@synthesize arrOfLockedFiles;
@synthesize webViewFlag;
//@synthesize filepaths;
//@synthesize arrOfFavouriteFilePath;
@synthesize iDVCCalledFirstTime;
@synthesize iDVFavVCFirstTime;

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


+(DatasourceSingltonClass*)sharedInstance
{
    static dispatch_once_t pred;
    static DatasourceSingltonClass *shared = nil;
    
    dispatch_once(&pred, ^{
        
        shared = [[DatasourceSingltonClass alloc] init];

        shared.sharedDataSource=[[NSMutableArray alloc] init];
        shared.favSharedDataSource=[[NSMutableArray alloc] init];
        shared.arrOfFavFiles=[[NSMutableArray alloc] init];
        shared.arrOfLockedFiles=[[NSMutableArray alloc] init];
       // shared.recentViewController=nil;
       // shared.favRecentViewController=nil;
    });
    return shared;
}


- (BOOL)createFolderAtPath:(NSString *)filePath
{
    NSError *error;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL isDirectory;
    
    if (![fileManager fileExistsAtPath:filePath isDirectory:&isDirectory])
    {
        // if folder doesn't exist, try to create it
        
       BOOL res= [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:&error];
        
        // if fail, report error
        NSLog(@"error=%@",error);
      //  if (&error)
      //  {
            
       //     return FALSE;
       // }
        
        if(res)
        {
            return TRUE;
        }
        else
        {
            return FALSE;
        }
        // directory successfully created
        
       // return TRUE;
    }
    else if (!isDirectory)
    {
        return FALSE;
    }
    // directory already existed
    
    return TRUE;
}

-(NSString*)rootFolderPath
{
    NSString*rootFolder = @"iDocDir/doc";
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    
    NSString *filepath = [path stringByAppendingPathComponent:rootFolder];
    
    return filepath;
}


/*** change from app delegate to shared class */
#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    
}
/*** change from app delegate to shared class */

-(void)performOperationsAfterAppLaunch
{
    NSDictionary * defaults = @{
                                
                                @"setPasscode":@NO
                                // you can list the default values for other defaults/switches here
                                } ;
    [ [ NSUserDefaults standardUserDefaults ] registerDefaults:defaults ] ;
    NSError *error=nil;
    BOOL isDIR;
    NSURL *docUrl=[[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"iDocDir"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:[docUrl path] isDirectory:&isDIR])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:[docUrl path] withIntermediateDirectories:YES attributes:nil error:&error];
        
    }
    
    // deleting zipped files..
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath=[paths objectAtIndex:0];
    NSString *documentsPath = [docPath stringByAppendingPathComponent:@"iDocDir"];
    NSString *pathToStoreTempZipFiles=[documentsPath stringByAppendingPathComponent:@"zipFiles"];
    NSString *pathToStoreTempDownloadFiles=[documentsPath stringByAppendingPathComponent:@"tempDownloadFiles"];
    
    
    NSString *favthumbnailFilesPath=[documentsPath stringByAppendingPathComponent:@"favouriteFileThumbnails"];
    
    NSString *pathToStoreTempThumbnails=[documentsPath stringByAppendingPathComponent:@"thumbnails"];
    
    [[NSFileManager defaultManager] removeItemAtPath:pathToStoreTempZipFiles error:&error];
    [[NSFileManager defaultManager] removeItemAtPath:pathToStoreTempDownloadFiles error:&error];
    
    [[NSFileManager defaultManager] removeItemAtPath:pathToStoreTempThumbnails error:&error];
    [[NSFileManager defaultManager] removeItemAtPath:favthumbnailFilesPath error:&error];

    iDVCCalledFirstTime=true;
    iDVFavVCFirstTime=true;
}

/*** change from app delegate to shared class */

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"DataModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
     NSError *error = nil;
    //$$
    BOOL isDIR;
     NSURL *docUrl=[[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"iDocDir"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:[docUrl path] isDirectory:&isDIR])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:[docUrl path] withIntermediateDirectories:YES attributes:nil error:&error];
        
    }

   
    NSURL *storeURL=[docUrl URLByAppendingPathComponent:@"DataModel.sqlite"];
    //$$
  //  NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"DataModel.sqlite"];
    
   
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

@end

@implementation NSURLRequest(DataController)
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host
{
    return YES;
}

@end

