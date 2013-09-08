//
//  PASuggestionsTableViewController.m
//  Suggest
//
//  Created by Camden Fullmer on 9/7/13.
//  Copyright (c) 2013 Camden Fullmer. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import "PAProductsTableViewController.h"
#import "FFCircularProgressView.h"

@interface PAProductsTableViewController ()

@property (nonatomic, strong) NSMutableString *keywords;
@property (nonatomic, strong) NSArray *products;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) dispatch_queue_t imageQueue;
@property (nonatomic, strong) FFCircularProgressView *circularProgressView;

@end

@implementation PAProductsTableViewController

@synthesize suggestion = _suggestion;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _keywords = [[NSMutableString alloc] init];
        _imageQueue = dispatch_queue_create("com.camdenfullmer.Suggest.queue2", NULL);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = self.suggestion.facebookName;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self retrieveProducts];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.products.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SuggestionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    Product *product = [self.products objectAtIndex:indexPath.row];
    
    if(product.image) {
        cell.imageView.image = [UIImage imageWithData:product.image];
        cell.imageView.layer.cornerRadius = 4.0;
        cell.imageView.layer.masksToBounds = YES;
    } else {
        cell.imageView.image = nil;
        dispatch_async(self.imageQueue, ^{
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:product.imageURL]];
            dispatch_async(dispatch_get_main_queue(), ^{
                product.image = imageData;
                cell.imageView.image = [UIImage imageWithData:imageData];
                cell.imageView.layer.cornerRadius = 4.0;
                cell.imageView.layer.masksToBounds = YES;
                @try{
                    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
                }
                @catch (NSException *exception) {   
                }
            });
        });
    }
    
    cell.textLabel.text = product.name;
    NSNumberFormatter *currencyStyle = [[NSNumberFormatter alloc] init];
    [currencyStyle setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [currencyStyle setNumberStyle:NSNumberFormatterCurrencyStyle];
    NSString *formatted = [currencyStyle stringFromNumber:product.price];
    cell.detailTextLabel.text = formatted;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Product *product =[self.products objectAtIndex:indexPath.row];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:product.link]];
}

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

#pragma mark - URL connection delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    self.responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSError* error;
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    NSArray* json = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableContainers error:&error];
    
    
    NSManagedObjectContext *context = [self managedObjectContext];
    if(json.count > 0) {
        // Create new products.
        for(NSDictionary *dict in json) {
            Product *product = [NSEntityDescription insertNewObjectForEntityForName:@"Product" inManagedObjectContext:context];
            product.name = dict[@"title"];
            product.imageURL = dict[@"image"];
            product.link = dict[@"link"];
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
            product.price = [formatter numberFromString:dict[@"price"]];
            product.suggestion = self.suggestion;
        }
        
        self.suggestion.created = [NSDate dateWithTimeIntervalSinceNow:0];
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
            return;
        }
        
        [self retrieveProducts];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Opps!" message:@"Unable to get response from server." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
    
    [self.circularProgressView removeFromSuperview];
    self.circularProgressView = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
}


- (void)retrieveInformation {
    self.circularProgressView = [[FFCircularProgressView alloc] initWithFrame:CGRectMake(0, 0, 50.0, 50.0)];
    self.circularProgressView.center = CGPointMake(CGRectGetMidX(self.tableView.bounds), CGRectGetMidY(self.tableView.bounds));
    [self.tableView addSubview:self.circularProgressView];
    [self.circularProgressView startSpinProgressBackgroundLayer];    
    
    if (FBSession.activeSession.isOpen) {
        FBRequest *friendRequest = [FBRequest requestForGraphPath:[NSString stringWithFormat:@"%@%@", self.suggestion.facebookId, @"?fields=likes"]];
        [friendRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://pinch-app-prod.herokuapp.com/q"]];
                request.HTTPMethod = @"POST";
                [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                
                NSArray *likes = result[@"likes"][@"data"];
                for(int i = 0; i < likes.count; i++) {
                    [result[@"likes"][@"data"][i] removeObjectForKey:@"category"];
                    [result[@"likes"][@"data"][i] removeObjectForKey:@"category_list"];
                    [result[@"likes"][@"data"][i] removeObjectForKey:@"created_time"];
                    [result[@"likes"][@"data"][i] removeObjectForKey:@"id"];
                }
                
                [result[@"likes"] removeObjectForKey:@"paging"];
                
                if(result[@"likes"]) {
                    NSData *data = [NSJSONSerialization dataWithJSONObject:result[@"likes"] options:NSJSONWritingPrettyPrinted error:&error];
                    [request setHTTPBody:data];
                    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
                    NSLog(@"%@", connection.description);
                } else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Opps!" message:@"Your friend has no interesting information." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alert show];
                }
            }
        }];
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

- (void)retrieveProducts {
    // Fetch the devices from persistent data store
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Product"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"suggestion == %@", self.suggestion];
    [fetchRequest setPredicate:predicate];
    self.products = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    if(self.products.count > 0) {
        [self.tableView reloadData];
    }
    else {
        [self retrieveInformation];
    }
}

@end
