//
//  MoviePlayer.h
//  MovieMania
//
//  Created by odaman on 2014/07/03.
//  Copyright (c) 2014年 odaman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface MoviePlayer : NSObject
@property (nonatomic, assign) CMTime duration;
@property (nonatomic, assign) NSTimeInterval loopStart;
@property (nonatomic, assign) NSTimeInterval loopEnd;
@property (nonatomic, assign) NSTimeInterval durationSecond;
@property (atomic, assign) BOOL readyToDisplay;
- (id)initWithMovie:(NSString *)filename;
- (void)addMovieLayerTo:(CALayer *)targetLayer;
- (void)play;
- (void)pause;
- (void)seekToTime:(NSTimeInterval)time;
@end
