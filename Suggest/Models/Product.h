//
//  Product.h
//  Suggest
//
//  Created by Camden Fullmer on 9/8/13.
//  Copyright (c) 2013 Camden Fullmer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Suggestion;

@interface Product : NSManagedObject

@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) Suggestion *suggestion;

@end
