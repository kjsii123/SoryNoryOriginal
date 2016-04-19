

#import <UIKit/UIKit.h>
#import "VerticalSliderAndFillBar.h"
#import "DbLabelView2.h"
#import "DGToneGenerator.h"
#import "SaveProfileStep1ViewController.h"
#import "HomeViewController.h"





//int dtmfNum;
//@protocol phoneViewDelegate <NSObject>
//
//@optional
//-(void)audioOnOffOrder:(BOOL)OnOffFlag;
//@end

@interface PhonesViewController : UIViewController<DGToneGeneratorDelegate> {
    
    DGToneGeneratorDtmf dtmf;
    BOOL buttonFlag;
    BOOL leftEars;
    BOOL testEnd;
    BOOL exitFlag; // 검사 도중 뷰를 떠났을때 취하는 이벤트를 결정하는 flag
    
    VerticalSliderAndFillBar *sliderFillBar;
    DbLabelView2 *dblabelView;
    
    IBOutlet UIView *dbContainerView;
    IBOutlet UIView *scrollContainer;
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIView *contentView;
    
    // 임시 라벨 
    IBOutlet UILabel *dbLabelTest;
    IBOutlet UILabel *frelabel;
    
    IBOutlet UIImageView *image125;
    IBOutlet UIImageView *image250;
    IBOutlet UIImageView *image500;
    IBOutlet UIImageView *image1K;
    IBOutlet UIImageView *image2K;
    IBOutlet UIImageView *image4K;
    IBOutlet UIImageView *image8k;
    
    IBOutlet UIButton *phonesButton;
    IBOutlet UIButton *earButton;
    
    
    DGToneGenerator *dgtone;
    
    NSMutableArray *leftDecibelData; // 왼쪽 청력검사 데이터
    NSMutableArray *rightDecibelData; // 오른쪽 청력검사 데이터
    
    BOOL isTestStart; // 테스트 중인지 아닌지 확인하는 flag, homeView로 전달하는 델리게이트 메소드의 인자로 사용 
}
//@property(strong, nonatomic) id <phoneViewDelegate> delegate;

- (IBAction)startAction:(id)sender;
-(void)increaseGraph:(CGFloat)value;

@end
