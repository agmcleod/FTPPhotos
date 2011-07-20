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

    
}

@property (nonatomic, retain) NSMutableArray *photos;
@property (nonatomic, retain) UIImagePickerController *picker;
@property (nonatomic, retain) UIBarButtonItem *addPhotoButton;

- (void) addPhoto:(id) sender;
- (void) showFTPView:(id) sender;
- (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
@end
