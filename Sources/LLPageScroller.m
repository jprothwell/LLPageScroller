/* Copyright 2010 Liberati Luca. All rights reserved. */

#import "LLPageScroller.h"
#import "LLPageScroller+Private.h"


@interface LLPageScroller ()
@property (nonatomic, assign) NSUInteger numberOfPages;
@property (nonatomic, retain) NSMutableSet *visiblePages;
@property (nonatomic, retain) NSMutableDictionary *reusablePages;
- (void)enqueuePage:(LLPage *)page;
- (CGRect)rectForPageThumbnailAtIndex:(NSUInteger)index;
@end


@implementation LLPageScroller

// private
@synthesize numberOfPages=_numberOfPages;
@synthesize visiblePages=_visiblePages;
@synthesize reusablePages=_reusablePages;
// public
@synthesize delegate=_delegate;
@synthesize dataSource=_dataSource;
@synthesize scrollView=_scrollView;
@synthesize titleLabel=_titleLabel;
@synthesize showTitle=_showTitle;
@synthesize mode;
@synthesize pageSize=_pageSize;
@synthesize pageSizeThumbnail=_pageSizeThumbnail;
@synthesize pageMargins=_pageMargins;
@synthesize currentPage=_currentPage;
@synthesize selectedPage=_selectedPage;


#pragma mark - Class lifecycle

- (void)dealloc
{
    _delegate = nil;
    _dataSource = nil;
    _selectedPage = nil;
    
    [_scrollView release];
    [_titleLabel release];
    [_visiblePages release];
    [_reusablePages release];
    
    [super dealloc];
}

- (void)commonInit
{
    self.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    self.clipsToBounds = YES;
    
    _numberOfPages = 0;
    _pageSize = CGSizeMake(self.bounds.size.width, self.bounds.size.width);
    _pageSizeThumbnail = CGSizeMake(200.0f, 200.0f);
    _pageMargins = LLPageMarginsMake(0.0f, 10.0f);
    _visiblePages = [[NSMutableSet alloc] init];
    _reusablePages = [[NSMutableDictionary alloc] init];
    
    _flags.mode = LLPageScrollerModeThumbnails;
    _flags.shouldUpdate = YES;
    
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.clipsToBounds = NO;
    _scrollView.delaysContentTouches = NO;
    _scrollView.delegate = self;
    _scrollView.pagingEnabled = YES;
    _scrollView.scrollsToTop = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    [self addSubview:_scrollView];
    
    CGRect titleLabelFrame = {
        0.0f,
        self.bounds.size.height - 65.0f,
        self.bounds.size.width,
        65.0f
    };
    _titleLabel = [[UILabel alloc] initWithFrame:titleLabelFrame];
    _titleLabel.adjustsFontSizeToFitWidth = NO;
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    _titleLabel.numberOfLines = 0;
    _titleLabel.text = @"title";
    _titleLabel.textAlignment = UITextAlignmentCenter;
    _titleLabel.textColor = [UIColor whiteColor];
    // label shadow
    _titleLabel.shadowColor = [UIColor blackColor];
    _titleLabel.shadowOffset = CGSizeMake(0.0f, -1.0f);
    _titleLabel.layer.shadowColor = [[UIColor blackColor] CGColor];
    _titleLabel.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    _titleLabel.layer.shadowOpacity = 0.75f;
    _titleLabel.layer.shadowRadius = 4.0f;
    _titleLabel.layer.shouldRasterize = YES;
    
    _showTitle = NO;
    
    // a tap will select the current view, displaying it full size
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
    [tapGesture addTarget:self action:@selector(handleTap:)];
    [_scrollView addGestureRecognizer:tapGesture];
    [tapGesture release];
    
    // a pinch in will deselect the current view, displaying the thumbnails
    // also will support pinch out, its behavior is the same as the tap one
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] init];
    [pinchGesture addTarget:self action:@selector(handlePinch:)];
    [self addGestureRecognizer:pinchGesture];
    [pinchGesture release];
    
    [self addObserver:self forKeyPath:@"showTitle" options:NSKeyValueObservingOptionNew context:NULL];
}

- (id)initWithFrame:(CGRect)frame
{
    if ( !(self = [super initWithFrame:frame]) ) return nil;
    
    [self commonInit];
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ( !(self = [super initWithCoder:aDecoder]) ) return nil;
    
    [self commonInit];
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_flags.shouldUpdate)
    {
        [self reloadData];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"showTitle"])
    {
        if (_showTitle)
        {
            [self addSubview:_titleLabel];
        }
        else
        {
            [_titleLabel removeFromSuperview];
        }
    }
}


#pragma mark Touch Handling

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    // check which UIView is touched
    UIView *hitView = [super hitTest:point withEvent:event];
    
    if ([hitView isEqual:self]) return _scrollView;
    
    return hitView;
}

- (void)handlePinch:(UIPinchGestureRecognizer *)gestureRecognier
{
    if (_flags.isAnimating) return;
    if (gestureRecognier.state != UIGestureRecognizerStateChanged) return;
    
    if (gestureRecognier.scale < 0.6)
    {
        [self showThumbnailsAnimated:YES];
    }
    else if (gestureRecognier.scale > 1.15)
    {
        [self showPageAtIndex:self.currentPage animated:YES];
    }
}

- (void)handleTap:(UITapGestureRecognizer *)tapGesture
{
    if (_flags.isAnimating) return;
    
    CGPoint tapPoint = [tapGesture locationInView:_scrollView];
    NSUInteger tappedPageIndex = [self indexForPageAtPoint:tapPoint];
    
    if (tappedPageIndex == self.currentPage)
    {
        [self showPageAtIndex:tappedPageIndex animated:YES];
    }
    else
    {
        [self scrollToPageAtIndex:tappedPageIndex animated:YES];
    }
}


#pragma mark - Getters / Setters

- (NSUInteger)currentPage
{
    CGPoint currentPagePoint = _scrollView.bounds.origin;
    
	NSUInteger x = floorf(currentPagePoint.x);
	NSUInteger index = x / (_pageSizeThumbnail.width + _pageMargins.left);
    
	if (index >= _numberOfPages) index = NSNotFound;
	
	return index;
}

- (void)setDelegate:(id <LLPageScrollerDelegate>)delegate
{
    if (!delegate) return;
    
    if (![delegate conformsToProtocol:@protocol(LLPageScrollerDelegate)])
    {
        [NSException raise:NSInvalidArgumentException format:@"The delegate object must conform to LLPageScrollerDelegate protocol"];
    }
    
    _delegate = delegate;
    
    [self updateDelegateFlags];
}

- (void)setDataSource:(id<LLPageScrollerDataSource>)dataSource
{
    if (!dataSource) return;
    
    if (![dataSource conformsToProtocol:@protocol(LLPageScrollerDataSource)])
    {
        [NSException raise:NSInvalidArgumentException format:@"The dataSource object must conform to LLPageScrollerDataSource protocol"];
    }
    
    _dataSource = dataSource;
    
    [self updateDataSourceFlags];
}


#pragma mark - Private methods

- (void)configurePage:(LLPage *)page forIndex:(NSUInteger)index
{
    [page toFullSizeAnimated:NO];
    
    CGFloat xScale = _pageSizeThumbnail.width / _pageSize.width;
    CGFloat yScale = _pageSizeThumbnail.height / _pageSize.height;
    page.scale = LLPageScaleMake(xScale, yScale);
    
    CGRect thumbnailRect = [self rectForPageThumbnailAtIndex:index];
    
    CGRect fullPageFrame = {
        thumbnailRect.origin.x,
        thumbnailRect.origin.y,
        _pageSize.width,
        _pageSize.height
    };
    page.frame = fullPageFrame;
    
    [page toThumbnailAnimated:NO];
    
    page.index = index;
    
    page.frame = thumbnailRect;
    
    if ([self dataSourceImplementsConfigurePage])
    {
        [self.dataSource configurePage:page forIndex:index];
    }
}

- (void)checkForReusablePages
{
    // Cache no-longer-visible pages
    [_visiblePages enumerateObjectsUsingBlock:^(LLPage *page, BOOL *stop) {
        
        CGRect scaledPageFrame = [self convertRect:page.frame fromView:_scrollView];
        BOOL isVisible = CGRectIntersectsRect(scaledPageFrame, self.bounds);
        
        if (isVisible == NO)
        {
            [self enqueuePage:page];
            [page removeFromSuperview];
            
            [_visiblePages removeObject:page];
        }
    }];
}

- (void)enqueuePage:(LLPage *)page
{
    NSMutableSet *reusableSet = [_reusablePages objectForKey:page.reuseIdentifier];
    
    if (reusableSet == nil)
    {
        reusableSet = [[NSMutableSet alloc] init];
        [_reusablePages setObject:reusableSet forKey:page.reuseIdentifier];
        [reusableSet release];
    }
    
    // called here to save memory:
    // it's better here than in the dequeue method, because if a page will never be reused,
    // it will rest in the set and its subviews will still be in memory.
    [page prepareForReuse];
    
    [reusableSet addObject:page];
}

- (NSUInteger)indexForPageAtPoint:(CGPoint)point
{
	NSUInteger x = (NSUInteger)floorf(point.x);
	NSUInteger index = x / (NSUInteger)(_pageSizeThumbnail.width + _pageMargins.left);
    
	if (index >= _numberOfPages) index = NSNotFound;
	
	return index;
}

- (CGPoint)originForPageThumbnailAtIndex:(NSUInteger)index
{
    CGPoint startPoint;
    startPoint.x = (_pageMargins.left + _pageSizeThumbnail.width) * index;
    startPoint.y = 0.0f;
    
    return startPoint;
}

- (CGRect)rectForPageScroller
{
    CGFloat width = _pageSizeThumbnail.width + _pageMargins.left;
    CGFloat height = _pageSizeThumbnail.height;
    
    CGRect scrollViewFrame = {
        (self.bounds.size.width / 2) - (width / 2),
        (self.bounds.size.height / 2) - (height / 2),
        width,
        height
    };
    
    return scrollViewFrame;
}

- (CGRect)rectForPageThumbnailAtIndex:(NSUInteger)index
{
    CGPoint startPoint = [self originForPageThumbnailAtIndex:index];
    
    CGFloat originX = (_pageMargins.left / 2);
    CGFloat originY = startPoint.y;
    
    if (index > 0)
    {
        originX += startPoint.x;
    }
    
    return CGRectMake(originX, originY, _pageSizeThumbnail.width, _pageSizeThumbnail.height);
}

- (CGSize)sizeForContent
{
    CGFloat width = (_pageMargins.left + _pageSizeThumbnail.width) * _numberOfPages;
    CGFloat height = _pageSizeThumbnail.height;
    
    return CGSizeMake(width, height);
}

- (NSIndexSet *)visiblePagesIndexesInRect:(CGRect)rect
{
    NSMutableIndexSet *indices = [NSMutableIndexSet indexSet];
    
    for (NSUInteger i=0; i < _numberOfPages; i++)
    {
        CGRect pageFrame = [self convertRect:[self rectForPageThumbnailAtIndex:i]
                                    fromView:_scrollView];
        
        if (CGRectIntersectsRect(pageFrame, rect))
        {
            [indices addIndex:i];
        }
    }
    
    return indices;
}


#pragma mark Update

- (void)loadPageForIndex:(NSUInteger)index
{
    __block BOOL isVisible = NO;
    [_visiblePages enumerateObjectsUsingBlock:^(LLPage *visiblePage, BOOL *stop) {
        
        if (visiblePage.index == index)
        {
            isVisible = YES;
            *stop = YES;
        }
    }];
    
    if (isVisible) return;
    
    LLPage *page = [self pageForIndexFromDataSource:index];
    
    if (page == nil) return;
    
    [self configurePage:page forIndex:index];
    
    if ([self delegateImplementsWillDisplayPage])
    {
        [self.delegate pageScroller:self willDisplayPageAtIndex:index];
    }
    
    [_scrollView addSubview:page];
    [_visiblePages addObject:page];
    
    if ([self delegateImplementsDidDisplayPage])
    {
        [self.delegate pageScroller:self didDisplayPageAtIndex:index];
    }
}

- (void)updateVisiblePagesNow
{
    NSIndexSet *visibleIndices = [self visiblePagesIndexesInRect:self.bounds];
    
    [visibleIndices enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
        [self loadPageForIndex:index];
    }];
}


#pragma mark - Public methods

- (id)dequeueReusablePageWithReuseIdentifier:(NSString *)reuseIdentifier
{
    NSMutableSet *reusableSet = [_reusablePages objectForKey:reuseIdentifier];
    LLPage *page = [[reusableSet anyObject] retain];
    
    if (page == nil) return nil;
    
    [reusableSet removeObject:page];
    
    return [page autorelease];
}

- (void)reloadData
{
    if ([self dataSourceImplementsNumberOfPages] == NO) return;
    
    _numberOfPages = [self numberOfPagesFromDataSource];
    
    _scrollView.frame = [self rectForPageScroller];
    _scrollView.contentSize = [self sizeForContent];
    
    [_visiblePages removeAllObjects];
    [_scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [self updateVisiblePagesNow];
    
    _flags.shouldUpdate = NO;
}

- (void)scrollToPageAtIndex:(NSUInteger)index animated:(BOOL)animated
{
    if (_flags.isAnimating) return;
    if (index >= _numberOfPages) return;
    
    _flags.isAnimating = YES;
    self.userInteractionEnabled = NO;
    
    CGPoint offset = CGPointMake(_scrollView.frame.size.width * index, 0.0f);
    
    [_scrollView setContentOffset:offset animated:animated];
    
    if ([self delegateImplementsDidScrollToPage])
    {
        [self.delegate pageScroller:self didScrollToPageIndex:index];
    }
}

- (void)showPageAtIndex:(NSUInteger)index animated:(BOOL)animated
{
    if (_flags.mode == LLPageScrollerModeFullPage) return;
    
    if ([self delegateImplementsWillMakePageFullScreen])
    {
        [self.delegate pageScroller:self willMakePageAtIndexFullScreen:index];
    }
    
    [UIView animateWithDuration:0.25 animations:^() {
        _titleLabel.hidden = YES;
    }];
    
    __block LLPage *selectedPage = nil;
    [_visiblePages enumerateObjectsUsingBlock:^(LLPage *page, BOOL *stop) {
        
        if (page.index == index)
        {
            selectedPage = page;
            *stop = YES;
        }
    }];
    
    _selectedPage = selectedPage;
    
    _scrollView.scrollEnabled = NO;
    
    // convert the frame for the main view bounds
    CGRect thumbnailPageFrame = [self convertRect:_selectedPage.frame fromView:_scrollView];
    _selectedPage.frame = thumbnailPageFrame;
    
    _flags.mode = LLPageScrollerModeFullPage;
    
    // show it full size
    [_selectedPage toFullSizeAnimated:YES];
    
    // add it to the main view
    [self addSubview:_selectedPage];
    
    if ([self delegateImplementsDidMadePageFullScreen])
    {
        [self.delegate pageScroller:self didMadePageAtIndexFullScreen:index];
    }
}

- (void)showThumbnailsAnimated:(BOOL)animated
{
    if (_flags.mode == LLPageScrollerModeThumbnails) return;
    
    if ([self delegateImplementsWillDisplayThumbnails])
    {
        [self.delegate pageScrollerWillDisplayThumbnails:self];
    }
    
    _flags.mode = LLPageScrollerModeThumbnails;
    
    // show it as a thumbnail
    [_selectedPage toThumbnailAnimated:YES];
    
    // convert the frame for the scrollview bounds
    CGRect pageFrame = [_scrollView convertRect:_selectedPage.frame fromView:self];
    _selectedPage.frame = pageFrame;
    
    // move the page from the main view to the scrollview
    [_scrollView addSubview:_selectedPage];
    
    _scrollView.scrollEnabled = YES;
    
    [UIView animateWithDuration:0.25 animations:^() {
        _titleLabel.hidden = NO;
    }];
    
    if ([self delegateImplementsDidDisplayThumbnails])
    {
        [self.delegate pageScrollerDidDisplayThumbnails:self];
    }
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self checkForReusablePages];
    [self updateVisiblePagesNow];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([self delegateImplementsDidScrollToPage])
    {
        [self.delegate pageScroller:self didScrollToPageIndex:self.currentPage];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    _flags.isAnimating = NO;
    self.userInteractionEnabled = YES;
}

@end
