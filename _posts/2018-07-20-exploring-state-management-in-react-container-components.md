---
layout: Blog.PostLayout
title: "Container Components: Exploring State Management in React (Part I)"
date: 2018-07-25 00:00:00 EST
categories: post
desc: This one simple trick will turn your unruly React components into the obedient angels they were meant to be!
permalink: /post/2018/07/25/exploring-state-management-in-react-container-components/
tags: [react, programming, javascript]
---

> At what level of complexity will my React application require Redux?

React developers have been asking this question for a long time, and answers still vary wildly. The truth is there is quite a bit we can do before needing to pull in Redux, and even then, _**Redux**_ isn't our only option! 

Even the creator of Redux, [Dan Abramov](https://twitter.com/dan_abramov?lang=en) thinks that we might not need Redux (although, I think the spirit this statement applies to all 3rd-party libraries meant to help reduce complexity of state).

> [You Might Not Need Redux](https://t.co/3zBPrbhFeL)
>
> &mdash; [Dan Abramov](@dan_abramov) ([September 19, 2016](https://twitter.com/dan_abramov/status/777983404914671616?ref_src=twsrc%5Etfw))

In this series, we'll explore a few different patterns you can introduce to your code base before reaching for a 3rd party solution!

## Container/Presenter Components

This pattern separates what might be a single component into two: a Container component to maintain state and a Presenter component to render visual markup. 

```jsx
const Cart = props => (
  <ul>
    <h2>Cart</h2>
    <input
      type="text"
      onChange={props.onNewItemChange}
      value={props.newItem}
    />
    <button onClick={props.addItem}>Add item</button>

    {props.items.map((item, idx) => (
      <li key={idx}>
        <button onClick={props.removeItem(item)}>Remove</button>
        {item}, &ensp;
        {props.discounts[idx]}% off!
      </li>
    ))}
  </ul>
);

class CartContainer extends React.Component {
  state = {
    newItem: "",
    items: [],
    discounts: []
  };

  componentDidUpdate(prevProps, prevState) {
    if (prevState.items.length !== this.state.items.length) {
      const itemsQuery = this.state.items.join(",");

      ajax(`https://discountdb.com/?items=${itemsQuery}`)
        .then(discounts => this.setState({ discounts }));
    }
  }

  onNewItemChange = event => this.setState({ newItem: event.target.value });

  addItem = () => {
    this.setState(prevState => ({
      items: [...prevState.items, prevState.newItem],
      newItem: ""
    }));
  };

  removeItem = item => () => {
    this.setState(prevState => ({
      items: prevState.items.filter(
        (i, idx, prevItems) => idx !== prevItems.indexOf(item)
      )
    }));
  };

  render() {
    return (
      <div>
        <Cart
          newItem={this.state.newItem}
          onNewItemChange={this.onNewItemChange}
          items={this.state.items}
          discounts={this.state.discounts}
          addItem={this.addItem}
          removeItem={this.removeItem}
        />
      </div>
    );
  }
}
```
[![Edit wo7y9voowk](https://codesandbox.io/static/img/play-codesandbox.svg)](https://codesandbox.io/s/wo7y9voowk)

Here we can see that we have a Container component, `CartContainer`, that handles controlling component state with the `addItem`, `removeItem`, and `onNewItemChange` callbacks, and fetching a list of discounts from an external REST api. This enables us to write `Cart`, our Presenter component, as a Pure Functional component. 

After extracting a Container and a Presenter from one of our bigger components, we might find the Container to still be fairly large, or handling several concerns, potentially signaling that we can break down our Container even further. 

In our case, we might extract a `DiscountContainer` from `CartContainer` to segregate the logic of maintaining the contents of the cart from the logic of fetching the discounts for those items.

The hierarchy of this would look like `CartContainer` -> `DiscountContainer` -> `Cart`, having `CartContainer` pass the discount-less items to the `DiscountContainer`, which will fetch the discounts and then pass the now discounted items to the `Cart`.

## Benefits

Partitioning our components on their state boundary will help reduce complexity by simply having less code to work with at a time, while still staying "inside React".

I think this pattern really starts to pay dividends when we have a lifecycle method, like `componentDidUpdate`, doing a lot of asynchronous work (like making HTTP requests). Given the asynchronous nature, this sort of code tends to be very difficult to test (with both automated unit testing and manual testing), so breaking this stateful logic into separate components helps keeps us sane and our code focused. 

It's helpful to remind ourselves that when unit testing a React component, we are essentially testing the `render` function. Given the inputs (`props`), what is the output? You've probably noticed tests are painful to write if there is a lot of setup, especially if the setup is required for a feature of the component that you aren't even testing.

Keeping our components small and focused will go a long way for keeping ourselves happy and productive!

## Drawbacks

While the Container/Presenter pattern is not always one-for-one (`Cart` <-> `CartContainer`), you will encounter a lot of similarly named components. This can sometimes cause a communication breakdown amongst the team, as you will trip over your own words attempting to say things like "The CartContainer passes the products to the Cart which then passes them to the Checkout component, or is it the CheckoutContainer component?".

If you can think of better names, I would suggest using them! Your code will still be following the pattern even if they don't have the word Container in the name. 😏

## Wrapping Up

My team has utilized this pattern heavily, and I believe it is a solid option to consider before reaching for a tool like Redux.

If you've never heard of this pattern and would like to learn more, Dan Abramov [has also written about this topic](https://medium.com/@dan_abramov/smart-and-dumb-components-7ca2f9a7c7d0).

Now try this in your codebase or introduce the idea to your team during a lunch-and-learn and let me know how it goes!
