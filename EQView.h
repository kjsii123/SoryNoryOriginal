//
//  EQView.h
//  SoryNoryFinal
//
//  Created by 권지수 on 2015. 7. 10..
//  Copyright (c) 2015년 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "OsciGraph.h"
#import "Equalizer10.h"



@interface EQMarkedKnob : UIView {
    
    //    NSString *knobText;
    UILabel *knobLabel;
//    UIButton *knobLabel;
}

-(void) setKnobText:(NSString*) text;
-(NSString*) knobText;

@end





#define NUMBER_OF_BANDS         10
#define KNOB_WIDTH              30 //22 -> 25 yong 8. 18 modified
#define KNOB_WIDTH_IPAD         44

#define KNOB_VALUE_MAX  5.0  //2.0 -> 5.0
#define KNOB_VALUE_MIN  0.0


#define EQ_PRESET_ID_NONE         0
#define EQ_PRESET_ID_BASSPLUSS    10
#define EQ_PRESET_ID_BASSMINUS    11
#define EQ_PRESET_ID_SPEECH       12


@protocol EQViewDelegate <NSObject>
-(void) aBandKnobWithNumber:(int) bandNumber valueChangedTo:(Float32) bandValue;
@end

@interface EQView : UIView{
    Float32 band1Vol, band2Vol, band3Vol, band4Vol, band5Vol, band6Vol, band7Vol, band8Vol, band9Vol, band10Vol;
    
    Float32 x_interval, y_interval;// 그래프 간격
    CGPoint curve_divide; // eqfitDevice메소드에서 늘어난만큼 줄여주기 위한 변수
    int touchedKnobTag;
    UIView *touchedView;
    CGSize realSize; // 실제 사이즈
    BOOL firstDraw; // realSize적용을 위해 첫 drawRect 일때만 초기화하기위해 선언
    id <EQViewDelegate> delegate;
    
    NSDictionary *eqViewDic;//notification에서 데이터 전송을 위한 딕셔너리 클래스 
    NSDictionary *eq10BandDic; // 이퀄라이저 값을 파일로 저장 하기 위한 딕셔너리
    
    
    char EQPresetID;
}



@property (assign) char EQPresetID;
@property (retain) id <EQViewDelegate> delegate;

@property (readonly) Float32  band1Vol;
@property (readonly) Float32  band2Vol;
@property (readonly) Float32  band3Vol;
@property (readonly) Float32  band4Vol;
@property (readonly) Float32  band5Vol;
@property (readonly) Float32  band6Vol;
@property (readonly) Float32  band7Vol;
@property (readonly) Float32  band8Vol;
@property (readonly) Float32  band9Vol;
@property (readonly) Float32  band10Vol;


-(void) displayKnobsAccordingToEqualizerValues:(Equalizer10Band *) equalizer;
-(void) setKnobWithNumber:(int) num toValue:(Float32) value;


@end
