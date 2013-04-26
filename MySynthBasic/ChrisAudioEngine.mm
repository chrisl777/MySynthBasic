//
//  ChrisAudioEngine.m
//  MySynthBasic
//
//  Created by Chris Livdahl on 7/19/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import "ChrisAudioEngine.h"
#import <AudioUnit/AudioUnitParameters.h>
#import <AudioUnit/AudioUnitProperties.h>
//#import "CAStreamBasicDescription.h" 


// the sample rate for our setup 
const Float64 kGraphSampleRate = 44100; 

#define DURATION 5.0 // not used

// the frequency, or note, to use, in the future this can be variable
#define sineFrequency 440.0 

@implementation ChrisAudioEngine

- (id)init
{
    self = [super init];
    
    if (self) {
        [self seedSineData];
        [self seedSquareData];
        [self seedTriangleData]; 
        [self seedSawData]; 
        
        [self initializeAUGraph]; 
        isPlaying = false; 
         
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
    AUGraphUninitialize(theGraph); 
    AUGraphClose(theGraph); 
    free(sineData); 
    free(squareData); 
    free(triangleData); 
    free(sawData); 
}


//
// This is the main callback function to provide audio samples
// to the audio pipeline. This callback is called by the 
// mixer, which is in turn called by the output device
//
OSStatus renderInput(void *inRefCon, 
                     AudioUnitRenderActionFlags *ioActionFlags, 
                     const AudioTimeStamp *inTimeStamp, 
                     UInt32 inBusNumber, 
                     UInt32 inNumberFrames, 
                     AudioBufferList *ioData)
{
    // get our custom input structure 
    SoundData *soundData = (SoundData *)inRefCon;
    
    // the point in the wave we are starting at 
    UInt32 phase = soundData->bufs[inBusNumber].startingFrame; 
    
    // the number of samples in our wave
    float wavelengthInSamples = kGraphSampleRate / sineFrequency;
    
    // output buffers 
    AudioUnitSampleType *outA = (AudioUnitSampleType *)ioData->mBuffers[0].mData;
    AudioUnitSampleType *outB = (AudioUnitSampleType *)ioData->mBuffers[1].mData;
    
    // fill the output buffers with wave data 
	for (UInt32 frame = 0; frame < inNumberFrames; frame++) 
	{
        (outA)[frame] = soundData->bufs[inBusNumber].data[phase]; 
        (outB)[frame] = soundData->bufs[inBusNumber].data[phase]; 
        
        // if the phase is greater than the wavelenght, reset
        phase++;
		if (phase > wavelengthInSamples) {
			phase -= wavelengthInSamples; 
        }
    }
    
    
    
    
    /* 
    code for generating a sin wave without a wavetable
     
    float *outA = (float*)ioData->mBuffers[0].mData;
    float *outB = (float*)ioData->mBuffers[1].mData;
     
    // optional: copy to right channel too
    //float *outB = (float*)ioData->mBuffers[1].mData;
    
    //double phaseIncrement = M_PI * sineFrequency / 44100.0;
    double twoPI = 2 * M_PI; 
    float cycleLength = 44100. / sineFrequency;
	UInt32 frame = 0;
	for (frame = 0; frame < inNumberFrames; ++frame) 
	{
        //(outA)[frame] = soundData->bufs[inBusNumber].data[frame]; 
        
        
        float output = (float) sin(twoPI * (phase / wavelengthInSamples)); 
        //printf("the output: %f\n", output); 
        
        (outA)[frame] = output; 
        //printf("the output: %f\n", outA[frame]); 
        
        (outB)[frame] = output; 
    
        phase++;
        if (phase > kGraphSampleRate)
            phase -= kGraphSampleRate;        
	
    }
    */ 
    
    soundData->bufs[inBusNumber].startingFrame = phase; 
	return noErr;
}


// 
// Create one wavelength, store it into an array. 
//
-(void)seedSineData
{
    // intialize memory 
    sineData = (float*)calloc(kGraphSampleRate, sizeof(float)); 
    
    UInt32 phase = 0; 
    
    // how many samples the wavelength will take up 
    float wavelengthInSamples = kGraphSampleRate / sineFrequency;
	
//    double twoPI = 2 * M_PI; 
    
    // wave alternates between 0 to 1 to 0 to -1 in a smooth curve
	for (UInt32 frame = 0; frame < wavelengthInSamples; ++frame) 
	{
        float output = (float) sin(2 * M_PI * phase / wavelengthInSamples); 
        
        sineData[frame] = output; 
        
        
		phase++;
		if (phase > wavelengthInSamples)
			phase -= wavelengthInSamples;        
        
    }
    
}

// 
// Create one wavelength, store it into an array. --__
//
-(void)seedSquareData {
    
    // intialize memory 
    squareData = (float*)calloc(kGraphSampleRate, sizeof(float)); 
    
    int subframe = 0;
    
    // how many samples the wavelength will take up 
    float wavelengthInSamples = kGraphSampleRate / sineFrequency; 
    
    // wave alternates from 1 to -1 for each wavelength
    for (int frame = 0; frame < wavelengthInSamples; frame += wavelengthInSamples ) { 
        
        for (subframe = frame; subframe < wavelengthInSamples / 2; subframe++) {
            squareData[subframe] = 1;      
        }
        
        for (subframe = wavelengthInSamples / 2; subframe < wavelengthInSamples; subframe++) { 
            squareData[subframe] = -1; 
        }
        
    }
}


// 
// Create one wavelength, store it into an array. /\
//
-(void)seedTriangleData {
    
    // initialize memory 
    triangleData = (float*)calloc(kGraphSampleRate, sizeof(float)); 
    
    int subframe = 0;
    
    // how many samples the wavelength will take up 
    float wavelengthInSamples = kGraphSampleRate / sineFrequency; 
    
    // wave rises from -1 to 1, then falls back to -1 for each wavelength
    for (int frame = 0; frame < wavelengthInSamples; frame ++) { 
        
        for (subframe = frame; subframe < wavelengthInSamples / 2; subframe++) {
            triangleData[subframe] = 2 * subframe/(wavelengthInSamples/2) - 1;       
        }
        
        for (subframe = wavelengthInSamples / 2; subframe < wavelengthInSamples; subframe++) { 
            triangleData[subframe] = 1 - (subframe - wavelengthInSamples/2)/(wavelengthInSamples/2); 
        }
        
    }

}


// 
// Create one wavelength, store it into an array. 
//
-(void)seedSawData {
    
    // initialize memory 
    sawData = (float*)calloc(kGraphSampleRate, sizeof(float)); 
    
    int subframe = 0;
    
    // how many samples the wavelength will take up 
    float wavelengthInSamples = kGraphSampleRate / sineFrequency; 
    
    // wave starts at 1, then falls to -1 for each wavelength
    for (int frame = 0; frame < wavelengthInSamples; frame ++) { 
        
        for (subframe = frame; subframe < wavelengthInSamples; subframe++) {
            sawData[subframe] =  1 - (2 * subframe)/(wavelengthInSamples);      
        }
        
    }
}


// 
// Stop the audio process. 
//
- (void)stop
{
	if (!isPlaying) return;
	printf("STOP\n");
	OSStatus err = AUGraphStop(theGraph);
	printf("AUGraphStop %d\n", err);
	isPlaying = false;
}


//
// Start the audio process. 
//
- (void)start 
{
    if (isPlaying) return; 
    printf("START\n"); 
    OSStatus err = AUGraphStart(theGraph); 
    printf("AUGraphStart %d\n", err); 
    isPlaying = true; 
}


//
// Not used. The old way to get the specs of the audio output. 
//
//- (void)getDeviceFormat
//{ 
//    AudioDeviceID device = kAudioDeviceUnknown;
//    OSStatus err = kAudioHardwareNoError;
//    UInt32 deviceBufferSize = 0; 
//    AudioStreamBasicDescription deviceFormat; 
//    
//    
//    // get the default output device for the HAL
//    UInt32 count = sizeof(device);		// it is required to pass the size of the data to be returned
//    err = AudioHardwareGetProperty(kAudioHardwarePropertyDefaultOutputDevice,  &count, (void *) &device);
//    if (err != kAudioHardwareNoError) {
//    	fprintf(stderr, "get kAudioHardwarePropertyDefaultOutputDevice error %ld\n", err);
//        return;
//    }
//    
//    // get the buffersize that the default device uses for IO
//    count = sizeof(deviceBufferSize);	// it is required to pass the size of the data to be returned
//    err = AudioDeviceGetProperty(device, 0, false, kAudioDevicePropertyBufferSize, &count, &deviceBufferSize);
//    if (err != kAudioHardwareNoError) {
//    	fprintf(stderr, "get kAudioDevicePropertyBufferSize error %d\n", err);
//        return;
//    }
//    fprintf(stderr, "deviceBufferSize = %d\n", (unsigned int)deviceBufferSize);
//    
//    // get a description of the data format used by the default device
//    count = sizeof(deviceFormat);	// it is required to pass the size of the data to be returned
//    err = AudioDeviceGetProperty(device, 0, false, kAudioDevicePropertyStreamFormat, &count, &deviceFormat);
//    
//    if (err != kAudioHardwareNoError) {
//    	fprintf(stderr, "get kAudioDevicePropertyStreamFormat error %d\n", err);
//        return;
//    }
//    if (deviceFormat.mFormatID != kAudioFormatLinearPCM) {
//    	fprintf(stderr, "mFormatID !=  kAudioFormatLinearPCM\n");
//        return;
//    }
//    if (!(deviceFormat.mFormatFlags & kLinearPCMFormatFlagIsFloat)) {
//    	fprintf(stderr, "Sorry, currently only works with float format....\n");
//        return;
//    }
//    
//        
//    fprintf(stderr, "mSampleRate = %g\n", deviceFormat.mSampleRate);
//    fprintf(stderr, "mFormatFlags = %08X\n", (unsigned int)deviceFormat.mFormatFlags);
//    fprintf(stderr, "mBytesPerPacket = %d\n", (unsigned int)deviceFormat.mBytesPerPacket);
//    fprintf(stderr, "mFramesPerPacket = %d\n", (unsigned int)deviceFormat.mFramesPerPacket);
//    fprintf(stderr, "mChannelsPerFrame = %d\n", (unsigned int)deviceFormat.mChannelsPerFrame);
//    fprintf(stderr, "mBytesPerFrame = %d\n", (unsigned int)deviceFormat.mBytesPerFrame);
//    fprintf(stderr, "mBitsPerChannel = %d\n", (unsigned int)deviceFormat.mBitsPerChannel);
//    
//}


//
// The audio graph contains all the parts of our audio setup
// as well as connections between each part. We can also specify
// a sound format for each connection and device. 
//
-(void)initializeAUGraph 
{
//    CAStreamBasicDescription desc;
	
    AudioStreamBasicDescription stereoStreamFormat; 
    
    OSStatus result = noErr;
//	UInt32 setting = 1;
    UInt32 numbuses;
	
    UInt32 bytesPerSample = sizeof (AudioSampleType);
    
    // Fill the application audio format struct's fields to define a linear PCM, 
    //        stereo, noninterleaved stream at the hardware sample rate.
    stereoStreamFormat.mFormatID          = kAudioFormatLinearPCM;
    stereoStreamFormat.mFormatFlags       = kAudioFormatFlagsAudioUnitCanonical;
    stereoStreamFormat.mBytesPerPacket    = bytesPerSample;
    stereoStreamFormat.mFramesPerPacket   = 1;
    stereoStreamFormat.mBytesPerFrame     = bytesPerSample;
    stereoStreamFormat.mChannelsPerFrame  = 2;              // 2 indicates stereo
    stereoStreamFormat.mBitsPerChannel    = 8 * bytesPerSample;
    
    stereoStreamFormat.mSampleRate        = kGraphSampleRate;
    
    
    /*
     // generate description that will match out output device (speakers)
     ComponentDescription outputcd = {0};
     outputcd.componentType = kAudioUnitType_Output;
     outputcd.componentSubType = kAudioUnitSubType_DefaultOutput;
     outputcd.componentManufacturer = kAudioUnitManufacturer_Apple;
     
     
     // create an instance of this component with ComponentManager
     // on 10.6+ and iOS, use AudioComponentManager APIs instead
     Component comp = FindNextComponent(NULL, &outputcd);
     if (comp == NULL) {
     printf ("can't get output unit");
     exit (-1);
     }
     
     result = OpenAComponent(comp, &outputUnit); 
     
     //		   "Couldn't open component for outputUnit");
     
     */ 

    // create our graph 
    result = NewAUGraph(&theGraph); 
    if (result) { printf("NewAUGraph result %lu %4.4s\n", (unsigned long)result, (char*)&result); return; }
    
    // output unit description
    AudioComponentDescription output_cd;
	output_cd.componentManufacturer = kAudioUnitManufacturer_Apple;
	output_cd.componentFlags = 0;
	output_cd.componentFlagsMask = 0;
    output_cd.componentType = kAudioUnitType_Output; 
    output_cd.componentSubType = kAudioUnitSubType_DefaultOutput; 
    
    // mixer unit description
    AudioComponentDescription mixer_cd; 
    mixer_cd.componentManufacturer = kAudioUnitManufacturer_Apple;
	mixer_cd.componentFlags = 0;
	mixer_cd.componentFlagsMask = 0;
    mixer_cd.componentType = kAudioUnitType_Mixer; 
    mixer_cd.componentSubType = kAudioUnitSubType_MultiChannelMixer; // kAudioUnitSubType_StereoMixer; // kAudioUnitSubType_MatrixMixer; //
    
    
    // Add the output node 
    result = AUGraphAddNode(theGraph, &output_cd, &outputNode); 
    if (result) { printf("AUGraphAddNode output result %lu %4.4s\n", (unsigned long)result, (char*)&result); return; }

    // Add the mixer node 
    result = AUGraphAddNode(theGraph, &mixer_cd, &multiChannelMixerNode); 
    if (result) { printf("AUGraphAddNode mixer result %lu %4.4s\n", (unsigned long)result, (char*)&result); return; }
    
    
    // Connect the mixer to the output node 
    result = AUGraphConnectNodeInput(theGraph, multiChannelMixerNode, 0, outputNode, 0);
	if (result) { printf("AUGraphConnectNodeInput result %lu %4.4s\n", (unsigned long)result, (char*)&result); return; }
    
    
    // open the graph 
    result = AUGraphOpen(theGraph);
	if (result) { printf("AUGraphOpen result %lu %4.4s\n", (unsigned long)result, (char*)&result); return; }

    
    // Get AudioUnit mixer instance from the node 
    result = AUGraphNodeInfo(theGraph, multiChannelMixerNode, NULL, &mixerUnit); 
    if (result) { printf("AUGraphNodeInfo result %lu %4.4s\n", (unsigned long)result, (char*)&result); return; }
    
    // Get AudioUnit output unit instance from the node 
    result = AUGraphNodeInfo(theGraph, outputNode, NULL, &outputUnit); 
    if (result) { printf("AUGraphNodeInfo output node result %lu %4.4s\n", (unsigned long)result, (char*)&result); return; }
    
    
    // turn metering ON
	//result = AudioUnitSetProperty(mixerUnit, kAudioUnitProperty_MeteringMode, kAudioUnitScope_Global, 0, &setting, sizeof(setting));
	
    
    
    result = AudioUnitSetParameter(mixerUnit, kMultiChannelMixerParam_Volume, kAudioUnitScope_Output, 0, 0.25, 0);
    if (result) { printf("Multi-channel mixer volume output result %lu %4.4s\n", (unsigned long)result, (char*)&result); return; }
    
    
    // set bus counts, i.e. 3 inputs to the mixer
	numbuses = 3;
    printf("set input bus count %d\n", numbuses);
	result = AudioUnitSetProperty(mixerUnit,
                                  kAudioUnitProperty_ElementCount,
                                  kAudioUnitScope_Input,
                                  0,
                                  &numbuses,
                                  sizeof(numbuses) );
	
	numbuses = 1;
    printf("set output bus count %d\n", numbuses);
	result = AudioUnitSetProperty(mixerUnit,
                                  kAudioUnitProperty_ElementCount,
                                  kAudioUnitScope_Output,
                                  0,
                                  &numbuses,
                                  sizeof(numbuses) );
    
    
    /*
    printf(">set output unit input format %d\n", 0);
    result = AudioUnitSetProperty(outputUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Input,
                                  0,
                                  &stereoStreamFormat,
                                  sizeof(stereoStreamFormat) );
    
    
    printf(">>set mixer unit output format %d\n", 0);
    result = AudioUnitSetProperty(	mixerUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Output,
                                  0,
                                  &stereoStreamFormat,
                                  sizeof(stereoStreamFormat) );
    */ 
    
    // loop through the mixer inputs and assign a callback to each
    // the callback will provide wave samples to each input 
    for (int i=0; i < 3; ++i) {
		
        // initialze each channel to a sine wave 
        dataStruct.bufs[i].data = sineData;  // sawData; // triangleData; // squareData; // sineData; 
        
        //for (int j=0; j<44100; j++) { 
        //    printf("output sample: %f", sineData[j]); 
        //}
        
        /*
        result = AudioUnitSetProperty(mixerUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, i, &stereoStreamFormat, sizeof(stereoStreamFormat));
        if (result) { printf("Multi-channel mixer input format result %lu %4.4s\n", (unsigned long)result, (char*)&result); return; } 
        */ 
        
        result = AudioUnitSetParameter(mixerUnit, kMultiChannelMixerParam_Volume, kAudioUnitScope_Input, i, 0.25, 0);
        if (result) { printf("Multi-channel mixer volume input result %lu %4.4s\n", (unsigned long)result, (char*)&result); return; }
        
        
        //OSStatus result = AudioUnitSetParameter(mixerUnit, kMultiChannelMixerParam_Enable, kAudioUnitScope_Input, i, 1, 0);
        //if (result) { printf("AudioUnitSetParameter kMultiChannelMixerParam_Enable result %ld %08X %4.4s\n", (long)result, (unsigned int)result, (char*)&result); return; }
        
        
        // set render callback
		AURenderCallbackStruct rcbs;
        
        memset(&rcbs, 0, sizeof(AURenderCallbackStruct));
        
        
		rcbs.inputProc = &renderInput;
		rcbs.inputProcRefCon = &dataStruct;
        
        /*
        result = AUGraphSetNodeInputCallback(theGraph, multiChannelMixerNode, i, &rcbs); 
        */ 
        
		result = AudioUnitSetProperty(mixerUnit, kAudioUnitProperty_SetRenderCallback,kAudioUnitScope_Input, i, &rcbs, sizeof(rcbs));
         
        
        /*
		// set input stream format
        desc.ChangeNumberChannels(2, false);						
		desc.mSampleRate = kGraphSampleRate;
		
		printf("set input format %d\n", i);
		result = AudioUnitSetProperty(mixerUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, i, &desc, sizeof(desc) );
         */ 
	}
	
    /*
    desc.ChangeNumberChannels(2, false);						
	desc.mSampleRate = kGraphSampleRate;
    */ 
    
    /*
    result = AudioUnitSetProperty(mixerUnit, kAudioUnitProperty_SampleRate, kAudioUnitScope_Output, 0, &kGraphSampleRate, sizeof(kGraphSampleRate));
    
    if (result) { printf("AudioUnit set mixer sample rate result %d %4.4s\n", result, (char*)&result);return; }
    */ 
    
    
    printf("AUGraphInitialize\n");
    
    // NOW that we've set everything up we can initialize the graph 
    // (which will also validate the connections)
	result = AUGraphInitialize(theGraph);
    if (result) { printf(" AUGraphInitialize result %lu %4.4s\n", (unsigned long)result, (char*)&result); return; }
    
    
    // print some info about our graph 
//    printf("sample rate: %f\n", desc.mSampleRate);   
//    printf("bits per channel: %u\n", desc.mBitsPerChannel); 
    CAShow(theGraph);
}


-(void)setMasterVolume:(double)input 
{
    
    printf("setting master volume to %f: ", input); 
    
    AudioUnitSetParameter(mixerUnit, kStereoMixerParam_Volume, kAudioUnitScope_Output, 0, input * .01, 0); //0xFFFFFFFF
    
}


-(void)setMixerChannelVolume:(double)input forChannel:(int)channel 
{ 
    AudioUnitSetParameter(mixerUnit, kStereoMixerParam_Volume, kAudioUnitScope_Input, channel - 1, input * .01, 0);
}


//
// Set the wave type for any given channel
//
-(void)setOSC:(NSString *)input forChannel:(int)channel 
{
    channel -= 1; 
    
    if ([input isEqualToString:@"Sine"]) {
        dataStruct.bufs[channel].data = sineData; 
    } else if ([input isEqualToString:@"Square"]) { 
        dataStruct.bufs[channel].data = squareData;
    } else if ([input isEqualToString:@"Triangle"]) { 
        dataStruct.bufs[channel].data = triangleData;
    } else if ([input isEqualToString:@"Saw"]) { 
        dataStruct.bufs[channel].data = sawData;
    }
    
}

@end
