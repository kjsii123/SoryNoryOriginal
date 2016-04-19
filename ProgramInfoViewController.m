//
//  ProgramInfoViewController.m
//  SoryNoryFinal
//
//  Created by 권지수 on 2015. 7. 15..
//  Copyright (c) 2015년 Mac. All rights reserved.
//

#import "ProgramInfoViewController.h"

@interface ProgramInfoViewController ()

@end

@implementation ProgramInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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

- (IBAction)cancleButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
