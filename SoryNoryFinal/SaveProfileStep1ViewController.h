

#import <UIKit/UIKit.h>
#import "SaveProfileStep2ViewController.h"

@interface SaveProfileStep1ViewController : UIViewController <UITextFieldDelegate, UIGestureRecognizerDelegate> {
    
    IBOutlet UITextField *theNameTextField;
}

@property (strong)NSMutableArray *leftDecibelData;
@property (strong)NSMutableArray *rightDecibelData;
@property (strong) UIViewController *parent;

- (IBAction)iconSelectAction:(UIButton *)sender;
- (IBAction)savedAndNextViewAction:(id)sender;

@end
