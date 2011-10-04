/* Copyright 2011 Liberati Luca. All rights reserved. */

/** LLPageMargins represents the margins at left and top sides of the page */
typedef struct
{
    CGFloat top;
    CGFloat left;
} LLPageMargins;
extern LLPageMargins LLPageMarginsMake(CGFloat top, CGFloat left);

/** LLPageScale will be used to scale the page when in thumbnail mode */
typedef struct
{
    CGFloat x;
    CGFloat y;
} LLPageScale;
extern LLPageScale LLPageScaleMake(CGFloat xScale, CGFloat yScale);

/** The current state of the page */
typedef enum
{
    LLPageStateFullSize,
    LLPageStateThumbnail
} LLPageState;


/** LLPageView represents a page in LLPageScroller */
@interface LLPage : UIView

@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, assign) LLPageScale scale;
@property (nonatomic, assign, readonly) LLPageState state;

/** */
+ (NSString *)reuseIdentifier;

/** */
- (NSString *)reuseIdentifier;

/** */
- (void)prepareForReuse;

/** */
- (void)toFullSizeAnimated:(BOOL)animated;

/** */
- (void)toThumbnailAnimated:(BOOL)animated;


@end
