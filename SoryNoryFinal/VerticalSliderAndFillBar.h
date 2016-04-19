#import <UIKit/UIKit.h>

@interface VerticalSliderAndFillBar : UISlider {
    
    ///from 0.0 to 1.0
    volatile CGFloat fillPercent; ///fill bar (kind of progress bar)
}

///from 0.0 to 1.0
-(CGFloat) fillPercent;
///from 0.0 to 1.0
-(oneway void) setFillPercent:(CGFloat) percent;
@end
