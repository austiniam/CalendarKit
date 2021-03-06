////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  CALNavControllerTransition.m
//  iOS Tester
//
//  Created by Austin Cherry on 4/4/14.
//  Copyright (c) 2014 Vluxe. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Bunch of Ugly Apple test code. Need to clean up/change before releasing this out to people...

#import "CALTransitionController.h"

@interface CALTransitionController ()

@property (nonatomic) UICollectionViewTransitionLayout* transitionLayout;
@property (nonatomic) id <UIViewControllerContextTransitioning> context;
@property (nonatomic) CGFloat initialPinchDistance;

@end

@implementation CALTransitionController

////////////////////////////////////////////////////////////////////////////////////////////////////
-(instancetype)initWithCollectionView:(UICollectionView*)collectionView
{
    self = [super init];
    if (self) {
        UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
        [collectionView addGestureRecognizer:pinchGesture];
        self.collectionView = collectionView;
    }
    return self;
}
////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    
}
////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 1.0;
}
////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)startInteractiveTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    self.context = transitionContext;
    UICollectionViewController* fromCollectionViewController = (UICollectionViewController*)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UICollectionViewController* toCollectionViewController   = (UICollectionViewController*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    self.transitionLayout = [fromCollectionViewController.collectionView startInteractiveTransitionToCollectionViewLayout:toCollectionViewController.collectionViewLayout completion:^(BOOL didFinish, BOOL didComplete) {
        [_context.containerView addSubview:toCollectionViewController.view];
        [_context completeTransition:didComplete];
        
        if (didComplete)
            self.collectionView.delegate = toCollectionViewController;
        else
            self.collectionView.delegate = fromCollectionViewController;
        self.transitionLayout = nil;
        self.context = nil;
        self.hasActiveInteraction = FALSE;
    }];
}
////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)updateWithProgress:(CGFloat)progress
{
    if (_context==nil)
    {
        return;
    }
    
    if ((progress != self.transitionLayout.transitionProgress)) {
        [self.transitionLayout setTransitionProgress:progress];
        [self.transitionLayout invalidateLayout];
        [_context updateInteractiveTransition:progress];
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)endInteractionWithSuccess:(BOOL)success
{
    if (_context==nil)
    {
        self.hasActiveInteraction = FALSE;
        return;
    }
    if ((self.transitionLayout.transitionProgress > 0.5) && success)
    {
        [self.collectionView finishInteractiveTransition];
        [_context finishInteractiveTransition];
    }
    else
    {
        [self.collectionView cancelInteractiveTransition];
        [_context cancelInteractiveTransition];
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)handlePinch:(UIPinchGestureRecognizer*)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        [self endInteractionWithSuccess:TRUE];
        return;
    }
    
    if (sender.state == UIGestureRecognizerStateCancelled)
    {
        [self endInteractionWithSuccess:FALSE];
        return;
    }
    
    if (sender.numberOfTouches < 2)
    {
        return;
    }
    CGPoint point1 = [sender locationOfTouch:0 inView:sender.view];
    CGPoint point2 = [sender locationOfTouch:1 inView:sender.view];
    CGFloat distance = sqrt((point1.x - point2.x) * (point1.x - point2.x) + (point1.y - point2.y) * (point1.y - point2.y));
    CGPoint point = [sender locationInView:sender.view];
    
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        if (self.hasActiveInteraction)
        {
            return;
        }
        self.initialPinchDistance = distance;
        self.hasActiveInteraction = TRUE;
        [self.delegate interactionBeganAtPoint:point];
        return;
    }
    if (!self.hasActiveInteraction)
    {
        return;
    }
    
    if (sender.state == UIGestureRecognizerStateChanged)
    {
        CGFloat distanceDelta = distance - self.initialPinchDistance;
        if (self.navigationOperation == UINavigationControllerOperationPop)
        {
            distanceDelta = -distanceDelta;
        }
        CGFloat dimension = sqrt(self.collectionView.bounds.size.width*self.collectionView.bounds.size.width + self.collectionView.bounds.size.height*self.collectionView.bounds.size.height);
        CGFloat progress = MAX(MIN((distanceDelta / dimension), 1.0), 0.0);
        [self updateWithProgress:progress];
        return;
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////////s
@end
