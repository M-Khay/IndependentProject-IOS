//
//  INDViewCustomerVC.h
//  INDSales
//
//////  Created by Kush on 13/11/16.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

typedef NS_ENUM(NSInteger, eSearchType)
{
    kSearchTypeName, //Default value starts with 0
    kSearchTypeCountry,
    kSearchTypeCompanyName
};

@interface INDViewCustomerVC : UIViewController<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate,NSFetchedResultsControllerDelegate,MFMailComposeViewControllerDelegate,ABPeoplePickerNavigationControllerDelegate>

@property (nonatomic) eSearchType searchType;

@end
