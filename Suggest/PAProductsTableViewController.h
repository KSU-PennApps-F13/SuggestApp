//
//  PASuggestionsTableViewController.h
//  Suggest
//
//  Created by Camden Fullmer on 9/7/13.
//  Copyright (c) 2013 Camden Fullmer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Product.h"
#import "Suggestion.h"

@interface PAProductsTableViewController : UITableViewController <NSURLConnectionDelegate>

@property (nonatomic, strong) Suggestion *suggestion;

@end
