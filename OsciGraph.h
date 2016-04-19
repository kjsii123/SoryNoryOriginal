//
//  OsciGraph.h
//  SoryNoryFinal
//
//  Created by 권지수 on 2015. 7. 2..
//  Copyright (c) 2015년 Mac. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>




#define DATA_BUFFER_LEN  44100*10 //INT32_MAX //1024 //262144 // 65536 //16384

#define MODE_TIME_DOMAIN 0
#define MODE_FREQ_DOMAIN 1
#define MODE_POINT_DOMAIN 2
#define MODE_CURVE_DOMAIN 3
#define MODE_POINT_DOMAIN2 4

#define FULL_TO_UPDATE  512


@interface OsciGraph : UIView {
    
    
    Float32 mainDataBuffer[DATA_BUFFER_LEN];
    UInt32 bufferFillPosition;
    
    NSTimeInterval updateInterval;
    char currentMode;
    Float32 maxValue, minValue;
    
    BOOL isHorizontal;
    BOOL oneTime; //  0824 kjs add
    UILabel  *displayHz;
    Float32  HzValue;  //콜백함수로부터 넘겨받는 Hz실수값
    Float32 x_interval, y_interval;// 그래프 간격
    Float32 temp_val; //  그래프 눈금
    Float32 temp_val_y;
    
    NSMutableArray* decibelValue;
}

@property (assign) char currentMode;

-(void)setDecibelValue : (NSMutableArray *)data;


- (CGSize)intrinsicContentSize;
-(CGPoint) fitDevice:(Float32) isDeviceValue realSize : (CGSize)realSize ctxRef : (CGContextRef) ctx;
-(void)drawRect:(CGRect)rect;
-(void)drawDottedLineFromStartingPoint:(CGPoint)startPoint ToEndPoint:(CGPoint)endPoint;

///add new data (copy) to show and invoke it's display right away
-(void) addAndDrawData:(Float32*) dataToAdd lenght:(UInt32) len;
-(void) addAndDrawUILabelHz:(Float32) HZ; //yong added 8.14 for Hz display
///set max and min of the incoming data to show it properly
-(void) setDataMaxValue:(Float32) maxVal minValue:(Float32) minVal;


-(void) addData2:(Float32*) dataToAdd lenght:(UInt32) len;
-(void) addData:(Float32 *) dataToAdd length:(UInt32) len;

-(void) setUpdateInterval:(NSTimeInterval) interval;
- (void)printAllFontFamilyAndFonts;
- (void)drawCircle;
-(float)isDevice;
@end
