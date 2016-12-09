//
//  BIDragDropCollectionViewFlowLayout.m
//  BI MSL
//
//  Created by IMran Shaikh on 05/09/13.
//  Copyright (c) 2013 Indegene. All rights reserved.
//

#import "BIDragDropCollectionViewFlowLayout.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#import "IDVCollectionVIewCustomCell.h"

#define LX_FRAMES_PER_SECOND 60.0

#ifndef CGGEOMETRY_LXSUPPORT_H_
CG_INLINE CGPoint
LXS_CGPointAdd(CGPoint point1, CGPoint point2) {
    return CGPointMake(point1.x + point2.x, point1.y + point2.y);
}
#endif

typedef NS_ENUM(NSInteger, LXScrollingDirection) {
    LXScrollingDirectionUnknown = 0,
    LXScrollingDirectionUp,
    LXScrollingDirectionDown,
    LXScrollingDirectionLeft,
    LXScrollingDirectionRight
};

static NSString * const kBIScrollingDirectionKey = @"LXScrollingDirection";
static NSString * const kBICollectionViewKeyPath = @"collectionView";

@interface CADisplayLink (LX_userInfo)
@property (nonatomic, copy) NSDictionary *LX_userInfo;
@end

@implementation CADisplayLink (LX_userInfo)
- (void) setLX_userInfo:(NSDictionary *) LX_userInfo {
    objc_setAssociatedObject(self, "LX_userInfo", LX_userInfo, OBJC_ASSOCIATION_COPY);
}

- (NSDictionary *) LX_userInfo {
    return objc_getAssociatedObject(self, "LX_userInfo");
}
@end

@interface UICollectionViewCell (LXReorderableCollectionViewFlowLayout)

- (UIImage *)LX_rasterizedImage;

@end

@implementation UICollectionViewCell (LXReorderableCollectionViewFlowLayout)

- (UIImage *)LX_rasterizedImage
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0.0f);
    
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

@end

@interface BIDragDropCollectionViewFlowLayout ()

@property (assign, nonatomic) BOOL isDropable;
@property (strong, nonatomic) NSIndexPath *dragCellItemIndexPath;

@property (strong, nonatomic) NSIndexPath *selectedItemIndexPath;
@property (strong, nonatomic) UIView *currentView;
@property (assign, nonatomic) CGPoint currentViewCenter;
@property (assign, nonatomic) CGPoint panTranslationInCollectionView;
@property (strong, nonatomic) CADisplayLink *displayLink;

//@property (assign, nonatomic, readonly) id<BIDragDropCollectionViewDataSource> dataSource;
//@property (assign, nonatomic, readonly) id<BIDragDropCollectionViewDelegateFlowLayout> delegate;

@end

@implementation BIDragDropCollectionViewFlowLayout

-(void)setEditOnoff:(BOOL)onoff
{
    NSLog(@"editOnff");
    
    if (onoff)
    {
        _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
        _longPressGestureRecognizer.delegate = self;
        //_longPressGestureRecognizer.minimumPressDuration = 0.55;
        
        // Links the default long press gesture recognizer to the custom long press gesture recognizer we are creating now
        // by enforcing failure dependency so that they doesn't clash.
        for (UIGestureRecognizer *gestureRecognizer in self.collectionView.gestureRecognizers) {
            if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
                [gestureRecognizer requireGestureRecognizerToFail:_longPressGestureRecognizer];
            }
        }
        
        [self.collectionView addGestureRecognizer:_longPressGestureRecognizer];
        
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        _panGestureRecognizer.delegate = self;
        
        [self.collectionView addGestureRecognizer:_panGestureRecognizer];
        
    }
    else {
        
        UICollectionViewCell *toCell = [self.collectionView cellForItemAtIndexPath:self.selectedItemIndexPath];
        [toCell.layer setBorderWidth:0.0];
        [toCell.layer setCornerRadius:0.0];
        [toCell.layer setBackgroundColor:[[UIColor clearColor] CGColor]];
        [toCell.layer setBorderColor:[[UIColor whiteColor] CGColor]];

        
        [self.currentView removeFromSuperview];
        self.currentView = nil;
        [self invalidateLayout];

        [self.collectionView removeGestureRecognizer:_longPressGestureRecognizer];
        [self.collectionView removeGestureRecognizer:_panGestureRecognizer];
    }
    
}

- (void)setDefaults
{
    self.isDropable = NO;
    _scrollingSpeed = 300.0f;
    _scrollingTriggerEdgeInsets = UIEdgeInsetsMake(50.0f, 50.0f, 50.0f, 50.0f);
}

- (void)setupCollectionView
{
    _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    _longPressGestureRecognizer.delegate = self;
    //_longPressGestureRecognizer.minimumPressDuration = 0.55;
    
    // Links the default long press gesture recognizer to the custom long press gesture recognizer we are creating now
    // by enforcing failure dependency so that they doesn't clash.
    for (UIGestureRecognizer *gestureRecognizer in self.collectionView.gestureRecognizers) {
        if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
            [gestureRecognizer requireGestureRecognizerToFail:_longPressGestureRecognizer];
        }
    }
    
    [self.collectionView addGestureRecognizer:_longPressGestureRecognizer];
    
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                    action:@selector(handlePanGesture:)];
    _panGestureRecognizer.delegate = self;
    [self.collectionView addGestureRecognizer:_panGestureRecognizer];
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        [self setDefaults];
        
        [self addObserver:self forKeyPath:kBICollectionViewKeyPath options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setDefaults];
        [self addObserver:self forKeyPath:kBICollectionViewKeyPath options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)dealloc {
    [self invalidatesScrollTimer];
    [self removeObserver:self forKeyPath:kBICollectionViewKeyPath];
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    if ([layoutAttributes.indexPath isEqual:self.selectedItemIndexPath]) {
        layoutAttributes.hidden = YES;
    }
}

- (id<BIDragDropCollectionViewDataSource>)dataSource {
    return (id<BIDragDropCollectionViewDataSource>)self.collectionView.dataSource;
}

- (id<BIDragDropCollectionViewDelegateFlowLayout>)delegate {
    return (id<BIDragDropCollectionViewDelegateFlowLayout>)self.collectionView.delegate;
}

- (void)invalidateLayoutIfNecessary
{
    NSIndexPath *newIndexPath = [self.collectionView indexPathForItemAtPoint:self.currentView.center];
    NSIndexPath *previousIndexPath = self.selectedItemIndexPath;
    
    if ((newIndexPath == nil) || [newIndexPath isEqual:previousIndexPath])
    {
        if (newIndexPath == nil)
        {
            //NSLog(@"newIndexPath nil");
            
            UICollectionViewCell *previousCell = [self.collectionView cellForItemAtIndexPath:previousIndexPath];
            [previousCell.layer setBorderWidth:0.0];
            [previousCell.layer setCornerRadius:0.0];
            [previousCell.layer setBackgroundColor:[[UIColor clearColor] CGColor]];
            [previousCell.layer setBorderColor:[[UIColor whiteColor] CGColor]];
            
            self.selectedItemIndexPath = self.dragCellItemIndexPath;
            
            self.isDropable = NO;
            
            return;
        }
        
        //NSLog(@"newIndexPath and previousIndexPath are same");
        
        return;
    }
    
   // if ( [self.dataSource respondsToSelector:@selector(collectionView:itemAtIndexPath:canMoveToIndexPath:)] &&
      //  ![self.dataSource BIcollectionView:self.collectionView itemAtIndexPath:self.dragCellItemIndexPath canMoveToIndexPath:newIndexPath] )
   if(![self.dataSource BIcollectionView:self.collectionView itemAtIndexPath:self.dragCellItemIndexPath canMoveToIndexPath:newIndexPath]) {
        NSLog(@"canMoveToIndexPath NO");
        
        UICollectionViewCell *previousCell = [self.collectionView cellForItemAtIndexPath:previousIndexPath];
        [previousCell.layer setBorderWidth:0.0];
        [previousCell.layer setCornerRadius:0.0];
        [previousCell.layer setBackgroundColor:[[UIColor clearColor] CGColor]];
        [previousCell.layer setBorderColor:[[UIColor whiteColor] CGColor]];
        
        self.isDropable = NO;
        
        self.selectedItemIndexPath = self.dragCellItemIndexPath;
        
        return;
    }
    else{
        NSLog(@"canMoveToIndexPath YES");
        
        UICollectionViewCell *previousCell = [self.collectionView cellForItemAtIndexPath:previousIndexPath];
        [previousCell.layer setBorderWidth:0.0];
        [previousCell.layer setCornerRadius:0.0];
        [previousCell.layer setBackgroundColor:[[UIColor clearColor] CGColor]];
        [previousCell.layer setBorderColor:[[UIColor whiteColor] CGColor]];
        
        UICollectionViewCell *toCell = [self.collectionView cellForItemAtIndexPath:newIndexPath];
        [toCell.layer setBorderWidth:2.0];
        [toCell.layer setCornerRadius:10.0];
        [toCell.layer setBackgroundColor:[[UIColor colorWithWhite:0 alpha:0.25] CGColor]];
        [toCell.layer setBorderColor:[[UIColor colorWithPatternImage:[UIImage imageNamed:@"Default@2x.png"]] CGColor]];
        
        self.isDropable = YES;
        
        self.selectedItemIndexPath = newIndexPath;
        }
    
    
    //    if ([self.dataSource respondsToSelector:@selector(collectionView:itemAtIndexPath:willMoveToIndexPath:)])
    //    {
    //        [self.dataSource collectionView:self.collectionView itemAtIndexPath:previousIndexPath willMoveToIndexPath:newIndexPath];
    //    }
    
    ///Animation for Cell Highlight
    
    
    /* __weak typeof(self) weakSelf = self;
     
     [self.collectionView performBatchUpdates:^{
     
     __strong typeof(self) strongSelf = weakSelf;
     
     if (strongSelf)
     {
     //[strongSelf.collectionView deleteItemsAtIndexPaths:@[ previousIndexPath ]];
     //[strongSelf.collectionView insertItemsAtIndexPaths:@[ newIndexPath ]];
     }
     } completion:^(BOOL finished)
     {
     __strong typeof(self) strongSelf = weakSelf;
     
     if ([strongSelf.dataSource respondsToSelector:@selector(collectionView:itemAtIndexPath:didMoveToIndexPath:)])
     {
     //[strongSelf.dataSource collectionView:strongSelf.collectionView itemAtIndexPath:previousIndexPath didMoveToIndexPath:newIndexPath];
     }
     }]; */
    
}

-(void)drawDashedBorderForCell:(UICollectionViewCell*)collectionCell;
{
    // Important, otherwise we will be adding multiple sub layers
    if ([[[collectionCell.contentView layer] sublayers] objectAtIndex:0])
    {
        collectionCell.contentView.layer.sublayers = nil;
    }
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setBounds:collectionCell.contentView.bounds];
    [shapeLayer setPosition:collectionCell.contentView.center];
    [shapeLayer setFillColor:[[UIColor clearColor] CGColor]];
    [shapeLayer setStrokeColor:[[UIColor blackColor] CGColor]];
    [shapeLayer setLineWidth:3.0f];
    [shapeLayer setLineJoin:kCALineJoinRound];
    [shapeLayer setLineDashPattern:
     [NSArray arrayWithObjects:[NSNumber numberWithInt:10],
      [NSNumber numberWithInt:5],nil]];
    
    // Setup the path
    CGMutablePathRef path = CGPathCreateMutable();
    //    CGPathMoveToPoint(path, NULL, beginPoint.center.x, beginPoint.center.y);
    //    CGPathAddLineToPoint(path, NULL, endPoint.center.x, endPoint.center.y);
    
    [shapeLayer setPath:path];
    CGPathRelease(path);
    
    [[collectionCell.contentView layer] addSublayer:shapeLayer];
}

- (void)invalidatesScrollTimer {
    if (!self.displayLink.paused) {
        [self.displayLink invalidate];
    }
    self.displayLink = nil;
}

- (void)setupScrollTimerInDirection:(LXScrollingDirection)direction {
    if (!self.displayLink.paused) {
        LXScrollingDirection oldDirection = [self.displayLink.LX_userInfo[kBIScrollingDirectionKey] integerValue];
        
        if (direction == oldDirection) {
            return;
        }
    }
    
    [self invalidatesScrollTimer];
    
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleScroll:)];
    self.displayLink.LX_userInfo = @{ kBIScrollingDirectionKey : @(direction) };
    
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

#pragma mark - Target/Action methods

// Tight loop, allocate memory sparely, even if they are stack allocation.
- (void)handleScroll:(CADisplayLink *)displayLink
{
    LXScrollingDirection direction = (LXScrollingDirection)[displayLink.LX_userInfo[kBIScrollingDirectionKey] integerValue];
    if (direction == LXScrollingDirectionUnknown) {
        return;
    }
    
    CGSize frameSize = self.collectionView.bounds.size;
    CGSize contentSize = self.collectionView.contentSize;
    CGPoint contentOffset = self.collectionView.contentOffset;
    CGFloat distance = self.scrollingSpeed / LX_FRAMES_PER_SECOND;
    CGPoint translation = CGPointZero;
    
    switch(direction) {
        case LXScrollingDirectionUp: {
            distance = -distance;
            CGFloat minY = 0.0f;
            
            if ((contentOffset.y + distance) <= minY) {
                distance = -contentOffset.y;
            }
            
            translation = CGPointMake(0.0f, distance);
        } break;
        case LXScrollingDirectionDown: {
            CGFloat maxY = MAX(contentSize.height, frameSize.height) - frameSize.height;
            
            if ((contentOffset.y + distance) >= maxY) {
                distance = maxY - contentOffset.y;
            }
            
            translation = CGPointMake(0.0f, distance);
        } break;
        case LXScrollingDirectionLeft: {
            distance = -distance;
            CGFloat minX = 0.0f;
            
            if ((contentOffset.x + distance) <= minX) {
                distance = -contentOffset.x;
            }
            
            translation = CGPointMake(distance, 0.0f);
        } break;
        case LXScrollingDirectionRight: {
            CGFloat maxX = MAX(contentSize.width, frameSize.width) - frameSize.width;
            
            if ((contentOffset.x + distance) >= maxX) {
                distance = maxX - contentOffset.x;
            }
            
            translation = CGPointMake(distance, 0.0f);
        } break;
        default: {
            // Do nothing...
        } break;
    }
    
    self.currentViewCenter = LXS_CGPointAdd(self.currentViewCenter, translation);
    self.currentView.center = LXS_CGPointAdd(self.currentViewCenter, self.panTranslationInCollectionView);
    self.collectionView.contentOffset = LXS_CGPointAdd(contentOffset, translation);
}


- (void)handleLongPressGesture:(UITapGestureRecognizer *)gestureRecognizer
{
    //NSLog(@"BIDragDropCollectionViewFlowLayout handleLongPressGesture:");
    
    switch(gestureRecognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            NSIndexPath *currentIndexPath = [self.collectionView indexPathForItemAtPoint:[gestureRecognizer locationInView:self.collectionView]];
            
            self.isDropable = NO;
            
           // if ([self.dataSource respondsToSelector:@selector(collectionView:canMoveItemAtIndexPath:)] &&
            //    ![self.dataSource BIcollectionView:self.collectionView canMoveItemAtIndexPath:currentIndexPath])
            if(![self.dataSource BIcollectionView:self.collectionView canMoveItemAtIndexPath:currentIndexPath]){
                return;
            }
            
            self.selectedItemIndexPath = currentIndexPath;
            self.dragCellItemIndexPath = currentIndexPath;
            
           // if ([self.delegate respondsToSelector:@selector(collectionView:layout:willBeginDraggingItemAtIndexPath:)]) {
                [self.delegate BIcollectionView:self.collectionView layout:self willBeginDraggingItemAtIndexPath:self.selectedItemIndexPath];
           // }
            
            UICollectionViewCell *collectionViewCell = [self.collectionView cellForItemAtIndexPath:self.selectedItemIndexPath];
            //BICollectionViewCell *collectionViewCell = (BICollectionViewCell*)[self.collectionView cellForItemAtIndexPath:self.selectedItemIndexPath];
            
            CGPoint centerPoint = collectionViewCell.center;
            
            int originX = 0;//collectionViewCell.frame.origin.x + ( collectionViewCell.frame.size.width - (collectionViewCell.frame.size.width/1.5))/2;
            int originY = 0;//collectionViewCell.frame.origin.y + ( collectionViewCell.frame.size.height - (collectionViewCell.frame.size.height/1.5))/2;
          //  int cellWidth = collectionViewCell.frame.size.width/1.5;
          //  int cellHeight = collectionViewCell.frame.size.height/1.5;
            
            int cellX = collectionViewCell.frame.origin.x;
            int cellY = collectionViewCell.frame.origin.y;
            int cellWidth = collectionViewCell.frame.size.width;
            int cellHeight = collectionViewCell.frame.size.height;

           // CGRect currentViewFrame = CGRectMake(originX , originY, cellWidth, cellHeight);
            CGRect currentViewFrame = CGRectMake(originX , originY, cellWidth/1.5, cellHeight/1.5);
            
            //[collectionViewCell.imageView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
            //[collectionViewCell.textLabel setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
            
            [collectionViewCell setFrame:currentViewFrame];
            [collectionViewCell setCenter:centerPoint];
            
            [collectionViewCell.layer setBorderWidth:2.0];
            [collectionViewCell.layer setCornerRadius:10.0];
            [collectionViewCell.layer setBorderColor:[[UIColor colorWithPatternImage:[UIImage imageNamed:@"Default@2x.png"]] CGColor]];
            
            ///
            //            CALayer *borderLayer = [CALayer layer];
            //            CGRect borderFrame = CGRectMake(0, 0, (collectionViewCell.frame.size.width), (collectionViewCell.frame.size.height));
            //            [borderLayer setBackgroundColor:[[UIColor clearColor] CGColor]];
            //            [borderLayer setFrame:borderFrame];
            //            [borderLayer setCornerRadius:10.0];
            //            [borderLayer setBorderWidth:5.0];
            //            [borderLayer setBorderColor:[[UIColor blackColor] CGColor]];
            //            [collectionViewCell.layer addSublayer:borderLayer];
            
            
            //            collectionViewCell.layer.masksToBounds = NO;
            //            collectionViewCell.layer.shadowOffset = CGSizeMake(15, 20);
            //            collectionViewCell.layer.shadowRadius = 5;
            //            collectionViewCell.layer.shadowOpacity = 0.5;
            ///
            
            self.currentView = [[UIView alloc] initWithFrame:collectionViewCell.frame];
            
            collectionViewCell.highlighted = YES;
            UIImageView *highlightedImageView = [[UIImageView alloc] initWithImage:[collectionViewCell LX_rasterizedImage]];
            highlightedImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            highlightedImageView.contentMode = UIViewContentModeCenter;
            highlightedImageView.alpha = 1.0f;
            
            collectionViewCell.highlighted = NO;
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[collectionViewCell LX_rasterizedImage]];
            imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            imageView.contentMode = UIViewContentModeCenter;
            imageView.alpha = 0.0f;
            
            [self.currentView addSubview:imageView];
            [self.currentView addSubview:highlightedImageView];
            [self.collectionView addSubview:self.currentView];
            
            self.currentViewCenter = self.currentView.center;
            
            __weak typeof(self) weakSelf = self;

            [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                
                 __strong typeof(self) strongSelf = weakSelf;

                if (strongSelf) {
                     strongSelf.currentView.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
                     highlightedImageView.alpha = 0.0f;
                     imageView.alpha = 1.0f;
                 }
             }
             completion:^(BOOL finished) {
                 __strong typeof(self) strongSelf = weakSelf;
                 if (strongSelf) {
                     [highlightedImageView removeFromSuperview];
                     
                   //  if ([strongSelf.delegate respondsToSelector:@selector(collectionView:layout:didBeginDraggingItemAtIndexPath:)]) {
                         [strongSelf.delegate BIcollectionView:strongSelf.collectionView layout:strongSelf didBeginDraggingItemAtIndexPath:strongSelf.selectedItemIndexPath];
                    // }
                 }
             }];
            
            [collectionViewCell setFrame:CGRectMake(cellX,cellY, cellWidth, cellHeight)];
            [collectionViewCell.layer setBorderWidth:0.0];
            [collectionViewCell.layer setCornerRadius:0.0];
            [collectionViewCell.layer setBorderColor:(__bridge CGColorRef)([UIColor clearColor])];
            
            [self invalidateLayout];
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            NSIndexPath *dragIndexPath = self.dragCellItemIndexPath;
            
            NSIndexPath *dropIndexPath = self.selectedItemIndexPath;
            
            if (dropIndexPath)
            {
               // if ([self.delegate respondsToSelector:@selector(collectionView:layout:willEndDraggingItemAtIndexPath:)]) {
                    
                   [self.delegate BIcollectionView:self.collectionView layout:self willEndDraggingItemAtIndexPath:dropIndexPath];
               // }
                
                if (self.isDropable)    //(dragIndexPath && ![dragIndexPath isEqual:dropIndexPath])
                {
                    NSLog(@"Dropable");
                    
                  //  BOOL fileExist = NO;
                   // if ([self.dataSource respondsToSelector:@selector(collectionView:itemAtIndexPath:willMoveToIndexPath:)]) {
                  //  fileExist =  [self.dataSource BIcollectionView:self.collectionView itemAtIndexPath:dragIndexPath fileExistAtIndexPath:dropIndexPath];
                  //  if (!fileExist)
                  //  {
                       // if ([self.dataSource respondsToSelector:@selector(BIcollectionView:itemAtIndexPath:willMoveToIndexPath:)]) {
                            
                            [self.dataSource BIcollectionView:self.collectionView itemAtIndexPath:dragIndexPath willMoveToIndexPath:dropIndexPath];
                       // }

                    
                    // [self.dataSource BIcollectionView:self.collectionView itemAtIndexPath:dragIndexPath willMoveToIndexPath:dropIndexPath];
                  //  }
                    
                    UICollectionViewCell *toCell = [self.collectionView cellForItemAtIndexPath:dropIndexPath];
                    [toCell.layer setBorderWidth:0.0];
                    [toCell.layer setCornerRadius:0.0];
                    [toCell.layer setBackgroundColor:[[UIColor clearColor] CGColor]];
                    [toCell.layer setBorderColor:[[UIColor whiteColor] CGColor]];
                    
                    [self.collectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:dragIndexPath]];
                    //[ self.dataSource BIcollectionView:self.collectionView itemAtIndexPath:dragIndexPath didMoveToIndexPath:dropIndexPath];
                }
                else
                {
                    NSLog(@"Not Dropable");
                }
                
                self.selectedItemIndexPath = nil;
                self.dragCellItemIndexPath = nil;
                self.currentViewCenter = CGPointZero;
                
                UICollectionViewLayoutAttributes *layoutAttributes = [self layoutAttributesForItemAtIndexPath:dropIndexPath];
                
                __weak typeof(self) weakSelf = self;
                
                [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                    
                    __strong typeof(self) strongSelf = weakSelf;
                    if (strongSelf)
                    {
                        strongSelf.currentView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                        strongSelf.currentView.center = layoutAttributes.center;
                    }
                }
                completion:^(BOOL finished)
                {
                     __strong typeof(self) strongSelf = weakSelf;
                     if (strongSelf) {
                         [strongSelf.currentView removeFromSuperview];
                         strongSelf.currentView = nil;
                         [strongSelf invalidateLayout];
                         
                        // if ([strongSelf.delegate respondsToSelector:@selector(collectionView:layout:didEndDraggingItemAtIndexPath:)])
                       //  {
                             [strongSelf.delegate BIcollectionView:strongSelf.collectionView layout:strongSelf didEndDraggingItemAtIndexPath:dropIndexPath];
                       //  }
                     }
                 }];
            }
            else
            {
                if ([self.delegate respondsToSelector:@selector(BIcollectionView:layout:willEndDraggingItemAtIndexPath:)])
                    [self.delegate BIcollectionView:self.collectionView layout:self willEndDraggingItemAtIndexPath:dropIndexPath];
                
                if ([self.delegate respondsToSelector:@selector(BIcollectionView:layout:didEndDraggingItemAtIndexPath:)])
                    [self.delegate BIcollectionView:self.collectionView layout:self didEndDraggingItemAtIndexPath:dropIndexPath];
            }
            
        } break;
            
        default: break;
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    //NSLog(@"BIDragDropCollectionViewFlowLayout handlePanGesture:");
    
    switch (gestureRecognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged:
        {
            self.panTranslationInCollectionView = [gestureRecognizer translationInView:self.collectionView];
            CGPoint viewCenter = self.currentView.center = LXS_CGPointAdd(self.currentViewCenter, self.panTranslationInCollectionView);
            
            [self invalidateLayoutIfNecessary]; //Flow Layout Changes Done here in this method
            
            switch (self.scrollDirection)
            {
                case UICollectionViewScrollDirectionVertical: {
                    if (viewCenter.y < (CGRectGetMinY(self.collectionView.bounds) + self.scrollingTriggerEdgeInsets.top)) {
                        [self setupScrollTimerInDirection:LXScrollingDirectionUp];
                    } else {
                        if (viewCenter.y > (CGRectGetMaxY(self.collectionView.bounds) - self.scrollingTriggerEdgeInsets.bottom)) {
                            [self setupScrollTimerInDirection:LXScrollingDirectionDown];
                        } else {
                            [self invalidatesScrollTimer];
                        }
                    }
                } break;
                case UICollectionViewScrollDirectionHorizontal: {
                    if (viewCenter.x < (CGRectGetMinX(self.collectionView.bounds) + self.scrollingTriggerEdgeInsets.left)) {
                        [self setupScrollTimerInDirection:LXScrollingDirectionLeft];
                    } else {
                        if (viewCenter.x > (CGRectGetMaxX(self.collectionView.bounds) - self.scrollingTriggerEdgeInsets.right)) {
                            [self setupScrollTimerInDirection:LXScrollingDirectionRight];
                        } else {
                            [self invalidatesScrollTimer];
                        }
                    }
                } break;
            }
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        {
            [self invalidatesScrollTimer];

        }
            break;
            
        default:
        {
            // Do nothing...
        }
            break;
    }
}

#pragma mark - UICollectionViewLayout overridden methods

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *layoutAttributesForElementsInRect = [super layoutAttributesForElementsInRect:rect];
    
    for (UICollectionViewLayoutAttributes *layoutAttributes in layoutAttributesForElementsInRect) {
        switch (layoutAttributes.representedElementCategory) {
            case UICollectionElementCategoryCell: {
                [self applyLayoutAttributes:layoutAttributes];
            } break;
            default: {
                // Do nothing...
            } break;
        }
    }
    
    return layoutAttributesForElementsInRect;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *layoutAttributes = [super layoutAttributesForItemAtIndexPath:indexPath];
    
    switch (layoutAttributes.representedElementCategory) {
        case UICollectionElementCategoryCell: {
            [self applyLayoutAttributes:layoutAttributes];
        } break;
        default: {
            // Do nothing...
        } break;
    }
    
    return layoutAttributes;
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
//    if ([self.panGestureRecognizer isEqual:gestureRecognizer]) {
//        return (self.selectedItemIndexPath != nil);
//    }
//    return YES;


    if ([gestureRecognizer class] == [UIPanGestureRecognizer class]) {
        
        return (self.selectedItemIndexPath != nil);
        
        return YES;
    }else if ([gestureRecognizer class] ==[UILongPressGestureRecognizer class]){
        
        return YES;
    }
    
    return NO;

}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([self.longPressGestureRecognizer isEqual:gestureRecognizer]) {
        return [self.panGestureRecognizer isEqual:otherGestureRecognizer];
    }
    
    if ([self.panGestureRecognizer isEqual:gestureRecognizer]) {
        return [self.longPressGestureRecognizer isEqual:otherGestureRecognizer];
    }
    
    return NO;
}

#pragma mark - Key-Value Observing methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:kBICollectionViewKeyPath]) {
        if (self.collectionView != nil) {
            [self setupCollectionView];
        } else {
            [self invalidatesScrollTimer];
        }
    }
}

#pragma mark - Depreciated methods

#pragma mark Starting from 0.1.0
- (void)setUpGestureRecognizersOnCollectionView {
    // Do nothing...
}

@end
