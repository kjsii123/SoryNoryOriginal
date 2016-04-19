

#import "DottedThumRedSwitch.h"

@implementation DottedThumRedSwitch

-(id) init {
    self = [super init];
    if (self) { [self commonInit]; }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) { [self commonInit]; }
    return self;
}

-(id) initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) { [self commonInit]; }
    return self;
}

-(void) commonInit {
    NSLog(@" DottedThumRedSwitch commont init ");
    
}




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
