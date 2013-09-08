//
//  PASelectFriendViewController.h
//  Pinch
//
//  Created by Camden Fullmer on 9/6/13.
//  Copyright (c) 2013 Camden Fullmer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@class PASelectFriendViewController;

@protocol PASelectFriendDelegate <NSObject>
@required
- (void)selectFriendViewController:(PASelectFriendViewController *)selectFriendViewController didSelectFriend:(FBGraphObject *)selectedFriend;
@end

@interface PASelectFriendViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *emptyView;
@property id<PASelectFriendDelegate> delegate;
- (IBAction)cancelButtonClicked:(id)sender;

@end
