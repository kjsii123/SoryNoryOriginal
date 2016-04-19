//
//  MyhearingResult.m
//  SoryNoryFinal
//
//  Created by 권지수 on 2015. 7. 3..
//  Copyright (c) 2015년 Mac. All rights reserved.
//

#import "MyhearingResult.h"

#define SAMPLE_RATE 22050 //22050 //11025 //44100
#define NUMCHANNELS 2
#define FRAMESIZE  512 //512 //256 //1024 //512 //256

#define DBOFFSET -74.0
#define LOWPASSFILTERTIMESLICE .001

Float32 *windowBuffer= NULL;
Float32 workBuffer[FRAMESIZE*NUMCHANNELS];
UInt32 frameSize = 512;
const UInt32 windowLength = SAMPLE_RATE;
Float32 zero = 0;
Float32 buffer = 40;



Float32 frequencyHerzValue(long frequencyIndex, long fftVectorSize, Float32 nyquistFrequency ) {
    return ((Float32)frequencyIndex/(Float32)fftVectorSize) * nyquistFrequency;
}



@interface MyhearingResult ()

@end

@implementation MyhearingResult

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
//    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
//    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
    
    

    
    //    -(void) drawLayer:(CALayer *)layer inContext:(CGContextRef)context
    printf("viewDidLoad start\n");
//    osciView = [[OsciGraph alloc] initWithFrame:CGRectMake(graphContainerView.frame.origin.x,
//                                                           graphContainerView.frame.origin.y,
//                                                           graphContainerView.frame.size.width,
//                                                           graphContainerView.frame.size.height)];
    
    osciView = [[OsciGraph alloc]initWithFrame:CGRectMake(0, 0, graphContainerView.frame.size.width,graphContainerView.frame.size.height)]; // 좌표는 0,0을 줌
    osciView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight; //Code로 오토 리사이징
    
    hzLabelView = [[HzLabelView alloc]initWithFrame:CGRectMake(0, 0, hzContainerView.frame.size.width, hzContainerView.frame.size.height)];
    hzLabelView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    dbLabelView = [[DbLabelView alloc]initWithFrame:CGRectMake(0, 0, dbContainerView.frame.size.width, dbContainerView.frame.size.height)];
    dbLabelView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
//    osciView = [[OsciGraph alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
//    osciView.translatesAutoresizingMaskIntoConstraints = NO;
    
    
//    [osciView addConstraint:[NSLayoutConstraint constraintWithItem:osciView
//                                                         attribute:NSLayoutAttributeWidth
//                                                         relatedBy:NSLayoutRelationEqual
//                                                            toItem:graphContainerView
//                                                         attribute:NSLayoutAttributeWidth
//                                                        multiplier:1.0
//                                                          constant:.0]];
//    [osciView addConstraint:[NSLayoutConstraint constraintWithItem:osciView
//                                                         attribute:NSLayoutAttributeHeight
//                                                         relatedBy:NSLayoutRelationEqual
//                                                            toItem:graphContainerView
//                                                         attribute:NSLayoutAttributeHeight
//                                                        multiplier:1.0
//                                                          constant:.0]];
    
    printf("width : %f\n height : %f\n",graphContainerView.frame.size.width,graphContainerView.frame.size.height);
    printf("x: %f\n y :  %f\n",graphContainerView.frame.origin.x,graphContainerView.frame.origin.y);
//
//    [graphContainerView sizeThatFits:<#(CGSize)#>];
//    UILayoutFittingExpandedSize;
    
//    [osciView systemLayoutSizeFittingSize:UILayoutFittingExpandedSize]; //
    
//    osciView.layer.masksToBounds = YES;
    //    osciView.currentMode = MODE_FREQ_DOMAIN;
//        osciView.currentMode = MODE_TIME_DOMAIN;
    osciView.currentMode = MODE_POINT_DOMAIN;
    
//    osciView.backgroundColor = [UIColor blueColor];
    [graphContainerView addSubview:[osciView autorelease]];
    [hzContainerView addSubview:[hzLabelView autorelease]];
    [dbContainerView addSubview:[dbLabelView autorelease]];
    
    
    NSLog(@"after osciview super View : %@",osciView.superview);
    NSLog(@"graph sub View : %@",graphContainerView.subviews);
    NSLog(@"graph subview of super View : %@",graphContainerView.superview.subviews);
//
//    [osciView addConstraint:[NSLayoutConstraint constraintWithItem:osciView
//                                                         attribute:NSLayoutAttributeWidth
//                                                         relatedBy:NSLayoutRelationEqual
//                                                            toItem:graphContainerView
//                                                         attribute:NSLayoutAttributeWidth
//                                                        multiplier:1.0
//                                                          constant:.0]];
//    [osciView addConstraint:[NSLayoutConstraint constraintWithItem:osciView
//                                                         attribute:NSLayoutAttributeHeight
//                                                         relatedBy:NSLayoutRelationEqual
//                                                            toItem:graphContainerView
//                                                         attribute:NSLayoutAttributeHeight
//                                                        multiplier:1.0
//                                                          constant:.0]];

}
//-(void)viewWillAppear:(BOOL)animated
//{
//    [UIView setAnimationsEnabled:NO];
//}
//-(void)viewDidAppear:(BOOL)animated
//{
//    [UIView setAnimationsEnabled:YES];
//}
- (BOOL)shouldAutorotate {
    return NO; //-- for presented controller use YES
}

- (NSUInteger)supportedInterfaceOrientations {
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


- (IBAction)cancleButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)drawRect:(CGRect)rect
{    printf("this is drawrect \n\n");
}

-(void)drawDottedLineFromStartingPoint:(CGPoint)startPoint ToEndPoint:(CGPoint)endPoint
{
    UIBezierPath *path = [[UIBezierPath alloc] init];
    
    [path moveToPoint:startPoint];
    [path addLineToPoint:endPoint];
    path.lineWidth = 4;
    
    CGFloat dashes[] = {path.lineWidth * 0, path.lineWidth * 2};
    
    [path setLineDash:dashes count:2 phase:0];
    path.lineCapStyle = kCGLineCapRound;
    
    CGContextRef ctx = UIGraphicsGetCurrentContext(); // 현재 사용중인 컨텍스트 가저오기.
//    CGContextSetStrokeColorWithColor(ctx, [ThemeManager mediumTextColor].CGColor);
    
    [path stroke];
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
