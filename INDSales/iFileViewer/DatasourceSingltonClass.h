//
//  DatasourceSingltonClass.h
//  iDocViewer
//
////  Created by Kush on 13/11/16.

//

#import <Foundation/Foundation.h>
#import "IDVCollectionVIew.h"
#import "IDVCoverFlowVIew.h"
#import "FavouriteFiles.h"
#import "IDVViewController.h"
#import "INDFileViewerConstants.h"

@class IDVCoverFlowVIew;
@class IDVCollectionVIew;
@interface DatasourceSingltonClass : NSObject

@property(strong,nonatomic) NSString *CommonDirectoryPath;
@property(strong,nonatomic) NSString *FavCommonDirectoryPath;
@property(unsafe_unretained, nonatomic) INDFileViewerType viewStyle;
@property(unsafe_unretained,nonatomic) INDFileViewerType favViewStyle;

@property(strong,nonatomic) IDVCollectionVIew *collectionViewObj;
@property(strong,nonatomic) IDVCoverFlowVIew *coverFlowViewObj;

@property (unsafe_unretained,nonatomic) BOOL viewControllerTag;
@property(unsafe_unretained,nonatomic) BOOL fileLockTag;
@property(strong,nonatomic) NSMutableArray *sharedDataSource;
@property(strong,nonatomic) NSMutableArray *favSharedDataSource;
@property(unsafe_unretained, nonatomic) NSInteger collectionViewEditFlag;
@property(strong,nonatomic) NSMutableArray *arrOfFavFiles;
@property(strong,nonatomic) NSMutableArray *arrOfLockedFiles;
@property(nonatomic,strong) NSString *webViewFlag;
@property(unsafe_unretained, nonatomic) BOOL iDVCCalledFirstTime;
@property(unsafe_unretained, nonatomic) BOOL iDVFavVCFirstTime;

+(DatasourceSingltonClass*)sharedInstance;
-(BOOL)createFolderAtPath:(NSString *)filePath;
-(NSString*)rootFolderPath;

/*** change from app delegate to shared class */

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
-(void)performOperationsAfterAppLaunch;
/*** change from app delegate to shared class */

@end
