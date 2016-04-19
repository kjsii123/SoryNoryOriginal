//
//  OsciGraph.m
//  SoryNoryFinal
//
//  Created by 권지수 on 2015. 7. 2..
//  Copyright (c) 2015년 Mac. All rights reserved.
//


#import "OsciGraph.h"

#import <Accelerate/Accelerate.h>
#import <CoreText/CoreText.h>


#define DEFAULT_UPDATE_INTERVAL 0.5
#define DEFAULT_MODE MODE_TIME_DOMAIN //MODE_FREQ_DOMAIN //MODE_TIME_DOMAIN
#define DEFAULT_HORIZONTAL_LAYOUT YES
#define DEFAULT_MAX_VALUE 1.0

#define DRAW_X 1
#define DRAW_Y 2
/*  */

//======================================================================================
//Detecting Frequency
//======================================================================================
#define SAMPLE_RATE 22050 //22050 //11025 //44100

const Float32 NyquistMaxFreq = SAMPLE_RATE/2.0;

//Float32 frequencyHerzValue(long frequencyIndex, long fftVectorSize, Float32 nyquistFrequency ) {
//    return ((Float32)frequencyIndex/(Float32)fftVectorSize) * nyquistFrequency;
//}

//static Float32 vectorMaxValueACC32(Float32 *vector, unsigned long size, long step) {
//    Float32 maxVal;
//    vDSP_maxv(vector, step, &maxVal, size);
//    return maxVal;
//}

static Float32 vectorMaxValueACC32_index(Float32 *vector, unsigned long size, long step, unsigned long *outIndex) {
    Float32 maxVal;
    vDSP_maxvi(vector, step, &maxVal, outIndex, size);
    return maxVal;
} //그냥 가저다 쓰면 되는 부분.




volatile BOOL allowDataCollect; // volatile 휘발성 예약어 (검색해보기), 중간에 값이 바뀌면 안되는 값은 vilotile로 선언하라는데..?


@implementation OsciGraph

@synthesize currentMode;
-(void)drawRect:(CGRect)rect // 이 부분에 좌표값 넣어서 그리기!
{
    
    int i;
    printf("drawRact\n");
    Float32 isDeviceValue;
    CGSize realSize;
    CGPoint startPoint, endPoint, tempPoint;
    
    isDeviceValue = [self isDevice];
    CGContextRef ctx = UIGraphicsGetCurrentContext();

        CGContextTranslateCTM(ctx, 0, self.bounds.size.height); // 좌표 위아래 바꾸는거
    realSize = [self intrinsicContentSize]; // get real size
    
    tempPoint = [self fitDevice:isDeviceValue realSize:realSize ctxRef:ctx];
    ///////////굵은 선 그리기
    [self graphLine:ctx point:tempPoint];
    
    CGContextSetStrokeColorWithColor(ctx, [UIColor lightGrayColor].CGColor);
    
    [self setOrigin:&tempPoint Start:&startPoint end:&endPoint flag:DRAW_X];
    ///////////////////////////////////////////////////////////////////////
    //if(mode_freq면)
    if(currentMode == MODE_FREQ_DOMAIN){
        
        x_interval = tempPoint.x / 8.0 - 0.02;
        y_interval = tempPoint.y / 14.0 - 0.02;
        
        
        temp_val = x_interval / 10.0;
        temp_val_y = y_interval / 10.0;
        
        for(i = 0; i < 14; i++){
            [self drawDottedLineFromStartingPoint:startPoint ToEndPoint:endPoint];
            startPoint.y += y_interval;
            endPoint.y += y_interval;
        }
        
        [self setOrigin:&tempPoint Start:&startPoint end:&endPoint flag:DRAW_Y];
        for(i = 0; i < 8; i++){
            [self drawDottedLineFromStartingPoint:startPoint ToEndPoint:endPoint];
            startPoint.x += x_interval;
            endPoint.x += x_interval;
        }

        
    }
    ///////////////////////////////////////////////////////////////////////
    else if(currentMode == MODE_POINT_DOMAIN2){
        x_interval = tempPoint.x / 7.0 - 0.02;
        y_interval = tempPoint.y / 13.0 - 0.02;
        
        
        temp_val = x_interval / 10.0;
        temp_val_y = y_interval / 10.0;
        
        for(i = 0; i < 13; i++){
            [self drawDottedLineFromStartingPoint:startPoint ToEndPoint:endPoint];
            startPoint.y += y_interval;
            endPoint.y += y_interval;
        }
        
        [self setOrigin:&tempPoint Start:&startPoint end:&endPoint flag:DRAW_Y];
        for(i = 0; i < 7; i++){
            [self drawDottedLineFromStartingPoint:startPoint ToEndPoint:endPoint];
            startPoint.x += x_interval;
            endPoint.x += x_interval;
        }
        
    }
    //여기부터
    else{
        x_interval = tempPoint.x / 8.0 - 0.02;
        y_interval = tempPoint.y / 9.0 - 0.02;
        
        
        temp_val = x_interval / 10.0;
        temp_val_y = y_interval / 10.0;
        printf("\n\n x_interval : %f   x_interval / 10 : %f\n\nf",x_interval, temp_val);
        for(i = 0; i < 9; i++){
            [self drawDottedLineFromStartingPoint:startPoint ToEndPoint:endPoint];
            startPoint.y += y_interval;
            endPoint.y += y_interval;
        }
        //    startPoint.x = tempPoint.x / 8.0;
        //    startPoint.y = 0;
        //    endPoint.x = tempPoint.x / 8.0;
        //    endPoint.y = tempPoint.y;
        printf("in oscigraph temp x : %f   temp y : %f\n\n",tempPoint.x/8,tempPoint.y/8);
        [self setOrigin:&tempPoint Start:&startPoint end:&endPoint flag:DRAW_Y];
        for(i = 0; i < 8; i++){
            [self drawDottedLineFromStartingPoint:startPoint ToEndPoint:endPoint];
            startPoint.x += x_interval;
            endPoint.x += x_interval;
        }
    }
    ////여기까지 else문으로 처리
}

-(void)drawDottedLineFromStartingPoint:(CGPoint)startPoint ToEndPoint:(CGPoint)endPoint // 점선 그리기
{
    float isDeviceValue;
    isDeviceValue = [self isDevice];
    
    
    UIBezierPath *path = [[UIBezierPath alloc] init];
    
    [path moveToPoint:startPoint];
    [path addLineToPoint:endPoint];
    path.lineWidth = 1;
    
    //    CGFloat dashes[] = {path.lineWidth * 0, path.lineWidth * 2};
    //
    //    [path setLineDash:dashes count:2 phase:0];
    CGFloat dashes[] = {path.lineWidth * 0, path.lineWidth * 2}; // 뒤에는 간격, 앞에는 얼마나 너부대대 한지
    
    [path setLineDash:dashes count:2 phase:0];
    path.lineCapStyle = kCGLineCapRound;
    //    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    
    
    [path stroke];
}
-(id) initWithCoder:(NSCoder *)aDecoder { // 파라미터 값은 unarchiver 객체
    self = [super initWithCoder:aDecoder]; // 디코더에 데이터를 이용하여 초기화
    if (self) {
        [self commonInit]; // 일반 초기화
    }
    return self;
}


-(float) isDevice{
    
    //BOOL isiPhone5 = CGSizeEqualToSize([[UIScreen mainScreen] preferredMode].size,CGSizeMake(640, 1136));
    //return isiPhone5;
    
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


- (id)initWithFrame:(CGRect)frame // Frame initialize
{
    printf("what?\n");
    self = [super initWithFrame:frame];
    printf("what?2\n");
    if (self) {
        printf("osci in if(self)\n");
        [self commonInit]; // 일반 초기화
        printf("thisi is initwithframe in oscigraph.m\n");
    }
    return self;
}
//get realsize method
- (CGSize)intrinsicContentSize{
    CGSize temp;
    temp.height  = self.frame.size.height;
    temp.width = self.frame.size.width;
    return temp;
}


-(void)setOrigin : (CGPoint *) tempPoint Start : (CGPoint *)startPoint  end : (CGPoint *)endPoint flag : (int) flag{
    
    switch (flag) {
        case DRAW_X:
            if(currentMode == MODE_FREQ_DOMAIN){
                startPoint->x = 4; // 굵은 선을 위해 4만큼 떨어저서 시작
                startPoint->y = tempPoint->y / 14.0;
                endPoint->x = tempPoint->x;
                endPoint->y = tempPoint->y / 14.0;
            }else if(currentMode == MODE_POINT_DOMAIN2){
                startPoint->x = 4; // 굵은 선을 위해 4만큼 떨어저서 시작
                startPoint->y = tempPoint->y / 13.0;
                endPoint->x = tempPoint->x;
                endPoint->y = tempPoint->y / 13.0;
            }
            else{
                startPoint->x = 4; // 굵은 선을 위해 4만큼 떨어저서 시작
                startPoint->y = tempPoint->y / 9.0;
                endPoint->x = tempPoint->x;
                endPoint->y = tempPoint->y / 9.0;
            }
            break;
        case DRAW_Y:
            if(currentMode == MODE_FREQ_DOMAIN){
                startPoint->x = tempPoint->x / 9.0;
                startPoint->y = 4; // 굵은 선을 위해 4만큼 떨어저서 시작
                endPoint->x = tempPoint->x / 9.0;
                endPoint->y = tempPoint->y;
            }else if(currentMode == MODE_POINT_DOMAIN2){
                startPoint->x = tempPoint->x / 7.0;
                startPoint->y = 4; // 굵은 선을 위해 4만큼 떨어저서 시작
                endPoint->x = tempPoint->x / 7.0;
                endPoint->y = tempPoint->y;
            }
            else{
                startPoint->x = tempPoint->x / 8.0;
                startPoint->y = 4; // 굵은 선을 위해 4만큼 떨어저서 시작
                endPoint->x = tempPoint->x / 8.0;
                endPoint->y = tempPoint->y;
            }
            break;
    }
    
}

-(void)graphLine:(CGContextRef)ctx point : (CGPoint) point{
    
    // x축 그리기 시작
    CGContextSetStrokeColorWithColor(ctx, [UIColor darkGrayColor].CGColor);
    
    CGContextSetLineWidth(ctx, 5.0);
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, 0, 0);
    CGContextAddLineToPoint(ctx, point.x, 0);
    CGContextStrokePath(ctx);
    // x축 그리기 끝
    // y축 그리기 시작
    CGContextSetLineWidth(ctx, 5.0);
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, 0, 0);
    CGContextAddLineToPoint(ctx, 0, point.y);
    CGContextStrokePath(ctx);
    // y축 그리기 끝
    
}

-(CGPoint) fitDevice:(Float32) isDeviceValue realSize : (CGSize)realSize ctxRef : (CGContextRef) ctx{
    
    CGPoint tempPoint;
    if(isDeviceValue == 4){CGContextScaleCTM(ctx, 1.5, -1.5);
        
        tempPoint.x = realSize.width / 1.5; // get max width
        tempPoint.y = realSize.height /1.5;  //get max height
        printf("iphone 4\n");
    }//iphone 4
    else if(isDeviceValue == 5){
        CGContextScaleCTM(ctx, 1.5, -1.5);
        
        tempPoint.x = realSize.width / 1.5; // get max width
        tempPoint.y = realSize.height /1.5;  //get max height
        printf("iphone 5\n");
    }// iphone 5
    else if(isDeviceValue == 6){CGContextScaleCTM(ctx, 2.5, -2.0);
        
        tempPoint.x = realSize.width / 2.5; // get max width
        tempPoint.y = realSize.height /2.0;  //get max height
        printf("iphone 6\n");
    } //iphone 6
    //    else if(isDeviceValue == 6.5){ CGContextScaleCTM(ctx, 2.5, -2.5);
    else{
        CGContextScaleCTM(ctx, 2.5, -2.5);
        
        tempPoint.x = realSize.width / 2.5; // get max width
        tempPoint.y = realSize.height /2.5;  //get max height
        printf("iphone 6+\n");
    }// iphone 6+
    
    return tempPoint;
}






-(void) commonInit { // 각 변수들 초기화
    
    decibelValue = [[NSMutableArray alloc]init];
    
    oneTime = YES;
    allowDataCollect = YES;
    currentMode = MODE_FREQ_DOMAIN;
    isHorizontal = YES;
    updateInterval = DEFAULT_UPDATE_INTERVAL;
    maxValue = DEFAULT_MAX_VALUE;
    memset(mainDataBuffer, 0, DATA_BUFFER_LEN*sizeof(Float32));
    self.backgroundColor = [UIColor clearColor];
    printf("osci : %f\n",maxValue);
    
    //    [self update];
}
- (void)printAllFontFamilyAndFonts // 사용할수 있는 폰트들을 log로 찍어서 보여주는 메소드
{
    //FontFamily
    NSArray *familyNames = [[NSArray alloc] initWithArray:[UIFont familyNames]]; // 지정된 배열(familyNames)에 객체를 배치하여 새롭게 할당 할 수 있도록 배열을 초기화
    //FontName
    NSArray *fontNames;
    NSInteger indFamily, indFont; //Integer 객체
    NSInteger fontsCount = [familyNames count]; // Font 갯수
    
    for (indFamily = 0; indFamily < fontsCount; ++indFamily) {
        NSLog (@"Family name: %@", [familyNames objectAtIndex:indFamily]); // objectAtIndex = set에 지정된 인덱스에 있는 객체를 리턴  파라미터 interger 객체
        fontNames = [[NSArray alloc] initWithArray:
                     [UIFont fontNamesForFamilyName:// 이 폰트 패밀리에서 사용할 수 있는 폰트들을 배열로  리턴
                      [familyNames objectAtIndex:indFamily]]];
        for (indFont = 0; indFont < [fontNames count]; ++indFont) {
            NSLog (@"    Font name: %@", [fontNames objectAtIndex:indFont]);
        }
        
    }
}

-(void) shiftCalcurator:(Float32)value inValueY:(Float32)y_value inContext : (CGContextRef) context Radius : (int) radius{
    int divide;
    Float32 x_point_value;
    Float32 y_point_value;
    Float32 shift; // 남은 이동 해야하는 간격값 저장
    Float32 y_shift;
    
    divide = y_value / 10;
    
    if(currentMode != MODE_POINT_DOMAIN2){
        if(divide <= 2){
            
            y_point_value = y_value /  2; // x_point_value 는 x축으로 몇 칸 이동할지 결정
            y_point_value = y_point_value * temp_val_y;
            
        }else{
            y_point_value = 10;
            y_shift = y_value  - 20;
            y_point_value = (y_point_value + y_shift) * temp_val_y;
        }
    }else{
        
        y_point_value = 10;
        y_shift = y_value  + 110;
//        y_shift = y_value - 20;
        printf("y_shift :  %f  y_value : %f\n",y_shift,y_value);
        y_point_value = (y_point_value + y_shift) * temp_val_y;
    
    }
    divide = value / 125;
    
    if(divide >= 80){
        printf("10k up value : %f   divide : %d\n",value,divide);
        
        x_point_value = 80;
        
        CGContextAddArc(context, temp_val*x_point_value, y_point_value, 3,0,2*3.1415926535898,1);
        CGContextDrawPath(context,kCGPathStroke);
    }
    else if(divide >= 64){
        printf("8k up value : %f   divide : %d\n",value,divide);
        
        x_point_value = 70;
        shift = value - 8000;
        x_point_value += shift / 200;
        
        CGContextAddArc(context, temp_val*x_point_value, y_point_value, 3,0,2*3.1415926535898,1);
        CGContextDrawPath(context,kCGPathStroke);
        
    }else if(divide >= 32){
        printf("4k up value : %f   divide : %d\n",value,divide);
        
        
        x_point_value = 60;
        shift = value - 4000;
        x_point_value += shift / 400;
        
        CGContextAddArc(context, temp_val*x_point_value, y_point_value, 3,0,2*3.1415926535898,1);
        CGContextDrawPath(context,kCGPathStroke);
        
        
    }else if(divide >= 16){
        printf("2k up value : %f   divide : %d\n",value,divide);
        
        x_point_value = 50;
        shift = value - 2000;
        x_point_value += shift / 200;
        
        CGContextAddArc(context, temp_val*x_point_value, y_point_value, 3,0,2*3.1415926535898,1);
        CGContextDrawPath(context,kCGPathStroke);
        
    }else if(divide >= 8){
        printf("1k up value : %f   divide : %d\n",value,divide);
        
        x_point_value = 40;
        shift = value - 1000;
        x_point_value += shift / 100;
        
        CGContextAddArc(context, temp_val*x_point_value, y_point_value, 3,0,2*3.1415926535898,1);
        CGContextDrawPath(context,kCGPathStroke);
        
    }else if(divide >= 4){
        printf("500k up value : %f  divide : %d\n",value,divide);
        
        x_point_value = 30;
        shift = value - 500;
        x_point_value += shift / 50;
        
        CGContextAddArc(context, temp_val*x_point_value, y_point_value, 3,0,2*3.1415926535898,1);
        CGContextDrawPath(context,kCGPathStroke);
        
    }else if(divide >= 2){
        printf("250 up value : %f  divide : %d\n",value,divide);
        
        x_point_value = 20;
        shift = value - 250;
        x_point_value += shift / 25;
        
        
        CGContextAddArc(context, temp_val*x_point_value, y_point_value, 3,0,2*3.1415926535898,1);
        CGContextDrawPath(context,kCGPathStroke);
        
    }else{
        printf("250 down value : %f  divide : %d\n",value,divide);
        x_point_value = value /  12.5; // x_point_value 는 x축으로 몇 칸 이동할지 결정
        CGContextAddArc(context, temp_val*x_point_value, y_point_value, 3,0,2*3.1415926535898,1);
        CGContextDrawPath(context,kCGPathStroke);
    }
    
    
}

-(void) drawLayer:(CALayer *)layer inContext:(CGContextRef)context {
    /*
     CALayer : 레이어 인스턴스 객체를 만들고 반환, 이미지 기반의 컨텐츠 관리하고 그 내용에 애니메이션 수행 가능
     CGContextRef :  2d 도면 환경을 나타내는 불투명한 객체
     */
    
    // NSLog(@" drawLayer mainT = %d", [NSThread isMainThread] );
    printf("drawlayer\n");
    allowDataCollect = NO; // Data type : BOOL
    
    float isDeviceValue = 0; // Device type
    
    NSNumber *number;
    [super drawLayer:layer inContext:context]; // 레이어의 내용을 그릴 수있는 대리자를 요청합니다.
    
    if (currentMode==MODE_TIME_DOMAIN) { // TIME_DOMAIN일 때
        
        CGContextSetLineWidth(context, 3.0);
        CGContextSetRGBStrokeColor(context, 255, 2, 1, 1);
        
        if (isHorizontal) {
            
            float x_shift = self.frame.size.width / bufferFillPosition;
            float y_middle = self.frame.size.height / 2.0;
            
            
            int step = 8;
            
            CGContextBeginPath(context);
            CGContextMoveToPoint(context, 0, y_middle);
            for (UInt32 i=0; i<bufferFillPosition; i=i+step) {
                if (maxValue==0 || x_shift==NAN || y_middle==NAN) { continue;
                    printf("in IF %f\n",x_shift);}
                CGContextAddLineToPoint(context, i*x_shift, y_middle+( (mainDataBuffer[i]/maxValue)*y_middle) );
                printf("timemode, i = %d    x_shift : %f    y_middle = %f   mainDataBuffer[%d] = %f    maxValue : %f\n",i,x_shift,y_middle,i,mainDataBuffer[i],maxValue);
            }
            CGContextStrokePath(context);
            
            
        } else {
            
        }
        
    }else if(currentMode == MODE_CURVE_DOMAIN){
        float x[9] = {80,190,390,550, 1124, 3050, 7100,8400,10000}; // 왼쪽 아래가 0,0
        float y[9] = {100,89, 93, 35, 62, 25, 53 , 47, 10};
        
        CGContextSetLineWidth(context, 5.0);
        CGContextSetStrokeColorWithColor(context, [UIColor orangeColor].CGColor);
        
        int radius = 3;
        printf("thisis curve domain\n");
        
        for(int i = 0; i<9;i++){
            [self shiftCalcurator:x[i] inValueY:y[i] inContext:context Radius:radius];
        }
    }else if(currentMode == MODE_POINT_DOMAIN ){ //SETUP - 내 청력검사 결과보기
        printf("this is point_domain\n");
        
        isDeviceValue =  [self isDevice];
        
        
        
        CGContextSetLineWidth(context, 5.0);
        CGContextSetStrokeColorWithColor(context, [UIColor orangeColor].CGColor);
        int radius = 3;
        
        // 임시 좌표들 나중에 dB로 변환해서 삽입!
        //        float x[8] = {0,20,40,60,80,100,120,140}; // 왼쪽 아래가 0,0
        //        float y[8] = {0,115,100,85,70,55,85,100};
        
                float x[9] = {80,190,390,550, 1124, 3050, 7100,8400,10000}; // 왼쪽 아래가 0,0
                 float y[9] = {100,50, 40, 30, 20, 10, 110 , 90, 80};
//        float x[7] = {125,250,500,1000, 2000, 4000, 8000};
        //        float y[13] = {100,50, 40, 30, 20, 10, 110 , 90, 80,70,60,120,130};
        //        float y[7] = {-110,-102.6,-89.24,-83.273,-70.2837,-63.329,-20.634};
//        float y[7];
//        for(int i = 0; i<9;i++){
//            number = [decibelValue objectAtIndex:i];
//            y[i] = [number floatValue];
//        }
        
        //test용 변수들
        //        Float32 x_test[8] = { 50, 140 , 270, 800, 1700, 3000,6000, 8300};
        //        Float32 x_test2[9] = {80,190,390,550, 1124, 3050, 7100,8400,10500};
        //test용 변수들 끝
        
        //        CGContextTranslateCTM(context, 0, self.bounds.size.height);   //-self.bounds.size.height  -넣으면 안보임. 문제 발생시 이거 보기
        
        
        //        if(isDeviceValue == 4){CGContextScaleCTM(context, 1.5, -2.0);}//iphone 4
        //        if(isDeviceValue == 5){CGContextScaleCTM(context, 2.0, -2.0);}// iphone 5
        //        else if(isDeviceValue == 6){CGContextScaleCTM(context, 2.5, -2.0);} //iphone 6
        //        else{CGContextScaleCTM(context, 3.0, -3.0);}// iphone 6+
        
        if(isHorizontal){ // 점 찍는 곳
            Float32 test; // 눈금 간격! 자로 치면 1cm 마다의 간격
            test = temp_val; // 눈금 간격을 저장
            Float32 y_point_value = 20;
            Float32 up_250value;
            for(int i = 0; i<9;i++){
                [self shiftCalcurator:x[i] inValueY:y[i] inContext:context Radius:radius];
            }
        }

        
    }else if (currentMode == MODE_POINT_DOMAIN2){ // 청력검사 후 나오는 결과 뷰
        printf("this is point_domain\n");
        
        isDeviceValue =  [self isDevice];
        
        
        
        CGContextSetLineWidth(context, 5.0);
        CGContextSetStrokeColorWithColor(context, [UIColor orangeColor].CGColor);
        int radius = 3;
        
        // 임시 좌표들 나중에 dB로 변환해서 삽입!
        //        float x[8] = {0,20,40,60,80,100,120,140}; // 왼쪽 아래가 0,0
        //        float y[8] = {0,115,100,85,70,55,85,100};
        
//        float x[9] = {80,190,390,550, 1124, 3050, 7100,8400,10000}; // 왼쪽 아래가 0,0
//         float y[9] = {100,50, 40, 30, 20, 10, 110 , 90, 80};
        float x[7] = {125,250,500,1000, 2000, 4000, 8000};
//        float y[13] = {100,50, 40, 30, 20, 10, 110 , 90, 80,70,60,120,130};
//        float y[7] = {-110,-102.6,-89.24,-83.273,-70.2837,-63.329,-20.634};
        float y[7];
        for(int i = 0; i<7;i++){
            number = [decibelValue objectAtIndex:i];
            y[i] = [number floatValue];
        }
        
        //test용 변수들
        //        Float32 x_test[8] = { 50, 140 , 270, 800, 1700, 3000,6000, 8300};
        //        Float32 x_test2[9] = {80,190,390,550, 1124, 3050, 7100,8400,10500};
        //test용 변수들 끝
        
        //        CGContextTranslateCTM(context, 0, self.bounds.size.height);   //-self.bounds.size.height  -넣으면 안보임. 문제 발생시 이거 보기
        
        
        //        if(isDeviceValue == 4){CGContextScaleCTM(context, 1.5, -2.0);}//iphone 4
        //        if(isDeviceValue == 5){CGContextScaleCTM(context, 2.0, -2.0);}// iphone 5
        //        else if(isDeviceValue == 6){CGContextScaleCTM(context, 2.5, -2.0);} //iphone 6
        //        else{CGContextScaleCTM(context, 3.0, -3.0);}// iphone 6+
        
        if(isHorizontal){ // 점 찍는 곳
            Float32 test; // 눈금 간격! 자로 치면 1cm 마다의 간격
            test = temp_val; // 눈금 간격을 저장
            Float32 y_point_value = 20;
            Float32 up_250value;
            for(int i = 0; i<7;i++){
                [self shiftCalcurator:x[i] inValueY:y[i] inContext:context Radius:radius];
            }
        }
    }else if (currentMode==MODE_FREQ_DOMAIN) {
        int Number;
        printf("this is FREQ_Domain\n");
        
        
        
        CGContextSetLineWidth(context, 10.0); //막대 그래프 두께
        //yong :    CGContextSetRGBStrokeColor(context, 255, 255, 255, 10);
        CGContextSetStrokeColorWithColor(context, [UIColor yellowColor].CGColor);
        if (isHorizontal) {
            
            float x_shift = self.frame.size.width / bufferFillPosition;
//            float x_shift = x_interval;
            //     printf("bufferFillPosition=%d",(unsigned int) bufferFillPosition);
            //     float y_middle = self.frame.size.height; // / 2.0;
            float y_axis = self.frame.size.height;
            //            printf("bufferFillPosition = %d \n",(unsigned int)bufferFillPosition);
            //            printf(" frame.size.width=%f\n, frame.size.height=%f\n", self.frame.size.width, self.frame.size.height);
            //            printf(" x_shift=%f, y_axis=%f\n", x_shift , y_axis);
            //  CGContextBeginPath(context);
            
            
            //[self displayHz];
            //    [self printAllFontFamilyAndFonts];
            //폰트설정 시작
            CTFontRef font = CTFontCreateWithName(CFSTR("AppleSDGothicNeo-Thin"), 16, NULL);
            CFStringRef keys[] = { kCTFontAttributeName };
            
            CFTypeRef values[] = { font };
            
            CFDictionaryRef font_attributes = CFDictionaryCreate(kCFAllocatorDefault, (const void **)&keys, (const void **)&values, sizeof(keys) / sizeof(keys[0]), &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
            
            //     CFRelease( "Verdana" ); //font_name AppleSDGothicNeo-Thin
            
            CFRelease(font);
            //폰트 설정 끝
            
            
            
            NSString *str = [NSString stringWithFormat:@"%4.0f Hz",  HzValue];
            
            const char *text = [str UTF8String]; // c문자열로의 표현을 리턴
            
            CFStringRef string = CFStringCreateWithCString(NULL, text, kCFStringEncodingMacRoman);
            
            CFAttributedStringRef attr_string = CFAttributedStringCreate(NULL, string, font_attributes);
            
            CTLineRef line = CTLineCreateWithAttributedString(attr_string);
            //yong added 8.18
            BOOL isiPhone5 = CGSizeEqualToSize([[UIScreen mainScreen] preferredMode].size,CGSizeMake(640, 1136));
            
            if (isiPhone5==NO) { //아이폰4이면,
                CGContextSetTextPosition(context, 210 , 2);  //좌표값  //iphone 4 inch 기존, 3.5인치에서는 새로 맞추어야함.
                
            } else { //아이폰5이면,
                CGContextSetTextPosition(context, 210 , 2);  //좌표값  //iphone 4 inch 기존, 3.5인치에서는 새로 맞추어야함.
                
                
            }
            //end
            
            
            // Core Text uses a reference coordinate system with the origin on the bottom-left
            // flip the coordinate system before drawing or the text will appear upside down
            /* UIView는   upper left,, coregrahics bottom-left
             */
            //      CGContextSelectFont("Helvetica", 25, kCGEncodingMacRoman);
            
            
//            CGContextTranslateCTM(context, self.bounds.size.width, self.bounds.size.height);   //-self.bounds.size.height  -넣으면 안보임.
//            CGContextScaleCTM(context, 1.0, -1.0);
            
            CTLineDraw(line, context);
            
            CFRelease(line);
            
            CFRelease(string);
            
            CFRelease(attr_string);
            
            //     CGContextRestoreGState(context);
            
            
            
            
            CGContextBeginPath(context);
            
            //6 CGContextSetLineWidth(ctx, 5);
            //      CGContextAddArc(context, 0, 0, 10.0, 0, 2*M_PI, 0);
            //      CGContextStrokePath(context);
            
            
            //  CGContextMoveToPoint(context, 30, 10); //0-> 10
            
            int step = 12;  // 12 -> 막대그래프 갯수
            int i_interval = bufferFillPosition/step;
            printf("i_interval : %d\n",i_interval);
//            printf("this is bufferposition : %u\n",(unsigned int)bufferFillPosition);
//            for(UInt32 i= 0; i<bufferFillPosition; i = i+step){ // 원본 
            for (UInt32 i=0; i<bufferFillPosition; i=i+i_interval) {
                
                if (maxValue==0 || x_shift==NAN || y_axis==NAN) { continue; } // 걸른다. NAN은 실수타입,  //y_middle -> y_axis
                
                //getting max
                Float32 max = 0;
                UInt32 length = (UInt32)step;
                vDSP_maxv(mainDataBuffer+i, 1, &max, length); //vector의 최대값 max 가져온다. //vDSP_maxv(vector, step, &maxVal, size);
                //    printf("mainDataBuffer+i= %f, max = %f ", mainDataBuffer+i , max );
                
                /* 주파수 변환 */
                
                //           UInt32 length = frameSize/2.0;
                //     fftData[0] = 0.0;  //초기값
                //  vDSP_maxv(fftData, 1, &fftMaxVal, length);  //fftMaxVal를 번지값으로 넘겨 받으면, 값을 받는다. length도 받는다.
                //printf("결과값:  fftMaxVal = %g \n ",   fftMaxVal  );
                
                
                
                unsigned long maxIndex = 0;
                //                Float32 fftMaxVal = 0; //초기값 초기화
                //                fftMaxVal = vectorMaxValueACC32_index(mainDataBuffer+i, length, 1, &maxIndex);  //벡터데이터, 길이  넣어주고,  최대인덱스와 실수 max값 가져온다.
                // if (freqValue!=NULL) { *freqValue = max; }
                //                Float32 HZ = frequencyHerzValue(maxIndex, length, NyquistMaxFreq);
                
                //    printf("\n결과값: i=%d:  fftMaxVal = %g , maxIndex= %ld HZ = %f  ",  i,  fftMaxVal, maxIndex, HZ ); //fftMaxVal과 max는 결과가 같다.
                
                /* static Float32 vectorMaxValueACC32_index(Float32 *vector, unsigned long size, long step, unsigned long *outIndex) {
                 Float32 maxVal;
                 vDSP_maxvi(vector, step, &maxVal, outIndex, size);  // Maximum value of vector, with index
                 
                 유사함: vDSP_maxv(fftData, 1, &fftMaxVal, length);  //fftMaxVal를 번지값으로 넘겨 받으면, 값을 받는다. length도 받는다.
                 
                 return maxVal;
                 } */
                
                
                /* 주파수 변환 */
                
                
                //printf("\n i=%d, getting max from vDSP_maxv( &max= %f )", i, max);
                
                //   CGContextMoveToPoint(context,  i*x_shift, y_middle);  //x 좌표를 12.5씩 증감해서, 해당 포인트로 이동하고,
                //                CGContextMoveToPoint(context,  50 + i*x_shift, 46);
                CGContextMoveToPoint(context,  x_interval + (i*x_shift), 4);
//                 CGContextMoveToPoint(context,  i*x_shift, 46); kjs
                //  printf("MoveToPoint: x, y = ( %f, %f )\n", i*x_shift, 0.0 ); //y_middle -> y_axis
                
                //  CGContextAddLineToPoint(context, i*x_shift, y_axis-( (max/maxValue)*y_axis) );  // 막대 그래프를 그린다.  //y_middle -> y_axis
                
                //                CGContextAddLineToPoint(context, 50 + i*x_shift, 46+ ( (max/maxValue)*y_axis) );
//                CGContextAddLineToPoint(context,i*x_shift,46 + ( (max/maxValue)*y_axis) );kjs
                CGContextAddLineToPoint(context,x_interval + (i*x_shift),4 + ( (max/maxValue)*y_axis) );
//                Float32 y = ((max/maxValue)*y_axis);
                //  printf("\nHz = %f, max=%2.2f, maxValue=%2.2f, y=%2.2f  ", HzValue, max, maxValue, y );
                //   CGContextAddLineToPoint(context, i*x_shift, ( (max/maxValue)*y_middle) );  //y_middle -> y_axis
                //   printf("max=%f, maxValue=%f   ", max, maxValue   );
                // printf("AddLineToPoint: i= %d, x, y = ( %f, %f )\n", i, i*x_shift, y_axis-( (max/maxValue)*y_axis) ); //y_middle -> y_axis
                printf("i is : %d\n",i);
                
            }
            //test for me
            
            
            CGContextStrokePath(context);
            //
            
            //NSLog(@" drawLayer FINISH");
        }
    }
    
    bufferFillPosition = 0;
    memset(mainDataBuffer, 0, DATA_BUFFER_LEN);
    allowDataCollect = YES;
}

- (void)drawCircle
{
    
}
-(void) addAndDrawData:(Float32*) dataToAdd lenght:(UInt32) len {
    // 데이타, 길이?
    //Float32 fftData[7]= {30,40,50,60,70,80,90}-> dataToAdd length = 256/2.0 -> len
    //len = 512;
    printf("addAndDrawData start\n");
    if (allowDataCollect==YES) {
        //        printf("before \ndataToAdd %f \n mainDataBuffer %f \n bufferFillPosition %d\n",*dataToAdd,*mainDataBuffer,  bufferFillPosition);
        memmove(mainDataBuffer+bufferFillPosition, dataToAdd, (size_t)len*sizeof(Float32));//memmove : c라이브러리
        // (size_t)len*sizeof(Float32) 바이트만큼 dataToAdd에서 mainDataBuffer + bufferFillPositon으로 복사(mainDataBuffer를 bufferFillPosition만큼 이동한곳에 복사 한다는 뜻)
        bufferFillPosition = bufferFillPosition+len;
        allowDataCollect=NO;
        [self.layer setNeedsDisplay]; // 레이어를 아마 하나더 만들어서 업데이트 하는 것인듯?(ex 포토샵 layer)
        
    }
    printf("addAndDrawData end\n");
}
-(void) addAndDrawUILabelHz:(Float32) HZ {
    
    
    
    HzValue = HZ   ;
    
    
    [self.layer setNeedsDisplay];
    
}
-(void) displayHz{
    
    displayHz.textColor =[UIColor blackColor];
    displayHz.text = [NSString stringWithFormat:@"%f", HzValue]; // Hz를 라벨에 표시
    //NSLog(@"HzValue = %f", HzValue);
}



-(void) addData2:(Float32*) dataToAdd lenght:(UInt32) len {
    if (allowDataCollect==YES) {
        memmove(mainDataBuffer+bufferFillPosition, dataToAdd, (size_t)len*sizeof(Float32));
        bufferFillPosition = bufferFillPosition+len;
        if (bufferFillPosition>=FULL_TO_UPDATE) { allowDataCollect=NO; [self.layer setNeedsDisplay]; }
    }
}




-(void) addData:(Float32 *) dataToAdd length:(UInt32) len {
    if (len+bufferFillPosition<=DATA_BUFFER_LEN && allowDataCollect==YES) {
        //        printf(" \n adding data..");
        memmove(mainDataBuffer+bufferFillPosition, dataToAdd, (size_t)len*sizeof(Float32));
        bufferFillPosition = bufferFillPosition+len;
    } else { //printf(" \n overflow mainT = %d", [NSThread isMainThread] );
    }
}

-(void) setUpdateInterval:(NSTimeInterval) interval {
    updateInterval = interval;
}


-(void) setDataMaxValue:(Float32) maxV minValue:(Float32) minV {
    maxValue = maxV; minValue = minV;
}

-(void) update {
    [self.layer setNeedsDisplay];
    [self performSelector:@selector(update) withObject:nil afterDelay:updateInterval];
}

-(void)setDecibelValue : (NSMutableArray *)data
{
    decibelValue = data;
}

-(void) dealloc {
    NSLog(@" osciGraph DEALLOC");
    [super dealloc];
}




@end


