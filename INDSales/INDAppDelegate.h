//
//  INDAppDelegate.h
//  INDSales
////  Created by Kush on 21/11/16.
//

#import <UIKit/UIKit.h>
#import "DatasourceSingltonClass.h"
#import "INDWebServiceModel.h"

#define   APP_DELEGATE  ((INDAppDelegate*)[[UIApplication sharedApplication] delegate])

@interface INDAppDelegate : UIResponder <UIApplicationDelegate,webServiceResponceProtocol>

@property (strong, nonatomic) IDVViewController *idvVC;

@property (strong, nonatomic) UIWindow *window;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) UINavigationController* nav;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
-(void)pushiDocViewerWithUrlPath:(NSString *)path withViewController:(UIViewController*)viewController;
-(NSString*)dateFormaterFromString: (NSString*)date;
-(CGSize)sizeOfText:(NSString*)text withFont:(UIFont*)font widthOflabel:(float) width;
-(void)flasfAlert:(NSString*)msg withheader:(NSString*)header;

@end
