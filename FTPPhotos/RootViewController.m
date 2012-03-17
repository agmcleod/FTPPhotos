//
//  RootViewController.m
//  FTPPhotos
//
//  Created by Aaron McLeod on 11-05-30.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "FTPViewController.h"
#import "SitesViewController.h"

@implementation RootViewController
@synthesize photos, picker, addPhotoButton, clearPhotosList, gotoSites;

- (void)viewDidLoad
{
    // initialize navigation bar stuff
    addPhotoButton = [[UIBarButtonItem alloc] initWithTitle:@"Add Photo" style:UIBarButtonItemStyleBordered target:self action:@selector(addPhoto:)];
    self.navigationItem.rightBarButtonItem = addPhotoButton;
    self.title = @"Select Photos";
    UIBarButtonItem *pushToServer = [[UIBarButtonItem alloc] initWithTitle:@"Upload" style:UIBarButtonItemStyleBordered target:self action:@selector(showFTPView:)];
    self.navigationItem.leftBarButtonItem = pushToServer;
    
    // initialize the array for the photos
    self.photos = [[NSMutableArray alloc] initWithCapacity:50];   
    
    // setup toolbar stuff
    clearPhotosList = [[UIBarButtonItem alloc] initWithTitle:@"Remove All Photos" style:UIBarButtonItemStyleBordered target:self action:@selector(clearPhotos)];
    gotoSites = [[UIBarButtonItem alloc] initWithTitle:@"Manage Sites" style: 
        UIBarButtonItemStyleBordered target:self action:@selector(showSitesView:)];
    
    // add buttons to bottom toolbar
    
    //[self.view addSubview:toolBar];
    [self.navigationController setToolbarHidden:NO];
    [self setToolbarItems:[NSArray arrayWithObjects:clearPhotosList, gotoSites, nil]];
    
    [pushToServer release];
    [super viewDidLoad];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    if([[self.navigationController.viewControllers lastObject] class] == [FTPViewController class]){
        
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration: 1.00];
		[UIView setAnimationTransition:UIViewAnimationTransitionCurlDown
                               forView:self.view cache:NO];
        
		UIViewController *viewController = 
            [self.navigationController popViewControllerAnimated:NO];
        
        FTPViewController *ftpview = ((FTPViewController *) viewController);
        ftpview.rootViewController = self;
        [ftpview resetStreams];
		[UIView commitAnimations];
        
		return viewController;
	} else {
		return [self.navigationController popViewControllerAnimated:animated];
	}
}

- (void) clearPhotos
{
    [self.photos removeAllObjects];
    [self.tableView reloadData];
}

- (void) showFTPView:(id) sender {
    if(photos.count > 0) {
        FTPViewController *ftpView = [[FTPViewController alloc] init];
        ftpView.photos = self.photos;
        [self.navigationController pushViewController:ftpView animated:NO];
        [ftpView release];
    }
}

- (void) showSitesView:(id)sender {
    SitesViewController *siteView = [[SitesViewController alloc] init];
    [self.navigationController pushViewController:siteView animated:NO];    
    [siteView release];
}

- (void)addPhoto:(id) sender {
    picker = [[UIImagePickerController alloc] init]; 
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary; 
    picker.delegate = self;
    [self presentModalViewController:self.picker animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *) img editingInfo:(NSDictionary *)editInfo {
    [self.photos addObject:img];
    [[self.picker parentViewController] dismissModalViewControllerAnimated:YES];
    [self.tableView reloadData];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [photos count];
}

// scale an image
- (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    UIImage *photo = [self.photos objectAtIndex: [indexPath row]];
    UIImage *previousPhoto = nil; 
    
    if ([self.photos count] > ([indexPath row] + 1)) {
        previousPhoto = [self.photos objectAtIndex: ([indexPath row] + 1)];
    }
    
    //[cell addSubview:photoView];
    cell.imageView.image = photo;
    // Configure the cell.
    return cell;
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
    // ...
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
	*/
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)dealloc
{
    [addPhotoButton dealloc];
    [clearPhotosList dealloc];
    [gotoSites dealloc];
    [photos dealloc];
    [picker dealloc];
    
    [super dealloc];
}

@end
