//
//  PAProfileViewController.m
//  Pinch
//
//  Created by Camden Fullmer on 9/7/13.
//  Copyright (c) 2013 Camden Fullmer. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import <DropboxSDK/DropboxSDK.h>
#import "PAProfileViewController.h"
#import "CFShareCircleView.h"
#import "CFSharer.h"
#import <Social/Social.h>

@interface PAProfileViewController () <CFShareCircleViewDelegate>

@property (nonatomic, strong) FBGraphObject *user;
@property (nonatomic, strong) CFShareCircleView *shareCircleView;

@end

@implementation PAProfileViewController

// Uncomment to take a screenshot for the launch image
//#define SCREENSHOTMODE

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
    [self popualteBirthdays];
    [self populateFriends];
    self.shareCircleView = [[CFShareCircleView alloc] initWithSharers:@[[CFSharer facebook], [CFSharer twitter]]];
    self.shareCircleView.delegate = self;
    
#ifdef SCREENSHOTMODE
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationController.view.backgroundColor = [UIColor whiteColor];
    self.title = @"";
    self.tabBarController.tabBar.selectionIndicatorImage = [[UIImage alloc] init];
    for (UIView *aView in self.view.subviews) {
        if ([aView isKindOfClass:[UILabel class]]) {
            [(UILabel *)aView setText:nil];
        }
        else if ([aView isKindOfClass:[UITableView class]]) {
            [(UITableView *)aView setDataSource:nil];
        }
        else if ([aView isKindOfClass:[UIToolbar class]]) {
            [(UIToolbar *)aView setItems:nil];
        }
        else if ([aView isKindOfClass:[UIImageView class]]) {
            [(UIImageView *)aView setImage:nil];
        } else {
            aView.hidden = YES;
        }
    }
    for(UITabBarItem *item in self.tabBarController.tabBar.items) {
        item.image = nil;
        item.title = @"";
    }
#endif
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self retrieveSuggestions];
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
                [self.profilePictureButton setBackgroundImage:img forState:UIControlStateNormal];
                self.profilePictureButton.layer.cornerRadius = img.size.width/2.0/2.0;
                self.profilePictureButton.layer.masksToBounds = YES;
                self.profilePictureButton.layer.borderColor = [UIColor blackColor].CGColor;
                self.profilePictureButton.layer.borderWidth = 0.5;
            });
        });
    }];
}

- (void)populateInformation {
    if (FBSession.activeSession.isOpen) {
        FBRequest *selfRequest = [FBRequest requestForGraphPath:@"me"];
        [selfRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            self.user = result;
            self.progressView.hidden = YES;
            self.profileNameLabel.text = [result objectForKey:@"name"];
            [self.profileWebsiteButton setTitle:[result objectForKey:@"website"] forState:UIControlStateNormal];
            self.informationView.hidden = NO;
        }];
    }
}

- (void)popualteBirthdays {
    if (FBSession.activeSession.isOpen) {
        // Query to fetch the active user's friends, limit to 25.
        NSString *query =
        @"SELECT birthday_date "
        @"FROM user "
        @"WHERE uid IN (SELECT uid2 FROM friend WHERE uid1 = me()) "
        @"AND strlen(birthday_date) != 0 "
        @"AND ((substr(birthday_date, 0, 2) = '09' "
        @"AND substr(birthday_date, 3, 5) >= '7') "
        @"OR (substr(birthday_date, 0, 2) = '10' "
        @"AND substr(birthday_date, 3, 5) < '7'))";
        // Set up the query parameter
        NSDictionary *queryParam = @{ @"q": query };
        // Make the API request that uses FQL
        [FBRequestConnection startWithGraphPath:@"/fql"
                                     parameters:queryParam
                                     HTTPMethod:@"GET"
                              completionHandler:^(FBRequestConnection *connection,
                                                  id result,
                                                  NSError *error) {
                                  if (error) {
                                      NSLog(@"Error: %@", [error localizedDescription]);
                                  } else {
                                      self.numUpcomingBirthdaysLabel.text = [NSString stringWithFormat:@"%d",((NSArray *)result[@"data"]).count];
                                  }
                              }];
    }
}

- (void)populateFriends {
    FBRequest *selfRequest = [FBRequest requestForGraphPath:@"me/friends"];
    [selfRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        self.numFriendsLabel.text = [NSString stringWithFormat:@"%d",((NSArray *)result[@"data"]).count];
    }];
}

- (IBAction)logoutButtonClicked:(id)sender {
    [[DBSession sharedSession] unlinkAll];
    [FBSession.activeSession closeAndClearTokenInformation];
}

- (IBAction)profilePictureButtonClicked:(id)sender {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"fb://profile/%@", self.user[@"id"]]];
    [[UIApplication sharedApplication] openURL:url];
}

- (IBAction)websiteButtonClicked:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@",self.user[@"website"]]]];
}

- (void)retrieveSuggestions {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Suggestion"];
    NSMutableArray *suggestions = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    if(suggestions) {
        self.numSuggestionsLabel.text = [NSString stringWithFormat:@"%d", suggestions.count];
    } else {
        self.numSuggestionsLabel.text = @"0";
    }
}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (IBAction)shareButtonClicked:(id)sender {
    [self.shareCircleView show];
}

- (void)shareCircleView:(CFShareCircleView *)shareCircleView didSelectSharer:(CFSharer *)sharer {
    if([sharer.name isEqualToString:@"Facebook"]) {
        SLComposeViewController *viewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [viewController setInitialText:@"@Suggest makes it easy to discover and pick great gifts for your friends and family!"];
        [self presentViewController:viewController animated:YES completion:nil];
    } else {
        SLComposeViewController *viewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [viewController setInitialText:@"@Suggest makes it easy to discover and pick great gifts for your friends and family!"];
        [self presentViewController:viewController animated:YES completion:nil];
    }
}

- (void)shareCircleCanceled:(NSNotification *)notification{
    NSLog(@"Share circle view was canceled.");
}
@end
