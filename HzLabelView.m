//
//  HzLabelView.m
//  SoryNoryFinal
//
//  Created by 권지수 on 2015. 7. 8..
//  Copyright (c) 2015년 Mac. All rights reserved.
//

#import "HzLabelView.h"

#import <Accelerate/Accelerate.h>
#import <CoreText/CoreText.h>

@implementation HzLabelView

float labelView_isDevice(void)
{
    /*
     iPhone 4 : 960 * 640
     iPhone 5 :  1136 * 640
     iPhone 6 : 1334 * 750
     iPhone 6+ : 1920 * 1080
     */
    
    float isDeviceValue;
    if(CGSizeEqualToSize([[UIScreen mainScreen] preferredMode].size, CGSizeMake(640, 960))){
        isDeviceValue = 4;
    }else if(CGSizeEqualToSize([[UIScreen mainScreen] preferredMode].size, CGSizeMake(640, 1136))){
        isDeviceValue = 5;
    }else if(CGSizeEqualToSize([[UIScreen mainScreen] preferredMode].size, CGSizeMake(750 , 1334))){
        isDeviceValue = 6;
    }else{
        isDeviceValue = 6.5;
    }
    return isDeviceValue;
}

- (CGSize)intrinsicContentSize
{
    CGSize temp;
    temp.height  = self.frame.size.height;
    temp.width = self.frame.size.width;
    return temp;
}

-(void) commonInit { // 각 변수들 초기화
    NSLog(@"this is labelview init");
    [self setBackgroundColor:[UIColor clearColor]];
}
- (id)initWithFrame:(CGRect)frame // Frame initialize
{
    self = [super initWithFrame:frame];
    if (self) [self commonInit]; // 일반 초기화
    return self;
}
-(void)setLabel : (CGPoint) xyPoint flag : (int) flag
{
    NSString *x_label[8] = {@"125",@"250",@"500",@"1K",@"2K",@"4K",@"8K",@"10K"};
    if(flag == 8){
        displayHz = [[UILabel alloc] initWithFrame:CGRectMake(xyPoint.x,xyPoint.y+10, 30, 20)];
        [displayHz setText:[NSString stringWithFormat:@"Hz"]];
        [displayHz setFont:[UIFont systemFontOfSize:15]];
        [displayHz setTextColor:[UIColor darkGrayColor]];
        [displayHz setTextAlignment:NSTextAlignmentCenter];
        [displayHz sizeToFit];
    }else{
        displayHz  = [[UILabel alloc] initWithFrame:CGRectMake(xyPoint.x-5,xyPoint.y, 30, 20)];
        [displayHz setText:[NSString stringWithFormat:@"%@",x_label[flag]]];
        [displayHz setFont:[UIFont systemFontOfSize:13]];
        [displayHz setTextColor:[UIColor blackColor]];
        [displayHz setTextAlignment:NSTextAlignmentCenter];
        [displayHz sizeToFit];
    }
    //            [displayLabel release];
}
-(void)drawRect:(CGRect)rect{
    
    Float32 isDeviceValue;
    CGSize realSize;
    CGPoint startPoint, tempPoint;
    
    isDeviceValue = labelView_isDevice();
    realSize = [self intrinsicContentSize]; // get real size
    
    printf("\nLabelView commonInit realSize width : %f    height : %f\n\n",realSize.width,realSize.height);
    printf("LabelView commonInit self width : %f    height : %f\n\n",self.frame.size.width,self.frame.size.height);
    tempPoint.x = realSize.width; // get max width
    tempPoint.y = realSize.height;  //get max height
    startPoint.x  = tempPoint.x / 8;
    startPoint.y = 5;
    
    for(int i = 0; i< 9; i++){
        if(i == 8){
            [self setLabel:startPoint flag:i];
            [self addSubview:displayHz];
            [displayHz release];
        }else{
            [self setLabel:startPoint flag:i];
            [self addSubview:displayHz];
            [displayHz release];
            if(i == 7) continue;
            startPoint.x += (tempPoint.x / 8);
        }
    }
    
}

-(void) dealloc {
    NSLog(@" LabelView DEALLOC");
    [super dealloc];
}
@end


