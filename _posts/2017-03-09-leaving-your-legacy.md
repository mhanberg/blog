---
layout: post
title: Leaving Your Legacy
date: 2017-03-09
categories: post
permalink: /:categories/:year/:month/:day/:title/
---

## Introduction

At one point or another, we all will work on a legacy project; you're between projects and you get put on an internal effort, you're starting a new project with a client and inherit the old code base, or something or another.

I was fortunate enough to get placed directly on a project when I joined my company, rich with modern coding practices: code review, scrum-style backlog and story mapping, and a team full of seasoned engineers who were all familiar with the code base.

Until it was my turn to say goodbye to the team and hello to new opportunities, and in the meantime, I would concentrate my efforts on one of our internal projects.

This post serves as an outlet for my experience.

**Note**: Team size = me.

<br>

## The Stack

Before starting on this project, I had an interest in exploring a new stack of technology, particularly Ruby web development with the Ruby on Rails framework. I had previously worked heavily in the .NET web stack and wanted to try my hand at something different. 

And then just like that, I'm told I have the opportunity to work on a Rails project in a professional setting, woo! I'm excited.

Working through my first task, naturally, I do some googling. I notice that everything I'm seeing online looks totally different than what I'm seeing in the code base. Eventually, I come to the realization that I'm working on Rails 3.2 and Ruby 1.9, a 5-year-old framework and a 10-year-old language. All I know about Ruby at this point has been deprecated for years (to a degree, the general syntax is similar).

Learning the ins and outs of an old version of a tool just seems backward, especially if you haven't used that tool before. Is upgrading to the latest versions worth it for this project? Not really, but that seems to be part of the problem.

<br>

## Testing

When I first started exploring the code base, I was excited to see how one went about testing in Ruby/Rails, only to find that half of the tests were failing. 

I spent a week ironing out the tests, with test failures ranging from a lack of test fixtures (test fixture file initialized at the top of the test, but nowhere to be found in the repository) to commented out blocks of deprecated code from a past framework upgrade that never got finished.

Testing stops being useful when you can't trust your tests.

This is where the difficulties of working on an internal project start to crop up, you see all these broken windows, but don't have the drive to fix them. You become desensitized to the lower quality of code and the code base suffers for it.

I fixed all the tests, but at this point, I ask myself, are these tests even valuable? What are they testing?

<br>

## Deployment

>Previously there was Jenkins integration with building and deployment using CloudFoundry, but this was not maintained and no longer works. Therefore, all staging and production deployments must be done manually

This was an actual quote from the project's wiki page (until I deleted it). I wasn't surprised by a defunct continuous integration setup, but that the expected deployment process was to *manually copy the files*. 

I did not think that this project needed some fancy system for deployment, but that just seemed wrong. 

I then experimented with just replacing the code on the server with a clone of the repository, and it deploy all it required was a git pull. Not much effort was put into this, but it was simple to implement and simple to use.

<br>

## Decay

This is the general theme, each time a new developer joins the project temporarily they will leave behind something corrosive, slowly decaying the project. Even experienced engineers can write some bad code if the circumstances are begging for it. 

Out of date comments are left to rot, wikis are stale and inaccurate, and tests break and remain broken. Now this happens over time, and I'm not sure if you'd be able to recognize it happening in real time. 

In order to stop (or at least slow down) the decay is to maintain verbose documentation. Commit messages need to be wordy and the wiki (if you have one) needs to be awfully explicit. Now I don't think it needs to be written for someone who isn't a developer, but it at least should be written for someone who has no experience in any of the project stack. 

Example of a commit message that is not helpful

~~~
fixed brokn thing .
~~~

Example of a commit message that is helpful

~~~
Fixed broken pagination after filtering list
 * Code was attempting to filter during pagination, now 
   the list filters completely and then paginates the filtered list
 * Updated the gem used for pagination from v0.5.1 to v1.0.1
~~~

I even think a project journal would be beneficial. After each task is finished, the developer will log everything that went into the task, including reasoning, failed attempts and possibly even short explanation of how a certain library was utilized. Anything that isn't written down is essentially lost for eternity, so any epiphanies you had are useless if you don't write them down for the next developer down the line.

<br>

## Conclusion

Working with legacy code is inevitable, but with a little TLC, you can make it less painful for those who will work with it after you. 

A couple takeaways from this experience are

* Always leave the project (or code, documentation, etc) in a better condition than when you joined. Take the bit of extra time to jot down broken windows you see or valuable (yet not expensive) improvements you can make, to either fix after your task or during.

* Find yourself a healthy level of criticality, don't assume all the code is crap, but don't assume that it's all great code.

* Ask questions. If you have to track down someone who worked on the project 4 years ago, do it. You're not going to find their rationale for a design decision on Stack Overflow.