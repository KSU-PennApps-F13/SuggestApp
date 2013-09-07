//
//  PAProfileViewController.h
//  Pinch
//
//  Created by Camden Fullmer on 9/7/13.
//  Copyright (c) 2013 Camden Fullmer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PAProfileViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) IBOutlet UILabel *profileNameLabel;
@property (strong, nonatomic) IBOutlet UIButton *profileWebsiteButton;
@property (strong, nonatomic) IBOutlet UIView *progressView;
@property (strong, nonatomic) IBOutlet UIScrollView *informationView;
@property (strong, nonatomic) IBOutlet UILabel *profileBirthdayLabel;
@property (strong, nonatomic) IBOutlet UILabel *profileEmailLabel;
@property (strong, nonatomic) IBOutlet UILabel *profileLocationLabel;
- (IBAction)logoutButtonClicked:(id)sender;

@end
