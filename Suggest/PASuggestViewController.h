//
//  PASuggestViewController.h
//  Pinch
//
//  Created by Camden Fullmer on 9/7/13.
//  Copyright (c) 2013 Camden Fullmer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PASuggestViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *emptyView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)createSuggestionButtonClicked:(id)sender;

@end
