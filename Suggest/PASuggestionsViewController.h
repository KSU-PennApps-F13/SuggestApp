//
//  PASuggestionsViewController.h
//  Pinch
//
//  Created by Camden Fullmer on 9/7/13.
//  Copyright (c) 2013 Camden Fullmer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface PASuggestionsViewController : UIViewController

@property (nonatomic, strong) FBGraphObject<FBGraphUser> *selectedFriend;
@property (strong, nonatomic) IBOutlet UILabel *friendNameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *friendProfileImage;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
