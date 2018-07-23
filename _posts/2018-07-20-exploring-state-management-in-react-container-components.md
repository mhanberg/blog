---
layout: post
title: Exploring State Management in React&#58; Container Components
date: 2018-07-20 09:00:00 -04:00
categories: post
desc: An amazing blog post, truly one of the best! PS CHANGEME
permalink: /:categories/:year/:month/:day/:title/
---

>When should we install Redux?

This question is often asked, and answers still vary wildly. The truth is there is quite a bit you can do before needing to pull in Redux, and even then Redux isn't your only option! 

Even the creator of Redux, [Dan Abramov](https://twitter.com/dan_abramov?lang=en) thinks that you might not need Redux (although, I think the spirit this statement applies to all 3rd-party libraries meant to help reduce complexity of state).

<blockquote class="twitter-tweet" data-lang="en"><p lang="en" dir="ltr">You Might Not Need Redux <a href="https://t.co/3zBPrbhFeL">https://t.co/3zBPrbhFeL</a></p>&mdash; Dan Abramov (@dan_abramov) <a href="https://twitter.com/dan_abramov/status/777983404914671616?ref_src=twsrc%5Etfw">September 19, 2016</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

<br>

Let's explore a few different patterns you can introduce to your code base before reaching for a 3rd party solution!

## Container/Presenter Components

This pattern separates what might be a single component into two (or three or four), a Container component(s) to maintain state and a Presenter component to render visual markup. 

```jsx
class Cart extends React.Component {
  state = {
    newItem: ""
  };

  handleAddItemClick = () => {
    this.props.addItem(this.state.newItem);

    this.setState({ newItem: "" });
  };

  render() {
    return (
      <ul>
        <h2>Cart</h2>
        <input
          type="text"
          onChange={({target:{value: newItem}}) => 
            this.setState({newItem})}
          value={this.state.newItem}
        />
        <button onClick={this.handleAddItemClick}>
          Add item
        </button>

        {this.props.items.map((item, idx) => (
          <li key={idx}>
            <button onClick={this.props.removeItem(item)}>
              Remove
            </button>
            {item}, &ensp;
            {this.props.discounts[idx]}% off!
          </li>
        ))}
      </ul>
    );
  }
}

class CartContainer extends React.Component {
  state = {
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

  addItem = item => {
    this.setState(prevState => ({
      items: [...prevState.items, item]
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
&nbsp;

## Benefits

Partitioning your components on the state boundary layer will help reduce complexity by simply having less code to work with at a time, while still staying "inside React".

I really think this pattern starts to pay dividends when you have a lifecycle method, like `componentDidUpdate`, doing a lot of asynchronous work (like making HTTP requests). Given the asynchronous nature, this sort of code tends to be very difficult to test (with both automated unit test and manual testing), so breaking this stateful logic into separate components helps keeps you sane and your code focused. 

It's helpful to remind yourself that when unit testing a React component, you are essentially testing the `render` function. Given the inputs (`props`), what is the output? You've probably noticed tests are painful to write if there is a lot of setup, especially if the setup is required for a feature of the component that you aren't even testing.

Keeping your components small and focused will go a long way for keeping yourself happy and productive!

Play with the code by following the link below!

[![Edit wo7y9voowk](https://codesandbox.io/static/img/play-codesandbox.svg)](https://codesandbox.io/s/wo7y9voowk)

