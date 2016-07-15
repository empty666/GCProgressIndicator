//
//  GCProgress.m
//  ViewTest
//
//  Created by Empty666 on 2016. 7. 13..
//  Copyright © 2016년 empty666. All rights reserved.
//

#import "GCProgress.h"

#define GC_INDICATOR_STROKE_END_ANIMATION               @"GC_STROKE_END"
#define GC_INDICATOR_STROKE_START_ANIMATION             @"GC_STROKE_START"

#define GC_PROGRESS_ANIMATION                           @"GC_PROGRESS"

#define GC_GRADIENT_RATATION_ANIMATION                  @"GC_GRADIENT_ROTATE"
#define GC_FADE_OUT_ANIMATION                           @"GC_FADE_OUT"

#define GC_DEFAULT_STROKE_ANIMATION_DURATION            2.0
#define GC_DEFAULT_SPIN_GRADIENT_DURATION               4.0
#define GC_DEFAULT_FADE_OUT_DURATION                    0.3
#define GC_DEFAULT_PROGRESS_LABEL_FONT_SIZE             40.0
#define GC_DEFAULT_PROGRESS_LABEL_FONT_NAME             @"HelveticaNeue-UltraLight"

@interface GCProgress ()

@property (nonatomic, strong) CAShapeLayer *circleLayer;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, strong) UILabel *progressLabel;

@end

@implementation GCProgress

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

        _fontSize = GC_DEFAULT_PROGRESS_LABEL_FONT_SIZE;
        _fontName = GC_DEFAULT_PROGRESS_LABEL_FONT_NAME;

        _indicatorDuration = GC_DEFAULT_STROKE_ANIMATION_DURATION;
        _spinBackgroundDuration = GC_DEFAULT_SPIN_GRADIENT_DURATION;
        
        [self createProgressLabel];
        [self createCircleLayer];

    }
    
    return self;
}

#pragma mark - Setup UI

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
    
    [circle setStrokeStart:0.0];
    [circle setStrokeEnd:0.0];
    
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

- (void)createProgressLabel
{
    _progressLabel = [[UILabel alloc] init];
    [_progressLabel setBackgroundColor:[UIColor clearColor]];

    [_progressLabel setText:@"0 %"];
    [_progressLabel setTextColor:[UIColor blackColor]];
    [_progressLabel setTextAlignment:NSTextAlignmentCenter];
    [_progressLabel setFont:[UIFont fontWithName:_fontName size:_fontSize]];
    _progressLabel.font = [_progressLabel.font fontWithSize:_fontSize];
    
    [_progressLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [_progressLabel setAlpha:0.0];
    [UIView animateWithDuration:GC_DEFAULT_FADE_OUT_DURATION
                     animations:^{
                         [_progressLabel setAlpha:1.0];
                     }];
}

#pragma mark - Paly Method

- (void)drawViewInitialize
{
    if ([[self layer] sublayers].count == 0)
    {
        _circleLayer = nil;
        _gradientLayer = nil;
        _progressLabel = nil;
        
        [self createCircleLayer];
        [self createProgressLabel];
        
        [[self layer] addSublayer:_gradientLayer];
        
        [self addSubview:_progressLabel];
        
        // Add Progress Label Constraint
        NSLayoutConstraint *xCenterLayout = [NSLayoutConstraint constraintWithItem:self
                                                                         attribute:NSLayoutAttributeCenterX
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:_progressLabel
                                                                         attribute:NSLayoutAttributeCenterX
                                                                        multiplier:1.0
                                                                          constant:0];
        
        NSLayoutConstraint *yCenterLayout = [NSLayoutConstraint constraintWithItem:self
                                                                         attribute:NSLayoutAttributeCenterY
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:_progressLabel
                                                                         attribute:NSLayoutAttributeCenterY
                                                                        multiplier:1.0
                                                                          constant:0];
        
        [self addConstraint:xCenterLayout];
        [self addConstraint:yCenterLayout];
    }
}

- (void)startProgress
{
    [self drawViewInitialize];
    
    [_gradientLayer addAnimation:[self rotationBackgroundAnimationWithDuration:_spinBackgroundDuration] forKey:GC_GRADIENT_RATATION_ANIMATION];
}

- (void)updateProgress:(CGFloat)progress
{
    if (progress > 1.0)
    {
        progress = 1.0;
    }
    
    [_circleLayer addAnimation:[self updateProgressAnimationWithProgress:progress] forKey:GC_PROGRESS_ANIMATION];
    [_circleLayer setStrokeEnd:progress];

    if (! [_gradientLayer animationForKey:GC_GRADIENT_RATATION_ANIMATION])
    {
         [_gradientLayer addAnimation:[self rotationBackgroundAnimationWithDuration:_spinBackgroundDuration] forKey:GC_GRADIENT_RATATION_ANIMATION];
    }
    
    [[self layer] addSublayer:_gradientLayer];
    
    [_progressLabel setText:[NSString stringWithFormat:@"%@ %%", [NSNumber numberWithFloat:progress * 100]]];

}

- (void)endProgress
{
    [_circleLayer addAnimation:[self stopFadeOutAnimation] forKey:GC_FADE_OUT_ANIMATION];
    [UIView animateWithDuration:GC_DEFAULT_FADE_OUT_DURATION
                     animations:^{
                         [_progressLabel setAlpha:0.0];
                     }];
}

#pragma mark - Animation Methods

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

- (CABasicAnimation *)updateProgressAnimationWithProgress:(CGFloat)progress
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    
    [animation setFromValue:[NSNumber numberWithFloat:[_circleLayer strokeEnd]]];
    [animation setToValue:[NSNumber numberWithFloat:progress]];
    [animation setDuration:0.2];
    [animation setFillMode:kCAFillModeForwards];

    return animation;
}

#pragma mark - CAAnimation Delegate Methods

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [_circleLayer removeFromSuperlayer];
    [_gradientLayer removeFromSuperlayer];
    [_progressLabel removeFromSuperview];
    
    [_circleLayer removeAllAnimations];
    [_gradientLayer removeAllAnimations];
}

@end
