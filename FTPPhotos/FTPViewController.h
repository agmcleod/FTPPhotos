//
//  FTPViewController.h
//  FTPPhotos
//
//  Created by Aaron McLeod on 11-06-21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"

enum {
    kSendBufferSize = 32768
};

@interface FTPViewController : UIViewController<NSStreamDelegate> {
    NSInteger photoIndexToUpload;
    
    // fields for ftp form
    UIView *uploadView;
    UITextField *address;
    UITextField *port;
    UITextField *username;
    UITextField *password;
    UILabel *addressLabel;
    UILabel *portLabel;
    UILabel *usernameLabel;
    UILabel *passwordLabel;
    UILabel *statusLabel;
    NSMutableArray *photos;
    UIButton *uploadButton;
    UIButton *cancelButton;
    UIButton *selectSiteButton;
    
    // variables for sending the FTP request
    NSOutputStream *_networkStream;
    NSInputStream *dataStream;
    uint8_t _buffer[kSendBufferSize];
    size_t _bufferOffset;
    size_t _bufferLimit;
    NSInteger _networkingCount;

    UIActivityIndicatorView *_activityIndicator;
    RootViewController *rootViewController;
}

@property (nonatomic, assign) NSInteger photoIndexToUpload;

@property (nonatomic, retain) IBOutlet UIView *uploadView;
@property (nonatomic, retain) IBOutlet UITextField *address;
@property (nonatomic, retain) IBOutlet UITextField *port;
@property (nonatomic, retain) IBOutlet UITextField *username;
@property (nonatomic, retain) IBOutlet UITextField *password;
@property (nonatomic, retain) IBOutlet UILabel *addressLabel;
@property (nonatomic, retain) IBOutlet UILabel *portLabel;
@property (nonatomic, retain) IBOutlet UILabel *usernameLabel;
@property (nonatomic, retain) IBOutlet UILabel *passwordLabel;
@property (nonatomic, retain) NSMutableArray *photos;
@property (nonatomic, retain) IBOutlet UIButton *uploadButton;
@property (nonatomic, retain) IBOutlet UILabel *statusLabel;
@property (nonatomic, retain) IBOutlet UIButton *cancelButton;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView * activityIndicator;
@property (nonatomic, retain) IBOutlet UIButton *selectSiteButton;

@property (nonatomic, readonly) BOOL isSending;
@property (nonatomic, retain) NSOutputStream *networkStream;
@property (nonatomic, retain) NSInputStream *dataStream;
@property (nonatomic, readonly) uint8_t *buffer;
@property (nonatomic, assign) size_t bufferOffset;
@property (nonatomic, assign) size_t bufferLimit;
@property (nonatomic, assign) NSInteger networkingCount;
@property (nonatomic, assign) RootViewController *rootViewController;


- (IBAction) uploadPhotos:(id)sender;
- (IBAction) cancelAction:(id)sender;
- (IBAction) showSitesList:(id)sender;

- (NSURL *)smartURLForString:(NSString *)str;
- (BOOL)isImageURL:(NSURL *)url;
- (void)didStartNetworking;
- (void)didStopNetworking;
- (void)_startSend:(NSString *)filePath withImage:(UIImage *)img imageIndex:(NSInteger)number;
- (void)_stopSendWithStatus:(NSString *)statusString;
- (void)_sendDidStopWithStatus:(NSString *)statusString;
- (void)_sendNextPhoto;
- (void)resetStreams;
- (NSString *)applicationDocumentsDirectory;
- (UIView *)labelCellWithWidth:(CGFloat)width rightOffset:(CGFloat)offset siteAddress:(NSString *)siteAddress;

@end
