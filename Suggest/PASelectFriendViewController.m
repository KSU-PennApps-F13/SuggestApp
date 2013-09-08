//
//  PASelectFriendViewController.m
//  Pinch
//
//  Created by Camden Fullmer on 9/6/13.
//  Copyright (c) 2013 Camden Fullmer. All rights reserved.
//

#import "PASelectFriendViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "UIImageView+AFNetworking.h"
#import "CFShareCircleView.h"

@interface PASelectFriendViewController () <UISearchDisplayDelegate>

@property (nonatomic, strong) NSArray *friends;
@property (nonatomic, strong) NSMutableArray *searchResults;

@end

@implementation PASelectFriendViewController

@synthesize delegate = _delegate;

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        // Custom initialization
        _friends = [[NSArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self populateFriends];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return self.searchResults.count;
    } else {
        return self.friends.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"FriendCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    FBGraphObject<FBGraphUser> *friend;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        friend = [self.searchResults objectAtIndex:indexPath.row];
    } else {
        friend = [self.friends objectAtIndex:indexPath.row];
    }
    
    cell.textLabel.text = friend.name;
    __weak UITableViewCell *weakCell = cell;
    [cell.imageView setImageWithURLRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:friend[@"picture"][@"data"][@"url"]]]
                          placeholderImage:nil
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image){
                                       weakCell.imageView.image = image;
                                       
                                       //only required if no placeholder is set to force the imageview on the cell to be laid out to house the new image.
                                       if(weakCell.imageView.frame.size.height==0 || weakCell.imageView.frame.size.width==0 ){
                                           [weakCell setNeedsLayout];
                                       }
                                   }
                                   failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                                       
                                   }];
    
    return cell;
}

# pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {    
    FBGraphObject *friend;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        friend = [self.searchResults objectAtIndex:indexPath.row];
    } else {
        friend = [self.friends objectAtIndex:indexPath.row];
    }
    
    [self.delegate selectFriendViewController:self didSelectFriend:friend];
}

# pragma mark - Search display delegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    return YES;
}

- (void)populateFriends {
    if (FBSession.activeSession.isOpen) {
        FBRequest *friendRequest = [FBRequest requestForGraphPath:@"me/friends?fields=name,picture.width(140).height(140)"];
        [friendRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                self.friends = [(NSArray *)[result objectForKey:@"data"] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                    return [[((FBGraphObject *) obj1) objectForKey:@"name"] compare:[((FBGraphObject *) obj2) objectForKey:@"name"]];
                }];
                self.searchResults = [NSMutableArray arrayWithCapacity:self.friends.count];
                self.tableView.hidden = NO;
                self.emptyView.hidden = YES;
                [self.tableView reloadData];
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            }
        }];
    }
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    [self.searchResults removeAllObjects];
    
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"name CONTAINS[c] %@", searchText];
    
    self.searchResults = [NSMutableArray arrayWithArray:[self.friends filteredArrayUsingPredicate:resultPredicate]];
}

- (IBAction)cancelButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
