//
//  Site.h
//  FTPPhotos
//
//  Created by Aaron McLeod on 11-10-31.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Site : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * port;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * password;

@end
