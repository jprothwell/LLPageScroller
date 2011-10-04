//  Copyright 2011 Liberati Luca. All rights reserved.

#import "LLPageScrollerDemoAppDelegate.h"


@implementation LLPageScrollerDemoAppDelegate

@synthesize window = _window;
@synthesize artworkScrollerVC = _artworkScrollerVC;

- (void)dealloc
{
    [_window release];
    [_artworkScrollerVC release];
    
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor viewFlipsideBackgroundColor];
    
    _artworkScrollerVC = [[ArtworkScrollerViewController alloc] init];
    
    [self.window addSubview:_artworkScrollerVC.view];
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
