//
//  PASuggestViewController.m
//  Pinch
//
//  Created by Camden Fullmer on 9/7/13.
//  Copyright (c) 2013 Camden Fullmer. All rights reserved.
//

#import "PASuggestViewController.h"
#import "PASelectFriendViewController.h"
#import "PAProductsTableViewController.h"
#import "FFCircularProgressView.h"

@interface PASuggestViewController () <UITableViewDataSource, UITableViewDelegate, PASelectFriendDelegate>
@property (nonatomic, strong) NSMutableArray *suggestions;
@property (nonatomic, strong) dispatch_queue_t imageQueue;
@end

@implementation PASuggestViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
        _suggestions = [[NSMutableArray alloc] init];
        _imageQueue = dispatch_queue_create("com.camdenfullmer.Suggest.queue", NULL);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.suggestions removeObjectAtIndex:indexPath.row];
        if(self.suggestions.count == 0) {
            self.tableView.hidden = YES;
            self.emptyView.hidden = NO;
        }
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - Table view datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.suggestions.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"SuggestionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [[self.suggestions objectAtIndex:indexPath.row] objectForKey:@"name"];
    
    FBGraphObject *suggestion = [self.suggestions objectAtIndex:[indexPath row]];
    if ([suggestion valueForKey:@"actualImage"]) {
        [[cell imageView] setImage:[suggestion valueForKey:@"actualImage"]];
        cell.imageView.layer.cornerRadius = cell.imageView.image.size.width / 2.0;
        cell.imageView.layer.masksToBounds = YES;
    } else {
        cell.imageView.image = nil;
        dispatch_async(self.imageQueue, ^{
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[[suggestion objectForKey:@"profile_picture"] objectForKey:@"data"] objectForKey:@"url"]]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [suggestion setValue:[UIImage imageWithData:imageData] forKey:@"actualImage"];
                [[cell imageView] setImage:[suggestion valueForKey:@"actualImage"]];
                cell.imageView.layer.cornerRadius = cell.imageView.image.size.width / 2.0;
                cell.imageView.layer.masksToBounds = YES;
                [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
            });
        });
    }
    
    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    PAProductsTableViewController *viewController = [segue destinationViewController];
    [viewController setSelectedFriend:[self.suggestions objectAtIndex:self.tableView.indexPathForSelectedRow.row]];
}

#pragma mark - Select friend delegate

- (void)selectFriendViewController:(PASelectFriendViewController *)selectFriendViewController didSelectFriend:(FBGraphObject *)selectedFriend {
    [self.suggestions addObject:selectedFriend];
    self.tableView.hidden = NO;
    self.emptyView.hidden = YES;
    [self dismissViewControllerAnimated:YES completion:^{
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createSuggestionButtonClicked:)];
        [self.tableView reloadData];
        PAProductsTableViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SuggestionsTableViewController"];
        [viewController setSelectedFriend:selectedFriend];
        [self.navigationController pushViewController:viewController animated:YES];
    }];
}

- (IBAction)createSuggestionButtonClicked:(id)sender {
    UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectFriendNavigationViewController"];
    PASelectFriendViewController *viewController = (PASelectFriendViewController *)navigationController.topViewController;
    viewController.delegate = self;
    [self presentViewController:navigationController animated:YES completion:nil];
}
@end
