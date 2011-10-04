//  Copyright 2011 Liberati Luca. All rights reserved.

#import "ArtworkScrollerViewController.h"


@implementation ArtworkScrollerViewController

@synthesize scroller=_scroller;


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    
    _scroller = [[LLPageScroller alloc] initWithFrame:appFrame];
    _scroller.backgroundColor = [UIColor lightGrayColor];
    _scroller.delegate = self;
    _scroller.dataSource = self;
    _scroller.pageMargins = LLPageMarginsMake(0.0f, 10.0f);
    _scroller.pageSize = CGSizeMake(320.0f, 320.0f);
    _scroller.pageSizeThumbnail = CGSizeMake(200.0f, 200.0f);
    _scroller.showTitle = YES;
    _scroller.titleLabel.text = @"Page 1";
    
    [self.view addSubview:_scroller];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.scroller = nil;
}


#pragma mark - LLPageScroller

- (NSUInteger)numberOfPagesForPageScroller:(LLPageScroller *)pageScroller
{
    return 6;
}

- (void)configurePage:(LLPage *)page forIndex:(NSUInteger)index
{
    UIImage *image = [UIImage imageNamed:@"artwork.jpg"];
    UIImageView *artwork = [[UIImageView alloc] initWithImage:image];
    artwork.frame = page.bounds;
    
    [page addSubview:artwork];
    
    [artwork release];
}

- (LLPage *)pageScroller:(LLPageScroller *)pageScroller pageForIndex:(NSUInteger)index
{
    LLPage *page = [pageScroller dequeueReusablePageWithReuseIdentifier:[LLPage reuseIdentifier]];
    
    if (page == nil)
    {
        page = [[[LLPage alloc] initWithFrame:CGRectZero] autorelease];
    }
    
    return page;
}

- (void)pageScroller:(LLPageScroller *)pageScroller didScrollToPageIndex:(NSUInteger)index
{
    _scroller.titleLabel.text = [NSString stringWithFormat:@"Page %i", index + 1];
}

@end
