//
//  MoviePlayer.m
//  MovieMania
//
//  Created by odaman on 2014/07/03.
//  Copyright (c) 2014年 odaman. All rights reserved.
//

#import "MoviePlayer.h"

@interface MoviePlayer ()
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@end

@implementation MoviePlayer
- (id)initWithMovie:(NSString *)filename {
	if ((self = [super init]) == nil)
		return nil;
	NSURL *url = [NSURL fileURLWithPath:filename];
	_playerItem = [AVPlayerItem playerItemWithURL:url];
	_player = [AVPlayer playerWithPlayerItem:_playerItem];
	_playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
	[_playerLayer addObserver:self forKeyPath:@"readyForDisplay" options:NSKeyValueObservingOptionNew context:nil];
	return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	BOOL readyForDisplay = [change[NSKeyValueChangeNewKey] boolValue];
	if (!readyForDisplay)
		return;
	AVPlayerLayer *playerLayer = object;
	[playerLayer removeObserver:self forKeyPath:@"readyForDisplay"];
	AVPlayerItem *playerItem = playerLayer.player.currentItem;
	self.duration = playerItem.duration;
	self.loopStart = 0;
	self.loopEnd = self.duration.value / self.duration.timescale;
	self.durationSecond = self.loopEnd;
	__weak MoviePlayer *wself = self;
	[self.player addPeriodicTimeObserverForInterval:CMTimeMake(self.duration.timescale / 2, self.duration.timescale) queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) usingBlock:^(CMTime time) {
		NSTimeInterval timeSecond = time.value / time.timescale;
		if (timeSecond >= wself.loopEnd)
			[wself.player seekToTime:CMTimeMake(wself.loopStart, 1)];
	}];
	self.readyToDisplay = YES;
}

- (void)addMovieLayerTo:(CALayer *)targetLayer {
	self.playerLayer.frame = targetLayer.bounds;
	[targetLayer addSublayer:self.playerLayer];
}

- (void)play {
	while (!self.readyToDisplay)
		[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
	[self.player play];
}

- (void)pause {
	[self.player pause];
}

- (void)seekToTime:(NSTimeInterval)time {
	[self.player seekToTime:CMTimeMake(time, 1)];
}
@end
