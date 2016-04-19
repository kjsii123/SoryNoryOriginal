//
//  ManuallySettingViewController.m
//  SoryNoryFinal
//
//  Created by 권지수 on 2015. 7. 10..
//  Copyright (c) 2015년 Mac. All rights reserved.
//
// 버튼 눌럿을때 이미지 바꾸기 구현
#import "ManuallySettingViewController.h"

#define SAMPLE_RATE 22050 //22050 //11025 //44100

Equalizer10Band theEqualizer10;

@interface ManuallySettingViewController ()

@end

@implementation ManuallySettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    printf("ManuallySettingViewController viewDidLoad start\n");
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
    
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
    // 7/13 add
//    initializeEqualizer10Band(&theEqualizer10, SAMPLE_RATE, 1);
    // 7/13 add end
    
    equalizerView = [[EQView alloc]initWithFrame:CGRectMake(0, 0, eqGraphViewContainer.frame.size.width, eqGraphViewContainer.frame.size.height)];
    equalizerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    CGContextTranslateCTM(ctx, 0, equalizerView.bounds.size.height); // 좌표 위아래 바꾸는거 // 추가
    [eqGraphViewContainer addSubview:[equalizerView autorelease]];
     equalizerView.exclusiveTouch = YES; //리시버가 터치이벤트를 독점적으로 처리할것인지 여부를 나타내는 BOOL 값.
    
    initializeEqualizer10Band(&theEqualizer10, SAMPLE_RATE, 4.5);
//    [equalizerView displayKnobsAccordingToEqualizerValues:&theEqualizer10];
    printf("Menually viewdidload\n");
}
-(void)viewDidLayoutSubviews{
    
    NSArray *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentRootPath = [documentPath objectAtIndex:0];
    
    NSString *stringFilaPath = [documentRootPath stringByAppendingPathComponent:@"EQValue.plist"];
    
    NSDictionary *eqValueDic = [[NSDictionary alloc] initWithContentsOfFile:stringFilaPath];
    
    
    if(eqValueDic){
        NSLog(@"Succed Load File");
        NSArray *bandValueArray2 = [eqValueDic objectForKey:@"bandValueArray"];
        NSLog(@"load value is %@",bandValueArray2);
        
        NSNumber *band1Value = [bandValueArray2 objectAtIndex:0];
        NSNumber *band2Value = [bandValueArray2 objectAtIndex:1];
        NSNumber *band3Value = [bandValueArray2 objectAtIndex:2];
        NSNumber *band4Value = [bandValueArray2 objectAtIndex:3];
        NSNumber *band5Value = [bandValueArray2 objectAtIndex:4];
        NSNumber *band6Value = [bandValueArray2 objectAtIndex:5];
        NSNumber *band7Value = [bandValueArray2 objectAtIndex:6];
        NSNumber *band8Value = [bandValueArray2 objectAtIndex:7];
        NSNumber *band9Value = [bandValueArray2 objectAtIndex:8];
        NSNumber *band10Value = [bandValueArray2 objectAtIndex:9];
        
        theEqualizer10.band1Volume = [band1Value floatValue];
        theEqualizer10.band2Volume = [band2Value floatValue];
        theEqualizer10.band3Volume = [band3Value floatValue];
        theEqualizer10.band4Volume = [band4Value floatValue];
        theEqualizer10.band5Volume = [band5Value floatValue];
        theEqualizer10.band6Volume = [band6Value floatValue];
        theEqualizer10.band7Volume = [band7Value floatValue];
        theEqualizer10.band8Volume = [band8Value floatValue];
        theEqualizer10.band9Volume = [band9Value floatValue];
        theEqualizer10.band10Volume = [band10Value floatValue];
        
        
    }else{
        NSLog(@"Dont Load FIle");
    }
    
    
    if(self.isBeingDismissed){
        NSLog(@"isBeingDismissed");
    }
    else{
        [equalizerView displayKnobsAccordingToEqualizerValues:&theEqualizer10];
        printf("ViewDidLayoutSubviews\n");
    }
    [super viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
    return NO; //-- for presented controller use YES
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape; //-- any orientation you need
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeLeft;
}
- (void)viewDidDisappear:(BOOL)animated
{
//    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
//    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
    NSNumber *band1Value = [NSNumber numberWithFloat:equalizerView.band1Vol];
    NSNumber *band2Value = [NSNumber numberWithFloat:equalizerView.band2Vol];
    NSNumber *band3Value = [NSNumber numberWithFloat:equalizerView.band3Vol];
    NSNumber *band4Value = [NSNumber numberWithFloat:equalizerView.band4Vol];
    NSNumber *band5Value = [NSNumber numberWithFloat:equalizerView.band5Vol];
    NSNumber *band6Value = [NSNumber numberWithFloat:equalizerView.band6Vol];
    NSNumber *band7Value = [NSNumber numberWithFloat:equalizerView.band7Vol];
    NSNumber *band8Value = [NSNumber numberWithFloat:equalizerView.band8Vol];
    NSNumber *band9Value = [NSNumber numberWithFloat:equalizerView.band9Vol];
    NSNumber *band10Value = [NSNumber numberWithFloat:equalizerView.band10Vol];
    
    NSArray *bandValueArray = [NSArray arrayWithObjects:band1Value,
                               band2Value,
                               band3Value,
                               band4Value,
                               band5Value,
                               band6Value,
                               band7Value,
                               band8Value,
                               band9Value,
                               band10Value,nil];
    
//    NSLog(@"bandValueArray : %@",bandValueArray);
    NSDictionary *eqValueDic = [[NSDictionary alloc] initWithObjectsAndKeys:bandValueArray,@"bandValueArray", nil];
    
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentRoothPath = [documentPaths objectAtIndex:0];
    NSString *stringFilePath = [documentRoothPath stringByAppendingPathComponent:@"EQValue.plist"];
    
    BOOL isWritten = NO;
    
    isWritten = [eqValueDic writeToFile:stringFilePath atomically:YES];
    
    if(isWritten){
        NSLog(@"Success");
    }else{
        NSLog(@"Failed");
    }
    
    
    
}

- (IBAction)EQBassPlussAction:(id)sender {
    //UI=========
    equalizerView.EQPresetID = EQ_PRESET_ID_BASSPLUSS;
    
//    [EQBassPlusBut setBackgroundImage:[UIImage imageNamed:@"effect01Active"] forState:UIControlStateNormal];
//    [EQBassPlusBut setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
//    
//    [EQBassMinusBut setBackgroundImage:[UIImage imageNamed:@"effect03Passive"] forState:UIControlStateNormal];
//    [EQBassMinusBut setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
//    
//    [EQSpeechBut setBackgroundImage:[UIImage imageNamed:@"effect02Passive"] forState:UIControlStateNormal];
//    [EQSpeechBut setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    //============
    
    //bass pluss or low frequency sound preset
    theEqualizer10.band1Volume = 2.0;
    theEqualizer10.band2Volume = 1.107;
    theEqualizer10.band3Volume = 0.535;
    theEqualizer10.band4Volume = 0.190;
    theEqualizer10.band5Volume = 0.047;
    theEqualizer10.band6Volume = 0.0;
    theEqualizer10.band7Volume = 0.0;
    theEqualizer10.band8Volume = 0.0;
    theEqualizer10.band9Volume = 0.0;
    theEqualizer10.band10Volume = 0.0;
    [equalizerView displayKnobsAccordingToEqualizerValues:&theEqualizer10];
    printf("plussAction \n");
    
//    [self showStethoscopeButtonDisabled];
}

- (IBAction)EQSpeechAction:(id)sender {
    
    equalizerView.EQPresetID = EQ_PRESET_ID_SPEECH;
//    [EQSpeechBut setBackgroundImage:[UIImage imageNamed:@"effect02Active"] forState:UIControlStateNormal];
//    [EQSpeechBut setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
//    
//    [EQBassPlusBut setBackgroundImage:[UIImage imageNamed:@"effect01Passive"] forState:UIControlStateNormal];
//    [EQBassPlusBut setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
//    
//    [EQBassMinusBut setBackgroundImage:[UIImage imageNamed:@"effect03Passive"] forState:UIControlStateNormal];
//    [EQBassMinusBut setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    
    //bass minus or high frequency sound preset
    theEqualizer10.band1Volume = 0.903;
    theEqualizer10.band2Volume = 1.833;
    theEqualizer10.band3Volume = 1.785;
    theEqualizer10.band4Volume = 1.035;
    theEqualizer10.band5Volume = 0.416;
    theEqualizer10.band6Volume = 0.0;
    theEqualizer10.band7Volume = 0.0;
    theEqualizer10.band8Volume = 0.0;
    theEqualizer10.band9Volume = 0.0;
    theEqualizer10.band10Volume = 0.0;
    [equalizerView displayKnobsAccordingToEqualizerValues:&theEqualizer10];

}

- (IBAction)EQBassMinusAction:(id)sender {
    equalizerView.EQPresetID = EQ_PRESET_ID_BASSMINUS;
    
//    [EQBassMinusBut setBackgroundImage:[UIImage imageNamed:@"effect03Active"] forState:UIControlStateNormal];
//    [EQBassMinusBut setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
//    
//    [EQBassPlusBut setBackgroundImage:[UIImage imageNamed:@"effect01Passive"] forState:UIControlStateNormal];
//    [EQBassPlusBut setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
//    
//    [EQSpeechBut setBackgroundImage:[UIImage imageNamed:@"effect02Passive"] forState:UIControlStateNormal];
//    [EQSpeechBut setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
//    
    //bass minus or high frequency sound preset
    theEqualizer10.band1Volume = 0.0;
    theEqualizer10.band2Volume = 0.0;
    theEqualizer10.band3Volume = 0.0;
    theEqualizer10.band4Volume = 0.0;
    theEqualizer10.band5Volume = 0.0;
    theEqualizer10.band6Volume = 0.0;
    theEqualizer10.band7Volume = 0.0;
    theEqualizer10.band8Volume = 0.23;
    theEqualizer10.band9Volume = 0.8;
    theEqualizer10.band10Volume = 2.0;
    [equalizerView displayKnobsAccordingToEqualizerValues:&theEqualizer10];

}

- (IBAction)cancleButton:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}


//-(void) aBandKnobWithNumber:(int)bandNumber valueChangedTo:(Float32)bandValue {
//    
//    if (bandNumber==1)  { theEqualizer10.band1Volume = bandValue; }
//    if (bandNumber==2) { theEqualizer10.band2Volume = bandValue; }
//    if (bandNumber==3) { theEqualizer10.band3Volume = bandValue; }
//    if (bandNumber==4) { theEqualizer10.band4Volume = bandValue; }
//    if (bandNumber==5) { theEqualizer10.band5Volume = bandValue; }
//    if (bandNumber==6) { theEqualizer10.band6Volume = bandValue; }
//    if (bandNumber==7) { theEqualizer10.band7Volume = bandValue; }
//    if (bandNumber==8) { theEqualizer10.band8Volume = bandValue; }
//    if (bandNumber==9) { theEqualizer10.band9Volume = bandValue; }
//    if (bandNumber==10) { theEqualizer10.band10Volume = bandValue; }
//    
//    /*[EQBassPlusBut setBackgroundImage:[UIImage imageNamed:@"effect01Passive"] forState:UIControlStateNormal];
//    [EQBassPlusBut setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
//    [EQBassMinusBut setBackgroundImage:[UIImage imageNamed:@"effect02Passive"] forState:UIControlStateNormal];
//    [EQBassMinusBut setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
//    [EQSpeechBut setBackgroundImage:[UIImage imageNamed:@"effect03Passive"] forState:UIControlStateNormal];
//    [EQSpeechBut setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];*/
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
