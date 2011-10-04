/* Copyright 2010 Liberati Luca. All rights reserved. */

#import "LLPage.h"

/** LLPageScrollerMode represents the state of the scroller.
 If a page is pinched-out, it will be animated to its full size and the scroller will be in LLPageScrollerModeFullPage.
 If a full sized page is pinched-in, it will be animated to its thumbnail size and the scroller will be in LLPageScrollerModeThumbnails.
 */
typedef enum
{
    LLPageScrollerModeFullPage,
    LLPageScrollerModeThumbnails
} LLPageScrollerMode;


@protocol LLPageScrollerDelegate, LLPageScrollerDataSource;

/** LLPageScroller it's meant to be used as a view scroller, that will give the user peaks at previous and next pages, so he knows that he can scroll through them.
    
    LLPageScroller works like an UITableView. It needs a delegate and a dataSource that provides info on the pages.
 */
@interface LLPageScroller : UIView <UIScrollViewDelegate>
{
    struct
    {
        unsigned int mode:1;
        unsigned int shouldUpdate:1;
        unsigned int isAnimating:1;
        
        unsigned int delegateDidDisplayPage:1;
        unsigned int delegateDidDisplayThumbnails:1;
        unsigned int delegateDidMadePageFullScreen:1;
        unsigned int delegateDidScrollToPage:1;
        unsigned int delegateWillDisplayPage:1;
        unsigned int delegateWillDisplayThumbnails:1;
        unsigned int delegateWillMakePageFullScreen:1;
        
        unsigned int dataSourceConfigurePage:1;
        unsigned int dataSourceNumberOfPages:1;
        unsigned int dataSourcePageForIndex:1;
    } _flags;
}

/** LLPageScroller delegate */
@property (nonatomic, assign) id <LLPageScrollerDelegate> delegate;

/** LLPageScroller dataSource */
@property (nonatomic, assign) id <LLPageScrollerDataSource> dataSource;

/** scroll view that contains the pages */
@property (nonatomic, retain, readonly) UIScrollView *scrollView;

/** label that appears under the scroller. If the text is not set, it will not be visible. */
@property (nonatomic, retain, readonly) UILabel *titleLabel;

/** show the titleLabel */
@property (nonatomic, assign) BOOL showTitle;

/** current mode of LLPageScroller. See LLPageScrollerMode */
@property (nonatomic, assign, readonly) LLPageScrollerMode mode;

/** fullsize of a page */
@property (nonatomic, assign) CGSize pageSize;

/** size of page when in thumbnail mode */
@property (nonatomic, assign) CGSize pageSizeThumbnail;

/** margins at the sides of a page. Use it to add or remove gap between pages */
@property (nonatomic, assign) LLPageMargins pageMargins;

/** current page index, starts at 0 */
@property (nonatomic, assign, readonly) NSUInteger currentPage;

/** a page that the user has select and is viewing in fullscreen */
@property (nonatomic, assign) LLPage *selectedPage;


/** Used to dequeue cached pages. Use it in pageScroller:pageForIndex:
 
 @param reuseIdentifier a string representing a cell identifier. LLPage instances can give you one using the reuseIdentifier method
 */
- (id)dequeueReusablePageWithReuseIdentifier:(NSString *)reuseIdentifier;

/** Returns the index of a page in the scroller by passing a point. The point must be relative to the scrollView bounds
 
 @param point a point inside the scroller view
 */
- (NSUInteger)indexForPageAtPoint:(CGPoint)point;

/** Forces reloading all the info from the dataSource */
- (void)reloadData;

/** Scroll programmatically to a specified index
 
 @param index the index of the page to where you want to scroll
 @param animated animate the scrolling?
 */
- (void)scrollToPageAtIndex:(NSUInteger)index animated:(BOOL)animated;

/** Enter in thumbnails mode (LLPageScrollerModeThumbnails). This will scale all the pages down to the specified thumbnail size in pageSizeThumbnail
 
 @param animated animate the move from a fullsize page to the thumbnails scroller?
 */
- (void)showThumbnailsAnimated:(BOOL)animated;

/** Enter in full page mode (LLPageScrollerModeFullPage). This will scale the page to the specified full size specified in pageSize. This also disables touch areas on the borders of the scroller. 
 
 @param index the index of the page that you want to show at fullsize
 @param animated animate the move from the thumbnails scroller to the fullsize page?
 */
- (void)showPageAtIndex:(NSUInteger)index animated:(BOOL)animated;

@end


@protocol LLPageScrollerDelegate <NSObject>

@optional
- (void)pageScroller:(LLPageScroller *)pageScroller didDisplayPageAtIndex:(NSUInteger)index;
- (void)pageScrollerDidDisplayThumbnails:(LLPageScroller *)pageScroller;
- (void)pageScroller:(LLPageScroller *)pageScroller didMadePageAtIndexFullScreen:(NSUInteger)index;
- (void)pageScroller:(LLPageScroller *)pageScroller didScrollToPageIndex:(NSUInteger)index;
- (void)pageScroller:(LLPageScroller *)pageScroller willDisplayPageAtIndex:(NSUInteger)index;
- (void)pageScrollerWillDisplayThumbnails:(LLPageScroller *)pageScroller;
- (void)pageScroller:(LLPageScroller *)pageScroller willMakePageAtIndexFullScreen:(NSUInteger)index;

@end


@protocol LLPageScrollerDataSource <NSObject>

- (void)configurePage:(LLPage *)page forIndex:(NSUInteger)index;
- (NSUInteger)numberOfPagesForPageScroller:(LLPageScroller *)pageScroller;
- (LLPage *)pageScroller:(LLPageScroller *)pageScroller pageForIndex:(NSUInteger)index;

@end
