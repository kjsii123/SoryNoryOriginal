

#import <UIKit/UIKit.h>
#import <Accelerate/Accelerate.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "EQView.h"


void safeRelease(NSObject **object);


#define UD [NSUserDefaults standardUserDefaults

typedef enum HZType{
    hz125=0,
    hz250,
    hz500,
    hz1K,
    hz2k,
    hz4k,
    hz8k,
}HZType;

@protocol homeViewControllerDelegate <NSObject>
@optional
-(void)AudioOnOff :(BOOL)flag;
-(BOOL)getOnOffFlag;
-(void)hearingTestNotif;
-(void)compressSetup;
@end
//@interface HomeViewController : UIViewController<phoneViewDelegate>{
@interface HomeViewController : UIViewController{
    IBOutlet UIButton *OnOffButton;
    //    BOOL OnOffFlag;
    IBOutlet UIButton *eqOnOffButton;
    NSDictionary *homeViewDic;
//    IBOutlet UIView *homeGraphViewContainer;
    IBOutlet UISlider *gainSlider;
    EQView *equalizerView;
    UIBackgroundTaskIdentifier backgroundTaskID;
    
    NSArray *testResultArray;
    Float32 leftResultArray[7];
    Float32 rightResultArray[7];
    Float32 averageResultArray[7];
    
}
@property (strong,nonatomic) id <homeViewControllerDelegate> delegate;
-(IBAction)moveToHomeSegue:(UIStoryboardSegue*)segue;
- (IBAction)On_OffAction:(id)sender;
- (IBAction)noiseButtonAction:(id)sender;

-(void) headphonesConnected:(BOOL) flag;
-(void) lowMainGainTwice;

//homeViewControllerDelegate 프로토콜 메소드
-(void)AudioOnOff:(BOOL)OnOffFlag;
-(BOOL)getOnOffFlag;
-(void)hearingTestNotif;

-(Float32)getAverageValue:(HZType)hzValue; // 평균값 반환 메소드

- (IBAction)gainAction:(id)sender;

@end

@interface PointerData : NSNumber{
    Float32* fftPointer;
}
@property (nonatomic) Float32* fftPointer;
-(Float32*)getData;
-(void)setData:(Float32*)pointer;
@end