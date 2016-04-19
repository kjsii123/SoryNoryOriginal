//
//  ManuallySettingViewController.h
//  SoryNoryFinal
//
//  Created by 권지수 on 2015. 7. 10..
//  Copyright (c) 2015년 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EQView.h"

#define NUMBER_OF_BANDS         10 // 이퀄라이저 채널 개수 

@interface ManuallySettingViewController : UIViewController{
   IBOutlet UIView *eqGraphViewContainer;
    EQView *equalizerView;
    NSMutableArray *eqValueToDictionary;
    
}



- (IBAction)EQBassPlussAction:(id)sender;
- (IBAction)EQSpeechAction:(id)sender;
- (IBAction)EQBassMinusAction:(id)sender;

- (IBAction)cancleButton:(id)sender;
@end
