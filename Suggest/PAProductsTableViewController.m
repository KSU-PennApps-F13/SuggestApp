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
#import "AFJSONRequestOperation.h"
#import "UIImageView+AFNetworking.h"

@interface PAProductsTableViewController () <DBRestClientDelegate>

@property (nonatomic, strong) NSMutableString *keywords;
@property (nonatomic, strong) NSArray *products;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) dispatch_queue_t imageQueue;
@property (nonatomic, strong) FFCircularProgressView *circularProgressView;

@end

@implementation PAProductsTableViewController

@synthesize suggestion = _suggestion;
@synthesize restClient = _restClient;

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
    if ([[DBSession sharedSession] isLinked]) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"dropbox-share.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(shareToDropbox)];
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    [self retrieveProducts];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.products = nil;
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
    cell.imageView.layer.cornerRadius = 4.0;
    cell.imageView.layer.masksToBounds = YES;
    cell.textLabel.text = product.name;
    NSNumberFormatter *currencyStyle = [[NSNumberFormatter alloc] init];
    [currencyStyle setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [currencyStyle setNumberStyle:NSNumberFormatterCurrencyStyle];
    NSString *formatted = [currencyStyle stringFromNumber:product.price];
    cell.detailTextLabel.text = formatted;
    __weak UITableViewCell *weakCell = cell;
    [cell.imageView setImageWithURLRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:product.imageURL]]
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Product *product =[self.products objectAtIndex:indexPath.row];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:product.link]];
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
                NSArray *likes = result[@"likes"][@"data"];
                for(int i = 0; i < likes.count; i++) {
                    [self queryServer:result[@"likes"][@"data"][i][@"name"]];
                }
                self.suggestion.created = [NSDate dateWithTimeIntervalSinceNow:0];
            }
        }];
    }
}

- (void)queryServer:(NSString *)keyword {
    NSError *error = nil;
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:@[keyword] forKeys:@[@"name"]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://pinch-app-prod.herokuapp.com/q"]];
    request.HTTPMethod = @"POST";
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    [request setHTTPBody:data];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSManagedObjectContext *context = [self managedObjectContext];
        NSArray *json = JSON;
        if(json.count > 0) {
            NSArray *shopYourWay = json[0];
            // Create new products.
            for(NSDictionary *dictionary in shopYourWay) {
                Product *product = [NSEntityDescription insertNewObjectForEntityForName:@"Product" inManagedObjectContext:context];
                product.name = dictionary[@"title"];
                product.imageURL = dictionary[@"image"];
                product.link = dictionary[@"link"];
                NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
                product.price = [formatter numberFromString:[NSString stringWithFormat:@"%@",dictionary[@"price"]]];
                product.suggestion = self.suggestion;
            }
            
            if(self.circularProgressView) {
                [self.circularProgressView removeFromSuperview];
                self.circularProgressView = nil;
                self.navigationItem.rightBarButtonItem.enabled = YES;
            }
            
            NSError *error = nil;
            if (![context save:&error]) {
                NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
                return;
            }
            
            [self retrieveProducts];
        }
        
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"%@", error.localizedDescription);
    }];
    [operation start];
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
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    else {
        [self retrieveInformation];
    }
}

- (void)shareToDropbox {
    NSArray *items = [self.products copy];
    NSMutableString *content = [[NSMutableString alloc] init];
    for(Product *product in items) {
        [content appendString:[NSString stringWithFormat:@"%@\n%@\n%@\n\n", product.name, product.link, product.price]];
    }
    
    NSString *documentsDirectory = [NSHomeDirectory()
                                    stringByAppendingPathComponent:@"Documents"];
    
    NSString *filePath = [documentsDirectory
                          stringByAppendingPathComponent:@"fileArray.txt"];
    
    // Write to the file
    NSError *error = nil;
    [content writeToFile:filePath atomically:YES
                    encoding:NSUTF8StringEncoding error:&error];
    
    NSString *destDir = @"/";
    [[self restClient] uploadFile:[NSString stringWithFormat:@"%@.txt", [self.suggestion.facebookName stringByReplacingOccurrencesOfString:@" " withString:@""]] toPath:destDir withParentRev:nil fromPath:filePath];
}

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath
              from:(NSString*)srcPath metadata:(DBMetadata*)metadata {
    
    UIAlertView *dbAlertView = [[UIAlertView alloc] initWithTitle:@"Awesome!" message:@"File was uploaded to Dropbox!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [dbAlertView show];
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error {
    NSLog(@"File upload failed with error - %@", error);
}

- (DBRestClient *)restClient {
    if (!_restClient) {
        _restClient =
        [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        _restClient.delegate = self;
    }
    return _restClient;
}

@end
