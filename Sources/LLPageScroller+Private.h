/* Copyright 2011 Liberati Luca. All rights reserved. */

#import "LLPageScroller.h"

@interface LLPageScroller (Private)

- (void)updateDelegateFlags;
- (void)updateDataSourceFlags;

// delegate helper methods
- (BOOL)delegateImplementsDidDisplayPage;
- (BOOL)delegateImplementsDidDisplayThumbnails;
- (BOOL)delegateImplementsDidMadePageFullScreen;
- (BOOL)delegateImplementsDidScrollToPage;
- (BOOL)delegateImplementsWillDisplayPage;
- (BOOL)delegateImplementsWillDisplayThumbnails;
- (BOOL)delegateImplementsWillMakePageFullScreen;

// datasource helper methods
- (NSUInteger)numberOfPagesFromDataSource;
- (LLPage *)pageForIndexFromDataSource:(NSUInteger)index;

- (BOOL)dataSourceImplementsConfigurePage;
- (BOOL)dataSourceImplementsNumberOfPages;
- (BOOL)dataSourceImplementsPageForIndex;

@end
