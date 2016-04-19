
#import "PhonesViewController.h"
#import "SaveProfileStep2ViewController.h"
/*
    수정해야할 사항 
    1. 뷰를 벗어나면 다시 처음부터 검사하도록 수정 
 */
@interface PhonesViewController ()

@end

@implementation PhonesViewController

//@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    printf("ViewDidLoad\n");
    
     dgtone = [[DGToneGenerator alloc] init];
    [self init];
    
    sliderFillBar = [[VerticalSliderAndFillBar alloc]initWithFrame: CGRectMake(0, 0, scrollContainer.frame.size.width, scrollContainer.frame.size.height)];
    sliderFillBar.autoresizingMask =UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    dblabelView = [[DbLabelView2 alloc]initWithFrame:CGRectMake(0, 0, dbContainerView.frame.size.width, dbContainerView.frame.size.height)];
    dblabelView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [scrollContainer addSubview:[sliderFillBar autorelease]];
    [dbContainerView addSubview:[dblabelView autorelease]];
    
    
    leftDecibelData = [[NSMutableArray alloc]init];
    rightDecibelData = [[NSMutableArray alloc]init];
    
//    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:7];
//    [tempArray addObject:[NSNumber numberWithFloat:5.0]];
//    [tempArray addObject:[NSNumber numberWithFloat:7.0]];
//    [tempArray addObject:[NSNumber numberWithFloat:5.0]];
//    [tempArray addObject:[NSNumber numberWithFloat:7.0]];
//    [tempArray addObject:[NSNumber numberWithFloat:5.0]];
//    [tempArray addObject:[NSNumber numberWithFloat:7.0]];
//    [tempArray addObject:[NSNumber numberWithFloat:5.0]];
//    [tempArray addObject:[NSNumber numberWithFloat:7.0]];
    
    
    
   
//    [self makeAndShowAlert:@"청력 검사전 스마트폰의 소리크기를 최대로 해주시고 왼쪽귀부터 오른쪽귀 순서로 검사합니다"];
//    [phonesButton setBackgroundImage:[UIImage imageNamed:@"phonesCheckButton"] forState:UIControlStateNormal];
//    [phonesButton setTitle:@"ready?" forState:UIControlStateNormal];
    
//    dtmfNum = 0;
//    
//    buttonFlag = TRUE;
//    sliderFillBar = [[VerticalSliderAndFillBar alloc]initWithFrame: CGRectMake(0, 0, scrollContainer.frame.size.width, scrollContainer.frame.size.height)];
//    sliderFillBar.autoresizingMask =UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    
//    dblabelView = [[DbLabelView2 alloc]initWithFrame:CGRectMake(0, 0, dbContainerView.frame.size.width, dbContainerView.frame.size.height)];
//    dblabelView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    
//    [scrollContainer addSubview:[sliderFillBar autorelease]];
//    [dbContainerView addSubview:[dblabelView autorelease]];
//    
//    dgtone = [[DGToneGenerator alloc] init];
//    dgtone.delegate = self;
////    dtmf = DGToneGeneratorDtmf0 + dtmfNum;
//    dtmf = DGToneGeneratorDtmf0;
    
    
}

-(void) viewDidAppear:(BOOL)animated { // help 누르고 와도 뜸, 그땐 안뜨도록
    printf("phonesview index : %d\n",self.tabBarController.selectedIndex);
    [self makeAndShowAlert:@"청력 검사전 스마트폰의 소리크기를 최대로 해주시고 왼쪽귀부터 오른쪽귀 순서로 검사합니다"];
    printf("ViewDidAppear\n");
}

-(void) viewDidDisappear:(BOOL)animated{
    if(exitFlag){//exitFlag == TRUE  : 
        exitFlag = FALSE;
    }else{//exitFlag == FALSE : 초기화만
        [leftDecibelData removeAllObjects];
        [rightDecibelData removeAllObjects];
        
        dtmf = DGToneGeneratorDtmf0;
        [self  changeImage:8];
        [self setTitleText:@"검사 시작" andDraw:phonesButton andImageNamed:@"phonesStartButton"];
        printf("viewDidDisAppear : leftDecibelData countd %d\n",leftDecibelData.count);
        printf("viewDidDisAppear : rightDecibelData countd %d\n",rightDecibelData.count);
    }
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        isTestStart = TRUE;
//        HomeViewController *hvc = [[HomeViewController alloc]init];
//        hvc.delegate = self;
//        if([hvc getOnOffFlag]){
//            [hvc AudioOnOff:isTestStart];
//        }
//    });
    [dgtone stop];
    [dgtone init];
    [self init];
    dispatch_async(dispatch_get_main_queue(), ^{
        [sliderFillBar setFillPercent:0.0];
        [sliderFillBar.layer setNeedsDisplay];
    });
}






- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

-(void)makeAndShowAlert:(NSString*)message{
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"주의사항"
                                                     message:message
                                                    delegate:nil
                                           cancelButtonTitle:@"확인"
                                           otherButtonTitles: nil] autorelease];
    [alert show];
}

-(void)init{
    self = [super init];
    if (self) {
        
//        dtmfNum = 0;
        isTestStart = TRUE;
        buttonFlag = TRUE;
        leftEars = TRUE;
        testEnd = FALSE;
        exitFlag = FALSE;
        
        
        
//        sliderFillBar = [[VerticalSliderAndFillBar alloc]initWithFrame: CGRectMake(0, 0, scrollContainer.frame.size.width, scrollContainer.frame.size.height)];
//        sliderFillBar.autoresizingMask =UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        
//        dblabelView = [[DbLabelView2 alloc]initWithFrame:CGRectMake(0, 0, dbContainerView.frame.size.width, dbContainerView.frame.size.height)];
//        dblabelView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        
//        [scrollContainer addSubview:[sliderFillBar autorelease]];
//        [dbContainerView addSubview:[dblabelView autorelease]];
//        
//        dgtone = [[DGToneGenerator alloc] init];
        dgtone.muteLeft = FALSE;
        dgtone.muteRight = YES;
        dgtone.delegate = self;
        //    dtmf = DGToneGeneratorDtmf0 + dtmfNum;
        dtmf = DGToneGeneratorDtmf0;
        
        
//        dtmf = DGToneGeneratorDtmf6;
        
        
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
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{// segue를 통해 data  전달 
    
    NSLog(@"prepareSegue : %@",segue.identifier);
    if([[segue identifier] isEqualToString:@"showStep1"]){
        SaveProfileStep1ViewController *spsv1 = (SaveProfileStep1ViewController *)segue.destinationViewController;
        spsv1.leftDecibelData = leftDecibelData;
        spsv1.rightDecibelData = rightDecibelData;
        spsv1.parent = (PhonesViewController*)self;
        
//        HomeViewController *hvc = [[HomeViewController alloc]init];
//        [hvc hearingTestNotif];
        
        NSLog(@"prepareSegue : leftDecibel transfer is %@",leftDecibelData);
        NSLog(@"prepareSegue : rightDecibel transfer is %@",rightDecibelData);
        printf("prepareSegue : leftDecibel Count : %d\n",leftDecibelData.count);
        printf("prepareSegue : rightDecibel Count : %d\n",rightDecibelData.count);
    }
    
    
}
- (IBAction)startAction:(id)sender {
    
//    [phonesButton setBackgroundImage:[UIImage imageNamed:@"phonesCheckButton"] forState:UIControlStateNormal];
//    [phonesButton setTitle:@"소리가 난후 바로 누르세요" forState:UIControlStateNormal];
    [self setTitleText:@"소리가 난후 바로 누르세요" andDraw:phonesButton andImageNamed:@"phonesCheckButton"];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(isTestStart){ // isOn의 초기값은 TRUE, TRUE면 여기서 델리게이트로 HomeVIew로 델리게이트를 이용하여 오디오를 꺼준다.
            isTestStart = FALSE;
            HomeViewController *hvc = [[HomeViewController alloc]init];
            hvc.delegate = self;
            [hvc AudioOnOff:isTestStart];
        }
    });

    if(buttonFlag == FALSE){
        
        if (leftEars == FALSE && testEnd == FALSE) { // 왼쪽귀의 청력검사가 끝나면 실행되는 부분 / 문제 : 알림창 나오고 소리(왼쪽귀 마지막)도 그대로 진행 됨
            [self makeAndShowAlert:@"왼쪽 청력검사를 끝마쳤습니다. 오른쪽 청력검사를 시작합니다."];
            [earButton setTitle:@"오른쪽 귀" forState:UIControlStateNormal];
//            leftEars = TRUE;
            printf("1\n");
            testEnd = TRUE;
            dtmf = DGToneGeneratorDtmf0;
//            [phonesButton setBackgroundImage:[UIImage imageNamed:@"phonesStartButton"] forState:UIControlStateNormal];
//            [phonesButton setTitle:@"Start checking" forState:UIControlStateNormal];
            [self setTitleText:@"검사 시작" andDraw:phonesButton andImageNamed:@"phonesStartButton"];
            [self changeImage:7];
            if(dgtone.muteRight){ // 왼쪽 귀 테스트 중이면
//                [leftDecibelData addObject:[NSNumber numberWithFloat:dgtone.dB+120]];// leftDecibelData에 저장
                [leftDecibelData addObject:[NSNumber numberWithFloat:dgtone.dB]];
                [dgtone stop];
                [dgtone init];
                buttonFlag = TRUE;
//                [dgtone init];
                printf("Temp\n");
                printf("left saved :%f\n",dgtone.dB);
            }
            dgtone.muteLeft = YES;
            dgtone.muteRight = FALSE;
        }
        else if(testEnd == TRUE && leftEars ==TRUE){ // 모든 검사가 끝나는 부분
            [dgtone stop];
            printf("end\n");
//            [rightDecibelData addObject:[NSNumber numberWithFloat:dgtone.dB+120]];//오른쪽 마지막 검사치 rightDecibelData에 저장
            [rightDecibelData addObject:[NSNumber numberWithFloat:dgtone.dB]];
//            [phonesButton setBackgroundImage:[UIImage imageNamed:@"phonesStartButton"] forState:UIControlStateNormal];
//            [phonesButton setTitle:@"Start checking" forState:UIControlStateNormal];
            [self setTitleText:@"Start Checking" andDraw:phonesButton andImageNamed:@"phonesStartButton"];
            [self changeImage:7];
            // 청력검사 데이터 결과치 저장? 아니면 모달뷰로 데이터 전송 ??
            NSLog(@"%@",leftDecibelData);
            NSLog(@"%@",rightDecibelData);
            printf("2\n");
//            printf("leftDecibel count : %d    rightDecbel count ; %d\n",leftDecibelData.count,rightDecibelData.count);
    
//            BOOL saveSuccess = NO;
//            saveSuccess = [self saveToDictionary:leftDecibelData];
////            NSLog(@"%hhd",saveSuccess);
//            saveSuccess = NO;
//            saveSuccess = [self saveToDictionary:rightDecibelData];
//            NSLog(@"%hhd",saveSuccess);
            
            // 모든 검사가 끝나면 청력검사 오디오를 위에 [dgtone stop]으로 꺼준 후 homeview로 델리게이틀 이용 하여 보청 오디오를 켠다.
//            dispatch_async(dispatch_get_main_queue(), ^{
//                isTestStart = TRUE;
//                HomeViewController *hvc = [[HomeViewController alloc]init];
//                hvc.delegate = self;
//                [hvc AudioOnOff:isTestStart];
//            });

           
            exitFlag = TRUE;
            // 청력검사 결과 보여주는 뷰 모달(Segue)로 연결
            NSLog(@"this is tabbar controller :%@",self.tabBarController.selectedViewController);
            [self performSegueWithIdentifier:@"showStep1" sender:self];
            
//            self.tabBarController.selectedIndex = 0;
//            printf("push ok button before index : %d\n",self.tabBarController.selectedIndex);
//            UIStoryboard * mainStoryboard =[UIStoryboard storyboardWithName:@"Main" bundle:nil];
//            SaveProfileStep1ViewController *sp1 = [mainStoryboard instantiateViewControllerWithIdentifier:@"SaveProfileStep1ViewController"];
////            MyhearingResult *mrView = [[MyhearingResult alloc] initWithNibName:<#(nullable NSString *)#> bundle:nil];
//            [sp1 setModalTransitionStyle:UIModalTransitionStylePartialCurl]; //모달뷰 전환효과
//            [self presentModalViewController:sp1 animated:YES];
            
        }else{
            // 소리가 들릴때 누르면 실행되는 부분
            //            dB값을 가저와서 저장 코딩.
            buttonFlag = TRUE;
            [dgtone stop];
            if(dgtone.muteRight){ // 왼쪽 귀 테스트 중이면
//                [leftDecibelData addObject:[NSNumber numberWithFloat:dgtone.dB+120]];// leftDecibelData에 저장
                [leftDecibelData addObject:[NSNumber numberWithFloat:dgtone.dB]];
                printf("left saved :%f\n",dgtone.dB);
            }else if(dgtone.muteLeft){ // 오른쪽 귀 테스트 중이면
//                [rightDecibelData addObject:[NSNumber numberWithFloat:dgtone.dB+120]];// rightDecibelData에 저장
                [rightDecibelData addObject:[NSNumber numberWithFloat:dgtone.dB]];
                printf("right saved :%f\n",dgtone.dB);
            }
            printf("3\n");
            printf("PhoneViewController Action  dB: %f\n",[dgtone dB]);
            [dgtone init];
            printf("PhoneViewController Action  after init dB: %f\n",[dgtone dB]);
        }
        
//        [self selcetDtmf:dtmf];
    }
    else{ // 시작 버튼 누를때 마다 호출
        printf("this????\n");
        printf("4\n");
        [dgtone setDtmfFrequency:dtmf];
        [dgtone play];
        printf("frequancy is %f\n",dgtone.frequency);
        buttonFlag = FALSE;
        [frelabel setText:[NSString stringWithFormat:@"%f",dgtone.frequency]];
        [self selcetDtmf:dtmf];
    }
    

}

-(void)setTitleText:(NSString *) text andDraw:(id)context andImageNamed:(NSString *)imageFile{
    [context setBackgroundImage:[UIImage imageNamed:imageFile] forState:UIControlStateNormal];
    [context setTitle:text forState:UIControlStateNormal];
}
-(void)increaseGraph:(CGFloat)value
{
    
//    dispatch_queue_t myQueue = dispatch_queue_create("My Queue",NULL);
//    dispatch_async(myQueue, ^{
//        [sliderFillBar setFillPercent:value*10];
//        [dbLabelTest setText:@"value"];
        // Perform long running process
    float tempMaxData = 120;
    float startData = -110;
    float tempValue = (value - startData) / tempMaxData; // 백분율 계산 : 현재값 - 시작값 / 총 값
//    printf("percentage : %f\n",tempValue);
        dispatch_async(dispatch_get_main_queue(), ^{
            // Update the UI
//            [NSString stringWithFormat:@"@",value];
            [sliderFillBar setFillPercent:tempValue];
            [dbLabelTest setText:[NSString stringWithFormat:@"%f",tempValue]];
            [sliderFillBar.layer setNeedsDisplay];
        }); 
//    });
//    printf("here is increaseGraph : %f\n",value);
//    [sliderFillBar setFillPercent:value];

//    [dgtone stop];
//    [dgtone play];

    
}

// Hz 이미지 변경 및 다음 frequency Setting
-(void)selcetDtmf : (DGToneGeneratorDtmf) inDtmf{
    switch (inDtmf)
    {
        case DGToneGeneratorDtmf0:
            dtmf = DGToneGeneratorDtmf1;
            [self changeImage:0];
            break;
        case DGToneGeneratorDtmf1:
            dtmf = DGToneGeneratorDtmf2;
            [self changeImage:1];
            break;
        case DGToneGeneratorDtmf2:
            dtmf = DGToneGeneratorDtmf3;
            [self changeImage:2];
            break;
        case DGToneGeneratorDtmf3:
            dtmf = DGToneGeneratorDtmf4;
            [self changeImage:3];
            break;
        case DGToneGeneratorDtmf4:
            dtmf = DGToneGeneratorDtmf5;
            [self changeImage:4];
            break;
        case DGToneGeneratorDtmf5:
            dtmf = DGToneGeneratorDtmf6;
            [self changeImage:5];
            break;
        case DGToneGeneratorDtmf6:
            if(leftEars == FALSE){
                testEnd = TRUE;
                leftEars = TRUE;
                printf("TRUE\n");
            }
            if(leftEars == TRUE && testEnd == FALSE){
                leftEars = FALSE;
                printf("leftEars set FALSE\n");
            }
//            if(testEnd == FALSE){
//                leftEars = FALSE;
//            }
            [self changeImage:6];
            break;
//            dtmf = DGToneGeneratorDtmf7;
//            break;
//        case DGToneGeneratorDtmf7:
//            dtmf = DGToneGeneratorDtmf8;
//            break;
//        case DGToneGeneratorDtmf8:
//            dtmf = DGToneGeneratorDtmf0;
//            break;
    }

}

-(void)changeImage : (int) flag{ // 파란/빨간색의 동그란 이미지 변경
    switch (flag) {
        case 0:
            printf("case 0 \n");
            [image125 setImage:[UIImage imageNamed:@"phoneHzred"]];
            [image8k setImage:[UIImage imageNamed:@"phoneHzblue"]];
            [image125 setNeedsDisplay];
            break;
        case 1:
            [image125 setImage:[UIImage imageNamed:@"phoneHzblue"]];
            [image250 setImage:[UIImage imageNamed:@"phoneHzred"]];
            break;
        case 2:
            [image125 setImage:[UIImage imageNamed:@"phoneHzblue"]];
            [image250 setImage:[UIImage imageNamed:@"phoneHzblue"]];
            [image500 setImage:[UIImage imageNamed:@"phoneHzred"]];
            break;
        case 3:
            [image125 setImage:[UIImage imageNamed:@"phoneHzblue"]];
            [image250 setImage:[UIImage imageNamed:@"phoneHzblue"]];
            [image500 setImage:[UIImage imageNamed:@"phoneHzblue"]];
            [image1K setImage:[UIImage imageNamed:@"phoneHzred"]];
            break;
        case 4:
            [image125 setImage:[UIImage imageNamed:@"phoneHzblue"]];
            [image250 setImage:[UIImage imageNamed:@"phoneHzblue"]];
            [image500 setImage:[UIImage imageNamed:@"phoneHzblue"]];
            [image1K setImage:[UIImage imageNamed:@"phoneHzblue"]];
            [image2K setImage:[UIImage imageNamed:@"phoneHzred"]];
            break;
        case 5:
            [image125 setImage:[UIImage imageNamed:@"phoneHzblue"]];
            [image250 setImage:[UIImage imageNamed:@"phoneHzblue"]];
            [image500 setImage:[UIImage imageNamed:@"phoneHzblue"]];
            [image1K setImage:[UIImage imageNamed:@"phoneHzblue"]];
            [image2K setImage:[UIImage imageNamed:@"phoneHzblue"]];
            [image4K setImage:[UIImage imageNamed:@"phoneHzred"]];
            break;
        case 6:
            [image125 setImage:[UIImage imageNamed:@"phoneHzblue"]];
            [image250 setImage:[UIImage imageNamed:@"phoneHzblue"]];
            [image500 setImage:[UIImage imageNamed:@"phoneHzblue"]];
            [image1K setImage:[UIImage imageNamed:@"phoneHzblue"]];
            [image2K setImage:[UIImage imageNamed:@"phoneHzblue"]];
            [image4K setImage:[UIImage imageNamed:@"phoneHzblue"]];
            [image8k setImage:[UIImage imageNamed:@"phoneHzred"]];
            break;
        case 7:
            [image8k setImage:[UIImage imageNamed:@"phoneHzblue"]];
            break;
        case 8:
            [image125 setImage:[UIImage imageNamed:@"phoneHzblue"]];
            [image250 setImage:[UIImage imageNamed:@"phoneHzblue"]];
            [image500 setImage:[UIImage imageNamed:@"phoneHzblue"]];
            [image1K setImage:[UIImage imageNamed:@"phoneHzblue"]];
            [image2K setImage:[UIImage imageNamed:@"phoneHzblue"]];
            [image4K setImage:[UIImage imageNamed:@"phoneHzblue"]];
            [image8k setImage:[UIImage imageNamed:@"phoneHzblue"]];
            break;
    }
}

/*
 performSelector:(SEL _Nonnull)aSelector
 withObject:(id _Nullable)anArgument
 afterDelay:(NSTimeInterval)delay
 */


- (void)dealloc {
    [dbLabelTest release];
    [frelabel release];
    [image125 release];
    [image125 release];
    [image250 release];
    [image500 release];
    [image1K release];
    [image2K release];
    [image4K release];
    [image8k release];
    [phonesButton release];
    [earButton release];
    NSLog(@"phonesView dealloc\n");
    [super dealloc];
}
@end
