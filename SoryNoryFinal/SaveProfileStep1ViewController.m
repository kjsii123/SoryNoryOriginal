

#import "SaveProfileStep1ViewController.h"

@interface SaveProfileStep1ViewController ()

@end


@implementation SaveProfileStep1ViewController
@synthesize leftDecibelData;
@synthesize rightDecibelData;
@synthesize parent;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self sps1News];
}


- (IBAction)iconSelectAction:(UIButton *)sender {
    
    //home icon
    if (sender.tag==1) { }
    
    //road icon
    if (sender.tag==2) { }
    
    //people icon
    if (sender.tag==3) { }
    
    //hospital icon
    if (sender.tag==4) { }
}

- (IBAction)savedAndNextViewAction:(id)sender {
//    UIStoryboard * mainStoryboard =[UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    SaveProfileStep1ViewController *sp2 = [mainStoryboard instantiateViewControllerWithIdentifier:@"SaveProfileStep2ViewController"];
//    //            MyhearingResult *mrView = [[MyhearingResult alloc] initWithNibName:<#(nullable NSString *)#> bundle:nil];
//    [sp2 setModalTransitionStyle:UIModalTransitionStylePartialCurl]; //모달뷰 전환효과
//    [self presentModalViewController:sp2 animated:YES];
//    NSLog(@"insideAction work pass to %@",sp2.class);
    [self performSegueWithIdentifier:@"showStep2" sender:self];
}

-(void)sps1News
{
    NSLog(@"step1 leftDecibel is %@",self.leftDecibelData);
    NSLog(@"step1 rightDecibel is %@",self.rightDecibelData);
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{// segue를 통해 data  전달
    
    NSLog(@"prepareSegue : %@",segue.identifier);
    if([[segue identifier] isEqualToString:@"showStep2"]){
        SaveProfileStep2ViewController *spsv2 = (SaveProfileStep2ViewController *)segue.destinationViewController;
        spsv2.leftDecibelData = leftDecibelData;
        spsv2.rightDecibelData = rightDecibelData;
        spsv2.parent = self.parent;
        spsv2.name = theNameTextField.text;
        spsv2.currentSegue = segue;
        NSLog(@"step1 prepareSegue : leftDecibel transfer is %@",leftDecibelData);
        NSLog(@"step1 prepareSegue : rightDecibel transfer is %@",rightDecibelData);
        NSLog(@"step1 prepareSegue : TextField is %@",theNameTextField.text);
    }
    
}

#define YTranslation self.view.frame.size.height/4.0
-(void) textFieldDidBeginEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.2 animations:^{
        textField.transform = CGAffineTransformTranslate(textField.transform, 0, -YTranslation);
    } completion:^(BOOL finished) {
    }];
}

-(void) textFieldDidEndEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.2 animations:^{
        textField.transform = CGAffineTransformTranslate(textField.transform, 0, YTranslation);
    } completion:^(BOOL finished) { 
    }];
}


-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}



//-(IBAction) screenTapAction:(UIGestureRecognizer*) recognizer {
//    [theNameTextField resignFirstResponder];
//}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
@end
