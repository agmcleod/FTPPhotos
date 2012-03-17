//
//  SitesViewController.m
//  FTPPhotos
//
//  Created by Aaron McLeod on 11-10-31.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SitesViewController.h"
#import "Site.h"
#import "SitesForm.h"

@implementation SitesViewController

@synthesize sites, addButton, toolBar;
@synthesize managedObjectContext = managedObjectContext;
@synthesize managedObjectModel = managedObjectModel;
@synthesize persistentStoreCoordinator = persistentStoreCoordinator;

- (void) fetchRecords {
    
    // Define our table/entity to use  
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Site" inManagedObjectContext:[self managedObjectContext]];   
    
    // Setup the fetch request  
    NSFetchRequest *request = [[NSFetchRequest alloc] init];  
    [request setEntity:entity];   
    
    // Define how we will sort the records  
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"address" ascending:NO];  
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];  
    [request setSortDescriptors:sortDescriptors];  
    [sortDescriptor release];   
    
    // Fetch the records and handle an error  
    NSError *error;  
    NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];   
    
    if (!mutableFetchResults) {  
        // Handle the error.  
        // This is a serious error and should advise the user to restart the application  
    }   
    
    // Save our fetched data to an array  
    [self setSites: mutableFetchResults];  
    [mutableFetchResults release];  
    [request release];  
}

- (void) addSite:(id)sender {
    SitesForm *sitesFormController = [[SitesForm alloc] init];
    
    [self.navigationController pushViewController:sitesFormController animated:NO];
    [sitesFormController release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Manage Sites";
    
    addButton = [[UIBarButtonItem alloc] initWithTitle:@"Add Site" style:UIBarButtonItemStyleBordered target:self action:@selector(addSite:)];
    
    [self setToolbarItems:[NSArray arrayWithObjects:addButton, nil]];
    
    // initialize core data objects
    
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
    
    [self fetchRecords];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

#pragma mark - View lifecycle


- (void)viewDidUnload
{
    [super viewDidUnload];    
    [sites release];
    [addButton release];
    [toolBar release];
    [sitesView release];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}




- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
