//
//  PASelectFriendViewController.m
//  Pinch
//
//  Created by Camden Fullmer on 9/6/13.
//  Copyright (c) 2013 Camden Fullmer. All rights reserved.
//

#import "PASelectFriendViewController.h"
#import "PASuggestionsViewController.h"
#import <FacebookSDK/FacebookSDK.h>

@interface PASelectFriendViewController () <UISearchDisplayDelegate>

@property (nonatomic, strong) NSArray *friends;
@property (nonatomic, strong) NSMutableArray *searchResults;
@property (nonatomic, weak) FBGraphObject<FBGraphUser> *selectedFriend;

@end

@implementation PASelectFriendViewController

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
    
    return cell;
}

# pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        self.selectedFriend = [self.searchResults objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"FriendToSuggestionSegue" sender:self];
    }
}

# pragma mark - Search display delegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    return YES;
}


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if(!self.selectedFriend) {
        self.selectedFriend = [self.friends objectAtIndex:self.tableView.indexPathForSelectedRow.row];
    }
    
    PASuggestionsViewController *viewController = [segue destinationViewController];
    [viewController setSelectedFriend:self.selectedFriend];
    self.selectedFriend = nil;
}

- (void)populateFriends {
    if (FBSession.activeSession.isOpen) {
        [[FBRequest requestForMyFriends] startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                self.friends = [(NSArray *)[result objectForKey:@"data"] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                    return [((FBGraphObject<FBGraphUser> *) obj1).name compare:((FBGraphObject<FBGraphUser> *) obj2).name];
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
