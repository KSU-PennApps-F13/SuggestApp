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

@interface PAProductsTableViewController : UITableViewController

@property (nonatomic, strong) Suggestion *suggestion;

@end
