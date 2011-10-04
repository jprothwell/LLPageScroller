/* Copyright 2011 Liberati Luca. All rights reserved. */

#import "LLPageScroller+Private.h"


@implementation LLPageScroller (Private)

- (void)updateDelegateFlags
{
    SEL delegateDidDisplayPage = @selector(pageScroller:didDisplayPageAtIndex:);
    SEL delegateDidDisplayThumbnails = @selector(pageScrollerDidDisplayThumbnails:);
    SEL delegateDidMadePageFullScreen = @selector(pageScroller:didMadePageAtIndexFullScreen:);
    SEL delegateDidScrollToPage = @selector(pageScroller:didScrollToPageIndex:);
    SEL delegateWillDisplayPageSel = @selector(pageScroller:willDisplayPageAtIndex:);
    SEL delegateWillDisplayThumbnailsSel = @selector(pageScrollerWillDisplayThumbnails:);
    SEL delegateWillMakePageFullScreenSel = @selector(pageScroller:willMakePageAtIndexFullScreen:);
    
    _flags.delegateDidDisplayPage = [self.delegate respondsToSelector:delegateDidDisplayPage];
    _flags.delegateDidDisplayThumbnails = [self.delegate respondsToSelector:delegateDidDisplayThumbnails];
    _flags.delegateDidMadePageFullScreen = [self.delegate respondsToSelector:delegateDidMadePageFullScreen];
    _flags.delegateDidScrollToPage = [self.delegate respondsToSelector:delegateDidScrollToPage];
    _flags.delegateWillDisplayPage = [self.delegate respondsToSelector:delegateWillDisplayPageSel];
    _flags.delegateWillDisplayThumbnails = [self.delegate respondsToSelector:delegateWillDisplayThumbnailsSel];
    _flags.delegateWillMakePageFullScreen = [self.delegate respondsToSelector:delegateWillMakePageFullScreenSel];
}

- (void)updateDataSourceFlags
{
    SEL dataSourceConfigurePageSel = @selector(configurePage:forIndex:);
    SEL dataSourceNumberOfPagesSel = @selector(numberOfPagesForPageScroller:);
    SEL dataSourcePageForIndex = @selector(pageScroller:pageForIndex:);
    
    _flags.dataSourceConfigurePage = [self.dataSource respondsToSelector:dataSourceConfigurePageSel];
    _flags.dataSourceNumberOfPages = [self.dataSource respondsToSelector:dataSourceNumberOfPagesSel];
    _flags.dataSourcePageForIndex = [self.dataSource respondsToSelector:dataSourcePageForIndex];
}


#pragma mark - Delegate helpers

- (BOOL)delegateImplementsDidDisplayPage
{
    return _flags.delegateDidDisplayPage;
}

- (BOOL)delegateImplementsDidDisplayThumbnails
{
    return _flags.delegateDidDisplayThumbnails;
}

- (BOOL)delegateImplementsDidMadePageFullScreen
{
    return _flags.delegateDidMadePageFullScreen;
}

- (BOOL)delegateImplementsDidScrollToPage
{
    return _flags.delegateDidScrollToPage;
}

- (BOOL)delegateImplementsWillDisplayPage
{
    return _flags.delegateWillDisplayPage;
}

- (BOOL)delegateImplementsWillDisplayThumbnails
{
    return _flags.delegateWillDisplayThumbnails;
}

- (BOOL)delegateImplementsWillMakePageFullScreen
{
    return _flags.delegateWillMakePageFullScreen;
}


#pragma mark - DataSource helpers

- (NSUInteger)numberOfPagesFromDataSource
{
    return [self.dataSource numberOfPagesForPageScroller:self];
}

- (LLPage *)pageForIndexFromDataSource:(NSUInteger)index
{
    return [self.dataSource pageScroller:self pageForIndex:index];
}

- (BOOL)dataSourceImplementsConfigurePage
{
    return _flags.dataSourceConfigurePage;
}

- (BOOL)dataSourceImplementsNumberOfPages
{
    return _flags.dataSourceNumberOfPages;
}

- (BOOL)dataSourceImplementsPageForIndex
{
    return _flags.dataSourcePageForIndex;
}

@end

