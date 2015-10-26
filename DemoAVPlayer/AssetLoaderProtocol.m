//
//  AssetLoaderProtocol.m
//  DemoAVPlayer
//
//  Created by 吴天 on 15/10/26.
//  Copyright © 2015年 Wutian. All rights reserved.
//

#import "AssetLoaderProtocol.h"

@interface AssetLoaderProtocol () <NSURLConnectionDataDelegate, NSURLConnectionDelegate>

@property (nonatomic, strong) NSURLConnection * connection;

@end

@implementation AssetLoaderProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    return [request.URL.scheme isEqual:@"wbvdo"];
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

- (void)startLoading
{
    NSMutableURLRequest * request = [self.request mutableCopy];
    
    NSURLComponents * comps = [[NSURLComponents alloc] initWithURL:request.URL resolvingAgainstBaseURL:NO];
    comps.scheme = @"http";
    request.URL = comps.URL;
    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    
    NSLog(@"request: %@", request.allHTTPHeaderFields[@"Range"]);
    
    NSURLConnection * connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    self.connection = connection;
    
    [connection start];
}

- (void)stopLoading
{
    if (self.connection) {
        [self.connection cancel];
        self.connection = nil;
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self.client URLProtocol:self didFailWithError:error];
    self.connection = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.client URLProtocol:self didLoadData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self.client URLProtocolDidFinishLoading:self];
    self.connection = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)response;
        NSHTTPURLResponse * fakeResponse = [[NSHTTPURLResponse alloc] initWithURL:self.request.URL statusCode:httpResponse.statusCode HTTPVersion:@"HTTP/1.1" headerFields:httpResponse.allHeaderFields];
        response = fakeResponse;
    }
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

//- (nullable NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(nullable NSURLResponse *)response
//{
//    NSMutableURLRequest * resultRequest = [request mutableCopy];
//    NSURLComponents * comps = [[NSURLComponents alloc] initWithURL:resultRequest.URL resolvingAgainstBaseURL:NO];
//    comps.scheme = @"wbvdo";
//    resultRequest.URL = comps.URL;
//    
//    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
//        NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)response;
//        NSHTTPURLResponse * fakeResponse = [[NSHTTPURLResponse alloc] initWithURL:self.request.URL statusCode:httpResponse.statusCode HTTPVersion:@"HTTP/1.1" headerFields:httpResponse.allHeaderFields];
//        response = fakeResponse;
//    }
//    
//    [self.client URLProtocol:self wasRedirectedToRequest:resultRequest redirectResponse:response];
//    return resultRequest;
//}

@end
