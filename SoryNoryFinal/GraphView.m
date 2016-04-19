//
//  GraphView.m
//  SoryNoryFinal
//
//  Created by 권지수 on 2015. 12. 16..
//  Copyright © 2015년 Mac. All rights reserved.
//

#import "GraphView.h"

#define XY_SPACE_SIZE 20 // 기본 간격
#define LABEL_WIDTH 50 // 라벨 가로
#define LABEL_HEIGHT 30 // 라벨 세로
#define LINE_WIDTH 2 //  선 굵기

#define NORMAL_LINE 0
#define DOTTED_LINE 1

@implementation GraphView

@synthesize threshould;
@synthesize ratio;

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        // init code
        [self setBackgroundColor:[UIColor clearColor]];
        isInit = NO;
        NSLog(@"GraphView initwithFrame Success");
    }
    return self;
}
-(void)commonInit // 초기화
{
    //    라벨은  CGContextTranslateCTM(context, 0.0,self.frame.size.height); // 좌표 원점(0,0) 바꾸기 왼쪽위 -> 왼쪽 아래
//    CGContextScaleCTM(context, 1.0, -1.0); // 좌표 +- 바꾸기, 비율 바꾸기 (1.0 이상 / 이하시에만)
//    적용 안되는듯
    
    x_width = self.frame.size.width - XY_SPACE_SIZE;
    y_height = self.frame.size.height - LABEL_HEIGHT;
//    threshould = 0.5;
//    ratio = 5.0;
    
    threshouldValue = (x_width + LABEL_WIDTH) * threshould; // 임시
    
    
    
    yPlusLabel = [[UILabel alloc] initWithFrame:CGRectMake(XY_SPACE_SIZE - 5,XY_SPACE_SIZE + 10, LABEL_WIDTH, LABEL_HEIGHT)];
    [yPlusLabel setText:[NSString stringWithFormat:@"DB+"]];
    [yPlusLabel setFont:[UIFont systemFontOfSize:15]];
    [yPlusLabel setTextColor:[UIColor blackColor]];
    [yPlusLabel setTextAlignment:NSTextAlignmentCenter];
    [yPlusLabel sizeToFit];
    
    yMinusLabel = [[UILabel alloc]initWithFrame:CGRectMake(XY_SPACE_SIZE - 5, self.frame.size.height - XY_SPACE_SIZE * 2, LABEL_WIDTH, LABEL_HEIGHT)];
    [yMinusLabel setText:[NSString stringWithFormat:@"DB-"]];
    [yMinusLabel setFont:[UIFont systemFontOfSize:15]];
    [yMinusLabel setTextColor:[UIColor blackColor]];
    [yMinusLabel setTextAlignment:NSTextAlignmentCenter];
    [yMinusLabel sizeToFit];
    
    label0 = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_WIDTH, self.frame.size.height - LABEL_HEIGHT, LABEL_WIDTH, LABEL_HEIGHT)];
    [label0 setText:[NSString stringWithFormat:@"0"]];
    [label0 setFont:[UIFont systemFontOfSize:15]];
    [label0 setTextColor:[UIColor blackColor]];
    [label0 setTextAlignment:NSTextAlignmentCenter];
    [label0 sizeToFit];
    
    label1 = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - XY_SPACE_SIZE, self.frame.size.height - LABEL_HEIGHT, LABEL_WIDTH, LABEL_HEIGHT)];
    [label1 setText:[NSString stringWithFormat:@"1"]];
    [label1 setFont:[UIFont systemFontOfSize:15]];
    [label1 setTextColor:[UIColor blackColor]];
    [label1 setTextAlignment:NSTextAlignmentCenter];
    [label1 sizeToFit];
    
    threshouldLabel = [[UILabel alloc] initWithFrame:CGRectMake(threshouldValue - LABEL_WIDTH / 2, self.frame.size.height - LABEL_HEIGHT, LABEL_WIDTH, LABEL_HEIGHT)];
    [threshouldLabel setText:[NSString stringWithFormat:@"경계값"]];
    [threshouldLabel setFont:[UIFont systemFontOfSize:15]];
    [threshouldLabel setTextColor:[UIColor blackColor]];
    [threshouldLabel setTextAlignment:NSTextAlignmentCenter];
    
    [self addSubview:yPlusLabel];
    [self addSubview:yMinusLabel];
    [self addSubview:label0];
    [self addSubview:label1];
    [self addSubview:threshouldLabel];
    
//    [self initLine];

//    printf("x : %f   y: %f\n",x_width,y_height);
//    printf("x / 2 : %f   y / 2 : %f \n",x_width/2,y_height/2);
//    [self drawLineStartX:XY_SPACE_SIZE andStartY:XY_SPACE_SIZE andEndX:self.frame.size.width
//                 andEndY:XY_SPACE_SIZE andLineColor:[UIColor grayColor]];
//    [self drawLineStartX:XY_SPACE_SIZE andStartY:XY_SPACE_SIZE andEndX:XY_SPACE_SIZE
//                 andEndY:self.frame.size.height andLineColor:[UIColor grayColor]];    
}

// 그래프 그리기
-(void) initLine{
    CGContextRef context= UIGraphicsGetCurrentContext();
    CGContextClearRect(context, aRect);
    
    
    threshouldValue =  LABEL_WIDTH + ((x_width - LABEL_WIDTH) * threshould); // 임시
    printf("1\n");
    [self drawLineStartX:LABEL_WIDTH andStartY:LABEL_HEIGHT //가로
                 andEndX:self.frame.size.width - XY_SPACE_SIZE andEndY:LABEL_HEIGHT andLineColor:[UIColor grayColor] andLineType:line];
    printf("2\n");
    [self drawLineStartX:LABEL_WIDTH andStartY:LABEL_HEIGHT  // 세로
                 andEndX:LABEL_WIDTH andEndY:self.frame.size.height - LABEL_HEIGHT andLineColor:[UIColor grayColor] andLineType:line];
    printf("3\n");
    [self drawLineStartX:LABEL_WIDTH+LINE_WIDTH andStartY:LABEL_HEIGHT+LINE_WIDTH  // 기준 압축없는 직선그래프
                 andEndX:self.frame.size.width - XY_SPACE_SIZE andEndY:self.frame.size.height - LABEL_HEIGHT  andLineColor:[UIColor blueColor] andLineType:line];
    printf("4\n");
//    Float32 tempValue = ((y_height + LABEL_HEIGHT) / 2.0) + (((y_height + LABEL_HEIGHT) - (y_height + LABEL_HEIGHT) / 2.0) / 3.0) ;
    
    Float32 tempValue = [self computeRatioGraph:threshould andHeight:LABEL_HEIGHT + ((y_height - LABEL_HEIGHT)  * threshould) andRatio:ratio];
    NSLog(@"temp Value %@",[NSString stringWithFormat:@"%f",tempValue]);
    
//    [self drawLineStartX:threshouldValue andStartY:(y_height + LABEL_HEIGHT) / 2.0
//                 andEndX:x_width andEndY:(y_height + LABEL_HEIGHT) * 1.15 andLineColor:[UIColor orangeColor] andLineType:line]; // 압축 결과 보여주는 직선

    [self drawLineStartX:threshouldValue andStartY:LABEL_HEIGHT + ((y_height - LABEL_HEIGHT)  * threshould)
                 andEndX:x_width andEndY:tempValue andLineColor:[UIColor orangeColor] andLineType:line]; // 압축 결과 그리기
    printf("5\n");
    printf("start y : %f, end y : %f\n",LABEL_HEIGHT + ((y_height - LABEL_HEIGHT)  * threshould),tempValue);
    [self drawLineStartX:threshouldValue andStartY:LABEL_HEIGHT andEndX:threshouldValue andEndY:self.frame.size.height - LABEL_HEIGHT // threshould 세로 점선
            andLineColor:[UIColor redColor] andLineType:dotted];
    
//    Float32 tempValue = y_height - x_width;
//    [self drawLineStartX:threshouldValue andStartY:(y_height + LABEL_HEIGHT) / 2.0 andEndX:x_width andEndY:y_height * 0.7 andLineColor:[UIColor orangeColor] andLineType:line];
}

-(Float32) computeRatioGraph:(Float32)tempThreshould andHeight:(Float32)yLength andRatio:(Float32) tempRatio{ // 압축한 그래프 길이 구하기
    Float32 graphLangth;
    
    graphLangth = yLength + ((self.frame.size.height - LABEL_HEIGHT - yLength) / tempRatio) ;
    printf("whahahah? : %f \n",(yLength * tempThreshould) );
    printf("what? :%f \n",((yLength - (yLength * tempThreshould)) / tempRatio));
    printf("result : %f\n",graphLangth);
    return graphLangth;
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    
    CGContextRef context= UIGraphicsGetCurrentContext(); // 뷰의 컨텍스트 얻음
    CGContextTranslateCTM(context, 0.0,self.frame.size.height); // 좌표 원점(0,0) 바꾸기 왼쪽위 -> 왼쪽 아래
    CGContextScaleCTM(context, 1.0, -1.0); // 좌표 +- 바꾸기, 비율 바꾸기 (1.0 이상 / 이하시에만)
    
    aRect = rect;
    
    if(!isInit){
        threshould = 0.5;
        ratio = 5.0;
        [self commonInit];
        isInit = YES;
        NSLog(@"GraphView Init success");
    }else{
//        threshouldValue = (x_width + LABEL_WIDTH) * threshould; // 임시
//        CGPoint movePoint;
//        movePoint.x = threshouldValue - LABEL_WIDTH / 2;
//        movePoint.y = self.frame.size.height - LABEL_HEIGHT;
//        threshouldLabel.frame.origin.x= movePoint.x;
    }
//    [self initLine];
//    CGContextClearRect(context, rect);
//    [self initLine];
//    CGContextClearRect(context, rect);
//
//    [self initLine];
//    CGContextClearRect(context, rect);
//
//    [self initLine];
//    CGContextClearRect(context, rect);
//
//    [self initLine];
//    CGContextClearRect(context, rect);
    
    [self initLine];

    NSLog(@"drawRect");

}
//라인 그리기
-(void)drawLineStartX:(CGFloat)startX andStartY:(CGFloat)startY andEndX:(CGFloat)endX andEndY:(CGFloat)endY andLineColor:(UIColor *)color andLineType:(lineType)type{
    CGContextRef context= UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2.0); // 두께 설정
    CGContextSetStrokeColorWithColor(context, color.CGColor); // 선색 설정
    CGFloat dashArray[] = {7,2};

    switch (type) {
        case line:
            CGContextMoveToPoint(context, startX, startY);
            CGContextAddLineToPoint(context, endX, endY);
            CGContextStrokePath(context);
            break;
        case dotted:
            CGContextSetLineWidth(context, 3.0);
            CGContextSetLineDash(context, 2, dashArray, 2);
            CGContextMoveToPoint(context, startX, startY);
            CGContextAddLineToPoint(context, endX, endY);
            CGContextStrokePath(context);
            CGContextSetLineDash(context, 0, NULL, 0); // 점선 삭제
            break;
    }
    
//    CGContextStrokePath(context);
    [self setNeedsDisplay];
}
//-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
//{
//    [self setBackgroundColor:[UIColor clearColor]];
//    //    displayHz = [[UILabel alloc] initWithFrame:CGRectMake(xyPoint.x,xyPoint.y+10, 30, 20)];
//    //    [displayHz setText:[NSString stringWithFormat:@"Hz"]];
//    //    [displayHz setFont:[UIFont systemFontOfSize:15]];
//    //    [displayHz setTextColor:[UIColor darkGrayColor]];
//    
////    CGContextRef context= UIGraphicsGetCurrentContext(); // 뷰의 컨텍스트 얻음
////    CGContextTranslateCTM(ctx, 0.0,self.frame.size.height); // 좌표 원점(0,0) 바꾸기 왼쪽위 -> 왼쪽 아래
////    CGContextScaleCTM(ctx, 1.0, -1.0); // 좌표 +- 바꾸기, 비율 바꾸기 (1.0 이상 / 이하시에만)
////    
////    yPlusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
////    [yPlusLabel setText:[NSString stringWithFormat:@"DB+"]];
////    [yPlusLabel setFont:[UIFont systemFontOfSize:15]];
////    [yPlusLabel setTextColor:[UIColor blackColor]];
//    
//    NSLog(@"compressSetup drawLayer123123123123123");
//    
//}


@end
