//
//  ViewController.m
//  MovieMania
//
//  Created by odaman on 2014/07/03.
//  Copyright (c) 2014年 odaman. All rights reserved.
//

#import "ViewController.h"
#import "MoviePlayer.h"

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
	[self viewWillAppear:animated];
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
@end
