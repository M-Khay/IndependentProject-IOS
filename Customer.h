//
//  Customer.h
//  INDSales
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Customer : NSManagedObject

@property (nonatomic, retain) NSString * alternatenumber;
@property (nonatomic, retain) NSString * company;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSString * countryCode;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * firstname;
@property (nonatomic, retain) NSString * lastname;
@property (nonatomic, retain) NSString * otherinfo;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * photoPath;
@property (nonatomic, retain) NSString * designation;

@end
