//
//  MySynthBasicAppDelegate.h
//  MySynthBasic
//
//  Created by Chris Livdahl on 7/16/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ChrisAudioEngine.h"

@interface MySynthBasicAppDelegate : NSObject <NSApplicationDelegate> {

    NSWindow *window;
    ChrisAudioEngine *audioEngine; 
    
    IBOutlet NSPopUpButton *OSCOne; 
    IBOutlet NSPopUpButton *OSCTwo; 
    IBOutlet NSPopUpButton *OSCThree; 
}

@property (assign) IBOutlet NSWindow *window;

- (IBAction)stop:(id)sender; 
- (IBAction)start:(id)sender; 
- (IBAction)setMasterVolume:(id)sender;
- (IBAction)setOSCOneVolume:(id)sender; 
- (IBAction)setOSCTwoVolume:(id)sender; 
- (IBAction)setOSCThreeVolume:(id)sender; 

- (IBAction)setOSCOne:(id)sender; 
- (IBAction)setOSCTwo:(id)sender; 
- (IBAction)setOSCThree:(id)sender; 

@end
