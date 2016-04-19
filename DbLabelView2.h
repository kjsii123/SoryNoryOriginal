//
//  DbLabelView2.h
//  SoryNoryFinal
//
//  Created by 권지수 on 2015. 7. 28..
//  Copyright (c) 2015년 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface DbLabelView2 : UIView{
    UILabel  *displayDb;
    CGPoint originXY;
    CGFloat test;
}
@property(nonatomic) bool isGraph;
@property(nonatomic) bool isTestSaved;

-(void) dealloc;
-(void)drawRect:(CGRect)rect;
- (CGSize)intrinsicContentSize;

@end
