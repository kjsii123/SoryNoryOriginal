

#import "SettingsViewController.h"
#define Left 1
#define Right 0
@interface SettingsViewController ()

@end

@implementation SettingsViewController

@synthesize contentView;
@synthesize  scrollView;

- (void)viewDidLoad {
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    

//    NSLayoutConstraint *leftConstraing = [NSLayoutConstraint constraintWithItem:self.contentView
//                                                                      attribute:NSLayoutAttributeLeading
//                                                                      relatedBy:0 toItem:self.view
//                                                                      attribute:NSLayoutAttributeLeft
//                                                                     multiplier:1.0
//                                                                       constant:0];
//    [self.view addConstraint:leftConstraing];
//    
//    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
//                                                                       attribute:NSLayoutAttributeTrailing
//                                                                       relatedBy:0
//                                                                          toItem:self.view
//                                                                       attribute:NSLayoutAttributeRight
//                                                                      multiplier:1.0
//                                                                        constant:0];
//    [self.view addConstraint:rightConstraint];
}
//
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationMaskPortrait;
//}

//- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
//    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
//    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
//}


//- (UIInterfaceOrientationMask)supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationMaskPortrait;
//}
//
//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
//{
//    return UIInterfaceOrientationPortrait;
//}
//
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
//    
//    return interfaceOrientation == UIInterfaceOrientationPortrait;
//}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
-(void)viewDidAppear:(BOOL)animated{
    printf("setup index : %d\n",self.tabBarController.selectedIndex);
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{// segue를 통해 data  전달

    NSLog(@"prepareSegue : %@",segue.identifier);
    if([[segue identifier] isEqualToString:@"showTestResult"]){
        SaveProfileStep2ViewController *spsv2 = (SaveProfileStep2ViewController *)segue.destinationViewController;
        //        spsv2.leftDecibelData = leftDecibelData;
        //        spsv2.rightDecibelData = rightDecibelData;
        //        spsv2.parent = self.parent;
        //        spsv2.name = theNameTextField.text;
        spsv2.currentSegue = segue;
        //        NSLog(@"step1 prepareSegue : leftDecibel transfer is %@",leftDecibelData);
        //        NSLog(@"step1 prepareSegue : rightDecibel transfer is %@",rightDecibelData);
        //        NSLog(@"step1 prepareSegue : TextField is %@",theNameTextField.text);
    }
    
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void)makeAndShowAlert:(NSString*)message{
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"주의사항"
                                                     message:message
                                                    delegate:nil
                                           cancelButtonTitle:@"확인"
                                           otherButtonTitles: nil] autorelease];
    [alert show];
}
-(NSDictionary *)loadToDictionary:(int)flag{
    
    NSArray *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentRootPath = [documentPath objectAtIndex:0];
    
    //    NSString *stringFilaPath = [documentRootPath stringByAppendingPathComponent:@"LeftHearingTestData.plist"];
    
    //    NSDictionary *eqValueDic = [[NSDictionary alloc] initWithContentsOfFile:stringFilaPath];
    NSString *stringFilaPath;
    NSDictionary *eqValueDic;
    switch(flag){
        case Left:
            stringFilaPath = [documentRootPath stringByAppendingPathComponent:@"LeftHearingTestData.plist"];
            
            eqValueDic = [[NSDictionary alloc] initWithContentsOfFile:stringFilaPath];
            if(eqValueDic){
                NSLog(@"LeftTestData Load Success");
                NSLog(@"%@",eqValueDic);
            }else{
                NSLog(@"TestData Load Failed");
            }
            break;
        case Right:
            stringFilaPath = [documentRootPath stringByAppendingPathComponent:@"RightHearingTestData.plist"];
            eqValueDic = [[NSDictionary alloc] initWithContentsOfFile:stringFilaPath];
            
            if(eqValueDic){
                NSLog(@"RightTestData Load Success");
                NSLog(@"%@",eqValueDic);
            }else{
                NSLog(@"EQValue Load Failed");
            }
            break;
    }
    return eqValueDic;
    //    if(eqValueDic){
    //        NSLog(@"LeftTestData Load Success");
    //        NSLog(@"%@",eqValueDic);
    //    }else{
    //        NSLog(@"TestData Load Failed");
    //    }
    
    //    stringFilaPath = [documentRootPath stringByAppendingPathComponent:@"RightHearingTestData.plist"];
    //    eqValueDic = [[NSDictionary alloc] initWithContentsOfFile:stringFilaPath];
    //
    //    if(eqValueDic){
    //        NSLog(@"RightTestData Load Success");
    //        NSLog(@"%@",eqValueDic);
    //    }else{
    //        NSLog(@"EQValue Load Failed");
    //    }
    
    //    stringFilaPath = [documentRootPath stringByAppendingPathComponent:@"EQValue.plist"];
    //    eqValueDic = [[NSDictionary alloc] initWithContentsOfFile:stringFilaPath];
    //
    //    if(eqValueDic){
    //        NSLog(@"EQValue Load Success");
    //        NSLog(@"%@",eqValueDic);
    //    }else{
    //        NSLog(@"EQValue Load Failed");
    //    }
    //    
    //    return eqValueDic;
}


- (IBAction)showResultAction:(id)sender {
    if([self loadToDictionary:Left] && [self loadToDictionary:Right]){
        [self performSegueWithIdentifier:@"showTestResult" sender:self];
    }else{
         [self makeAndShowAlert:@"저장된 청력검사결과가 존재하지 않습니다."];
    }
}
@end
