//
//  PASuggestViewController.m
//  Pinch
//
//  Created by Camden Fullmer on 9/7/13.
//  Copyright (c) 2013 Camden Fullmer. All rights reserved.
//

#import "PASuggestViewController.h"
#import "PASelectFriendViewController.h"

@interface PASuggestViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation PASuggestViewController

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
    self.pickFriendButton.layer.cornerRadius = 4.0;
    self.pickFriendButton.layer.shadowColor = [UIColor colorWithWhite:0.6 alpha:1.0].CGColor;
    self.pickFriendButton.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    self.pickFriendButton.layer.shadowRadius = 5.0;
    self.pickFriendButton.layer.shadowOpacity = 0.5;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pickFriendButtonClicked:(id)sender {
    PASelectFriendViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectFriendNavigationViewController"];
    [self presentViewController:viewController animated:YES completion:nil];
}

#pragma mark - Table view delegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Recent Suggestions";
}

#pragma mark - Table view datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"RecentSuggestionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    return cell;
}

@end
