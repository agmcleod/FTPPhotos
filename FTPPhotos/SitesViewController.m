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

@synthesize sites, addButton, toolBar, tableView;
@synthesize managedObjectContext = managedObjectContext;
@synthesize managedObjectModel = managedObjectModel;
@synthesize persistentStoreCoordinator = persistentStoreCoordinator;

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [sites count];
}

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
}

-(void)viewDidAppear:(BOOL)animated
{
    [self fetchRecords];
    [self setEditing:YES];
    [self.tableView setEditing:YES];
    [self.tableView reloadData];
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
    [tableView release];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath

{
    
    if (!indexPath) return UITableViewCellEditingStyleNone;
    
    if (indexPath.row == ([sites count]))
    {        
        return UITableViewCellEditingStyleInsert;
        
    }
    else
    {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;    
}

- (void)tableView:(UITableView *)aTableView 
    commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
    forRowAtIndexPath:(NSIndexPath *)indexPath

{
    
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        // db delete code
        Site *site = [sites objectAtIndex: [indexPath row]];
        [managedObjectContext deleteObject:site];
        NSError *error = nil;
        [managedObjectContext save:&error];
        if(error != nil)
        {
            NSLog(error.description);
        }
        [sites removeObjectAtIndex:indexPath.row];
        [self.tableView reloadData];
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath

      toIndexPath:(NSIndexPath *)toIndexPath
{
    NSString *item = [[sites objectAtIndex:fromIndexPath.row] retain];
    [sites removeObject:item];
    [sites insertObject:item atIndex:toIndexPath.row];
    [item release];
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath { 
    
    static NSString *CellIdentifier = @"Cell";    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier]; 
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    Site *site = [sites objectAtIndex: [indexPath row]];
    cell.textLabel.text = site.address;
    
    /* Site *previous = nil; 
    
    if ([sites count] > ([indexPath row] + 1)) {
        previous = [sites objectAtIndex: ([indexPath row] + 1)];
    } */
    
    return cell; 
    
}

- (BOOL)tableView:(UITableView *)tableView 
canEditRowAtIndexPath:(NSIndexPath *)indexPath 
{ 
    return YES; 
}

@end
