MySynthBasic
============

A Cocoa OS X app example of setting up an AUGraph in Core Audio, and using a wavetable play a sine wave tone. 

Basically, I wanted to create a synthesizer app, and the first thing I needed to figure out was out to generated a sound wave, then move the bits through the audio pipeline, and output stereo audio. In Core Audio, you can do this with an [Audio Processing Graph] (https://developer.apple.com/library/mac/#documentation/MusicAudio/Conceptual/CoreAudioOverview/CoreAudioEssentials/CoreAudioEssentials.html#//apple_ref/doc/uid/TP40003577-CH10-SW1).

This app seeds three arrays with sine, triangle, and square wave data. It creates three wave generators and mixes their output through the Core Audio "graph," which is kind of like a mixer. It mixes the three waves together and allows you to change the input volume of each wave, as well as the master volume of the combined signal. 

![ScreenShot](https://github.com/chrisl777/MySynthBasic/blob/master/MySynthBasic.png) 
