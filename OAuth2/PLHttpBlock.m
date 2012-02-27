//
//  PLHttpBlock.m
//  LessDJ
//
//  Created by xu xhan on 11/7/11.
//  Copyright (c) 2011 xu han. All rights reserved.
//

#import "PLHttpBlock.h"
#import "APIEngine.h"
#import "JSONKit.h"

#define ENABLE_CACHE 1
#if ENABLE_CACHE
#import "CacheCenter.h"
#endif
//#import "DBFM.h"

@implementation PLHttpBlock

- (void)getForce:(NSURL *)url ok:(PLBlockDict)blockOK fail:(PLBlockError)blockError
{
    [self _prepareBlock:blockOK fail:blockError];
    [super get:url];    
}

- (void)get:(NSURL *)url ok:(PLBlockDict)blockOK fail:(PLBlockError)blockError
{
    [self get:url cache:15 ok:blockOK fail:blockError]; //cache 20 seconds
}

- (void)get:(NSURL *)url cache:(int)seconds ok:(PLBlockDict)blockOK fail:(PLBlockError)blockError
{
#if ENABLE_CACHE    
    _cacheSeconds = seconds;
    NSDictionary* obj = [[CacheCenter defaultCenter] objectForCachedKey:url];
    if ([obj isKindOfClass:NSDictionary.class]) {
        //PLOG(@"get response from cache");        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
            blockOK(obj);
        });
        
        //TODO: still need to fetch url if possible
    }else{
        [self getForce:url ok:blockOK fail:blockError];
    }
#else
    [self getForce:url ok:blockOK fail:blockError];
#endif    
}


- (void)post:(NSURL *)url body:(NSString *)body ok:(PLBlockDict)blockOK fail:(PLBlockError)blockError
{
    [self _prepareBlock:blockOK fail:blockError];
    [super post:url body:body];
}

- (void)post:(NSURL *)url bodyDict:(NSDictionary *)body ok:(PLBlockDict)blockOK fail:(PLBlockError)blockError
{
    [self post:url 
          body:[body JSONString] 
            ok:blockOK
          fail:blockError];
}

- (void)postForm:(NSURL *)url params:(NSDictionary *)params file:(NSString*)name data:(NSData*)data ok:(PLBlockDict)blockOK fail:(PLBlockError)blockError
{
    [self _prepareBlock:blockOK fail:blockError];
    [super postForm:url params:params fileName:name fileData:data];
}

- (void)_prepareBlock:(PLBlockDict)blockOK fail:(PLBlockError)blockError
{
    self.delegate = nil;
    [self _cleanBlock];    
    _blockDict = Block_copy(blockOK);
    _blockError= Block_copy(blockError);
    self.delegate = self;
}
- (void)_cleanBlock
{
    if (_blockDict) {
        Block_release(_blockDict), _blockDict = NULL;
    }
    if (_blockError) {
        Block_release(_blockError), _blockError = NULL;
    }
}


- (void)cleanBeforeRelease
{
    self.delegate = nil;
    [self _cleanBlock];
    [self cancel];
}

- (void)dealloc
{
    [self _cleanBlock];
    [super dealloc];
}

#pragma mark - delegate

- (void)httpClient:(PLHttpClient *)hc failed:(NSError *)error
{
    if (_blockError) {
        _blockError(error);
    }
    
    [self _cleanBlock];
}

- (void)httpClient:(PLHttpClient *)hc successed:(NSData *)data
{
    NSError* error;
//    NSDictionary* dict = [DBFM parseContent:[hc stringValue] withError:&error];
    NSDictionary* dict = [APIEngine parseContent:[hc stringValue] withError:&error];
    if (error) {
        [self httpClient:hc failed:error];
    }else{
#if ENABLE_CACHE         
        if (_cacheSeconds >0 && hc.requestMethod == PLHttpMethodGet) {
            [[CacheCenter defaultCenter] cacheObject:dict forKey:[hc url] duration2expire:_cacheSeconds];
        }
        _cacheSeconds = 0;
#endif        
        if (_blockDict) {
            _blockDict(dict);
        }        
        [self _cleanBlock];
    }
}

@end
