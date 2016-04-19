//
//  SaveProfileStep2ViewController.m
//  SoryNoryFinal
//
//  Created by 권지수 on 2015. 10. 12..
//  Copyright © 2015년 Mac. All rights reserved.
//

#import "SaveProfileStep2ViewController.h"

#define Left 1
#define Right 0


@interface SaveProfileStep2ViewController ()

@end

@implementation SaveProfileStep2ViewController
@synthesize leftDecibelData;
@synthesize rightDecibelData;
@synthesize parent;
@synthesize name;
@synthesize currentSegue;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
//    osciView = [[OsciGraph alloc]initWithFrame:CGRectMake(0, 0, graphContainerView.frame.size.width,graphContainerView.frame.size.height)]; // 좌표는 0,0을 줌
//    osciView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight; //Code로 오토 리사이징
//    
//    hzLabelView = [[HzLabelView alloc]initWithFrame:CGRectMake(0, 0, hzContainerView.frame.size.width, hzContainerView.frame.size.height)];
//    hzLabelView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    
//    dbLabelView = [[DbLabelView alloc]initWithFrame:CGRectMake(0, 0, dbContainerView.frame.size.width, dbContainerView.frame.size.height)];
//    dbLabelView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//       osciView.currentMode = MODE_POINT_DOMAIN;
//        [graphContainerView addSubview:[osciView autorelease]];
//    [hzContainerView addSubview:[hzLabelView autorelease]];
//    [dbContainerView addSubview:[dbLabelView autorelease]];
    
//    [self tempNews];
    if ([currentSegue.identifier isEqualToString:@"showStep2"]) { // 프로필 저장 segue를 통해 호출 됬을때
        NSLog(@"step2 viewDidLoad segueIdentifier showStep2");
    }
//     설정에서 segue를 통해 호출 됬을때
//  1. 데이터 로드
//      - 로드 실패시 알람창 띄우고 다시 설정창으로
//      - 성공시 leftDecibelData, rightDecibelData에 각각 저장
    if([currentSegue.identifier isEqualToString:@"showTestResult"]){
        NSDictionary *data;
        NSLog(@"step2 viewDidLoad segueIdentifier showTestResult");
        if(data = [self loadToDictionary:Left]){
            NSLog(@"left load success");
            leftDecibelData = [data objectForKey:@"dataArray"];
            NSLog(@"%@",leftDecibelData);
        }
        if (data = [self loadToDictionary:Right]) {
            NSLog(@"right load success");
            rightDecibelData = [data objectForKey:@"dataArray"];
            NSLog(@"%@",rightDecibelData);
        }
        
    }

    
    leftGraphView = [[OsciGraph alloc]initWithFrame:CGRectMake(0, 0, leftGraphVieContainer.frame.size.width, leftGraphVieContainer.frame.size.height)];
    leftGraphView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [leftGraphView setDecibelValue:leftDecibelData];
    
    rightGraphView = [[OsciGraph alloc]initWithFrame:CGRectMake(0, 0, rightGraphViewContainer.frame.size.width, rightGraphViewContainer.frame.size.height)];
    rightGraphView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [rightGraphView setDecibelValue:rightDecibelData];
    
    dbLabelView = [[DbLabelView2 alloc]initWithFrame:CGRectMake(0, 0, dbLabelViewcontainer.frame.size.width ,dbLabelViewcontainer.frame.size.height)];
    dbLabelView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    
    
//    leftGraphView.currentMode = MODE_POINT_DOMAIN;
//    rightGraphView.currentMode = MODE_POINT_DOMAIN;
    
    leftGraphView.currentMode = MODE_POINT_DOMAIN2;
    rightGraphView.currentMode = MODE_POINT_DOMAIN2;
    
    dbLabelView.isTestSaved = TRUE;
    
    [leftGraphVieContainer addSubview:[leftGraphView autorelease]];
    [rightGraphViewContainer addSubview:[rightGraphView autorelease]];
    [dbLabelViewcontainer addSubview:[dbLabelView autorelease]];
 
    NSLog(@"step2 viewDidLoad");
    
}
-(void)tempNews{ // segue로 받아 온 데이터를 출력 하는 부분
    NSLog(@"step2 leftDecibel is %@",self.leftDecibelData);
    NSLog(@"step2 rightDecibel is %@",self.rightDecibelData);
    NSLog(@"step2 parent is %@",self.parent);
    NSLog(@"step2 label is %@",self.name);
    NSLog(@"step2 current segue identifier : %@",currentSegue.identifier);
    NSLog(@"step2 current segue sourceViewController: %@",currentSegue.sourceViewController);
    [profileLabel setText:self.name];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewDidAppear:(BOOL)animated{
    NSLog(@"step2 viewDidAppear");
    [self tempNews];
}
-(void)viewDidDisappear:(BOOL)animated{
    // 파일 저장 완료 확인.
    if([currentSegue.identifier isEqualToString:@"showStep2"]){
        if([self loadToDictionary:Left]){
            NSLog(@"step2 LeftDataLoad Success");
        }
        if([self loadToDictionary:Right]){
            NSLog(@"step2 RightDataLoad Success");
        }
    }
    else if([currentSegue.identifier isEqualToString:@"showTestResult"]){
        NSLog(@"showTestResult Segue end View");
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

- (void)dealloc {
    [leftGraphVieContainer release];
    [rightGraphViewContainer release];
    [dbLabelViewcontainer release];
    NSLog(@"step2View dealloc");
    [profileLabel release];
    [super dealloc];
}
-(BOOL)saveToDictionary : (NSMutableArray *) dataArray andName:(NSString*)fileName{ // Array 데이터를 Dictionary로 저장
    //여기에 앞서 저장했던 데이터 지우기
    //
    NSDictionary *eqValueDic = [[NSDictionary alloc] initWithObjectsAndKeys:dataArray,@"dataArray", nil];
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
-(UILabel*)createPopup{ // 팝업 띄우기
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"알 림" attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:24], NSParagraphStyleAttributeName : paragraphStyle}];
    NSAttributedString *lineOne = [[NSAttributedString alloc] initWithString:@"청력검사 결과 전송" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18], NSParagraphStyleAttributeName : paragraphStyle}];
    UIImage *icon = [UIImage imageNamed:@"saveProfHome_normal"];
    
    NSAttributedString *lineTwo = [[NSAttributedString alloc] initWithString:@"전송중" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18], NSForegroundColorAttributeName : [UIColor colorWithRed:0.46 green:0.8 blue:1.0 alpha:1.0], NSParagraphStyleAttributeName : paragraphStyle}];
    
    NSAttributedString *buttonTitle = [[NSAttributedString alloc] initWithString:@"닫 기" attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:18], NSForegroundColorAttributeName : [UIColor whiteColor], NSParagraphStyleAttributeName : paragraphStyle}];
    
    CNPPopupController *popupController = [[CNPPopupController alloc] initWithTitle:title contents:@[lineOne, icon, lineTwo] buttonTitles:@[buttonTitle] destructiveButtonTitle:nil];
    popupController.theme = [CNPPopupTheme defaultTheme];
    popupController.theme.popupStyle = 1;
    popupController.theme.presentationStyle = CNPPopupPresentationStyleSlideInFromTop;
    popupController.theme.dismissesOppositeDirection = YES;
    popupController.delegate = self;
    UILabel* tempLabel = [popupController presentPopupControllerAnimated:YES];
    return tempLabel;
    
}
- (IBAction)moveHomeAction:(id)sender {
//    [self performSegueWithIdentifier:@"moveHomeSegue" sender:self];
    
//    PhonesViewController *viewController =(PhonesViewController*) self.parentViewController;
//    viewController.tabBarController.selectedIndex = 0;
    
    //  만약 설정에서 왔다면 설정창으로 돌아 가게끔 하고 데이터 저장은 할 필요 없음.
    if([currentSegue.identifier isEqualToString:@"showStep2"]){
        BOOL isSaved = FALSE;
        isSaved = [self saveToDictionary:leftDecibelData andName:@"LeftHearingTestData.plist"];
        if(isSaved) NSLog(@"Save Success");
        else NSLog(@"Save Failed");
        isSaved = [self saveToDictionary:rightDecibelData andName:@"RightHearingTestData.plist"];
        if(isSaved) NSLog(@"Save Success");
        else NSLog(@"Save Failed");
        
        HomeViewController* hvc = [[HomeViewController alloc]init];
        hvc.delegate = self;
        [hvc hearingTestNotif];
        
        dispatch_async(dispatch_get_main_queue(),^{
            if([hvc getOnOffFlag])
                [hvc AudioOnOff:TRUE];
        });
        
        parent.tabBarController.selectedIndex = 0;
        UILabel* tempLabel = [self createPopup];
        //    NSString *stringValue[7] = {@"125Hz 전송....",@"250Hz 전송....",
        //                                @"500Hz 전송....",@"1000Hz 전송....",
        //                                @"2000Hz 전송....",@"4000Hz 전송....",
        //                                @"8000Hz 전송...."};
        NSString *stringValue[8] = {@"125Hz 전송....",@"250Hz 전송....",
            @"500Hz 전송....",@"1000Hz 전송....",
            @"2000Hz 전송....",@"4000Hz 전송....",
            @"8000Hz 전송....",@"전송완료"};
//        [tempLabel setText:@"전송완료"];
        for(NSInteger i = 0 ; i < 8; i++){
            NSString *string = stringValue[i];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, i * NSEC_PER_SEC * 1.5),
                       dispatch_get_main_queue(), ^{
                           [tempLabel setText:string];
                       });
        }
//        for(int i = 0 ; i<7;i++){
////            NSString *string = stringValue[i];
//            dispatch_async(dispatch_get_main_queue(),^{
//                [tempLabel setText:@"전송완료"];
//                [tempLabel setNeedsLayout];
//                sleep(1);
//            });
//        }
    }
//    [self.parent2 dismissViewControllerAnimated:YES completion:nil];
//    [self dismissViewControllerAnimated:YES completion:nil];
    

    UIViewController *gp = self.presentingViewController.presentingViewController;
    [self dismissViewControllerAnimated:YES completion:^{
        [gp dismissViewControllerAnimated:YES completion:nil];
        [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }];
}
-(NSDictionary *)loadToDictionary:(int)flag{
    
    NSArray *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentRootPath = [documentPath objectAtIndex:0];
    
//    NSString *stringFilaPath = [documentRootPath stringByAppendingPathComponent:@"LeftHearingTestData.plist"];
    
//    NSDictionary *eqValueDic = [[NSDictionary alloc] initWithContentsOfFile:stringFilaPath];
    NSString *stringFilaPath;
    NSDictionary *eqValueDic = nil;
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



@end
