//
//  Suggestion.h
//  Suggest
//
//  Created by Camden Fullmer on 9/7/13.
//  Copyright (c) 2013 Camden Fullmer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Product;

@interface Suggestion : NSManagedObject

@property (nonatomic, retain) NSString * facebookId;
@property (nonatomic, retain) NSString * facebookName;
@property (nonatomic, retain) NSString * facebookPictureURL;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSData * facebookPicture;
@property (nonatomic, retain) NSSet *products;
@end

@interface Suggestion (CoreDataGeneratedAccessors)

- (void)addProductsObject:(Product *)value;
- (void)removeProductsObject:(Product *)value;
- (void)addProducts:(NSSet *)values;
- (void)removeProducts:(NSSet *)values;

@end
