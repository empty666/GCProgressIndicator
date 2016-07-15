//
//  GCIndicator.m
//  ViewTest
//
//  Created by Empty666 on 2016. 7. 13..
//  Copyright © 2016년 empty666. All rights reserved.
//

#import "GCIndicator.h"

#define GC_INDICATOR_STROKE_END_ANIMATION               @"GC_STROKE_END"
#define GC_INDICATOR_STROKE_START_ANIMATION             @"GC_STROKE_START"
#define GC_GRADIENT_RATATION_ANIMATION                  @"GC_GRADIENT_ROTATE"
#define GC_FADE_OUT_ANIMATION                           @"GC_FADE_OUT"

#define GC_DEFAULT_STROKE_ANIMATION_DURATION            2.0
#define GC_DEFAULT_SPIN_GRADIENT_DURATION               4.0
#define GC_DEFAULT_FADE_OUT_DURATION                    0.3


@interface GCIndicator ()

@property (nonatomic, strong) CAShapeLayer *circleLayer;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@end

@implementation GCIndicator

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame andLineWidth:(CGFloat)lineWith andColors:(NSArray *)colors
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        _lineWidth = lineWith;
        _colors = colors;
    
        _indicatorDuration = GC_DEFAULT_STROKE_ANIMATION_DURATION;
        _spinBackgroundDuration = GC_DEFAULT_SPIN_GRADIENT_DURATION;
        
        [self createCircleLayer];
    }
    
    return self;
}

- (void)createCircleLayer
{
    CAShapeLayer *circle = [CAShapeLayer layer];
    
    [circle setFillColor:[[UIColor clearColor] CGColor]];
    [circle setStrokeColor:[[UIColor redColor] CGColor]];
    [circle setLineWidth:_lineWidth];
    [circle setLineCap:kCALineCapRound];
    
    CGPoint center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    CGFloat startAngle = -M_PI_2;
    CGFloat endAngle = startAngle + (M_PI * 2);
    
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:center
                                                              radius:(CGRectGetWidth(self.bounds) / 2) - _lineWidth
                                                          startAngle:startAngle
                                                            endAngle:endAngle
                                                           clockwise:YES];
    
    [circle setPath:[circlePath CGPath]];

    CAGradientLayer *gradient = [CAGradientLayer layer];
    
    [gradient setStartPoint:CGPointMake(0.5, 1.0)];
    [gradient setEndPoint:CGPointMake(0.5, 0.0)];
    [gradient setFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
    
    NSMutableArray *circleColors = [NSMutableArray array];
    for (UIColor *color in _colors)
    {
        [circleColors addObject:(id)[color CGColor]];
    }
    
    [gradient setColors:circleColors];
    [gradient setMask:circle];
    
    _circleLayer = circle;
    _gradientLayer = gradient;
}

#pragma mark - Paly Method

- (void)drawViewInitialize
{
    if ([[self layer] sublayers].count == 0)
    {
        _circleLayer = nil;
        _gradientLayer = nil;
        
        [self createCircleLayer];
        [[self layer] addSublayer:_gradientLayer];
    }
}

- (void)playIndicator
{
    [self drawViewInitialize];
    
    [_circleLayer addAnimation:[self strokeEndAnimationWithDuration:_indicatorDuration] forKey:GC_INDICATOR_STROKE_END_ANIMATION];
    [_circleLayer addAnimation:[self strokeStartAnimationWithDuration:_indicatorDuration] forKey:GC_INDICATOR_STROKE_START_ANIMATION];
    [_gradientLayer addAnimation:[self rotationBackgroundAnimationWithDuration:_spinBackgroundDuration] forKey:GC_GRADIENT_RATATION_ANIMATION];
}

- (void)stopIndicator
{
    [_circleLayer addAnimation:[self stopFadeOutAnimation] forKey:GC_FADE_OUT_ANIMATION];
}

#pragma mark - Animation Methods

- (CAAnimationGroup *)strokeEndAnimationWithDuration:(CGFloat)duration
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    
    [animation setDuration:duration];
    [animation setFromValue:[NSNumber numberWithFloat:0.0f]];
    [animation setToValue:[NSNumber numberWithFloat:1.0f]];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    
    [group setRepeatCount:MAXFLOAT];
    [group setDuration:duration + 0.5];
    [group setAnimations:@[animation]];
    
    return group;
}

- (CAAnimationGroup *)strokeStartAnimationWithDuration:(CGFloat)duration
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    
    [animation setBeginTime:0.5];
    [animation setDuration:duration];
    [animation setFromValue:[NSNumber numberWithFloat:0.0f]];
    [animation setToValue:[NSNumber numberWithFloat:1.0f]];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    [group setRepeatCount:MAXFLOAT];
    [group setDuration:duration + 0.5];
    [group setAnimations:@[animation]];
    
    return group;
}

- (CABasicAnimation *)rotationBackgroundAnimationWithDuration:(CGFloat)duration
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    
    [animation setDuration:duration];
    [animation setFromValue:[NSNumber numberWithFloat:0.0]];
    [animation setToValue:[NSNumber numberWithFloat:M_PI * 2]];
    [animation setRepeatCount:MAXFLOAT];
    
    return animation;
}

- (CABasicAnimation *)stopFadeOutAnimation
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    
    [animation setFromValue:[NSNumber numberWithFloat:1.0f]];
    [animation setToValue:[NSNumber numberWithFloat:0.0f]];
    [animation setDuration:GC_DEFAULT_FADE_OUT_DURATION];
    [animation setRepeatCount:1];
    [animation setRemovedOnCompletion:YES];
    [animation setFillMode:kCAFillModeBoth];
    [animation setAdditive:NO];
    [animation setDelegate:self];
    
    return animation;
}

#pragma mark - CAAnimation Delegate Methods

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [_circleLayer removeFromSuperlayer];
    [_gradientLayer removeFromSuperlayer];
    
    [_circleLayer removeAllAnimations];
    [_gradientLayer removeAllAnimations];
}

@end
