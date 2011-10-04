/* Copyright 2011 Liberati Luca. All rights reserved. */

#import "LLPage.h"


LLPageMargins LLPageMarginsMake(CGFloat top, CGFloat left)
{
    LLPageMargins margin = { top, left };
    
    return margin;
}

LLPageScale LLPageScaleMake(CGFloat xScale, CGFloat yScale)
{
    LLPageScale scale = { xScale, yScale };
    
    return scale;
}


@implementation LLPage

@synthesize index=_index;
@synthesize scale=_scale;
@synthesize state=_state;


#pragma mark - Class lifecycle

- (id)initWithFrame:(CGRect)frame
{
    if ( !(self = [super initWithFrame:frame]) ) return nil;
    
    _index = NSNotFound;
    _scale = LLPageScaleMake(0.5, 0.5);
    _state = LLPageStateFullSize;
    
    return self;
}


#pragma mark - Public methods

- (NSString *)reuseIdentifier
{
    return [[self class] reuseIdentifier];
}

+ (NSString *)reuseIdentifier
{
    return NSStringFromClass([self class]);
}

- (void)prepareForReuse
{
    // in subclasses you can reset views here
}

- (void)toFullSizeAnimated:(BOOL)animated
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    if (animated)
    {
        [UIView animateWithDuration:0.1 animations:^(void) {
            
            self.transform = transform;
        }];
    }
    else
    {
        self.transform = transform;
    }
    
    _state = LLPageStateFullSize;
}

- (void)toThumbnailAnimated:(BOOL)animated
{
    CGAffineTransform scaleFinalStep = CGAffineTransformMakeScale(_scale.x, _scale.y);
    
    if (animated)
    {
        CGAffineTransform scaleStep1 = CGAffineTransformMakeScale(_scale.x + 0.1, _scale.y + 0.1);
        CGAffineTransform scaleStep2 = CGAffineTransformMakeScale(_scale.x - 0.1, _scale.y - 0.1);
        
        void(^step3Animation)(void) = ^(void) {
            
            [UIView animateWithDuration:0.1
                             animations:^(void) {
                                 
                                 self.transform = scaleFinalStep;
                             }];
        };
        
        void(^step2Animation)(void) = ^(void) {
            
            [UIView animateWithDuration:0.1
                             animations:^(void) {
                                 
                                 self.transform = scaleStep2;
                             }
                             completion:^(BOOL finished) {
                                 
                                 step3Animation();
                             }];
        };
        
        [UIView animateWithDuration:0.1
                         animations:^(void) {
                             
                             self.transform = scaleStep1;
                         }
                         completion:^(BOOL finished) {
                             
                             step2Animation();
                         }];
    }
    else
    {
        self.transform = scaleFinalStep;
    }
    
    [self setNeedsDisplay];
    
    _state = LLPageStateThumbnail;
}

@end
