//
//  treeNode.h
//  INDSales
//
//

#import <Foundation/Foundation.h>

@interface treeNode : NSObject
@property(weak,nonatomic)treeNode* parent;
@property(strong,nonatomic)NSMutableArray*children;
@property(strong,nonatomic)id value;
@end
