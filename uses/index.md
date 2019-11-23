---
layout: uses
title: Uses
---

# Uses

No one ever asks me what font or syntax theme I use, but the [first rule](https://i.imgur.com/IOHSP6M.png) of being a power user is telling everyone about it.

## Development

#### [Vim](https://www.vim.org) / [NeoVim](https://neovim.io)

I started using Vim full time since the beginning of 2018 and I can't imagine my life without it. Vim is a gateway drug to the life of optimizing for productivity (even if it costs you some productivity up front!).

I typically use MacVim as I like to be able to command-tab between my editor, browser, and terminal. When I do use the TUI, I use NeoVim as it seems to have better performance when used in the Mac/Tmux combination.

##### Why?

The primary reason why I love Vim is the keyboard focused design. It keeps my hands and arms in relatively the same position as I work, as I rarely need to reach for the mouse. It's not that the mouse is a bad input device, but the travel distance between the mouse and home row on your keyboard starts to become a problem the faster you work. You can cut down on this by getting a [tenkeyless](https://keyboardwhiz.com/tenkeyless/) or [60%](https://keyboardwhiz.com/60-percent/), but it can't beat not moving your hands at all!


##### Plugins

I use [vim-plug](https://github.com/junegunn/vim-plug) to manage my plugins; you can see all of the plugins I in my [dotfiles](https://github.com/mhanberg/.dotfiles/blob/master/vimrc#L41).

#### [Night Owl theme](https://github.com/sdras/night-owl-vscode-theme)

I recently switched over to using this great theme from [Sarah Drasner](https://sarahdrasnerdesign.com/). Since its a _very_ popular theme, it has been ported to many different tools, so I also it for my iTerm2 and Alfred themes, and I even implemented it for [lightline.vim](https://github.com/haishanh/night-owl.vim/pull/24)!

Sarah wrote a comprehensive [CSS Tricks](https://css-tricks.com/creating-a-vs-code-theme/) article on how she made the theme.

#### [Hack](https://sourcefoundry.org/hack/)

Hack is a free coding font designed for legibility.

#### [iTerm2](https://iterm2.com/)

I originally switched to iTerm from Terminal.app for the ability to create vertical _and_ horizontal splits, but since I started using tmux, that hasn't really been an issue.

#### [Postico](https://eggerapps.at/postico/)

Postico is a minimal Postgres GUI client and is an example of an amazing macOS application, amazing performance and has just the functionality that I need.

#### [Firefox](https://www.mozilla.org/en-US/firefox/new/?redirect_source=firefox-com)

I am giving Firefox another try, and so far I am liking it! I am a fan of the [Facebook](https://www.mozilla.org/en-US/firefox/facebookcontainer/) and [Google](https://addons.mozilla.org/en-US/firefox/addon/google-container/) container extensions.

There are a few features that I am still missing from Chrome, but I've been able to get by without them.

#### [Sublime Merge](https://www.sublimemerge.com/)

This is the best Git GUI application that I have ever used. 

The features that I enjoy the most is the three way merge, staging/unstaging individual lines of code, and the ability to search just about anything in the repository.

#### [Dash](https://kapeli.com/dash)

Dash is an offline documentation repository with full text search. Combined with the Alfred Dash workflow, this is a must have application for anyone writing software on a Mac.

#### [Sketch](https://www.sketch.com/)

I don't do a whole lot of designing, but when I do I like doing it in Sketch. 

#### [Figma](https://www.figma.com/)

I sometimes use Figma for design in addition to Sketch, but I end up using it as a cloud-enabled MS Paint.

## CLI

#### [zsh](https://www.zsh.org/)

zsh is pretty much an improved version of Bash. It is worth using because of the community that has been built up around it (see [ohmyzsh](https://github.com/ohmyzsh/ohmyzsh)) and the number of plugins available.

It's even the default shell on macOS now!

#### [zplug](https://github.com/zplug/zplug)

zplug is a plugin manager for zsh that is inspired by vim-plug. I recently switched from ohmyzsh to zplug to get a better handle on my configuration and make it easier to install plugins.

#### [tmux](https://github.com/tmux/tmux#welcome-to-tmux)

tmux is primarily what I use to manage terminal splits and windows. It follows the Vim philosophy of keyboard shortcuts and extensibility, so they make a fine pair.

#### [asdf](https://github.com/asdf-vm/asdf)

Once I started programming in Elixir, I needed to be manage two languages at once (the other being Erlang) and asdf makes that super simple. It is based on a plugin architecture, so there is a plugin for just about every language you can think of.

I contributed to the [Io plugin](https://github.com/mracos/asdf-io/pull/5) when I was reading [Seven Languages in Seven Weeks](https://amzn.to/37lmG5E) by Bruce Tate.

#### [fzf](https://github.com/junegunn/fzf)

fzf is a versatile tool that allows you to pipe in arbitrary text to form fuzzy pattern searching.

#### [hub](https://github.com/github/hub)

I use hub to easily create GitHub pull requests from the terminal. When you run `hub pull-request`, it will open up a window in your `$EDITOR` (Vim for me) and allow you to craft your title and description for the new PR for the current branch.

#### [ag](https://github.com/ggreer/the_silver_searcher)

This is a blazingly fast grep replacement. I use it for searching in the terminal and as my `grepprg` in vim.

## Productivity

#### [Alfred](https://www.alfredapp.com/)

Alfred is a workhorse of a tool. It's amazing for launching apps, searching your computer, managing your pasteboard, and snippets. It becomes really powerful when you start using workflows as it enables Alfred to integrate with other apps and run arbitrary scripts in any language.

It's definitely my #1 productivity tool for macOS.

#### [1Password](https://1password.com/)

1Password is some of the best money I've ever spent on software.

#### [Things 3](https://culturedcode.com/things/)

I like Things for personal projects, but I don't actually use it that much in my daily life because my work projects already have a form of project management software.

#### [Fastmail](https://ref.fm/u20036168)

I started using Fastmail as a cheap way to use my domain as my email address, then I learned of some of the powerful aliasing features which I now love.

#### [Mail.app](https://support.apple.com/mail)

I just use the built in Mail app on macOS and iOS. I don't send that much email so I haven't needed anything more powerful.

#### [Calendar.app](https://support.apple.com/guide/calendar/welcome/mac)

The stock Calendar app is good enough for me. I am able to load my shared Google calendars and my work Exchange account all into the same app.

#### [Itsycal](https://www.mowglii.com/itsycal/)

This is a neat little menubar app that works really well for seeing what upcoming events you have over the next few days.

#### [Dropbox](https://db.tt/Y20mNcDT98)

Dropbox is another service I've been using for years.

I originally used it as a way of syncing source code files between my computer and a tiny (I mean like the screen wouldn't expand larger than 400x300px) Linux VM that I had to use for a course in college.

#### [Licecap](https://www.cockos.com/licecap/)

Licecap is a handy tool for taking quick video gifs of your screen. It looks arcane but it works.

I use it a lot for sharing new designs and how to reproduce bugs in pull requests.

## Hardware

#### [2013 13" MacBook Pro](https://support.apple.com/kb/SP691?locale=en_US)

This was my first Apple computer and I am never going back. It's starting to reach the end of it's life, but I'm holding out for a MacBook Air with the new Magic keyboard (or a windfall of cash 😏).

#### [2018 15" MacBook Pro](https://support.apple.com/kb/SP776?locale=en_US)

This is the computer I use at work. It is pretty much plugged into a Thunderbolt 3 docking station 24/7.

#### [Ergodoz EZ](https://ergodox-ez.com/)

This is the best keyboard ever made.

It's a split ortholinear keyboard that is incredibly extensible, you can find my config [here](https://configure.ergodox-ez.com/ergodox-ez/layouts/GGYnj/latest/0).

I use this one at work.

#### [OLKB Preonic](https://drop.com/buy/preonic-mechanical-keyboard)

This is second favorite keyboard. Just as extensible as the Ergodox, but in a tight form factor that is easy to carry.

You can find my config [here](https://github.com/mhanberg/.dotfiles/blob/master/mitch-preonic.json).

I use this one at home/travel.

#### [Logitech M570 Trackball Mouse](https://amzn.to/2D94AGn)

This is a solid trackball mouse. I originally got one when I had a crappy standing desk converter that gave me no room to be able to move the mouse. The nice thing about a trackball is the mouse always stays right next to the keyboard.

#### [LG 27UD68-W](https://amzn.to/3389fCI)

Solid 4K monitor I got on Prime Day. I only wish I had known that my 2013 MacBook isn't capable for driving a 60hz 4K display... so I use it at a fuzzy 1080p. I may get a lower resolution 1440p monitor instead on Black Friday.


#### [Philips Hue Bulbs](https://amzn.to/37mgzy2)

I have these throughout my home. They're really nice in my office as it allows me to dim and change the warmth of the light to be easier on the eyes in the dark.


#### [IKEA BEKANT sit/stand desk](https://www.ikea.com/us/en/p/bekant-corner-desk-right-sit-stand-black-stained-ash-veneer-black-s79282389/)

I use this desk at work and I really like it. I tend to stand in the mornings and the towards the end of the day, and sit right after lunch and during our midday calls with the client.
