//
//  PAProfileViewController.h
//  Pinch
//
//  Created by Camden Fullmer on 9/7/13.
//  Copyright (c) 2013 Camden Fullmer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PAProfileViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *profileNameLabel;
@property (strong, nonatomic) IBOutlet UIButton *profileWebsiteButton;
@property (strong, nonatomic) IBOutlet UIView *progressView;
@property (strong, nonatomic) IBOutlet UIScrollView *informationView;
- (IBAction)logoutButtonClicked:(id)sender;
- (IBAction)profilePictureButtonClicked:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *profilePictureButton;
- (IBAction)websiteButtonClicked:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *numSuggestionsLabel;

@end
