//
//  FTPPhotosAppDelegate.h
//  FTPPhotos
//
//  Created by Aaron McLeod on 11-05-30.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"

@interface FTPPhotosAppDelegate : NSObject <UIApplicationDelegate> {
    UINavigationController *navigationController;
    RootViewController *rootViewController;
}

@property (nonatomic, retain) UINavigationController *navigationController;
@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) RootViewController *rootViewController;

@end
