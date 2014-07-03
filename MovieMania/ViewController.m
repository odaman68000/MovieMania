//
//  ViewController.m
//  MovieMania
//
//  Created by odaman on 2014/07/03.
//  Copyright (c) 2014年 odaman. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface MoviePlayer : NSObject
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, assign) CMTime duration;
@property (nonatomic, assign) NSTimeInterval loopStart;
@property (nonatomic, assign) NSTimeInterval loopEnd;
@property (nonatomic, assign) NSTimeInterval durationSecond;
@property (atomic, assign) BOOL readyToDisplay;
- (id)initWithMovie:(NSString *)filename;
- (void)addMovieLayerTo:(CALayer *)targetLayer;
- (void)play;
- (void)pause;
- (void)seekToTime:(CMTime)time;
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

- (void)seekToTime:(CMTime)time {
	[self.player seekToTime:time];
}
@end

@interface ViewController ()
@property (nonatomic, weak) IBOutlet UIView *lView;
@property (nonatomic, weak) IBOutlet UIView *rView;
@property (nonatomic, weak) IBOutlet UISlider *ulSlider;
@property (nonatomic, weak) IBOutlet UISlider *urSlider;
@property (nonatomic, weak) IBOutlet UISlider *llSlider;
@property (nonatomic, weak) IBOutlet UISlider *lrSlider;
@property (nonatomic, strong) MoviePlayer *leftPlayer;
@property (nonatomic, strong) MoviePlayer *rightPlayer;
@end

@implementation ViewController
- (void)viewDidLoad {
	[super viewDidLoad];
	NSString *movie1 = [[NSBundle mainBundle] pathForResource:@"movie1" ofType:@"mp4"];
	NSString *movie2 = [[NSBundle mainBundle] pathForResource:@"movie2" ofType:@"mp4"];
	self.leftPlayer = [[MoviePlayer alloc] initWithMovie:movie1];
	self.rightPlayer = [[MoviePlayer alloc] initWithMovie:movie2];
}

- (void)viewWillAppear:(BOOL)animated {
	[self.leftPlayer addMovieLayerTo:self.lView.layer];
	[self.rightPlayer addMovieLayerTo:self.rView.layer];
	while (!(self.leftPlayer.readyToDisplay && self.rightPlayer.readyToDisplay))
		[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
	self.ulSlider.maximumValue = self.leftPlayer.durationSecond;
	self.urSlider.maximumValue = self.rightPlayer.durationSecond;
	self.llSlider.maximumValue = self.leftPlayer.durationSecond;
	self.lrSlider.maximumValue = self.rightPlayer.durationSecond;
	self.llSlider.value = self.leftPlayer.durationSecond;
	self.lrSlider.value = self.rightPlayer.durationSecond;
	[self.leftPlayer play];
	[self.rightPlayer play];
}

- (IBAction)sliderChanged:(id)sender {
	UISlider *slider = (UISlider *)sender;
	float current = slider.value;
	CMTime time = CMTimeMake(current, 1);
	if (slider == self.ulSlider) {
		self.leftPlayer.loopStart = current;
		[self.leftPlayer seekToTime:time];
	} else if (slider == self.urSlider) {
		self.rightPlayer.loopStart = current;
		[self.rightPlayer seekToTime:time];
	} else if (slider == self.llSlider) {
		self.leftPlayer.loopEnd = current;
	} else if (slider == self.lrSlider) {
		self.rightPlayer.loopEnd = current;
	}
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}
@end
