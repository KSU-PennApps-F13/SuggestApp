//
//  PASuggestionsViewController.m
//  Pinch
//
//  Created by Camden Fullmer on 9/7/13.
//  Copyright (c) 2013 Camden Fullmer. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PASuggestionsViewController.h"

@interface PASuggestionsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *friendsLikes;
@property (nonatomic, strong) NSString *friendsBirthday;
@property (nonatomic, strong) NSArray *friendsInterests;
@property (nonatomic, strong) NSArray *categories;

@end

@implementation PASuggestionsViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        _friendsLikes = [[NSArray alloc] init];
        _friendsInterests = [[NSArray alloc] init];
        _categories = @[@"Birthday", @"Likes", @"Interests"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.friendNameLabel.text = self.selectedFriend.name;
    [self loadFriendsInfo];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadFriendsInfo{
    if (FBSession.activeSession.isOpen) {
        FBRequest *friendRequest = [FBRequest requestForGraphPath:[NSString stringWithFormat:@"%@%@",self.selectedFriend.id ,@"?fields=profile_picture,likes,birthday,interests"]];
        [friendRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            // Store the friend's likes.
            self.friendsLikes = [[result objectForKey:@"likes"] objectForKey:@"data"];
            self.friendsBirthday = [result objectForKey:@"birthday"];
            self.friendsInterests = [[result objectForKey:@"interests"] objectForKey:@"data"];
            
            // Take care of the friend's profile picture.
            NSURL *url = [NSURL URLWithString:[[[result objectForKey:@"profile_picture"] objectForKey:@"data"] objectForKey:@"url"]];
            
            dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
            dispatch_async(q, ^{
                /* Fetch the image from the server... */
                NSData *data = [NSData dataWithContentsOfURL:url];
                UIImage *img = [[UIImage alloc] initWithData:data];
                dispatch_async(dispatch_get_main_queue(), ^{
                    /* This is the main thread again, where we set the tableView's image to
                     be what we just fetched. */
                    self.friendProfileImage.image = img;
                    self.friendProfileImage.layer.cornerRadius = img.size.width / 2.0;
                    self.friendProfileImage.layer.masksToBounds = YES;
                });
            });

            [self.tableView reloadData];
        }];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Table view datasource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"SuggestionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    switch(indexPath.section) {
        case 0:
            cell.textLabel.text = self.friendsBirthday;
            cell.detailTextLabel.text = nil;
            break;
        case 1:
            cell.textLabel.text = [[self.friendsLikes objectAtIndex:indexPath.row] objectForKey:@"name"];
            cell.detailTextLabel.text = [[self.friendsLikes objectAtIndex:indexPath.row] objectForKey:@"category"];
            break;
        case 2:
            cell.textLabel.text = [[self.friendsInterests objectAtIndex:indexPath.row] objectForKey:@"name"];
            cell.detailTextLabel.text = [[self.friendsInterests objectAtIndex:indexPath.row] objectForKey:@"category"];
    }
    
    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch(section) {
        case 0:
            return 1;
            break;
        case 1:
            return self.friendsLikes.count;
            break;
        case 2:
            return self.friendsInterests.count;
            break;
        default:
            return 0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.categories.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.categories objectAtIndex:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *customTitleView = [ [UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 40.0)];
    customTitleView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    UILabel *titleLabel = [ [UILabel alloc] initWithFrame:CGRectMake(15.0, 0, 300, 40.0)];
    titleLabel.text = [self.categories objectAtIndex:section];
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:22.0f];
    titleLabel.textColor = [UIColor colorWithRed:189.0/255.0 green:35.0/255.0 blue:43.0/255.0 alpha:1.0];
    [customTitleView addSubview:titleLabel];
    
    return customTitleView;
}

@end
