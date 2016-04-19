//
//  GraphView.h
//  SoryNoryFinal
//
//  Created by 권지수 on 2015. 12. 16..
//  Copyright © 2015년 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum lineType{
    line = 0,
    dotted
}lineType;
@interface GraphView : UIView{
    UILabel *yPlusLabel;
    UILabel *yMinusLabel;
    UILabel *label0;
    UILabel *label1;
    UILabel *threshouldLabel;
    
    CGRect aRect;
    
    Float32 x_width;
    Float32 y_height;
    Float32 threshouldValue; // 좌표에 쓰이는 쓰레숄드 적용 후의 좌표값
    
//    Float32 threshould; // 쓰레숄드 변수
//    Float32 ratio; // 압축비율 변수
    
    BOOL isInit; // 초기화에 쓰이는 플래그
}
@property (nonatomic)  Float32 threshould;
@property (nonatomic)  Float32 ratio;

-(void)commonInit;
-(void) initLine;
@end
