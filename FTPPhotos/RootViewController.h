//
//  RootViewController.h
//  FTPPhotos
//
//  Created by Aaron McLeod on 11-05-30.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UITableViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    NSMutableArray *photos;
    UIImagePickerController *picker;
    UIBarButtonItem *addPhotoButton;
    UIBarButtonItem *clearPhotosList;
    UIBarButtonItem *gotoSites;
}

@property (nonatomic, retain) NSMutableArray *photos;
@property (nonatomic, retain) UIImagePickerController *picker;
@property (nonatomic, retain) UIBarButtonItem *addPhotoButton;
@property (nonatomic, retain) UIBarButtonItem *clearPhotosList;
@property (nonatomic, retain) UIBarButtonItem *gotoSites;
- (void) addPhoto:(id) sender;
- (void) clearPhotos;
- (void) showFTPView:(id) sender;
- (void) showSitesView:(id) sender;
- (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
@end
