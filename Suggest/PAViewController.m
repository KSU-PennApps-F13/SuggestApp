//
//  PAViewController.m
//  Pinch
//
//  Created by Camden Fullmer on 9/6/13.
//  Copyright (c) 2013 Camden Fullmer. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PAViewController.h"
#import "PAAppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>

@interface PAViewController ()

@end

@implementation PAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.logoLabel.font = [UIFont fontWithName:@"Sail-Regular" size:85.0];
    self.facebookLoginButton.layer.cornerRadius = 4.0f;
    self.facebookLogo.layer.shadowColor = [UIColor colorWithWhite:0.1 alpha:1.0].CGColor;
    self.facebookLogo.layer.shadowOffset = CGSizeMake(1.0, 1.0);
    self.facebookLogo.layer.shadowRadius = 0.0;
    self.facebookLogo.layer.shadowOpacity = 1.0;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self animateBackgroundLeft];
}

- (void)animateBackgroundLeft {
    CGPoint center = self.backgroundImageView.center;
    center.x +=500;    // shift right by 500pts
    
    [UIView
     animateWithDuration:70.0
     delay: 0.0
     options: UIViewAnimationOptionCurveEaseIn
     animations:^ {
         CGRect anim = self.backgroundImageView.frame;
         anim.origin.x = 0.0;
         self.backgroundImageView.frame = anim;
     }
     completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)facbookLoginButtonClicked:(id)sender {
    PAAppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate openSession];
}
@end
