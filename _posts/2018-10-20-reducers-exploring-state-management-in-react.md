---
layout: post
title: Reducers&#58; Exploring State Management in React (Part 2)
date: 2018-10-20 09:00:00 -04:00
categories: post
desc: Let's explore how to extract React state transformations to better isolate and understand the way our component state changes.
permalink: /:categories/:year/:month/:day/:title/
---

In a previous [post](https://www.mitchellhanberg.com/post/2018/07/25/exploring-state-management-in-react-container-components/), we demonstrated how the Container/Presenter pattern is a solid approach to managing your React state. This time we are going to look into using Reducer functions as the method to managing change in state of your components.

## Reduce

Reduce (also known as a [fold](https://en.wikipedia.org/wiki/Fold_%28higher-order_function%29)) is a functional programming concept that deals with the transformation of data structures using recursion and higher order functions. If you have used either the `Array.prototype.reduce` or `Array.prototype.map` functions, you already have experience with this technique.

## The Approach

The general approach is to have a `reduce` (can be named whatever you'd like) function that understands how to respond to certain messages and will output the transformed state. We'll normally call this `reduce` function from a `dispatch` function.

Let's examine the code snippet below.

```jsx
function reduce(prevState, { type, payload }) {
  switch (type) {
    case "ADD":
      return {
        items: [...prevState.items, prevState.newItem],
        newItem: ""
      };
    case "REMOVE":
      return {
        items: prevState.items.filter(
          (i, idx, prevItems) => idx !== prevItems.indexOf(payload)
        )
      };
    case "CHANGE":
      return { newItem: payload };
    case "DISCOUNTS":
      return { discounts: payload };
    case "INITIAL":
      return {
        newItem: "",
        items: [],
        discounts: []
      };
    default:
      throw new Error("Unknown message type received");
  }
}

class Cart extends React.Component {
  state = reduce(undefined, { type: "INITIAL" });

  componentDidUpdate(prevProps, prevState) {
    if (prevState.items.length !== this.state.items.length) {
      const itemsQuery = this.state.items.join(",");

      ajax(`https://discountdb.com/?items=${itemsQuery}`)
        .then(discounts => 
          this.dispatch({ type: "DISCOUNTS", payload: discounts }));
    }
  }

  dispatch = action => 
    this.setState(prevState => reduce(prevState, action));

  onNewItemChange = event =>
    this.dispatch({ type: "CHANGE", payload: event.target.value });

  addItem = () => this.dispatch({ type: "ADD" });

  removeItem = item => 
    () => this.dispatch({ type: "REMOVE", payload: item });

  render() {
    return (
      <ul>
        <h2>Cart</h2>
        <input
          type="text"
          onChange={this.onNewItemChange}
          value={this.state.newItem}
        />
        <button onClick={this.addItem}>Add item</button>

        {this.state.items.map((item, idx) => (
          <li key={idx}>
            <button onClick={this.removeItem(item)}>Remove</button>
            {item}, &ensp;
            {this.state.discounts[idx]}% off!
          </li>
        ))}
      </ul>
    );
  }
}
```

[![Edit zrww3wp57m](https://codesandbox.io/static/img/play-codesandbox.svg)](https://codesandbox.io/s/zrww3wp57m)

Here our `reduce` function resolves to a switch statement which delegates according to certain messages. We call this function in two places; we call it directly to initialize our component state and we call it in our `dispatch` function to allow our event handlers to dynamically pass messages.

Unlike the function you pass to `Array.prototype.reduce`, our reduce only returns the changes to state and not the entire new state. This is because we only pass changes to `this.setState`.

_Notice that the only place we call `this.setState` directly is in the `dispatch` function._

## Benefits

What we have done is extract and enumerate the various transformations that can happen to our component state.

Isolating our state transformations this way can be beneficial when it comes to unit testing; our reducer is just plain JavaScript (no React). We fully extracted all state transformations into the reducer, but you are free to only pull out the ones that can benefit from the indirection.

This also allows you to get a taste for how Redux might feel in your codebase without having to add it to your project just yet.

## Drawbacks

This increases indirection and adds boilerplate to your code, which can have negative consequences if not implemented for the right reasons.

If you ever think to yourself (like how I felt writing the above contrived example), "Why am I even doing this?" your component might not be complex enough to warrant this.

## Wrapping Up

This isn't an original concept; [Dan Abramov]() has discussed this before and his [article](https://medium.com/@dan_abramov/you-might-not-need-redux-be46360cf367) is also worth reading. This post is mostly an exercise in exploring different ways to organize and transform React component state. 

Next time you are working with a React component, try to think of new ways you can work with state and let me know what you come up with on Twitter: [@mitchhanberg](https://twitter.com/mitchhanberg).
