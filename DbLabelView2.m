//
//  DbLabelView2.m
//  SoryNoryFinal
//
//  Created by 권지수 on 2015. 7. 28..
//  Copyright (c) 2015년 Mac. All rights reserved.
//

#import "DbLabelView2.h"
#import <Accelerate/Accelerate.h>
#import <CoreText/CoreText.h>


@implementation DbLabelView2

@synthesize isGraph;
@synthesize isTestSaved;

float dBlabelView2_isDevice(void)
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

-(void) commondBInit { // 각 변수들 초기화
    NSLog(@"this is labelview init");
    [self setBackgroundColor:[UIColor clearColor]];
    test = 0.0;
    isGraph = FALSE;
    isTestSaved = FALSE;
}
- (id)initWithFrame:(CGRect)frame // Frame initialize
{
    self = [super initWithFrame:frame];
    if (self) [self commondBInit]; // 일반 초기화
    return self;
}
- (id)initWithFrame:(CGRect)frame flag:(int)flag// Frame initialize
{
    self = [super initWithFrame:frame];
    if (self) [self commondBInit]; // 일반 초기화
    return self;
}
-(void)setdBLabel2 : (CGPoint) xyPoint flag : (int) flag
{
    if(isTestSaved == FALSE){
        NSString *y_label[13] = {@"10",@"0",@"-10",@"-20",@"-30",@"-40",@"-50",@"-60",@"-70",@"-80",@"-90",@"-100",@"-110"};
//        NSString *y_label[13] = {@"110",@"100",@"90",@"80",@"70",@"60",@"50",@"40",@"30",@"20",@"10",@"0",@"-10"};
        if(flag == 13){
            displayDb = [[UILabel alloc] initWithFrame:CGRectMake(3,-7, 30, 20)];
            [displayDb setText:[NSString stringWithFormat:@"dB"]];
            [displayDb setFont:[UIFont systemFontOfSize:15]];
            [displayDb setTextColor:[UIColor darkGrayColor]];
            [displayDb setTextAlignment:NSTextAlignmentCenter];
            [displayDb sizeToFit];
            //        printf("this is onemore time call\n");
        }else{
            displayDb = [[UILabel alloc] initWithFrame:CGRectMake(xyPoint.x,xyPoint.y-7, 30, 20)];
            [displayDb setText:[NSString stringWithFormat:@"%@",y_label[flag]]];
            [displayDb setFont:[UIFont systemFontOfSize:13]];
            [displayDb setTextColor:[UIColor blackColor]];
            //        [displayDb setTextAlignment:NSTextAlignmentCenter];
            [displayDb sizeToFit];
        }
//        NSLog(@"this value is %@",y_label[flag]);
    }else{
//        NSString *y_label[9] = {@"10",@"0",@"-10",@"-20",@"-30",@"-40",@"-50",@"-60",@"-70"};
//        if(flag == 9){
//            displayDb = [[UILabel alloc] initWithFrame:CGRectMake(3,-7, 30, 20)];
//            [displayDb setText:[NSString stringWithFormat:@"dB"]];
//            [displayDb setFont:[UIFont systemFontOfSize:15]];
//            [displayDb setTextColor:[UIColor darkGrayColor]];
//            [displayDb setTextAlignment:NSTextAlignmentCenter];
//            [displayDb sizeToFit];
//            //        printf("this is onemore time call\n");
//        }else{
//            displayDb = [[UILabel alloc] initWithFrame:CGRectMake(xyPoint.x,xyPoint.y-7, 30, 20)];
//            [displayDb setText:[NSString stringWithFormat:@"%@",y_label[flag]]];
//            [displayDb setFont:[UIFont systemFontOfSize:13]];
//            [displayDb setTextColor:[UIColor blackColor]];
//            //        [displayDb setTextAlignment:NSTextAlignmentCenter];
//            [displayDb sizeToFit];
//        }
//        NSLog(@"this value is %@",y_label[flag]);
        NSString *y_label[13] = {@"-10",@"0",@"10",@"20",@"30",@"40",@"50",@"60",@"70",@"80",@"90",@"100",@"110"};
//        NSString *y_label[13] = {@"110",@"100",@"90",@"80",@"70",@"60",@"50",@"40",@"30",@"20",@"10",@"0",@"-10"};
        if(flag == 13){
            displayDb = [[UILabel alloc] initWithFrame:CGRectMake(3,-7, 30, 20)];
            [displayDb setText:[NSString stringWithFormat:@"dB"]];
            [displayDb setFont:[UIFont systemFontOfSize:15]];
            [displayDb setTextColor:[UIColor darkGrayColor]];
            [displayDb setTextAlignment:NSTextAlignmentCenter];
            [displayDb sizeToFit];
            //        printf("this is onemore time call\n");
        }else{
            displayDb = [[UILabel alloc] initWithFrame:CGRectMake(xyPoint.x,xyPoint.y-7, 30, 20)];
            [displayDb setText:[NSString stringWithFormat:@"%@",y_label[flag]]];
            [displayDb setFont:[UIFont systemFontOfSize:13]];
            [displayDb setTextColor:[UIColor blackColor]];
            //        [displayDb setTextAlignment:NSTextAlignmentCenter];
            [displayDb sizeToFit];
        }


        
    }
    //            [displayLabel release];
}
-(void)drawRect:(CGRect)rect{
    
    Float32 isDeviceValue;
    CGSize realSize;
    CGPoint startPoint, tempPoint;
    
    isDeviceValue = dBlabelView2_isDevice();
    realSize = [self intrinsicContentSize]; // get real size
    
//    printf("\nLabelView commonInit realSize width : %f    height : %f\n\n",realSize.width,realSize.height);
//    printf("LabelView commonInit self width : %f    height : %f\n\n",self.frame.size.width,self.frame.size.height);
    tempPoint.x = realSize.width; // get max width
    tempPoint.y = realSize.height;  //get max height
    if(isGraph){startPoint.x  = 25;}
    else{startPoint.x = 0;}
    startPoint.y = 0;
    if(isTestSaved == FALSE){
        for(int i = 0; i< 14; i++){
            if( i  == 13 ){
                if(isGraph){
                    [self setdBLabel2:startPoint flag:i];
                    [self addSubview:displayDb];
                    [displayDb release];
                }
            }else{
                [self setdBLabel2:startPoint flag:i];
                [self addSubview:displayDb];
                [displayDb release];
            }
            //            if(i == 8) continue;
            startPoint.y += tempPoint.y / 13;
            
        }
    }else{
//        for(int i = 0; i< 10; i++){
//            if( i  == 9 ){
//                if(isGraph){
//                    [self setdBLabel2:startPoint flag:i];
//                    [self addSubview:displayDb];
//                    [displayDb release];
//                }
//            }else{
//                [self setdBLabel2:startPoint flag:i];
//                [self addSubview:displayDb];
//                [displayDb release];
//            }
//            //            if(i == 8) continue;
//            startPoint.y += tempPoint.y / 9;
//            
//        }
        
        for(int i = 0; i< 14; i++){
            if( i  == 13 ){
                if(isGraph){
                    [self setdBLabel2:startPoint flag:i];
                    [self addSubview:displayDb];
                    [displayDb release];
                }
            }else{
                [self setdBLabel2:startPoint flag:i];
                [self addSubview:displayDb];
                [displayDb release];
            }
            //            if(i == 8) continue;
            startPoint.y += tempPoint.y / 13;
            
        }


        
    }

}

-(void) dealloc {
    NSLog(@" LabelView DEALLOC");
    [super dealloc];
}
@end