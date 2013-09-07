//
//  PAProfileViewController.m
//  Pinch
//
//  Created by Camden Fullmer on 9/7/13.
//  Copyright (c) 2013 Camden Fullmer. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import "PAProfileViewController.h"

@interface PAProfileViewController ()

@end

@implementation PAProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self populateInformation];
    [self populateProfilePicture];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)populateProfilePicture {
    FBRequest *friendRequest = [FBRequest requestForGraphPath:@"me?fields=picture.width(140).height(140)"];
    [friendRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        // Take care of the friend's profile picture.
        NSURL *url = [NSURL URLWithString:[[[result objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"]];
        
        dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(q, ^{
            /* Fetch the image from the server... */
            NSData *data = [NSData dataWithContentsOfURL:url];
            UIImage *img = [[UIImage alloc] initWithData:data];
            dispatch_async(dispatch_get_main_queue(), ^{
                /* This is the main thread again, where we set the tableView's image to
                 be what we just fetched. */
                self.profileImageView.image = img;
                self.profileImageView.layer.cornerRadius = img.size.width/2.0/2.0;
                self.profileImageView.layer.masksToBounds = YES;
            });
        });
    }];
}

- (void)populateInformation {
    if (FBSession.activeSession.isOpen) {
        FBRequest *selfRequest = [FBRequest requestForGraphPath:@"me"];
        [selfRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            self.progressView.hidden = YES;
            self.profileNameLabel.text = [result objectForKey:@"name"];
            [self.profileWebsiteButton setTitle:[result objectForKey:@"website"] forState:UIControlStateNormal];
            self.profileEmailLabel.text = [result objectForKey:@"email"];
            self.profileBirthdayLabel.text = [result objectForKey:@"birthday"];
            self.profileLocationLabel.text = [[result objectForKey:@"location"] objectForKey:@"name"];
            self.informationView.hidden = NO;
        }];
    }
}

- (IBAction)logoutButtonClicked:(id)sender {
    [FBSession.activeSession closeAndClearTokenInformation];
}
@end
