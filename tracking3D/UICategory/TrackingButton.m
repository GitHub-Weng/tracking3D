//
//  TrackingButton.m
//  Real-time-Tracking-iOS
//
//  Created by wengdada on 12/03/2018.
//  Copyright © 2018 ShenZhen University. All rights reserved.
//

#import "TrackingButton.h"
#import "UIView+Extension.h"

@interface TrackingButton()
@property (nonatomic, strong) UILabel *appNameLabel;
@property (nonatomic, strong) UIButton *appButton;
@end

@implementation TrackingButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        CGRect appBtnFrame = CGRectMake(0, 0, frame.size.width, frame.size.width);
        self.appButton = [[UIButton alloc]initWithFrame:appBtnFrame];
        float cornerRadius = frame.size.width/6;
        self.appButton.layer.cornerRadius = cornerRadius;
        self.appButton.layer.masksToBounds = YES;
        
        self.appNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.appButton.width+5, self.appButton.width, frame.size.height - self.appButton.width)];
        self.appNameLabel.textColor = [UIColor whiteColor];
        [self.appNameLabel setText:@""];
        self.appNameLabel.font = [UIFont systemFontOfSize:12];
        self.appNameLabel.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:self.appButton];
        [self addSubview:self.appNameLabel];
        
        [self addTarget:self action:@selector(singleClick) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(longPressUp) forControlEvents:UIControlEventTouchDragOutside];
        [self addTarget:self action:@selector(longPressDown) forControlEvents:UIControlEventTouchUpOutside];
        
    }
    return self;
}
//将按钮透明度变为一半
-(void)singleClick{
    if(self.appButton.alpha == 1){
        self.appButton.alpha = 0.5;
    }else{
        self.appButton.alpha = 1;
    }
    
}

//定义为删除操作
-(void)longPressUp
{
    [self imgAnimate:self.appButton];
}
//定义为按钮抖动
-(void)longPressDown
{
     [self shakeToShow:self.appButton];
}

-(void)shakeToShow:(UIButton *)button
{
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 2.0;
    
    NSMutableArray *values = [NSMutableArray array];
    
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];

    animation.values = values;
    
    [button.layer addAnimation:animation forKey:nil];
}

//btn变大变小的效果
- (void)imgAnimate:(UIButton*)btn{
    UIView *view=btn.subviews[0];
    [UIView animateWithDuration:0.1 animations:
     ^(void){
         view.transform = CGAffineTransformScale(CGAffineTransformIdentity,0.8, 0.8);
     } completion:^(BOOL finished){//do other thing
         [UIView animateWithDuration:0.2 animations:
          ^(void){
              view.transform = CGAffineTransformScale(CGAffineTransformIdentity,1.2, 1.2);
          } completion:^(BOOL finished){//do other thing
              [UIView animateWithDuration:0.1 animations:
               ^(void){
                   view.transform = CGAffineTransformScale(CGAffineTransformIdentity,1,1);
               } completion:^(BOOL finished){//do other thing
               }];
          }];
     }];
}

-(void)setAppNameLabelText:(NSString*)appName{
    [self.appNameLabel setText:appName];
}
-(void)setImage:(UIImage *)image forState:(UIControlState)state{
    [self.appButton setImage:image forState:state];
}


@end
