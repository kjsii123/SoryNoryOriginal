//
//  SaveProfileStep2ViewController.h
//  SoryNoryFinal
//
//  Created by 권지수 on 2015. 10. 12..
//  Copyright © 2015년 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DbLabelView2.h"
#import "OsciGraph.h"
#import "PhonesViewController.h"
#import "CNPPopupController.h"
@interface SaveProfileStep2ViewController : UIViewController{
    
    IBOutlet UIView *leftGraphVieContainer;
    IBOutlet UIView *rightGraphViewContainer;
    IBOutlet UIView *dbLabelViewcontainer;
    IBOutlet UILabel *profileLabel;
    
    
    
    DbLabelView2 *dbLabelView;
    OsciGraph *leftGraphView;
    OsciGraph *rightGraphView;
}

@property (strong)NSMutableArray *leftDecibelData;
@property (strong)NSMutableArray *rightDecibelData;
@property (strong) UIViewController *parent;
@property (strong) NSString *name;
@property (strong) UIStoryboardSegue* currentSegue;

- (IBAction)moveHomeAction:(id)sender;

@end
