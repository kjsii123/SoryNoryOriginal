#import "VerticalSliderAndFillBar.h"


@implementation VerticalSliderAndFillBar

- (id)initWithCoder:(NSCoder *)decoder
{
    printf("initWithCoder \n");
	self = [super initWithCoder:decoder];
	if (self) {
		[self initVerticalSlider];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
    printf("initWithFrame \n");
	self = [super initWithFrame:frame];
	if (self) {
		[self initVerticalSlider];
	}
	return self;
}

- (void)initVerticalSlider
{
    fillPercent = 0.0;
    self.clipsToBounds = NO;
    self.backgroundColor = [UIColor clearColor];

    CGRect rect = self.frame;
    self.transform = CGAffineTransformMakeRotation(-M_PI_2);
    self.frame = rect;
    
//	[self setThumbImage:[self thumbImageForState:UIControlStateNormal] forState:UIControlStateNormal];  kjs add joosuk
//	[self setThumbImage:[self thumbImageForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
//	[self setThumbImage:[self thumbImageForState:UIControlStateSelected] forState:UIControlStateSelected];
//	[self setThumbImage:[self thumbImageForState:UIControlStateDisabled] forState:UIControlStateDisabled]; kjs add end joosuk
    
    [self setMinimumTrackTintColor:[UIColor clearColor]];
    [self setMaximumTrackTintColor:[UIColor clearColor]];
    
    [self setThumbImage:[self rotatedImage:[UIImage imageNamed:@"phonesVertSliderThumb"] ] forState:UIControlStateNormal];
}


-(CGFloat) fillPercent {
    return fillPercent;
}

-(void) setFillPercent:(CGFloat) percent {
    fillPercent = percent;
    if (fillPercent>1.0) { fillPercent = 1.0; }
    if (fillPercent<0.0) { fillPercent = 0.0; }
//    [self.layer setNeedsDisplay];
}


-(void) drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextRotateCTM(ctx, M_PI_2);
    CGContextTranslateCTM(ctx, 0, -self.frame.size.height);
    
    //white line
    CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(ctx, 22);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    CGFloat marginOffset = 12.0;
    CGPoint topP = CGPointMake(self.frame.size.width/2.0, marginOffset);
    CGPoint bottomP = CGPointMake(self.frame.size.width/2.0, self.frame.size.height-marginOffset);
    CGContextMoveToPoint(ctx, topP.x, topP.y);
    CGContextAddLineToPoint(ctx, bottomP.x, bottomP.y);
    CGContextStrokePath(ctx);
    
    //black inner line
    CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithRed:91/255.0 green:105/255.0 blue:108/255.0 alpha:1].CGColor);
    CGContextSetLineWidth(ctx, 8);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    
    marginOffset = 16.0;
    topP = CGPointMake(self.frame.size.width/2.0, marginOffset);
    bottomP = CGPointMake(self.frame.size.width/2.0, self.frame.size.height-marginOffset);
    CGContextMoveToPoint(ctx, topP.x, topP.y);
    CGContextAddLineToPoint(ctx, bottomP.x, bottomP.y);
    CGContextStrokePath(ctx);
    
    
    //blue fill bar
    CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithRed:19/255.0 green:181/255.0 blue:203/255.0 alpha:1].CGColor);
    CGContextSetLineWidth(ctx, 8);
//    CGContextMoveToPoint(ctx, topP.x, topP.y+10);
//    printf("what the fuck\n");
//    CGContextAddLineToPoint(ctx, bottomP.x, bottomP.y);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    
    //will draw from the bottom
    marginOffset = 16.0;
    bottomP = CGPointMake(self.frame.size.width/2.0, self.frame.size.height-marginOffset);
    CGFloat barHite = (self.frame.size.height-marginOffset/2.0) * fillPercent;
    CGContextMoveToPoint(ctx, bottomP.x, bottomP.y);
    CGContextAddLineToPoint(ctx, bottomP.x, bottomP.y-barHite);
    CGContextStrokePath(ctx);
    }


- (UIImage *)rotatedImage:(UIImage *)image
{
	if (!image) { return nil; }
    CGFloat factor = 0.6;
//    UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.height*factor, image.size.width*factor),
//                                           NO, image.scale); kjs add joosuk
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.frame.size.height, image.size.width*factor),
                                           NO, image.scale);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextRotateCTM(context, M_PI_2);
//    [image drawInRect:CGRectMake(0.0, -image.size.height*factor,
//                                 image.size.height*factor,
//                                 image.size.width*factor)]; kjs add joosuk end
    [image drawInRect:CGRectMake(0.0, -20.0*fillPercent,
                                 image.size.height*factor,
                                 image.size.width*factor)];
    printf("rotateImage\n");
    
    
    return UIGraphicsGetImageFromCurrentImageContext();
}
@end
