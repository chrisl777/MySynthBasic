//
//  ChrisAudioEngine.h
//  MySynthBasic
//
//  Created by Chris Livdahl on 7/19/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import <AudioUnit/AudioUnit.h> 
#import <AudioToolbox/AudioToolbox.h>  //for AUGraph
#import <CoreAudio/CoreAudio.h> 
//

typedef struct 
{
	AudioStreamBasicDescription asbd;
	UInt32 startingFrame;
	float *data;
	UInt32 numFrames;
    UInt32 phase;
	NSString *name;
} SndBuf;

#define MAXBUFS 8

struct SoundData
{
	int numbufs;
	SndBuf bufs[MAXBUFS];
	int select;
};


@interface ChrisAudioEngine : NSObject {

    AUGraph theGraph; 
    
    AUNode generatorOne; 
    AUNode generatorTwo; 
    AUNode generatorThree; 
    
    AUNode outputNode; 
    AUNode multiChannelMixerNode; 
    
    AudioUnit mixerUnit; 
    AudioUnit outputUnit; 
    
    struct SoundData dataStruct; 
    
    Boolean isPlaying; 
    
    float* sineData; 
    float* squareData; 
    float* triangleData; 
    float* sawData; 
}

-(void)initializeAUGraph; 
-(void)start; 
-(void)stop; 
-(void)setMasterVolume:(double)input; 
-(void)setMixerChannelVolume:(double)input forChannel:(int)channel; 
-(void)setOSC:(NSString *)input forChannel:(int)channel; 

-(void)seedSineData; 
-(void)seedSquareData; 
-(void)seedTriangleData; 
-(void)seedSawData; 


@end
