//
//  compressResultViewController.h
//  SoryNoryFinal
//
//  Created by 권지수 on 2015. 7. 9..
//  Copyright (c) 2015년 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accelerate/Accelerate.h>
#import <AudioToolbox/AudioToolbox.h>
#import "OsciGraph.h"
#import "FFTHelper.h"
#import "HzLabelView.h"
#import "DbLabelView.h"

OsciGraph *osciView;
HzLabelView *hzLabelView;
DbLabelView *dbLabelView;

@interface compressResultViewController : UIViewController{
    IBOutlet UIView *graphContainerView;  // 주파수 그래프를 보여주는 뷰
    IBOutlet UIView *hzContainerView;
    IBOutlet UIView *dbContainerView;
}
- (IBAction)cancleButton:(id)sender;
@end
