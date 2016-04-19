//
//  CompressSetup.h
//  SoryNoryFinal
//
//  Created by 권지수 on 2015. 12. 16..
//  Copyright © 2015년 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphView.h"
#import "CompressSetupPopupView.h"
#import "CompressSetupPopupView2.h"



@interface CompressSetupViewController : UIViewController{
//    id <CompressSetupViewControllerDelegate> delegate;
    
    GraphView *setupGraphView;
}



@property (retain, nonatomic) IBOutlet UIView *graphViewContainer;
@property (retain, nonatomic) IBOutlet CompressSetupPopupView *popupView;
@property (retain, nonatomic) IBOutlet CompressSetupPopupView2 *popupView2;
@property (retain, nonatomic) IBOutlet UIButton *threshouldButton;
@property (retain, nonatomic) IBOutlet UIButton *ratioButton;


- (IBAction)threshouldButtonAction:(id)sender;
- (IBAction)compressRatioButtonAction:(id)sender;
- (IBAction)compressSetupCancleAction:(id)sender;
- (IBAction)threshouldPopupAction:(id)sender;
- (IBAction)compressRatioPopupAction:(id)sender;

@end
