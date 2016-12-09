//
//  INDAddCustomerVC.h
//  INDSales
//
//////  Created by Kush on 13/11/16.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Customer.h"
#import "UIImage+fixOrientation.h"
typedef enum {
    addNew=1,
    saveExisting
}operationType;



@interface INDAddCustomerVC : UIViewController<UIPopoverControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property(nonatomic,assign)operationType addNewOrSave;
@property(nonatomic,weak)Customer* customerDetail;
@end