//
//  FTPViewController.m
//  FTPPhotos
//
//  Created by Aaron McLeod on 11-06-21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FTPViewController.h"
#include <CFNetwork/CFNetwork.h>
#import <CoreData/CoreData.h>
#import "Site.h"

@implementation FTPViewController
@synthesize address, port, username, password, addressLabel, portLabel, usernameLabel, passwordLabel, uploadView, photos, uploadButton, cancelButton, statusLabel, networkingCount, 
    activityIndicator, dataStream, photoIndexToUpload, rootViewController, selectSiteButton, sites, 
    pickerView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [self _stopSendWithStatus:@"Stopped"];
    [uploadView release];
    [address release];
    [port release];
    [username release];
    [password release];
    [addressLabel release];
    [portLabel release];
    [usernameLabel release];
    [passwordLabel release];
    [photos release];
    [selectSiteButton release];
    [pickerView release];
    [sites release];
    [super dealloc];
}

- (IBAction) uploadPhotos:(id)sender {
    self.photoIndexToUpload = 0;
    [self _sendNextPhoto];
}

- (IBAction) showSitesList:(id)sender {
    
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    NSError * error = nil;
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"FTPPhotos.sqlite"]];
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    if(![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
        NSLog(@"Unresolved Error %@, %@", error, [error userInfo]);
        abort();
    }
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:persistentStoreCoordinator];
    
    
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Site" inManagedObjectContext:managedObjectContext];   
    
    // Setup the fetch request  
    NSFetchRequest *request = [[NSFetchRequest alloc] init];  
    [request setEntity:entity];   
    
    // Define how we will sort the records  
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"address" ascending:NO];  
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];  
    [request setSortDescriptors:sortDescriptors];  
    [sortDescriptor release];   
    
    // Fetch the records and handle an error  
    
    NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];   
    
    if (!mutableFetchResults) {  
        // Handle the error.  
        // This is a serious error and should advise the user to restart the application  
    }   
    
    // Save our fetched data to an array  
    sites = mutableFetchResults;
    

    
    [self.view addSubview:pickerView];
}

- (NSInteger)numberOfComponentsInPickerView:
(UIPickerView *)pickerView
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [sites count];
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    Site *site = [sites objectAtIndex:row];
    return site.address;
}
     
 - (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
     // If the user chooses a new row, update the label accordingly.
     
}

- (void)_sendNextPhoto
{
    if(self.photoIndexToUpload < [self.photos count] && !self.isSending) {
        NSString *  filePath;
        NSInteger i = self.photoIndexToUpload;
        // User the tag on the UIButton to determine which image to send.
        UIImage *tempImage = [photos objectAtIndex:i];
        filePath = @""; // TODO: get rid of later
        assert(tempImage != nil);
        [self _startSend:filePath withImage:tempImage imageIndex:i];
        self.photoIndexToUpload += 1;
    }
    else {
        [self.rootViewController clearPhotos];
    }
}

- (IBAction) cancelAction:(id)sender 
{
    [self _stopSendWithStatus:@"Cancelled"];
}

- (void)_sendDidStart
{
    self.statusLabel.text = @"Sending";
    self.cancelButton.enabled = YES;
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    [self didStartNetworking];
}

- (void)_updateStatus:(NSString *)statusString
{
    assert(statusString != nil);
    self.statusLabel.text = statusString;
}

- (void)_sendDidStopWithStatus:(NSString *)statusString
{
    if (statusString == nil) {
        statusString = @"Uploaded successfully!";
    }
    self.statusLabel.text = statusString;
    self.cancelButton.enabled = NO;
    [self.activityIndicator stopAnimating];
    self.activityIndicator.hidden = YES;
    [self didStopNetworking];
    [self _sendNextPhoto];
}

- (UILabel *)labelCellWithWidth:(CGFloat)width rightOffset:(CGFloat)offset siteAddress:(NSString *)siteAddress {
    
    // Create a new view that contains a label offset from the right.
    CGRect frame = CGRectMake(0.0, 0.0, width, 32.0);
    //UIView *view = [[[UIView alloc] initWithFrame:frame] autorelease];
    
    frame.size.width = width - offset;
    UILabel *subLabel = [[UILabel alloc] initWithFrame:frame];
    subLabel.textAlignment = UITextAlignmentRight;
    subLabel.backgroundColor = [UIColor whiteColor];
    subLabel.font = [UIFont systemFontOfSize:24.0];
    subLabel.userInteractionEnabled = NO;
    subLabel.text = siteAddress;
    subLabel.textColor = [UIColor blackColor];
    
    //[view insertSubview:subLabel atIndex:idx];
    //[subLabel release];
    return subLabel;
}

#pragma mark * Core transfer code

// This is the code that actually does the networking.

@synthesize networkStream = _networkStream;
@synthesize bufferOffset  = _bufferOffset;
@synthesize bufferLimit   = _bufferLimit;

// Because buffer is declared as an array, you have to use a custom getter.  
// A synthesised getter doesn't compile.

- (uint8_t *)buffer
{
    return self->_buffer;
}

- (BOOL)isSending
{
    return (self.networkStream != nil);
}

- (void)_startSend:(NSString *)filePath withImage:(UIImage *)img imageIndex:(NSInteger)number
{
    BOOL                    success;
    NSURL *                 url;
    CFWriteStreamRef        ftpStream;
    
    // assert(filePath != nil);
    // assert([[NSFileManager defaultManager] fileExistsAtPath:filePath]);
    // assert( [filePath.pathExtension isEqual:@"png"] || [filePath.pathExtension isEqual:@"jpg"] );
    
    assert(self.networkStream == nil);      // don't tap send twice in a row!
    assert(self.dataStream == nil);         // ditto
    
    // First get and check the URL.
    
    url = [self smartURLForString:self.address.text];
    success = (url != nil);
    
    NSLog([NSString stringWithFormat:@"i is %d", number]);
    
    if (success) {
        // Add the last part of the file name to the end of the URL to form the final 
        // URL that we're going to put to.
        NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
        // NSTimeInterval is defined as double
        NSNumber *timeStampObj = [NSNumber numberWithDouble: timeStamp];
        NSString *fileName = [NSString stringWithFormat:@"%@_%d.jpg", [timeStampObj stringValue], number];
        
        url = [NSMakeCollectable(
                                 CFURLCreateCopyAppendingPathComponent(NULL, (CFURLRef) url, (CFStringRef) fileName, false)
                                 ) autorelease];
        success = (url != nil);
    }
    
    // If the URL is bogus, let the user know.  Otherwise kick off the connection.
    
    if ( ! success) {
        self.statusLabel.text = @"Invalid URL";
    } else {
        
        // Open a stream for the file we're going to send.  We do not open this stream; 
        // NSURLConnection will do it for us.
        
        // self.fileStream = [NSInputStream inputStreamWithFileAtPath:filePath];
        
        self.dataStream = [NSInputStream inputStreamWithData: UIImageJPEGRepresentation(img, 1.0)];
        [self.dataStream open];
        
        // Open a CFFTPStream for the URL.
        
        ftpStream = CFWriteStreamCreateWithFTPURL(NULL, (CFURLRef) url);
        assert(ftpStream != NULL);
        
        self.networkStream = (NSOutputStream *) ftpStream;
        
        if (self.username.text.length != 0) {
#pragma unused (success) //Adding this to appease the static analyzer.
            success = [self.networkStream setProperty:self.username.text forKey:(id)kCFStreamPropertyFTPUserName];
            assert(success);
            success = [self.networkStream setProperty:self.password.text forKey:(id)kCFStreamPropertyFTPPassword];
            assert(success);
        }
        
        self.networkStream.delegate = self;
        [self.networkStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.networkStream open];
        
        // Have to release ftpStream to balance out the create.  self.networkStream 
        // has retained this for our persistent use.
        
        CFRelease(ftpStream);
        
        // Tell the UI we're sending.
        
        [self _sendDidStart];
    }
}

- (void)_stopSendWithStatus:(NSString *)statusString
{
    [self resetStreams];
    [self _sendDidStopWithStatus:statusString];
}

- (void)resetStreams {
    if (self.networkStream != nil) {
        [self.networkStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        self.networkStream.delegate = nil;
        [self.networkStream close];
        self.networkStream = nil;
    }
    if (self.dataStream != nil) {
        [self.dataStream close];
        self.dataStream = nil;
    }
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
// An NSStream delegate callback that's called when events happen on our 
// network stream.
{
#pragma unused(aStream)
    assert(aStream == self.networkStream);
    
    switch (eventCode) {
        case NSStreamEventOpenCompleted: {
            [self _updateStatus:@"Opened connection"];
        } break;
        case NSStreamEventHasBytesAvailable: {
            assert(NO);     // should never happen for the output stream
        } break;
        case NSStreamEventHasSpaceAvailable: {
            [self _updateStatus:@"Sending"];
            // If we don't have any data buffered, go read the next chunk of data.
            
            if (self.bufferOffset == self.bufferLimit) {
                NSInteger   bytesRead;
                bytesRead = [self.dataStream read:self.buffer maxLength:kSendBufferSize];
                
                if (bytesRead == -1) {
                    [self _stopSendWithStatus:@"File read error"];
                } else if (bytesRead == 0) {
                    NSLog(@"Out of data");
                    [self _stopSendWithStatus:nil];
                } else {
                    self.bufferOffset = 0;
                    self.bufferLimit  = bytesRead;
                }
            }
            
            // If we're not out of data completely, send the next chunk.
            
            if (self.bufferOffset != self.bufferLimit) {
                NSInteger   bytesWritten;
                bytesWritten = [self.networkStream write:&self.buffer[self.bufferOffset] maxLength:self.bufferLimit - self.bufferOffset];
                assert(bytesWritten != 0);
                if (bytesWritten == -1) {
                    [self _stopSendWithStatus:@"Network write error"];
                } else {
                    self.bufferOffset += bytesWritten;
                }
            }
        } break;
        case NSStreamEventErrorOccurred: {
            [self _stopSendWithStatus:@"Stream open error. Double check your entered information."];
        } break;
        case NSStreamEventEndEncountered: {
            
        } break;
        default: {
            assert(NO);
        } break;
    }
}

// this hides the keyboard on return
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if([textField isFirstResponder]) {
        [textField resignFirstResponder];
        return true;
    }
    else {
        return false;
    }
}


- (NSURL *)smartURLForString:(NSString *)str
{
    NSURL *     result;
    NSString *  trimmedStr;
    NSRange     schemeMarkerRange;
    NSString *  scheme;
    
    assert(str != nil);
    
    result = nil;
    
    trimmedStr = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ( (trimmedStr != nil) && (trimmedStr.length != 0) ) {
        schemeMarkerRange = [trimmedStr rangeOfString:@"://"];
        
        if (schemeMarkerRange.location == NSNotFound) {
            result = [NSURL URLWithString:[NSString stringWithFormat:@"ftp://%@", trimmedStr]];
        } else {
            scheme = [trimmedStr substringWithRange:NSMakeRange(0, schemeMarkerRange.location)];
            assert(scheme != nil);
            
            if ( ([scheme compare:@"ftp"  options:NSCaseInsensitiveSearch] == NSOrderedSame) ) {
                result = [NSURL URLWithString:trimmedStr];
            } else {
                // It looks like this is some unsupported URL scheme.
            }
        }
    }
    
    return result;
}

- (BOOL)isImageURL:(NSURL *)url
{
    BOOL        result;
    NSString *  path;
    NSString *  extension;
    
    assert(url != nil);
    
    path = [url path];
    result = NO;
    if (path != nil) {
        extension = [path pathExtension];
        if (extension != nil) {
            result = ([extension caseInsensitiveCompare:@"gif"] == NSOrderedSame)
            || ([extension caseInsensitiveCompare:@"png"] == NSOrderedSame)
            || ([extension caseInsensitiveCompare:@"jpg"] == NSOrderedSame);
        }
    }
    return result;
}

- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (void)didStartNetworking
{
    self.networkingCount += 1;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didStopNetworking
{
    if(self.networkingCount > 0) {
        self.networkingCount -= 1;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = 
            (self.networkingCount != 0);
    }
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    self.activityIndicator.hidden = YES;
    self.cancelButton.enabled = NO;
    pickerView = [[UIPickerView alloc] init];
    pickerView.backgroundColor = [UIColor whiteColor];
    [pickerView setDataSource:self];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
