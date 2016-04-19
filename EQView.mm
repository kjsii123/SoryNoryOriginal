//
//  EQView.m
//  SoryNoryFinal
//
//  Created by 권지수 on 2015. 7. 10..
//  Copyright (c) 2015년 Mac. All rights reserved.
//
// 여기는 좌표 반전 안줌 따라서 y좌표값에 -만 얹으면 됨
#import "EQView.h"
#import <QuartzCore/QuartzCore.h>

#define DRAW_X 1
#define DRAW_Y 2
#define DRAW_CURVE 3

static CGPoint midPoint(CGPoint p1, CGPoint p2, CGPoint divide)
{
    return CGPointMake((p1.x + p2.x) * 0.5, ((p1.y + p2.y) * 0.5));
//    return CGPointMake((p1.x + p2.x), (p1.y + p2.y));
}

static bool isIpad(void) {
    return [[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPad;
}

#define KNOB_AUTO_WIDTH (isIpad() ? KNOB_WIDTH_IPAD : KNOB_WIDTH )

@implementation EQMarkedKnob


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}


-(void) commonInit {    self.layer.masksToBounds = YES;
    self.backgroundColor = [UIColor whiteColor];
    
    if (isIpad()) {
        knobLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        knobLabel.backgroundColor = [UIColor clearColor];
        knobLabel.userInteractionEnabled = NO;
        knobLabel.minimumScaleFactor = 0.05;
        knobLabel.adjustsFontSizeToFitWidth = YES;
        knobLabel.font = [UIFont fontWithName:@"Verdana" size:22];
        knobLabel.text = @"0";
        knobLabel.textAlignment = NSTextAlignmentCenter;
        self.layer.cornerRadius = 22;
    } else {
        self.layer.cornerRadius = 10; // 모서리를 둥글게
        knobLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        knobLabel.backgroundColor = [UIColor clearColor];
        knobLabel.userInteractionEnabled = YES;
        knobLabel.minimumScaleFactor = 0.05;
        knobLabel.adjustsFontSizeToFitWidth = YES;
        knobLabel.font = [UIFont fontWithName:@"Verdana" size:22];  //fond size 10-> 22
        knobLabel.text = @"0";
        knobLabel.textAlignment = NSTextAlignmentCenter;
    }
    [self addSubview:[knobLabel autorelease]];
}



-(void) setKnobText:(NSString*) text {
    knobLabel.text = text;
    //    if (knobText!=nil) { [knobText release]; }
    //    knobText = [text retain];
}

-(NSString*) knobText {
    return knobLabel.text;
}

@end


@implementation EQView


@synthesize band1Vol, band2Vol, band3Vol, band4Vol, band5Vol, band6Vol, band7Vol, band8Vol, band9Vol, band10Vol;
@synthesize delegate;
@synthesize EQPresetID;

- (CGSize)intrinsicContentSize{
    CGSize temp;
    temp.height  = self.frame.size.height;
    temp.width = self.frame.size.width;
    return temp;
}

- (id)initWithFrame:(CGRect)frame
{      self = [super initWithFrame:frame];
    if (self) {
        firstDraw = TRUE;
//        [self commonInit2];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit2];
    }
    return self;
}


-(void) commonInit2 { // 이게 왜 2번 불리지??
//    self.backgroundColor = [UIColor grayColor];
    self.tag = 0;
    self.clipsToBounds = YES;
    [self addKnobs];
    self.exclusiveTouch = YES;
    self.EQPresetID = EQ_PRESET_ID_NONE;
}


-(void)setOrigin : (CGPoint *) tempPoint Start : (CGPoint *)startPoint  end : (CGPoint *)endPoint flag : (int) flag{
    
    switch (flag) {
        case DRAW_X:
            startPoint->x = 0;
            startPoint->y =-1;
//            tempPoint->y / 14.0;
            endPoint->x = tempPoint->x;
            endPoint->y = -1;
            break;
        case DRAW_Y:
            startPoint->x = tempPoint->x / 8.0;
            startPoint->y = 4;
            endPoint->x = tempPoint->x / 8.0;
            endPoint->y = tempPoint->y;
            break;
        case DRAW_CURVE:
            startPoint->x = tempPoint->x / 10;
            startPoint->y = tempPoint->y / 2;
//            endPoint->x = tempPoint ->
            break;
    }
}

-(float) eqisDevice{
    
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

-(CGPoint) eqfitDevice:(Float32) isDeviceValue realSize : (CGSize)realsize ctxRef : (CGContextRef) ctx{
    
    CGPoint tempPoint;
    if(isDeviceValue == 4){CGContextScaleCTM(ctx, 1.5, -1.5);
        
        tempPoint.x = realsize.width /1.5; // get max width
        tempPoint.y = realsize.height /1.5;  //get max height
        curve_divide.x = 1.5;
        curve_divide.y = 1.5;
//        printf("iphone 4\n");
    }//iphone 4
    else if(isDeviceValue == 5){CGContextScaleCTM(ctx, 1.5, -1.5);
        
        tempPoint.x = realsize.width / 1.5; // get max width
        tempPoint.y = realsize.height /1.5;  //get max height
        curve_divide.x = 1.5;
        curve_divide.y = 1.5;
//        printf("iphone 5\n");
    }// iphone 5
    else if(isDeviceValue == 6){CGContextScaleCTM(ctx, 2.5, -2.0);
        
        tempPoint.x = realsize.width / 2.5; // get max width
        tempPoint.y = realsize.height /2.0;  //get max height
        curve_divide.x = 2.5;
        curve_divide.y = 2.0;
//        printf("iphone 6\n");
    } //iphone 6
    //    else if(isDeviceValue == 6.5){ CGContextScaleCTM(ctx, 2.5, -2.5);
    else{
        CGContextScaleCTM(ctx, 2.5, -2.5);
        
        tempPoint.x = realsize.width / 2.5; // get max width
        tempPoint.y = realsize.height /2.5;  //get max height
        curve_divide.x = 2.5;
        curve_divide.y = 2.5;
//        printf("iphone 6+\n");
    }// iphone 6+
    
    return tempPoint;
}

-(void)eqdrawDottedLineFromStartingPoint:(CGPoint)startPoint ToEndPoint:(CGPoint)endPoint // 점선 그리기
{
    float isDeviceValue;
    isDeviceValue = [self eqisDevice];
    
    
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

-(void)drawRect:(CGRect)rect{
//    printf("EQView drawRect Start\n");
    Float32 isDeviceValue;
//    CGSize realSize;
    CGPoint startPoint, endPoint, tempPoint;
    
    isDeviceValue = [self eqisDevice];
    realSize = [self intrinsicContentSize]; // get real size
    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    CGContextTranslateCTM(ctx, 0, self.bounds.size.height); // 좌표 위아래 바꾸는거
    
//    realSize = [self intrinsicContentSize]; // get real size
     tempPoint = [self eqfitDevice:isDeviceValue realSize:realSize ctxRef:ctx];
    if(firstDraw == TRUE){
        [self commonInit2];
        firstDraw = FALSE;
    }
//    tempPoint = [self eqfitDevice:isDeviceValue realSize:realSize ctxRef:ctx];
    CGContextSetStrokeColorWithColor(ctx, [UIColor lightGrayColor].CGColor);
    
    [self setOrigin:&tempPoint Start:&startPoint end:&endPoint flag:DRAW_X]; // 스타트 포인트 지정
    
    x_interval = tempPoint.x / 8.0 - 0.02; // 간격 
    y_interval = tempPoint.y / 14.0;
    
    for(int i = 0; i < 14; i++){
        [self eqdrawDottedLineFromStartingPoint:startPoint ToEndPoint:endPoint]; // 점선 그리기-
        startPoint.y -= y_interval;
        endPoint.y -= y_interval;
    }
    
    // add 7/13
    //curve line
//    tempPoint.x = tempPoint.x /2.0;
//    tempPoint.y = tempPoint.y / 2.0;
    CGContextSetLineWidth(ctx, 3.0 );
    /*    CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
     CGContextSetFillColorWithColor(context, [UIColor lightGrayColor].CGColor); */
    CGContextSetStrokeColorWithColor(ctx, [UIColor grayColor].CGColor);
    CGContextSetFillColorWithColor(ctx, [UIColor grayColor].CGColor);
    CGPoint firstPoint = [self viewWithTag:1].center;
    
//    CGContextMoveToPoint(ctx, firstPoint.x, firstPoint.y);
//    //    CGContextStrokePath(context);
//    
//    for (int i=3; i<=NUMBER_OF_BANDS; i++) { // 버튼간 선을 연결해주는 부분인듯.
//        
//        CGPoint currentPoint = [self viewWithTag:i].center;
//        CGPoint prevPoint = [self viewWithTag:i-1].center;
//        CGPoint beforePrevPoint = [self viewWithTag:i-2].center;
//        
//        CGPoint mid1 = midPoint(beforePrevPoint, prevPoint);
//        CGPoint mid2 = midPoint(prevPoint, currentPoint);
//        //        CGContextMoveToPoint(context, mid1.x, mid1.y);
//        CGContextAddQuadCurveToPoint(ctx, mid1.x, mid1.y, mid1.x, mid1.y);
//        CGContextAddQuadCurveToPoint(ctx, prevPoint.x, prevPoint.y, mid2.x, mid2.y);
//    }
//    //viewWithTag : 파라미터로 넘긴 값과 일치한 뷰를 리턴
//    CGPoint lastPoint = [self viewWithTag:NUMBER_OF_BANDS].center;
//    //    CGContextMoveToPoint(context, lastPoint.x, lastPoint.y);
//    CGContextAddQuadCurveToPoint(ctx, lastPoint.x, lastPoint.y, lastPoint.x, lastPoint.y); // 이것이 곡선!
//    
//    CGContextStrokePath(ctx);

    firstPoint.x /= curve_divide.x;
    firstPoint.y /= -curve_divide.y;
    CGContextMoveToPoint(ctx, firstPoint.x, firstPoint.y);//    CGContextMoveToPoint(ctx, 0, 0);
//    CGPoint firstPoint = (realSize.width-KNOB_WIDTH*10) / NUMBER_OF_BANDS + (realSize.width -KNOB_WIDTH*10 + KNOB_WIDTH /2);
//    CGPoint firstPoint = tempPoint ;
    //    CGContextStrokePath(context);
//    printf("firstPoint x: %f y: %f\n",firstPoint.x,firstPoint.y);
    for (int i=3; i<=NUMBER_OF_BANDS; i++) { // 버튼간 선을 연결해주는 부분인듯.
        
        CGPoint currentPoint = [self viewWithTag:i].center;
        CGPoint prevPoint = [self viewWithTag:i-1].center;
        CGPoint beforePrevPoint =[self viewWithTag:i-2].center;
        
        currentPoint.x /=  curve_divide.x;
        currentPoint.y /= -curve_divide.y;
        prevPoint.x /= curve_divide.x;
        prevPoint.y /= -curve_divide.y;
        beforePrevPoint.x  /= curve_divide.x;
        beforePrevPoint.y /= -curve_divide.y;
        
        CGPoint mid1 = midPoint(beforePrevPoint, prevPoint,curve_divide);
        CGPoint mid2 = midPoint(prevPoint, currentPoint,curve_divide);
        
        CGContextAddQuadCurveToPoint(ctx, mid1.x, mid1.y, mid1.x, mid1.y);
        CGContextAddQuadCurveToPoint(ctx, prevPoint.x, prevPoint.y, mid2.x, mid2.y);
    }
    //viewWithTag : 파라미터로 넘긴 값과 일치한 뷰를 리턴
    CGPoint lastPoint = [self viewWithTag:NUMBER_OF_BANDS].center;
    //    CGContextMoveToPoint(context, lastPoint.x, lastPoint.y);
    lastPoint.x /= curve_divide.x;
    lastPoint.y /= -curve_divide.y;
    CGContextAddQuadCurveToPoint(ctx, lastPoint.x, lastPoint.y, lastPoint.x, lastPoint.y); // 이것이 곡선!
    CGContextStrokePath(ctx);
    
    printf("drawrect End\n");
//     add end 7/13
    
}
//-(void) drawLayer:(CALayer *)layer inContext:(CGContextRef)context {
//    
////    if(firstDraw == TRUE){
////        [self commonInit2];
////        firstDraw = FALSE;
////    }
//////      CGContextTranslateCTM(context, 0, self.bounds.size.height);
////    
////    CGContextSetStrokeColorWithColor(context, [UIColor clearColor].CGColor);
//    
//}
//add 7/13


-(void) displayKnobsAccordingToEqualizerValues:(Equalizer10Band *) equalizer{
    [self setKnobWithNumber:1 toValue:equalizer->band1Volume];
    [self setKnobWithNumber:2 toValue:equalizer->band2Volume];
    [self setKnobWithNumber:3 toValue:equalizer->band3Volume];
    [self setKnobWithNumber:4 toValue:equalizer->band4Volume];
    [self setKnobWithNumber:5 toValue:equalizer->band5Volume];
    [self setKnobWithNumber:6 toValue:equalizer->band6Volume];
    [self setKnobWithNumber:7 toValue:equalizer->band7Volume];
    [self setKnobWithNumber:8 toValue:equalizer->band8Volume];
    [self setKnobWithNumber:9 toValue:equalizer->band9Volume];
    [self setKnobWithNumber:10 toValue:equalizer->band10Volume];
    
    
}


-(void) setKnobWithNumber:(int) num toValue:(Float32) value {
    
    EQMarkedKnob *properKnob = nil;
    for (UIView *view in self.subviews) {
        if (view.tag==num && [view isKindOfClass:[EQMarkedKnob class]]) {
            properKnob = (EQMarkedKnob*) view;
            printf("this is for loop\n");
        }
    }
    if (properKnob==nil) { printf("this is nill\n");return; }
    else{
        printf("not nill\n");
    }
    
    Float32 yPos = (value / (KNOB_VALUE_MAX-KNOB_VALUE_MIN)) * (self.frame.size.height-properKnob.frame.size.height);
    yPos = (self.frame.size.height - yPos) -properKnob.frame.size.height/2.0; //...
    properKnob.center = CGPointMake(properKnob.center.x, yPos);
    
    if (num==1) { band1Vol = value; }
    if (num==2) { band2Vol = value; }
    if (num==3) { band3Vol = value; }
    if (num==4) { band4Vol = value; }
    if (num==5) { band5Vol = value; }
    if (num==6) { band6Vol = value; }
    if (num==7) { band7Vol = value; }
    if (num==8) { band8Vol = value; }
    if (num==9) { band9Vol = value; }
    if (num==10) { band10Vol = value; }
    // 이분에다가 Notification으로 넘기는걸 구현한 메소드 작성해주면 될듯.
    NSNumber *tagValue = [NSNumber numberWithInt:num];
    NSNumber *band = [NSNumber numberWithFloat:value];
    [self runNotif:tagValue andBandValue:band];
    [self setNeedsDisplay];
}



-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    //    touchedView = touch.view;
    CGPoint location = [touch locationInView:self];
    touchedView = self; // 뷰 전체를 터치뷰로! 그래야 스와이프적용되는듯.
    
    EQMarkedKnob *knob1 = (EQMarkedKnob*) [self viewWithTag:1];
    EQMarkedKnob *knob2 = (EQMarkedKnob*) [self viewWithTag:2];
    EQMarkedKnob *knob3 = (EQMarkedKnob*) [self viewWithTag:3];
    EQMarkedKnob *knob4 = (EQMarkedKnob*) [self viewWithTag:4];
    EQMarkedKnob *knob5 = (EQMarkedKnob*) [self viewWithTag:5];
    EQMarkedKnob *knob6 = (EQMarkedKnob*) [self viewWithTag:6];
    EQMarkedKnob *knob7 = (EQMarkedKnob*) [self viewWithTag:7];
    EQMarkedKnob *knob8 = (EQMarkedKnob*) [self viewWithTag:8];
    EQMarkedKnob *knob9 = (EQMarkedKnob*) [self viewWithTag:9];
    EQMarkedKnob *knob10 = (EQMarkedKnob*) [self viewWithTag:10];
    
    if (CGRectContainsPoint(knob1.frame, location)) { touchedView = knob1; }
    if (CGRectContainsPoint(knob2.frame, location)) { touchedView = knob2; }
    if (CGRectContainsPoint(knob3.frame, location)) { touchedView = knob3; }
    if (CGRectContainsPoint(knob4.frame, location)) { touchedView = knob4; }
    if (CGRectContainsPoint(knob5.frame, location)) { touchedView = knob5; }
    if (CGRectContainsPoint(knob6.frame, location)) { touchedView = knob6; }
    if (CGRectContainsPoint(knob7.frame, location)) { touchedView = knob7; }
    if (CGRectContainsPoint(knob8.frame, location)) { touchedView = knob8; }
    if (CGRectContainsPoint(knob9.frame, location)) { touchedView = knob9; }
    if (CGRectContainsPoint(knob10.frame, location)) { touchedView = knob10; }
}


-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    NSNumber *tagValue;
    NSNumber *band;
    if (touchedView!=nil) {
        UITouch *touch = [touches anyObject];
        CGFloat yShift = [touch previousLocationInView:self].y - [touch locationInView:self].y; // 아마도 y 축으로 이동할떄? -> 손으로 버튼을 스와이프할떄
        
        if (touchedView.tag>=1 && touchedView.tag<=NUMBER_OF_BANDS) { //touched a knob
            CGRect viewRect = touchedView.frame;
            
            if ( (viewRect.origin.y-yShift)<=0.0) { viewRect.origin.y = 0.0; }
            else if ( (viewRect.origin.y-yShift+KNOB_AUTO_WIDTH)>=self.frame.size.height) {
                viewRect.origin.y = self.frame.size.height-KNOB_AUTO_WIDTH;
            } else {
                viewRect.origin.y = viewRect.origin.y - yShift;;
            }
            touchedView.frame = viewRect;
            [self setNeedsDisplay];
            
            float bandValue = ( (self.frame.size.height-touchedView.center.y-touchedView.frame.size.height/2.0) / (self.frame.size.height-touchedView.frame.size.height) ) * (KNOB_VALUE_MAX-KNOB_VALUE_MIN);
            
            if (touchedView.tag==1) { band1Vol = bandValue; };
            if (touchedView.tag==2) { band2Vol = bandValue; };
            if (touchedView.tag==3) { band3Vol = bandValue; };
            if (touchedView.tag==4) { band4Vol = bandValue; };
            if (touchedView.tag==5) { band5Vol = bandValue; };
            if (touchedView.tag==6) { band6Vol = bandValue; };
            if (touchedView.tag==7) { band7Vol = bandValue; };
            if (touchedView.tag==8) { band8Vol = bandValue; };
            if (touchedView.tag==9) { band9Vol = bandValue; };
            if (touchedView.tag==10) { band10Vol = bandValue; };
            float yvalue = [touch locationInView:self].y; // y 좌표값  x 좌표값은 아마  [touch locationView:self].x 하면 얻을 듯
            yvalue = touchedView.center.y - KNOB_WIDTH/2.0; // 이것이 y 좌표값임 ! !
            tagValue = [NSNumber numberWithInt:touchedView.tag];
            band = [NSNumber numberWithFloat:bandValue];
            
            
//            eqViewDic = [NSDictionary dictionaryWithObjectsAndKeys:tagValue,@"tagValue",
//                         band,@"bandValue", nil];
            
            self.EQPresetID = EQ_PRESET_ID_NONE;
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"eqViewNotif"
//                                                                object:self
//                                                              userInfo:eqViewDic]; // 이부분을 메소드로, 파라미터 값은 tagValue, bandValue
            [self runNotif:tagValue andBandValue:band];
            
                NSLog(@" band1 = %f ", band1Vol);
                NSLog(@" band2 = %f ", band2Vol);
                NSLog(@" band3 = %f ", band3Vol);
                NSLog(@" band4 = %f ", band4Vol);
                NSLog(@" band5 = %f ", band5Vol);
                NSLog(@" band6 = %f ", band6Vol);
                NSLog(@" band7 = %f ", band7Vol);
                NSLog(@" band8 = %f ", band8Vol);
                NSLog(@" band9 = %f ", band9Vol);
                NSLog(@" band10 = %f ", band10Vol);
            
//            [delegate aBandKnobWithNumber:touchedView.tag valueChangedTo:bandValue];  //EQ뷰콘트롤러가 델리게이트에게 , 프로토콜에서 선언한 함수로, 이퀄의 태그와, 밴드가 게인값을 넘겨준다.
        }
    }
}


-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    touchedView = nil;
    //    NSLog(@" band1 = %f ", band1Vol);
    //    NSLog(@" band2 = %f ", band2Vol);ㅁ
    //    NSLog(@" band3 = %f ", band3Vol);
    //    NSLog(@" band4 = %f ", band4Vol);
    //    NSLog(@" band5 = %f ", band5Vol);
    //    NSLog(@" band6 = %f ", band6Vol);
    //    NSLog(@" band7 = %f ", band7Vol);
    //    NSLog(@" band8 = %f ", band8Vol);
    //    NSLog(@" band9 = %f ", band9Vol);
    //    NSLog(@" band10 = %f ", band10Vol);
    //
    //    NSLog(@"---------------------------------");
}

-(void) runNotif : (NSNumber *)tagValue andBandValue : (NSNumber *) band{
    
    printf("runNotif method\n");
    eqViewDic = [NSDictionary dictionaryWithObjectsAndKeys:tagValue,@"tagValue",
                 band,@"bandValue", nil];
    
    self.EQPresetID = EQ_PRESET_ID_NONE;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"eqViewNotif"
                                                        object:self
                                                      userInfo:eqViewDic];
    
}

#pragma mark helpers
-(void) addKnobs{
    /*
     initBandPassFilter(&EQDef->BPFilter1, sampleRate, 62.5, 187.5);  //중심주파수 125
     initBandPassFilter(&EQDef->BPFilter2, sampleRate, 187.5, 312.5); //250
     initBandPassFilter(&EQDef->BPFilter3, sampleRate, 437.5, 562.5); //500
     initBandPassFilter(&EQDef->BPFilter4, sampleRate, 937.5, 1062.5); //1000
     initBandPassFilter(&EQDef->BPFilter5, sampleRate, 1937.5, 2062.5); //2000
     initBandPassFilter(&EQDef->BPFilter6, sampleRate, 3937.5, 4062.5); //4000
     initBandPassFilter(&EQDef->BPFilter7, sampleRate, 5937.5, 6062.5); //6000
     initBandPassFilter(&EQDef->BPFilter8, sampleRate, 6937.5, 7062.5); //7000
     initBandPassFilter(&EQDef->BPFilter9, sampleRate, 7937.5, 8062.5); //8000
     initBandPassFilter(&EQDef->BPFilter10, sampleRate, 89375, 9062.5); //9000
     */

    
    printf("addknobs realsize : %f %f\n",realSize.width,realSize.height);
    printf("in addKnobs \n");
    if (isIpad()) {
        float spaceBetKnobs = (self.frame.size.width-KNOB_WIDTH_IPAD*10) / NUMBER_OF_BANDS;
        
        EQMarkedKnob *knobView1 = [[EQMarkedKnob alloc] initWithFrame:CGRectMake( (KNOB_WIDTH_IPAD+spaceBetKnobs)*0+spaceBetKnobs/2.0, self.frame.size.height/2.0-KNOB_WIDTH_IPAD/2.0, KNOB_WIDTH_IPAD, KNOB_WIDTH_IPAD)];
        knobView1.tag = 1;
        [knobView1 setKnobText:@"133"];
        [self addSubview:[knobView1 autorelease]];
        
        EQMarkedKnob *knobView2 = [[EQMarkedKnob alloc] initWithFrame:CGRectMake((KNOB_WIDTH_IPAD+spaceBetKnobs)*1+spaceBetKnobs/2.0, self.frame.size.height/2.0-KNOB_WIDTH_IPAD/2.0, KNOB_WIDTH_IPAD, KNOB_WIDTH_IPAD)];
        knobView2.tag = 2;
        [knobView2 setKnobText:@"375"];
        [self addSubview:[knobView2 autorelease]];
        
        EQMarkedKnob *knobView3 = [[EQMarkedKnob alloc] initWithFrame:CGRectMake( (KNOB_WIDTH_IPAD+spaceBetKnobs)*2+spaceBetKnobs/2.0, self.frame.size.height/2.0-KNOB_WIDTH_IPAD/2.0, KNOB_WIDTH_IPAD, KNOB_WIDTH_IPAD)];
        knobView3.tag = 3;
        [knobView3 setKnobText:@"750"];
        [self addSubview:[knobView3 autorelease]];
        
        EQMarkedKnob *knobView4 = [[EQMarkedKnob alloc] initWithFrame:CGRectMake( (KNOB_WIDTH_IPAD+spaceBetKnobs)*3+spaceBetKnobs/2.0, self.frame.size.height/2.0-KNOB_WIDTH_IPAD/2.0, KNOB_WIDTH_IPAD, KNOB_WIDTH_IPAD)];
        knobView4.tag = 4;
        [knobView4 setKnobText:@"1.5k"];
        [self addSubview:[knobView4 autorelease]];
        
        EQMarkedKnob *knobView5 = [[EQMarkedKnob alloc] initWithFrame:CGRectMake( (KNOB_WIDTH_IPAD+spaceBetKnobs)*4+spaceBetKnobs/2.0, self.frame.size.height/2.0-KNOB_WIDTH_IPAD/2.0, KNOB_WIDTH_IPAD, KNOB_WIDTH_IPAD)];
        knobView5.tag = 5;
        [knobView5 setKnobText:@"3k"];
        [self addSubview:[knobView5 autorelease]];
        
        EQMarkedKnob *knobView6 = [[EQMarkedKnob alloc] initWithFrame:CGRectMake( (KNOB_WIDTH_IPAD+spaceBetKnobs)*5+spaceBetKnobs/2.0, self.frame.size.height/2.0-KNOB_WIDTH_IPAD/2.0, KNOB_WIDTH_IPAD, KNOB_WIDTH_IPAD)];
        knobView6.tag = 6;
        [knobView6 setKnobText:@"5k"];
        [self addSubview:[knobView6 autorelease]];
        
        EQMarkedKnob *knobView7 = [[EQMarkedKnob alloc] initWithFrame:CGRectMake( (KNOB_WIDTH_IPAD+spaceBetKnobs)*6+spaceBetKnobs/2.0, self.frame.size.height/2.0-KNOB_WIDTH_IPAD/2.0, KNOB_WIDTH_IPAD, KNOB_WIDTH_IPAD)];
        knobView7.tag = 7;
        [knobView7 setKnobText:@"7k"];
        [self addSubview:[knobView7 autorelease]];
        
        EQMarkedKnob *knobView8 = [[EQMarkedKnob alloc] initWithFrame:CGRectMake( (KNOB_WIDTH_IPAD+spaceBetKnobs)*7+spaceBetKnobs/2.0, self.frame.size.height/2.0-KNOB_WIDTH_IPAD/2.0, KNOB_WIDTH_IPAD, KNOB_WIDTH_IPAD)];
        knobView8.tag = 8;
        [knobView8 setKnobText:@"9k"];
        [self addSubview:[knobView8 autorelease]];
        
        EQMarkedKnob *knobView9 = [[EQMarkedKnob alloc] initWithFrame:CGRectMake( (KNOB_WIDTH_IPAD+spaceBetKnobs)*8+spaceBetKnobs/2.0, self.frame.size.height/2.0-KNOB_WIDTH_IPAD/2.0, KNOB_WIDTH_IPAD, KNOB_WIDTH_IPAD)];
        knobView9.tag = 9;
        [knobView9 setKnobText:@"11k"];
        [self addSubview:[knobView9 autorelease]];
        
        
        EQMarkedKnob *knobView10 = [[EQMarkedKnob alloc] initWithFrame:CGRectMake( (KNOB_WIDTH_IPAD+spaceBetKnobs)*9+spaceBetKnobs/2.0, self.frame.size.height/2.0-KNOB_WIDTH/2.0, KNOB_WIDTH_IPAD, KNOB_WIDTH_IPAD)];
        knobView10.tag = 10;
        [knobView10 setKnobText:@"14k"];
        [self addSubview:[knobView10 autorelease]];
        
        knobView1.userInteractionEnabled = knobView2.userInteractionEnabled = knobView3.userInteractionEnabled = knobView4.userInteractionEnabled = knobView5.userInteractionEnabled = knobView6.userInteractionEnabled = knobView7.userInteractionEnabled = knobView8.userInteractionEnabled = knobView9.userInteractionEnabled = knobView10.userInteractionEnabled = YES;
        
        knobView9.userInteractionEnabled = YES;
        
    } else { //아이폰이면,
        // 여기서 실제 사이즈랑 매칭해야 할듯.
        
        printf("in addKnobs iphone\n");
//        float spaceBetKnobs = (realSize.width) / NUMBER_OF_BANDS;
//        printf("realsize.width / numberband : %f\n",spaceBetKnobs);
        float spaceBetKnobs = (realSize.width-KNOB_WIDTH*10) / NUMBER_OF_BANDS;
//        float spaceBetKnobs = (self.frame.size.width-KNOB_WIDTH*10) / NUMBER_OF_BANDS;
        EQMarkedKnob *knobView1 = [[EQMarkedKnob alloc] initWithFrame:CGRectMake((KNOB_WIDTH+spaceBetKnobs)*0+spaceBetKnobs/2.0, realSize.height/2.0-KNOB_WIDTH/2.0, KNOB_WIDTH, KNOB_WIDTH)];
        printf("knob_width+space  : %f\n",KNOB_WIDTH+spaceBetKnobs);
        printf("spaceBetKnobs/2.0: %f\n",spaceBetKnobs/2.0);
        printf("realSize.height/2.0 : %f\n",realSize.height/2.0);
        
        knobView1.tag = 1;
        [knobView1 setKnobText:@"125"];
        [self addSubview:[knobView1 autorelease]];
        
        EQMarkedKnob *knobView2 = [[EQMarkedKnob alloc] initWithFrame:CGRectMake((KNOB_WIDTH+spaceBetKnobs)*1+spaceBetKnobs/2.0, realSize.height/2.0-KNOB_WIDTH/2.0, KNOB_WIDTH, KNOB_WIDTH)];
        printf("init yvalue %f\n", realSize.height/2.0 - KNOB_WIDTH/2.0);
        printf("realsize.height : %f",realSize.height);
        knobView2.tag = 2;
        [knobView2 setKnobText:@"250"];
        [self addSubview:[knobView2 autorelease]];
        
         EQMarkedKnob *knobView3 = [[EQMarkedKnob alloc] initWithFrame:CGRectMake((KNOB_WIDTH+spaceBetKnobs)*2+spaceBetKnobs/2.0,realSize.height/2.0-KNOB_WIDTH/2.0, KNOB_WIDTH, KNOB_WIDTH)];
        knobView3.tag = 3;
        [knobView3 setKnobText:@"500"];
        [self addSubview:[knobView3 autorelease]];
        
        EQMarkedKnob *knobView4 = [[EQMarkedKnob alloc] initWithFrame:CGRectMake( (KNOB_WIDTH+spaceBetKnobs)*3+spaceBetKnobs/2.0, realSize.height/2.0-KNOB_WIDTH/2.0, KNOB_WIDTH, KNOB_WIDTH)];
        knobView4.tag = 4;
        [knobView4 setKnobText:@"1K"];
        [self addSubview:[knobView4 autorelease]];
        
        EQMarkedKnob *knobView5 = [[EQMarkedKnob alloc] initWithFrame:CGRectMake( (KNOB_WIDTH+spaceBetKnobs)*4+spaceBetKnobs/2.0, realSize.height/2.0-KNOB_WIDTH/2.0, KNOB_WIDTH, KNOB_WIDTH)];
        knobView5.tag = 5;
        [knobView5 setKnobText:@"2k"];
        [self addSubview:[knobView5 autorelease]];
        
        EQMarkedKnob *knobView6 = [[EQMarkedKnob alloc] initWithFrame:CGRectMake( (KNOB_WIDTH+spaceBetKnobs)*5+spaceBetKnobs/2.0, realSize.height/2.0-KNOB_WIDTH/2.0, KNOB_WIDTH, KNOB_WIDTH)];
        knobView6.tag = 6;
        [knobView6 setKnobText:@"4k"];
        [self addSubview:[knobView6 autorelease]];
        
        EQMarkedKnob *knobView7 = [[EQMarkedKnob alloc] initWithFrame:CGRectMake( (KNOB_WIDTH+spaceBetKnobs)*6+spaceBetKnobs/2.0, realSize.height/2.0-KNOB_WIDTH/2.0, KNOB_WIDTH, KNOB_WIDTH)];
        knobView7.tag = 7;
        [knobView7 setKnobText:@"6k"];
        [self addSubview:[knobView7 autorelease]];
        
        EQMarkedKnob *knobView8 = [[EQMarkedKnob alloc] initWithFrame:CGRectMake( (KNOB_WIDTH+spaceBetKnobs)*7+spaceBetKnobs/2.0, realSize.height/2.0-KNOB_WIDTH/2.0, KNOB_WIDTH, KNOB_WIDTH)];
        knobView8.tag = 8;
        [knobView8 setKnobText:@"7k"];
        [self addSubview:[knobView8 autorelease]];
        
        EQMarkedKnob *knobView9 = [[EQMarkedKnob alloc] initWithFrame:CGRectMake( (KNOB_WIDTH+spaceBetKnobs)*8+spaceBetKnobs/2.0, realSize.height/2.0-KNOB_WIDTH/2.0, KNOB_WIDTH, KNOB_WIDTH)];
        knobView9.tag = 9;
        [knobView9 setKnobText:@"8k"];
        [self addSubview:[knobView9 autorelease]];
        
        
        EQMarkedKnob *knobView10 = [[EQMarkedKnob alloc] initWithFrame:CGRectMake((KNOB_WIDTH+spaceBetKnobs)*9+spaceBetKnobs/2.0,realSize.height/2.0-KNOB_WIDTH/2.0, KNOB_WIDTH, KNOB_WIDTH)];
        
        knobView10.tag = 10;
        [knobView10 setKnobText:@"9k"];
        [self addSubview:[knobView10 autorelease]];
        
        knobView1.userInteractionEnabled = knobView2.userInteractionEnabled = knobView3.userInteractionEnabled = knobView4.userInteractionEnabled = knobView5.userInteractionEnabled = knobView6.userInteractionEnabled = knobView7.userInteractionEnabled = knobView8.userInteractionEnabled = knobView9.userInteractionEnabled = knobView10.userInteractionEnabled = YES;
        
        knobView9.userInteractionEnabled = YES;
    }
}


-(void) dealloc {
    self.delegate = nil;
    [super dealloc];
}
// end add 7/13
@end
