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
#import "PAAppDelegate.h"
#import "Suggestion.h"
#import "Product.h"
#import "TTTTimeIntervalFormatter.h"

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
    [self retrieveSuggestions];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0f;
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
        // Delete object from database
        NSManagedObjectContext *context = [self managedObjectContext];
        [context deleteObject:[self.suggestions objectAtIndex:indexPath.row]];
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
            return;
        }
        
        // Remove device from table view
        [self.suggestions removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        if(self.suggestions.count == 0) {
            self.tableView.hidden = YES;
            self.emptyView.hidden = NO;
            self.navigationItem.leftBarButtonItem = nil;
        }
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
    
    Suggestion *suggestion = [self.suggestions objectAtIndex:[indexPath row]];
    
    cell.textLabel.text = suggestion.facebookName;
    if(suggestion.created) {
        TTTTimeIntervalFormatter *timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Created %@", [timeIntervalFormatter stringForTimeInterval:[suggestion.created timeIntervalSinceNow]]];
    } else {
        cell.detailTextLabel.text = @"";
    }
    
    if (suggestion.facebookPicture) {
        cell.imageView.image = [UIImage imageWithData:suggestion.facebookPicture];
        cell.imageView.layer.cornerRadius = cell.imageView.image.size.width / 2.0;
        cell.imageView.layer.masksToBounds = YES;
    } else {
        cell.imageView.image = nil;
        dispatch_async(self.imageQueue, ^{
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:suggestion.facebookPictureURL]];
            dispatch_async(dispatch_get_main_queue(), ^{
                suggestion.facebookPicture = imageData;
                
                NSError *error = nil;
                // Save the object to persistent store
                if (![[self managedObjectContext] save:&error]) {
                    NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
                }
                cell.imageView.image = [UIImage imageWithData:imageData];
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
    [viewController setSuggestion:[self.suggestions objectAtIndex:self.tableView.indexPathForSelectedRow.row]];
}

#pragma mark - Select friend delegate

- (void)selectFriendViewController:(PASelectFriendViewController *)selectFriendViewController didSelectFriend:(FBGraphObject *)selectedFriend {
    NSManagedObjectContext *context = [self managedObjectContext];
    
    // Create a new suggestion.
    Suggestion *suggestion = [NSEntityDescription insertNewObjectForEntityForName:@"Suggestion" inManagedObjectContext:context];
    [suggestion setValue:selectedFriend[@"name"] forKey:@"facebookName"];
    [suggestion setValue:selectedFriend[@"id"] forKey:@"facebookId"];
    [suggestion setValue:selectedFriend[@"profile_picture"][@"data"][@"url"] forKey:@"facebookPictureURL"];
    
    NSError *error = nil;
    // Save the object to persistent store
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        PAProductsTableViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SuggestionsTableViewController"];
        [viewController setSuggestion:suggestion];
        [self.navigationController pushViewController:viewController animated:YES];
    }];
}

- (IBAction)createSuggestionButtonClicked:(id)sender {
    UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectFriendNavigationViewController"];
    PASelectFriendViewController *viewController = (PASelectFriendViewController *)navigationController.topViewController;
    viewController.delegate = self;
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)retrieveSuggestions {
    // Fetch the devices from persistent data store
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Suggestion"];
    self.suggestions = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    if(self.suggestions.count == 0) {
        self.tableView.hidden = YES;
        self.emptyView.hidden = NO;
        self.navigationItem.leftBarButtonItem = nil;
    }
    else {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createSuggestionButtonClicked:)];
        self.tableView.hidden = NO;
        self.emptyView.hidden = YES;
    }
    
    [self.tableView reloadData];
}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

@end
