//
//  compressResultViewController.m
//  SoryNoryFinal
//
//  Created by 권지수 on 2015. 7. 9..
//  Copyright (c) 2015년 Mac. All rights reserved.
//

#import "compressResultViewController.h"

@implementation compressResultViewController

-(void)viewDidLoad{
    
//    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
//    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
    osciView = [[OsciGraph alloc]initWithFrame:CGRectMake(0, 0, graphContainerView.frame.size.width,graphContainerView.frame.size.height)]; // 좌표는 0,0을 줌
    osciView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight; //Code로 오토 리사이징
    
    hzLabelView = [[HzLabelView alloc]initWithFrame:CGRectMake(0, 0, hzContainerView.frame.size.width, hzContainerView.frame.size.height)];
    hzLabelView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    dbLabelView = [[DbLabelView alloc]initWithFrame:CGRectMake(0, 0, dbContainerView.frame.size.width, dbContainerView.frame.size.height)];
    dbLabelView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    osciView.currentMode = MODE_CURVE_DOMAIN;
    
    [graphContainerView addSubview:[osciView autorelease]];
    [hzContainerView addSubview:[hzLabelView autorelease]];
    [dbContainerView addSubview:[dbLabelView autorelease]];
    
}

- (BOOL)shouldAutorotate {
    return NO; //-- for presented controller use YES
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape; //-- any orientation you need
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeLeft;
}

- (void)viewDidDisappear:(BOOL)animated
{
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}

- (IBAction)cancleButton:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
