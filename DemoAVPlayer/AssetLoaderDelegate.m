
#import "AssetLoaderDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface AssetLoaderDelegate () <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSMutableDictionary * connectionMap;
@property (nonatomic, strong) NSMutableDictionary * requestMap;

@end

@implementation AssetLoaderDelegate

- (instancetype)init
{
    if (self = [super init]) {
        self.connectionMap = [NSMutableDictionary dictionary];
        self.requestMap = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSURLConnection *)connectionForLoadingRequest:(AVAssetResourceLoadingRequest *)request
{
    if (!request) {
        return nil;
    }
    return self.connectionMap[[NSString stringWithFormat:@"%p", request]];
}

- (AVAssetResourceLoadingRequest *)loadingRequestForConnection:(NSURLConnection *)connection
{
    if (!connection) {
        return nil;
    }
    for (NSString * key in _connectionMap) {
        NSURLConnection * value = _connectionMap[key];
        if (value == connection) {
            return _requestMap[key];
        }
    }
    return nil;
}

- (void)removeConnection:(NSURLConnection *)connection
{
    AVAssetResourceLoadingRequest * request = [self loadingRequestForConnection:connection];
    [self removeRequest:request];
}

- (void)removeRequest:(AVAssetResourceLoadingRequest *)request
{
    if (!request) {
        return;
    }
    
    NSString * key = [NSString stringWithFormat:@"%p", request];
    
    NSURLConnection * c = _connectionMap[key];
    [c cancel];
    
    [_connectionMap removeObjectForKey:key];
    [_requestMap removeObjectForKey:key];
}

- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest
{
    NSMutableURLRequest * request = loadingRequest.request.mutableCopy;
    NSURLComponents * comps = [[NSURLComponents alloc] initWithURL:request.URL resolvingAgainstBaseURL:NO];
    comps.scheme = @"http";
    request.URL = comps.URL;
    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    
    NSLog(@"request: %@", request.allHTTPHeaderFields[@"Range"]);
    
//    if (loadingRequest.dataRequest) {
//        long long offset = loadingRequest.dataRequest.requestedOffset;
//        NSInteger length = loadingRequest.dataRequest.requestedLength;
//        NSString *rangeValue = [NSString stringWithFormat:@"bytes=%llu-%llu", offset, offset + length - 1];
//        [request setValue:rangeValue forHTTPHeaderField:@"Range"];
//    }
    
    NSURLConnection * connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    
    _connectionMap[[NSString stringWithFormat:@"%p", loadingRequest]] = connection;
    _requestMap[[NSString stringWithFormat:@"%p", loadingRequest]] = loadingRequest;
    
    [connection start];
    
    return YES;
}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest
{
    [self removeRequest:loadingRequest];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSString *contentType = [response MIMEType];
    unsigned long long contentLength = [response expectedContentLength];
    
    // 自己解析文件总大小
    NSString *rangeValue = [(NSHTTPURLResponse *)response allHeaderFields][@"Content-Range"];
    if (rangeValue)
    {
        NSArray *rangeItems = [rangeValue componentsSeparatedByString:@"/"];
        if (rangeItems.count > 1)
        {
            contentLength = [rangeItems[1] longLongValue];
        }
        else
        {
            contentLength = [response expectedContentLength];
        }
    }

    AVAssetResourceLoadingRequest * request = [self loadingRequestForConnection:connection];
    request.response = response;
    request.contentInformationRequest.contentLength = contentLength;
    request.contentInformationRequest.contentType = contentType;
    request.contentInformationRequest.byteRangeAccessSupported = YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    AVAssetResourceLoadingRequest * request = [self loadingRequestForConnection:connection];
    [request.dataRequest respondWithData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"request finished: %@", connection.originalRequest.allHTTPHeaderFields[@"Range"]);
    AVAssetResourceLoadingRequest * request = [self loadingRequestForConnection:connection];
    [request finishLoading];
    [self removeRequest:request];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"request failed: %@, error: %@", connection.originalRequest.allHTTPHeaderFields[@"Range"], error);

    AVAssetResourceLoadingRequest * request = [self loadingRequestForConnection:connection];
    [request finishLoadingWithError:error];
    [self removeRequest:request];
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
    AVAssetResourceLoadingRequest * loadingRequest = [self loadingRequestForConnection:connection];
    loadingRequest.redirect = request;
    return request;
}

@end
