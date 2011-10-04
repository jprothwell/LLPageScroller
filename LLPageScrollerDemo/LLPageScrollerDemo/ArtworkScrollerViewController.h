//  Copyright 2011 Liberati Luca. All rights reserved.

#import "LLPageScroller.h"


@interface ArtworkScrollerViewController : UIViewController
<LLPageScrollerDelegate, LLPageScrollerDataSource>

@property (nonatomic, retain) LLPageScroller *scroller;

@end
