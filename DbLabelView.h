//
//  DbLabelView.h
//  SoryNoryFinal
//
//  Created by 권지수 on 2015. 7. 8..
//  Copyright (c) 2015년 Mac. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface DbLabelView : UIView{
    UILabel  *displayDb;
    CGPoint originXY;
}


-(void) dealloc;
-(void)drawRect:(CGRect)rect;
- (CGSize)intrinsicContentSize;

@end
