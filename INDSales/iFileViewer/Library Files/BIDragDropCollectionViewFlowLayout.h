//
//  BIDragDropCollectionViewFlowLayout.h
//  BI MSL
//
//  Created by IMran Shaikh on 05/09/13.
//  Copyright (c) 2013 Indegene. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BIDragDropCollectionViewDataSource <UICollectionViewDataSource>
@optional
- (void)BIcollectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath;
- (void)BIcollectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath didMoveToIndexPath:(NSIndexPath *)toIndexPath;
- (BOOL)BIcollectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)BIcollectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath canMoveToIndexPath:(NSIndexPath *)toIndexPath;
- (BOOL)BIcollectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath fileExistAtIndexPath:(NSIndexPath *)toIndexPath;
@end

@protocol BIDragDropCollectionViewDelegateFlowLayout <UICollectionViewDelegateFlowLayout>
@optional
- (void)BIcollectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)BIcollectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)BIcollectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)BIcollectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath;
@end


@interface BIDragDropCollectionViewFlowLayout : UICollectionViewFlowLayout<UIGestureRecognizerDelegate>

@property (assign, nonatomic) id<BIDragDropCollectionViewDataSource> dataSource;
@property (assign, nonatomic) id<BIDragDropCollectionViewDelegateFlowLayout> delegate;

@property (assign, nonatomic) CGFloat scrollingSpeed;
@property (assign, nonatomic) UIEdgeInsets scrollingTriggerEdgeInsets;
@property (strong, nonatomic, readonly) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (strong, nonatomic, readonly) UIPanGestureRecognizer *panGestureRecognizer;

- (void)setUpGestureRecognizersOnCollectionView __attribute__((deprecated("Calls to setUpGestureRecognizersOnCollectionView method are not longer needed as setup are done automatically through KVO.")));

-(void)setEditOnoff:(BOOL)onoff;

@end




