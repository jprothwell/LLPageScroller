//
//  main.m
//  LLPageScrollerDemo
//
//  Created by Luca Liberati on 27/07/11.
//  Copyright 2011 Liberati Luca. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LLPageScrollerDemoAppDelegate.h"

int main(int argc, char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, NSStringFromClass([LLPageScrollerDemoAppDelegate class]));
    [pool release];
    
    return retVal;
}
