//
//  PASettingsViewController.m
//  Suggest
//
//  Created by Camden Fullmer on 9/7/13.
//  Copyright (c) 2013 Camden Fullmer. All rights reserved.
//

#import "PASettingsViewController.h"

@interface PASettingsViewController () <UIActionSheetDelegate>

@end

@implementation PASettingsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch(indexPath.section) {
        case 0:
            switch(indexPath.row) {
                case 0:
                    [self showClearActionSheet];
                    break;
            }
        break;
            
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if([actionSheet.title isEqualToString:@"Are you sure you want to clear all suggestions?"] && buttonIndex == 0) {
        NSManagedObjectContext *context = [self managedObjectContext];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:[NSEntityDescription entityForName:@"Suggestion" inManagedObjectContext:context]];
        [request setIncludesPropertyValues:NO]; //only fetch the managedObjectID
        
        NSError * error = nil;
        NSArray *suggestions = [context executeFetchRequest:request error:&error];
        //error handling goes here
        for (NSManagedObject *suggestion in suggestions) {
            [context deleteObject:suggestion];
        }
        NSError *saveError = nil;
        [context save:&saveError];
        //more error handling here
    }
}

- (void)showClearActionSheet {
    UIActionSheet *clearActionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure you want to clear all suggestions?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil];
    [clearActionSheet showInView:self.tableView];
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
