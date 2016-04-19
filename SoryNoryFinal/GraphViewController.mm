

#import "GraphViewController.h"

// 노티피케이션으로 구현하자
// 포인터값 넘기는 법만 알면 될듯.?

@interface GraphViewController ()

@end


@implementation GraphViewController

- (void)viewDidLoad {
    
//    self.homeVC = [[HomeViewController alloc] init];
//    self.homeVC.delegate = self;
//    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
////    dispatch_async(dispatch_get_main_queue(), ^{
//        [self presentViewController:self.homeVC animated:NO completion:nil];
//        [self dismissViewControllerAnimated:YES completion:nil];
//    });
    pointerData = [[PointerData alloc]init];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(handleFourthViewSubmit:)
//                                                 name:@"fourthViewSubmit"
//                                               object:nil];
    

    graphOsciView = [[OsciGraph alloc] initWithFrame:CGRectMake(0, 0, self.graphViewContainer.frame.size.width, self.graphViewContainer.frame.size.height)];
    graphOsciView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight; //Code로 오토 리사이징
    
    graphHzLabelView = [[HzLabelView alloc]initWithFrame:CGRectMake(0, 0, graphHzContainer.frame.size.width, graphHzContainer.frame.size.height)];
    graphHzLabelView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    
//    graphDbLabelView = [[DbLabelView alloc]initWithFrame:CGRectMake(0, 0, graphDbContainer.frame.size.width, graphDbContainer.frame.size.height)];
//    graphDbLabelView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    graphDbLabelView = [[DbLabelView2 alloc]initWithFrame:CGRectMake(0, 0, graphDbContainer.frame.size.width, graphDbContainer.frame.size.height)];
    graphDbLabelView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    graphDbLabelView.isGraph = TRUE;
    
    /****  여기서 뷰 연결안하고 바로 그림 */
    
    //    osciView.layer.mask = mainGraphCircle.layer;
    //yong : 그냥 사각형, 원이 아닌 용도로 제거    osciView.layer.cornerRadius = 20;
    graphOsciView.layer.masksToBounds = YES;
    graphOsciView.currentMode = MODE_FREQ_DOMAIN;
    
    [self.graphViewContainer addSubview:  [graphOsciView autorelease]];
    [graphHzContainer addSubview:  [graphHzLabelView autorelease]];
    [graphDbContainer addSubview:  [graphDbLabelView autorelease]];
    
    [pointerData autorelease];
    
}

- (void)handleFourthViewSubmit:(NSNotification *)notification {
    NSDictionary *theData = [notification userInfo];  // theData is the data from your fourth view controller
    NSNumber *fftMaxVal = [theData objectForKey:@"fftMaxVal"];
//    NSNumber *fftData = [theData objectForKey:@"fftData"];
    NSNumber *length = [theData objectForKey:@"length"];
//    Float32 fftDataFloat32 = fftData.floatValue;
    pointerData = [theData objectForKey:@"fftData"];
    printf("breake\n");
    dispatch_async(dispatch_get_main_queue(), ^{
        [graphOsciView setDataMaxValue:fftMaxVal.floatValue minValue:0];  //최소값 0, 최대값 fftMaxVal로 설정
        [graphOsciView addAndDrawData:pointerData.fftPointer lenght:length.floatValue];
    });

    
//    id temp;
//    printf("this is notif\n");
//    [theData getObjects:temp andKeys:@"fftMaxVal"];
    // pop views and process theData
    
}

-(void)viewDidAppear:(BOOL)animated{ // 이뷰에 들어 왔을때 옵저버를 등록
    [super viewDidAppear:animated];
    printf("graph index : %d\n",self.tabBarController.selectedIndex);
    if(self.observationInfo == nil){
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleFourthViewSubmit:)
                                                     name:@"fourthViewSubmit"
                                                   object:nil];

        
    }
//    self.homeVC.delegate = self;
}
-(void)viewDidDisappear:(BOOL)animated{ // 다른뷰로 전활할때 옵저버를 해지
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    self.homeVC.delegate = nil;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}


//-(void)drawGraphMaxVal:(Float32)maxData andfftData:(Float32*)fftData andLenth:(UInt32)lengthData;
//{
////    NSLog(@"Graph view data: %f", maxData);
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [graphOsciView setDataMaxValue:maxData minValue:0];  //최소값 0, 최대값 fftMaxVal로 설정
//        [graphOsciView addAndDrawData:fftData lenght:lengthData];
//    });
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_graphViewContainer release];
    [graphDbContainer release];
    [graphHzContainer release];
    [super dealloc];
}
@end
