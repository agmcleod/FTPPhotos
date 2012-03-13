//
//  SitesViewController.h
//  FTPPhotos
//
//  Created by Aaron McLeod on 11-10-31.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FTPPhotosAppDelegate.h"
#import <CoreData/CoreData.h>

@interface SitesViewController : UIViewController {
    UITableView *sitesView;
    NSManagedObjectContext *managedObjectContext;
    NSMutableArray *sites;
    UIBarButtonItem *addButton;
    UIToolbar *toolBar;
}

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) NSMutableArray *sites;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *addButton;
@property (nonatomic, retain) IBOutlet UIToolbar *toolBar;

- (void) fetchRecords;  
- (void) addSite:(id)sender;
- (NSURL *)applicationDocumentsDirectory;

@end
