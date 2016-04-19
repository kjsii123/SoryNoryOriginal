

#import "HelpPageViewController.h"

@interface HelpPageViewController ()

@end

@implementation HelpPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@" Help Page Presented");
}



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


- (IBAction)cancleView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
