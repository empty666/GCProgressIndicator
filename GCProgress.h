//
//  GCProgress.h
//  ViewTest
//
//  Created by Empty666 on 2016. 7. 13..
//  Copyright © 2016년 empty666. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GCProgress : UIView

@property (nonatomic) CGFloat lineWidth;
@property (nonatomic, strong) NSArray *colors;
@property (nonatomic) CGFloat fontSize;
@property (nonatomic, strong) NSString *fontName;

@property (nonatomic) CGFloat indicatorDuration;
@property (nonatomic) CGFloat spinBackgroundDuration;

- (instancetype)initWithFrame:(CGRect)frame andLineWidth:(CGFloat)lineWith andColors:(NSArray *)colors;

- (void)startProgress;
- (void)updateProgress:(CGFloat)progress;
- (void)endProgress;
@end
