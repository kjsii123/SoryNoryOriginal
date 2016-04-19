//
//  CompressSetup.m
//  SoryNoryFinal
//
//  Created by 권지수 on 2015. 12. 16..
//  Copyright © 2015년 Mac. All rights reserved.
//

#import "CompressSetupViewController.h"

#define THRESHOULD 0
#define RATIO 1

@interface CompressSetupViewController ()

@end

@implementation CompressSetupViewController
//graphOsciView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight; //Code로 오토 리사이징

#pragma mark viewDidLoad
- (void)viewDidLoad { // ratio /  threshold 설정해주기. plist로 저장 안되었을 시 기본값으로 세팅.
    [super viewDidLoad];
//
    NSDictionary *dataDic;
    NSMutableArray *data = [[NSMutableArray alloc]init];
    NSNumber *floatNumber;
    dataDic = [self loadToDictionary];
    data = [dataDic objectForKey:@"data"];
    floatNumber = [data objectAtIndex:THRESHOULD];
    
    setupGraphView = [[GraphView alloc] initWithFrame:CGRectMake(0, 0, self.graphViewContainer.frame.size.width, self.graphViewContainer.frame.size.height)];
    setupGraphView.autoresizingMask =  UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight; //Code로 오토 리사이징
    [setupGraphView setThreshould:[floatNumber floatValue] * 0.1];
    
    [self.threshouldButton setTitle:[NSString stringWithFormat:@"%d",[floatNumber intValue]*10] forState:UIControlStateNormal];
    floatNumber  = [data objectAtIndex:RATIO];
    [setupGraphView setRatio:[floatNumber floatValue]];
    [self.ratioButton setTitle:[NSString stringWithFormat:@"1 : %d",[floatNumber intValue]] forState:UIControlStateNormal];
    [self.graphViewContainer addSubview:[setupGraphView autorelease]];
    
    [self.popupView setHidden:YES];
    [self.popupView2 setHidden:YES];
    
    NSLog(@"csetup viewDidload");
    // Do any additional setup after loading the view.
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
    [_graphViewContainer release];
    [_popupView release];
    [_popupView2 release];
    [_threshouldButton release];
    [_ratioButton release];
    [super dealloc];
}
#pragma mark ACTION
- (IBAction)threshouldButtonAction:(id)sender {
    [self.popupView setHidden:NO];
//    [self.graphViewContainer setHidden:YES];
    [self.popupView2 setHidden:YES];
}

- (IBAction)compressRatioButtonAction:(id)sender {
    [self.popupView setHidden:YES];
//    [self.graphViewContainer setHidden:YES];
    [self.popupView2 setHidden:NO];
}

- (IBAction)compressSetupCancleAction:(id)sender {
    if( !(self.popupView.hidden) || !(self.popupView2.hidden)){
        [self.popupView setHidden:YES];
        [self.popupView2 setHidden:YES];
    }else{
        NSMutableArray *data = [[NSMutableArray alloc]init];
        
        [data addObject:[NSNumber numberWithFloat:setupGraphView.threshould * 10]];
        [data addObject:[NSNumber numberWithFloat:setupGraphView.ratio]];
        if([self saveToDictionary:data andName:@"compressInfo.plist"]){
            [data removeAllObjects];
            NSLog(@"compressInfo Save Success");
        }
        NSLog(@"1");
        NSLog(@"compressSetupView ratiod : %@",[NSString stringWithFormat:@"%f",setupGraphView.ratio]);
        NSLog(@"compressSetupView threshold : %@",[NSString stringWithFormat:@"%f",setupGraphView.threshould]);
        NSDictionary *compressValueDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:setupGraphView.ratio],@"compressRatio",
                     [NSNumber numberWithFloat:setupGraphView.threshould],@"compressThreshold", nil];
        NSLog(@"2");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"compressSetupNotif"
                                                            object:self
                                                          userInfo:compressValueDic];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    NSLog(@"cancleAction");
}

- (IBAction)threshouldPopupAction:(id)sender{
    NSLog(@"threshouldPopupAction");
    NSLog(@"%@",[NSString stringWithFormat:@"%ld",(long)[sender tag]]);
    
    
//    [setupGraphView setThreshould:[sender tag]*0.1];
//    [setupGraphView setRatio:3.0];
    
    setupGraphView.threshould = (Float32)[sender tag] * 0.1;
    printf("threshould : %f\n",setupGraphView.threshould);
    [setupGraphView setNeedsDisplay];
    [self.threshouldButton setTitle:[NSString stringWithFormat:@"%ld",(long)[sender tag]*10] forState:UIControlStateNormal];
    [self.popupView setHidden:YES];
    
}
- (IBAction)compressRatioPopupAction:(id)sender{
    NSLog(@"ratioPopupAction");
    NSLog(@"%@",[NSString stringWithFormat:@"%ld",(long)[sender tag]]);
    if([sender tag] == 1){
        setupGraphView.ratio = 1.5;
        [self.ratioButton setTitle:@"1 : 1.5" forState:UIControlStateNormal];
    }else{
        setupGraphView.ratio = [sender tag];
        [self.ratioButton setTitle:[NSString stringWithFormat:@"1 : %ld",(long)[sender tag]] forState:UIControlStateNormal];
    }
    [setupGraphView setNeedsDisplay];
    [self.popupView2 setHidden:YES];
}


-(BOOL)saveToDictionary : (NSMutableArray *) data andName:(NSString*)fileName{ // Array 데이터를 Dictionary로 저장
    //여기에 앞서 저장했던 데이터 지우기
    //
    NSDictionary *eqValueDic = [[NSDictionary alloc] initWithObjectsAndKeys:data,@"data", nil];
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentRoothPath = [documentPaths objectAtIndex:0];
    NSString *stringFilePath = [documentRoothPath stringByAppendingPathComponent:fileName];
    
    BOOL isWritten = NO;
    
    isWritten = [eqValueDic writeToFile:stringFilePath atomically:YES];
    
    //    if(isWritten){
    //        NSLog(@"Success");
    //    }else{
    //        NSLog(@"Failed");
    //    }
    return isWritten;
}



-(NSDictionary *)loadToDictionary{
    
    NSArray *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentRootPath = [documentPath objectAtIndex:0];
    
    NSString *stringFilaPath;
    NSDictionary *eqValueDic = nil;
    
    stringFilaPath = [documentRootPath stringByAppendingPathComponent:@"compressInfo.plist"];
    
    eqValueDic = [[NSDictionary alloc] initWithContentsOfFile:stringFilaPath];
    if(eqValueDic){
        NSLog(@"compressInfo Load Success");
        NSLog(@"%@",eqValueDic);
    }
    return eqValueDic;
}



@end
