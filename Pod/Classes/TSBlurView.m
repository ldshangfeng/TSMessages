//
//  TSBlurView.m
//  Pods
//
//  Created by Felix Krause on 20.08.13.
//
//

#import "TSBlurView.h"
#import "TSMessage.h"
#import <QuartzCore/QuartzCore.h>

@interface TSBlurView ()

@property (nonatomic, strong) UIToolbar *toolbar;

@end

@implementation TSBlurView

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        if([TSMessage iOS10StyleEnabled]) {
            self.layer.cornerRadius = 10;
            self.layer.masksToBounds = YES;
        }
    }
    return self;
}

- (UIView *)titleView {
    if (!_titleView) {
        _titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 30)];
        _titleView.autoresizingMask = UIViewAutoresizingFlexibleWidth;

        [self addSubview:_titleView];
        [self bringSubviewToFront:_titleView];
    }
    return _titleView;
}


- (UIToolbar *)toolbar
{
    if (_toolbar == nil) {
        _toolbar = [[UIToolbar alloc] initWithFrame:self.bounds];
        _toolbar.userInteractionEnabled = NO;
        _toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _toolbar.alpha = 1;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
        [_toolbar setBackgroundImage:nil forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsCompact]; // remove background set through the appearence proxy
#endif
        [self addSubview:_toolbar];
    }

    return _toolbar;
}

- (void)setBlurTintColor:(UIColor *)blurTintColor
{
    if ([TSMessage iOS10StyleEnabled]) {
        if ([self.titleView respondsToSelector:@selector(setBackgroundColor:)]) {
            [self.titleView performSelector:@selector(setBackgroundColor:) withObject:blurTintColor];
        }
        NSAssert([self canProvideRGBComponents:blurTintColor], @"Must be an RGB color");
        const CGFloat *c = CGColorGetComponents(blurTintColor.CGColor);
        CGFloat red = c[0];
        CGFloat green = c[1];
        CGFloat blue = c[2];
        if ([self colorSpaceModel:blurTintColor] == kCGColorSpaceModelMonochrome) {
            green = c[0];
            blue = c[0];
        }
        UIColor *backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:0.98];
        self.backgroundColor = backgroundColor;
    } else {
        if ([self.toolbar respondsToSelector:@selector(setBarTintColor:)]) {
            [self.toolbar performSelector:@selector(setBarTintColor:) withObject:blurTintColor];
        }
    }
    
}

- (UIColor *)blurTintColor
{
    if ([self.toolbar respondsToSelector:@selector(barTintColor)]) {
        return [self.toolbar performSelector:@selector(barTintColor)];
    }
    return nil;
}
- (CGColorSpaceModel)colorSpaceModel:(UIColor *)color {
    return CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor));
}

- (BOOL)canProvideRGBComponents:(UIColor *)color {
    switch ([self colorSpaceModel:color]) {
        case kCGColorSpaceModelRGB:
        case kCGColorSpaceModelMonochrome:
            return YES;
        default:
            return NO;
    }
}
@end
