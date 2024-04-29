---
layout: Blog.PostLayout
title: First Dive into Development for VR
date: 2017-04-11
categories: post
permalink: /:categories/:year/:month/:day/vr-first-steps/
---

## Intro

Having some free time, I was asked to investigate the current state of Virtual Reality (hardware, development kits, etc) and to attempt build a prototype in order to start building our chops.

Going into this, I didn't have any prior experience with VR, 3D modeling, or physics engines and I wasn't sure if I would be able to even get anything to compile, yet I was able to build a small game and deploy it to a VR headset in only a few days. 

## The Platforms

There are a couple of categories: Desktop VR and Mobile VR. 

Examples of desktop VR are the Oculus Rift and the HTC Vive. These devices are headsets that are connected to a PC primarily used to play video games that have been optimized for VR.

Examples of mobile VR are the Samsung Gear VR (which is powered by Oculus) and Google Daydream. Both of which can only run on certain devices.

For our situation, we already had a Gear VR compatible phone (Samsung Galaxy S7), so we went down that path.

## Development

What I learned during this experiment is that building a "VR app" is really just creating something in a game engine, enabling VR support, and then building it for whatever platform. The VR layer of the whole process is rather thin, it's more about keeping VR in mind during development in order to really take advantage of the platform. 

Most of the VR platforms have support for Unity and Unreal Engine, so I chose Unity and followed their basic [tutorial](https://unity3d.com/learn/tutorials/projects/roll-ball-tutorial) (a roll-a-ball game, in which the player moves a ball to collect objects), just to get something up and running. 

Unity has an amazing amount of documentation available, so getting it installed and commencing on the tutorial game was a fairly painless process. I was able to get the tutorial finished in a couple of hours.

![picture](/images/roll-a-ball-screenshot.png)

At this point it was time to get it on the phone and be able to view it in the headset. We hadn't bought the actual Gear VR headset yet, but we were able to find a 3rd party headset somewhere in the office. 

The steps to deploy were pretty simple

1. Install the Android SDK
2. Point Unity to the path of the SDK
3. Create an Oculus .osig and copy it to the appropriate folder in your project
4. Configure the appropriate build settings
5. Hit "Build and Run"

Normally the phone will have a "Insert into headset" message and won't display your app until it's inserted, but after enabling developer mode from within the "Gear VR Service", you are able to start the app and view it with a 3rd party headset. 

The Gear VR headset has a touchpad on it, which allows you to interact with the app while viewing it with the headset. The headset I was using did not have such capabilities and I had yet to create a work around, so at this point you couldn't actually play the game while wearing the headset.

## Retrospective

The key aspects of creating content for the Virtual Reality platform were not what I expected and it feels cool to play around with a game engine. The business opportunities for VR are still being uncovered and it'll be interesting to see how the platform evolves. 
