//
//  INDAppDelegate.m
//  INDSales
//
//  Created by Kush on 21/11/16.//

#import "INDAppDelegate.h"
#import "INDConfigModel.h"
#import "IDVViewController.h"
#import "NSDate+TimeAgo.h"
#import "INDWebservices.h"
#import "INDLiveChatModel.h"
#import "IDVViewController.h"

@implementation INDAppDelegate
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize idvVC;
@synthesize nav;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
 
//    NSString *generalConfigFilePathInBundle = [[NSBundle mainBundle] pathForResource:@"generalConfig" ofType:@"plist"];
//    NSDictionary* generalConfig=[NSDictionary dictionaryWithContentsOfFile:generalConfigFilePathInBundle];
//    [INDConfigModel shared].baseUrlPath=[generalConfig objectForKey:@"baseUrl"];
//    [[DatasourceSingltonClass sharedInstance] performOperationsAfterAppLaunch];
//    
//    [[UIApplication sharedApplication] cancelAllLocalNotifications];
//
//    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
//    
//    
//    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    //navController.navigationBarHidden = YES;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        idvVC=[[IDVViewController alloc]initWithNibName:@"IDVViewController_iPhone" bundle:nil];
    }
    else
    {
        idvVC=[[IDVViewController alloc]initWithNibName:@"IDVViewController" bundle:nil];
    }
    nav = [[UINavigationController alloc] initWithRootViewController:idvVC];

    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    

    return YES;
    
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    [INDConfigModel shared].deviceToken=token;

}

							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
     [self saveContext];
}


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
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"INDSales" withExtension:@"momd"];
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
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"INDSales.sqlite"];
    
    NSError *error = nil;
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

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

//push view controller
-(void)pushiDocViewerWithUrlPath:(NSString *)path withViewController:(UIViewController*)viewController
{
    IDVViewController *idvVC=[[IDVViewController alloc]initWithNibName:@"IDVViewController" bundle:nil];
    [viewController.navigationController pushViewController:idvVC animated:YES];
    [idvVC downloadFromGivenLink:path];

}

-(NSString*)dateFormaterFromString: (NSString*)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSDate *dateOfCreation = [[NSDate alloc] init];
    

    NSArray *component = [date componentsSeparatedByString:@" "];
    
    NSString* timeZone=component[2];
    
    
    
    if ([timeZone rangeOfString:@":"].location == NSNotFound) {
        //America/Los_Angeles
        
        dateFormatter.timeZone=[[NSTimeZone alloc] initWithName:[NSString stringWithFormat:@"%@",timeZone]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        dateOfCreation = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@ %@",component[0],component[1]]];
    }
    else
    {
        //+05:30
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZ"];
        dateOfCreation = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@ %@ %@",component[0],component[1],component[2]]];
        
        
    }
    
    NSString *strDate=[dateOfCreation dateTimeAgo];
    
    return strDate;
}


-(CGSize)sizeOfText:(NSString*)text withFont:(UIFont*)font widthOflabel:(float) width
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    CGRect textRect1 = [text boundingRectWithSize:CGSizeMake(width, 9999)
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:@{NSFontAttributeName:font,NSParagraphStyleAttributeName: paragraphStyle.copy}
                                          context:nil];
    return textRect1.size;
}

-(void)flasfAlert:(NSString*)msg withheader:(NSString*)header
{
    
    UIAlertView*msgAlertView= [[UIAlertView alloc]initWithTitle:header message:msg delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    
    [msgAlertView show];
    
    [self performSelector:@selector(cancelAlert:) withObject:msgAlertView afterDelay:2.0];
    
    
}

-(void)cancelAlert:(UIAlertView*)alert
{
    
    [alert dismissWithClickedButtonIndex:0 animated:YES];
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"userInfo: %@",userInfo);
    NSString* alert=[[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    
    NSString* loginIdOfSender=[[alert componentsSeparatedByString:@":"] firstObject];
    [[INDLiveChatModel shared] newChatHasArrivedOfLoginId:loginIdOfSender];
}

@end
