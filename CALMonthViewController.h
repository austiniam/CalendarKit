////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  CALMonthViewController.h
//  iOS Tester
//
//  Created by Austin Cherry on 3/28/14.
//  Copyright (c) 2014 Basement Krew. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////////////////////////

#import <UIKit/UIKit.h>
#import "CALBaseViewController.h"
#import "CALMonth.h"

@interface CALMonthViewController : CALBaseViewController

- (id)initWithMonth:(CALMonth *)month;

@end