//
//  ViewController.m
//  DemoAVPlayer
//
//  Created by 吴天 on 15/10/23.
//  Copyright © 2015年 Wutian. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "AssetLoaderDelegate.h"
#import "AssetLoaderProtocol.h"

@interface ViewController ()

@property (nonatomic, strong) AssetLoaderDelegate * loaderDelegate;

@end

@implementation ViewController

static AVPlayer * theplayer = nil;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.loaderDelegate = [[AssetLoaderDelegate alloc] init];
    
    NSURL * url = [NSURL URLWithString:@"videotest://gslb.miaopai.com/stream/1Hjncfts3zwAecszeN4FgQ__.mp4?yx=&refer=weibo_app"];
    AVURLAsset * asset = [AVURLAsset assetWithURL:url];
    [asset.resourceLoader setDelegate:self.loaderDelegate queue:dispatch_get_main_queue()];
    AVPlayerItem * item = [[AVPlayerItem alloc] initWithAsset:asset];
    AVPlayer * player = [AVPlayer playerWithPlayerItem:item];
    
    
//    [NSURLProtocol registerClass:[AssetLoaderProtocol class]];
//    NSURL * url = [NSURL URLWithString:@"wbvdo://gslb.miaopai.com/stream/bMXSqHume6Tck40Ya3lsdA__.mp4?yx=&refer=weibo_app"];
//    AVURLAsset * asset = [AVURLAsset assetWithURL:url];
//    AVPlayerItem * item = [[AVPlayerItem alloc] initWithAsset:asset];
//    AVPlayer * player = [AVPlayer playerWithPlayerItem:item];

    
    self.player = player;
    
    theplayer = player;
    [player play];
}

+ (AVPlayer *)player
{
    return theplayer;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
