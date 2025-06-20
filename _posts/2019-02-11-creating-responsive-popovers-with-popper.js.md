---
layout: Blog.PostLayout
title: Creating Responsive Popovers with Popper.js
date: 2019-02-11 09:00:00 EST
categories: post
desc: Guide on making responsive popovers using Popper.js
permalink: /creating-responsive-popovers-with-popper.js/
tags: [javascript, programming, tips]
---

Making _simple_ popovers is pretty easy.

Making popovers that position themselves based on the available screen real estate so they're _always visible_ is not.

Luckily [Popper.js](https://popper.js.org/) will do the math for us and is straight forward to implement given the proper instructions.

## JavaScript

The JavaScript portion is simple. The `Popper` constructor takes a DOM node to attach the popover to and a DOM node that will be the body of the popover.

```javascript
// index.js

const attachmentNode = document.querySelector("#attachment-point");
const popoverNode = document.querySelector("#my-popover");

const myPopper = new Popper(attachmentNode, popoverNode);
```

## HTML and CSS

The HTML and CSS is simple unless you want an arrow tab on your popover.

The docs make it seem like the arrow comes for free, but you'll have to implement it yourself. 

```html
<!-- index.html -->

<button id="attachment-point"> Open Sesame! </button>

<div class="popover" id="my-popover">
  <div x-arrow></div>

  <div>
    <!-- your popover content here -->
  </div>
</div>
```

Popper.js will look for an element with the `x-arrow` attribute to use for the arrow tab.

In order for the arrow to be on the correct side of the popover, we need to style it as described below.

```css
/* styles.css */

[x-arrow] {
  position: absolute;
}

.popover {
  margin-top: 10px;
  margin-bottom: 10px;
}

.popover[x-placement="bottom"] [x-arrow] {
  top: -10px;
  border-bottom: 10px solid white;
  border-right: 10px solid transparent;
  border-left: 10px solid transparent;
}

.popover[x-placement="top"] [x-arrow] {
  bottom: -10px;
  border-top: 10px solid white;
  border-right: 10px solid transparent;
  border-left: 10px solid transparent;
}
```

The `x-placement` attribute added by Popper.js allows you to style the arrow based on the orientation of the popover.

The goofiness you see with the borders is a hack you can use to create a triangle using a `div`. I haven't tried it, but I imagine using an `svg` yields better results.

## Wrapping Up

Popper.js takes care of the hard part so you can focus on building your application.

If you want the popover to show on click or hover, you'll have to add a little more JavaScript and CSS.

Hop into this Code Sandbox and give it a shot.

<iframe src="https://codesandbox.io/embed/501wn1yvk?hidenavigation=1" style="width:100%; height:500px; border:0; border-radius: 4px; overflow:hidden;" sandbox="allow-modals allow-forms allow-popups allow-scripts allow-same-origin"></iframe>
