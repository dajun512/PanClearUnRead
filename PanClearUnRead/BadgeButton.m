//
//  BadgeButton.m
//  PanClearUnRead
//
//  Created by pro on 2018/5/2.
//  Copyright © 2018年 ChenXiaoJun. All rights reserved.
//

#import "BadgeButton.h"

@interface BadgeButton() 

/** smallCircle */
@property (nonatomic,weak) UIView *smallCircleView;

/** shapeLayer */
@property (nonatomic,strong) CAShapeLayer *shapeLayer;


@end

@implementation BadgeButton{
    CGFloat _maxDistance; //两个圆心最大距离
}
#pragma mark - lazy
-(UIView *)smallCircleView
{
    if (!_smallCircleView) {
        CGFloat WH = self.bounds.size.width * 0.5;
        UIView *smallView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WH, WH)];
        smallView.layer.anchorPoint = CGPointMake(0.5, 0.5);
        smallView.center = self.center;
        smallView.backgroundColor = self.backgroundColor;
        smallView.layer.cornerRadius = WH * 0.5;
        _smallCircleView = smallView;
        [self.superview insertSubview:smallView belowSubview:self];
    }
    return _smallCircleView;
}

-(CAShapeLayer *)shapeLayer
{
    if (!_shapeLayer) {
        _shapeLayer = [CAShapeLayer layer];
        _shapeLayer.fillColor = self.backgroundColor.CGColor;
        [self.superview.layer insertSublayer:_shapeLayer below:self.layer];
    }
    return _shapeLayer;
}


/**
 代码初始化
 */
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setUp];
    }
    return self;
}


-(void)setUp
{
    self.backgroundColor = [UIColor redColor];
    self.layer.cornerRadius = self.bounds.size.width * 0.5;
    self.layer.masksToBounds = YES;
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.titleLabel.font = [UIFont systemFontOfSize:11.0f];
    //添加拖拽手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureHandle:)];
    [self addGestureRecognizer:pan];
    

    //圆心最大距离
    _maxDistance = self.layer.cornerRadius * 5;
    
    
}



/**
 拖拽手势
 */
-(void)panGestureHandle:(UIPanGestureRecognizer *)gesture
{
    CGPoint curP = [gesture translationInView:gesture.view];
    
    CGPoint centerP = self.center;
    centerP.x += curP.x;
    centerP.y += curP.y;
    self.center = centerP;
    [gesture setTranslation:CGPointZero inView:gesture.view];
    
    //计算两个圆心的距离
    CGFloat centerDistance = [self distanceWithPointA:self.center pointB:self.smallCircleView.center];
    
    if (centerDistance < _maxDistance) {
        //在范围内
        self.smallCircleView.hidden = NO;
        if (centerDistance > 0) {
            self.shapeLayer.path = [self pathWithBigCircleView:self smallCircleView:self.smallCircleView].CGPath;
        }
    }else{
        //超出范围
        [self.shapeLayer removeFromSuperlayer];
        self.shapeLayer = nil;
        self.smallCircleView.hidden = YES;
    }
    
    //手势结束时
    if (gesture.state == UIGestureRecognizerStateEnded) {
        if (centerDistance < _maxDistance) {
            //在范围内
            [self.shapeLayer removeFromSuperlayer];
            self.shapeLayer = nil;
            
            [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.center = self.smallCircleView.center;
            } completion:^(BOOL finished) {
                self.smallCircleView.hidden = NO;
            }];
        }else{
            //超出范围
            [self killAll];
        }
    }
    
    
    
    
    
    
    
    
}




/**
 画出路径
 */
-(UIBezierPath *)pathWithBigCircleView:(UIView *)bigView smallCircleView:(UIView *)smallView
{
    CGPoint bigCenter = bigView.center;
    CGFloat x2 = bigCenter.x;
    CGFloat y2 = bigCenter.y;
    CGFloat r2 = bigView.bounds.size.height / 2;
    
    CGPoint smallCenter = smallView.center;
    CGFloat x1 = smallCenter.x;
    CGFloat y1 = smallCenter.y;
    CGFloat r1 = smallView.bounds.size.width / 2;
    
    // 获取圆心距离
    CGFloat d = [self distanceWithPointA:self.smallCircleView.center pointB:self.center];
    CGFloat sinθ = (x2 - x1) / d;
    CGFloat cosθ = (y2 - y1) / d;
    
    // 坐标系基于父控件
    CGPoint pointA = CGPointMake(x1 - r1 * cosθ, y1 + r1 * sinθ);
    CGPoint pointB = CGPointMake(x1 + r1 * cosθ, y1 - r1 * sinθ);
    CGPoint pointC = CGPointMake(x2 + r2 * cosθ, y2 - r2 * sinθ);
    CGPoint pointD = CGPointMake(x2 - r2 * cosθ, y2 + r2 * sinθ);
    CGPoint pointO = CGPointMake(pointA.x + d / 2 * sinθ, pointA.y + d / 2 * cosθ);
    CGPoint pointP = CGPointMake(pointB.x + d / 2 * sinθ, pointB.y + d / 2 * cosθ);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    // A
    [path moveToPoint:pointA];
    // AB
    [path addLineToPoint:pointB];
    // 绘制BC曲线
    [path addQuadCurveToPoint:pointC controlPoint:pointP];
    // CD
    [path addLineToPoint:pointD];
    // 绘制DA曲线
    [path addQuadCurveToPoint:pointA controlPoint:pointO];
    
    return path;
}


/**
 计算两个圆心的距离
 */
-(CGFloat)distanceWithPointA:(CGPoint)pointA pointB:(CGPoint)pointB
{
    CGFloat offsetX = pointA.x - pointB.x;
    CGFloat offsetY = pointA.y - pointB.y;
    CGFloat dist = sqrtf(offsetX * offsetX + offsetY * offsetY);
    
    return dist;
}




/**
 设置未读数
 */
-(void)setUnreadValue:(NSInteger)value
{
    if (value <= 0) return [self killAll];
    
    NSString *valueStr = value <= 99 ? [[NSNumber numberWithInteger:value] stringValue] : @"..";
    [self setTitle:valueStr forState:UIControlStateNormal];
    
    self.smallCircleView.center = self.center;
}




/**
 删除未读数
 */
-(void)killAll
{
    [self removeFromSuperview];
    [self.smallCircleView removeFromSuperview];
    [self.shapeLayer removeFromSuperlayer];
}



/**
 取消高亮
 */
-(void)setHighlighted:(BOOL)highlighted{}

@end
