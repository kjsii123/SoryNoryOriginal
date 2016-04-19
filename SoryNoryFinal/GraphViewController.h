
#import <UIKit/UIKit.h>
//#import <Accelerate/Accelerate.h>
//#import <AudioToolbox/AudioToolbox.h>
#import "OsciGraph.h"
#import "HzLabelView.h"
#import "DbLabelView2.h"
//#import "FFTHelper.h"
#import "HomeViewController.h" 




@interface GraphViewController : UIViewController{
//@interface GraphViewController : UIViewController{
    IBOutlet UIView *graphDbContainer;
    IBOutlet UIView *graphHzContainer;
    PointerData *pointerData;
    
    OsciGraph *graphOsciView; // temp
    HzLabelView *graphHzLabelView;
    DbLabelView2 *graphDbLabelView;
}
@property (retain, nonatomic) IBOutlet UIView *graphViewContainer;
//@property (nonatomic, strong) HomeViewController *homeVC;
@end


