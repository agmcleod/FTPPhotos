//
//  SitesForm.m
//  FTPPhotos
//
//  Created by Aaron McLeod on 12-03-12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SitesForm.h"

@implementation SitesForm

@synthesize address, port, username, password, addressLabel, portLabel, usernameLabel, passwordLabel, saveButton, managedObjectModel, managedObjectContext, status, persistentStoreCoordinator;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    NSError * error = nil;
    
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"FTPPhotos.sqlite"]];
    
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    if(![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
        NSLog(@"Unresolved Error %@, %@", error, [error userInfo]);
        abort();
    }
    managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:persistentStoreCoordinator];
}

- (IBAction)saveSite:(id)sender
{
    Site *site = (Site *)[NSEntityDescription insertNewObjectForEntityForName:@"Site" inManagedObjectContext:managedObjectContext];
    
    [site setAddress:address.text];
    [site setPort:port.text];
    [site setUsername:username.text];
    [site setPassword:password.text];
    
    NSError *error;
    
    if(![managedObjectContext save:&error]) {
        NSLog(@"Error with saving data");
        self.status.text = @"An error occured trying to save the site information.";
    }
    else {
        self.status.text = @"Site saved!";
        self.address.text = @"ftp://";
        self.port.text = @"21";
        self.username.text = @"";
        self.password.text = @"";
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

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


@end
