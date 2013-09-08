//
//  PASuggestionsTableViewController.h
//  Suggest
//
//  Created by Camden Fullmer on 9/7/13.
//  Copyright (c) 2013 Camden Fullmer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PAProductsTableViewController : UITableViewController <NSURLConnectionDelegate>

@property (nonatomic, strong) FBGraphObject *selectedFriend;

@end
