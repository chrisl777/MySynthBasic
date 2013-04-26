//
//  MySynthBasicAppDelegate.m
//  MySynthBasic
//
//  Created by Chris Livdahl on 7/16/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import "MySynthBasicAppDelegate.h"

@implementation MySynthBasicAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    audioEngine = [[ChrisAudioEngine alloc] init]; 
}

- (IBAction)stop:(id)sender
{
	[audioEngine stop]; 
}

- (IBAction)start:(id)sender
{
	[audioEngine start]; 
}

- (IBAction)setMasterVolume:(id)sender 
{
    [audioEngine setMasterVolume:[sender doubleValue]]; 
}

- (IBAction)setOSCOneVolume:(id)sender 
{
    [audioEngine setMixerChannelVolume:[sender doubleValue] forChannel:1]; 
}

- (IBAction)setOSCTwoVolume:(id)sender
{
    [audioEngine setMixerChannelVolume:[sender doubleValue] forChannel:2]; 
}

- (IBAction)setOSCThreeVolume:(id)sender
{
    [audioEngine setMixerChannelVolume:[sender doubleValue] forChannel:3]; 
}

- (IBAction)setOSCOne:(id)sender 
{
    [audioEngine setOSC:[[sender selectedItem] title] forChannel: 1]; 
}

- (IBAction)setOSCTwo:(id)sender
{
    [audioEngine setOSC:[[sender selectedItem] title] forChannel: 2]; 
}

- (IBAction)setOSCThree:(id)sender
{
    [audioEngine setOSC:[[sender selectedItem] title] forChannel: 3]; 
}
 


@end
