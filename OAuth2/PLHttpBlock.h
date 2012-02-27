//
//  PLHttpBlock.h
//  LessDJ
//
//  Created by xu xhan on 11/7/11.
//  Copyright (c) 2011 xu han. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PLHttpClient.h"

/*
    version 1.0
    > origin codes from LessDJ project
    version 1.1
    > added diction(JSON) support
    > version 1.2
    > added cache support
 */

//typedef void (^PLBlockOK)(NSDictionary*);
typedef void (^PLBlockError)(NSError*);
typedef void (^PLBlockOK)(id);

@interface PLHttpBlock : PLHttpClient<PLHttpClientDelegate>
{
    PLBlockOK _blockDict;
    PLBlockError _blockError;
    int _cacheSeconds;
}

- (void)getForce:(NSURL *)url ok:(PLBlockOK)blockOK fail:(PLBlockError)blockError;
- (void)get:(NSURL *)url ok:(PLBlockOK)blockOK fail:(PLBlockError)blockError;

- (void)get:(NSURL *)url cache:(int)seconds ok:(PLBlockOK)blockOK fail:(PLBlockError)blockError;

- (void)post:(NSURL *)url body:(NSString *)body ok:(PLBlockOK)blockOK fail:(PLBlockError)blockError;

- (void)postForm:(NSURL *)url params:(NSDictionary *)params file:(NSString*)name data:(NSData*)data ok:(PLBlockOK)blockOK fail:(PLBlockError)blockError;

- (void)post:(NSURL *)url bodyDict:(NSDictionary *)body ok:(PLBlockOK)blockOK fail:(PLBlockError)blockError;

- (void)_prepareBlock:(PLBlockOK)blockOK fail:(PLBlockError)blockError;
- (void)_cleanBlock;

+ (NSString *)stringFromDictionary:(NSDictionary *)dict;
@end
