---
layout: post
title: "The Comprehensive Guide to Elixir's List Comprehension"
date: 2022-04-15 01:00:00 -04:00
categories: post
permalink: /:title/
toc: true

---

## Table of Contents
{:.no_toc}

* toc
{:toc}

## What is it?

The `for` special form, also known as a list comprehension, is a construct designed for concise and powerful enumerable transformation in Elixir.

It looks very similar to a "for loop" in other languages like JavaScript and C, but rather than being a language construct, it is an expression (like everything else in Elixir). This means that it evaluates to a value that can be bound to a variable. You may have heard this before as "statement vs expression".

```elixir
last_names = 
  for friend <- friends do
    friend.last_name
  end
```

Before reading this rest of this article, I suggest you read the list comprehension guide on [elixir-lang.org](https://elixir-lang.org/getting-started/comprehensions.html). I will go over some of the same details, but hopefully will go much more in depth.

## Generators

The primary ingredient in a comprehension is the generator. The only other place you will see this "left arrow" syntax (`lhs <- rhs`) is in the `with` special form.

The right hand side is the enumerable you want to loop over and the left hand side is the intermediate pattern you want to match on during each iteration. This is a normal pattern, so you can pattern match like you would anywhere else.

```elixir
friends = [
  %{first_name: "Joe", last_name: "Swanson"},
  %{first_name: "Greg", last_name: "Mefford"},
  %{first_name: "Erik", last_name: "Plostins"},
]

for %{last_name: last_name} <- friends do
  last_name
end

# ["Swanson", "Mefford", "Plostins"]
```

### Multiple Generators

Comprehensions are very concise in that you can declare multiple generators, allowing you to generate every permutation of both enumerables. A great example is generating a list of coordinate pairs from a range of `x` values and `y` values.

A key detail to recognize is that the both values are yielded to the same block, so the result is a flat list.

```elixir
for x <- 0..99, y <- 0..99 do
  {x, y}
end

# [{0, 0}, {0, 1}, {0, 2}, ...]
```

The counter example using [`Enum.map/2`](https://hexdocs.pm/elixir/Enum.html#map/2) is not nearly as readable and demonstrates that you need to remember to flatten the outer loop, or else you'll get a list of lists.

```elixir
Enum.flat_map(0..99, fn x ->
  Enum.map(0..99, fn y ->
    {x, y}
  end)
end)

# [{0, 0}, {0, 1}, {0, 2}, ...]
```

### Generators work with maps too

The comprehension works with anything that implements the `Enumerable` protocol, so you can iterate through a map as well. The generator will yield each key/value pair of the given map.

```elixir
dictionary = %{
  "low-latency" => "short delay before a transfer of data begins following an instruction for its transfer",
  "distributed" => "(of a computer system) spread over several machines, especially over a network",
  "fault-tolerant" => "relating to or being a computer or program with a self-contained backup system that allows continued operation when major components fail"
}

for {word, definition} <- dictionary do
  IO.puts "#{word}: #{definition}"
end
```

As seen above, we can iterate through a `Range` as well.

```elixir
for x <- 0..99, y <- 0..99 do
  {x, y}
end

# [{0, 0}, {0, 1}, {0, 2}, ...]
```

### Bitstring generators

The generators we've seen so far have been "list generators". The other type of generator is the "bitstring generator". The bitstring generator allows you to easily loop over a bitstring while correctly parsing bytes.

This is often very useful when parsing binary protocols like database protocols. Below is an example that demonstrates that each iteration of the comprehension reads the message length and then uses it to know how much more of the bitstring to read next. While the previous examples could be translated into various form of `Enum.map/2`, this example can only be achieved with normal recursion.

```elixir
bitstring = <<1, "I", 6, "really", 4, "love", 4, "list", 14, "comprehensions", 1, "!">>

# <<1, 73, 6, 114, 101, 97, 108, 108, 121, 4, 108, 111, 118, 101, 4, 108, 105,
#  115, 116, 14, 99, 111, 109, 112, 114, 101, 104, 101, 110, 115, 105, 111, 110,
#  115, 1, 33>>

for <<message_length::integer, message::binary-size(message_length) <- bitstring>> do
 message
end

# ["I", "really", "love", "list", "comprehensions", "!"]
```

The example using recursion looks like:

```elixir
defmodule For do
  def loop(""), do: []

  def loop(<<message_length::integer, message::binary-size(message_length), rest::binary>>) do
    [message | loop(rest)]
  end
end

bitstring = <<1, "I", 6, "really", 4, "love", 4, "list", 14, "comprehensions", 1, "!">>

For.loop(bitstring)

# ["I", "really", "love", "list", "comprehensions", "!"]
```

### Chaining generators

List comprehensions allow you to chain generators together by using the `lhs` value from a generator in the `rhs` of a subsequent generator.

Here's an example that demonstrates getting a list of all of your friends hobbies:

```elixir
friends = [
  %{name: "Derek", hobbies: ["Movies", "Hot Sauce"]},
  %{name: "Joe", hobbies: ["Yu-Gi-Oh!", "Tattoos"]},
  %{name: "Andres", hobbies: ["Photoshop", "Oreos", "Cereal"]},
]

for %{hobbies: hobbies} <- friends, hobby <- hobbies do
  hobby
end

# ["Movies", "Hot Sauce", "YuGiOh", "Tattoos", "Photoshop", "Oreos", "Cereal"]
```

### Generators filter non-matching lhs values

If the match expression in the `lhs` of a generator does not match on the value yielded from the `rhs`, it will be rejected and the list comprehension will move on to the next element in the enumerable.

This is slightly surprising behavior at first and should be kept in mind when using list comprehensions. The following example might lead to a bug in your program.

```elixir
friends = [
    %{"name" => "Derek"},
    %{name: "Joe"}
  ]

for %{name: name} <- friends do
  name
end

# ["Joe"]
```

If you were to have written this program using `Enum.map/2`, you would have ran into a function clause error.

```elixir
friends = [
    %{"name" => "Derek"},
    %{name: "Joe"}
  ]

Enum.map(friends, fn %{name: name} ->
  name
end)

# ** (FunctionClauseError) no function clause matching in :erl_eval."-inside-an-interpreted-fun-"/1
# 
#    The following arguments were given to :erl_eval."-inside-an-interpreted-fun-"/1:
# 
#        # 1
#        %{"name" => "Derek"}
# 
#    (stdlib 3.17.1) :erl_eval."-inside-an-interpreted-fun-"/1
#    (stdlib 3.17.1) erl_eval.erl:834: :erl_eval.eval_fun/6
#    (elixir 1.13.3) lib/enum.ex:1593: Enum."-map/2-lists^map/1-0-"/2
```

This behaviour can be useful! If you only wanted to iterate over configuration options that are enabled, you could write something like this:

```elixir
configs = [
  %{name: :feature_a, enabled: true},
  %{name: :feature_b, enabled: false},
  %{name: :feature_c, enabled: true}
]

for %{enabled: true} = config <- configs do
  config
end

# [%{name: :feature_a, enabled: true}, %{name: :feature_c, enabled: true}]
```

## Filters

Now that we've talked about _generator filtering_, let's talk about _Filters_.

So for we have seen one type of "argument" that can be passed to the comprehension, the generator. Another "argument" is the filter! Let's look at a quick example.

In this example, we iterate over a list of employees, filter based on the employees status, and return a list of the employee's names

```elixir
employees = [
  %{name: "Eric", status: :active},
  %{name: "Mitch", status: :former},
  %{name: "Greg", status: :active}
]

for employee <- employees, employee.status == :active do
  employee.name
end

# ["Eric", "Greg"]
```

As with generators, filters can use values bound in a previous step of the comprehension. And like generators, you can use multiple filters as well. You can even mix and match them!

```elixir
employees = [
  %{
    name: "Eric",
    status: :active,
    hobbies: [%{name: "Text Adventures", type: :gaming}, %{name: "Chickens", type: :animals}]
  },
  %{
    name: "Mitch",
    status: :former,
    hobbies: [%{name: "Woodworking", type: :making}, %{name: "Homebrewing", type: :making}]
  },
  %{
    name: "Greg",
    status: :active,
    hobbies: [
      %{name: "Dungeons & Dragons", type: :gaming},
      %{name: "Woodworking", type: :making}
    ]
  }
]

for employee <- employees,
    employee.status == :active,
    hobby <- employee.hobbies,
    hobby.type == :gaming do
  {employee.name, hobby}
end

# [
#   {"Eric", %{name: "Text Adventures", type: :gaming}},
#   {"Greg", %{name: "Dungeons & Dragons", type: :gaming}}
# ]

```

At this point we can recognize that the list comprehension has the characteristics of a function with [variadic arguments](https://en.wikipedia.org/wiki/Variadic_function). If we were to write our own `for` using plain functions, we'd have to pass it a list of callbacks to evaluate and a final callback to do the mapping. While we aren't necessarily concerned with how we'd implement `for` as a plain function, it's important to recognize aspects that are "different" from "normal" constructs in the language.

One of the great things about the list comprehension is that it allows you to operate on `Enumerable` data structures in fewer passes (usually 1) than when using the `Enum` module.

We can write our previous example using functions like so:

```elixir
employees = [
  %{name: "Eric", status: :active},
  %{name: "Mitch", status: :former},
  %{name: "Greg", status: :active}
]

employees
|> Enum.filter(fn employee -> employee.status == :active end)
|> Enum.map(fn employee -> employee.name end)

# ["Eric", "Greg"]

employees
|> Enum.reduce([], fn employee, acc -> 
  if employee.status == :active do
    [employee.name | acc]
  else
    acc
  end
end)
|> Enum.reverse()

# ["Eric", "Greg"]

:lists.filtermap(
  fn employee ->
    if employee.status == :active do
      {true, employee.name}
    else
      false
    end
  end,
  employees
)

# ["Eric", "Greg"]
```

You can see benchmarks of all of these styles of "filter map" [here](https://github.com/mhanberg/notebooks/blob/c0c0c710fd5ca7a6f36d5acdca9043911d49044d/notebooks/list_benchmarks.livemd).

## Options

Now that we've covered the basic principles of the list comprehension, we can explore the various options that can be passed to augment it's behavior. The default behavior is to act more or less like `Enum.map/2` with regard to the return type.

As of this writing, there are three options available: `:uniq`, `:into`, and `:reduce`

### :uniq

`:uniq` is the least interesting of the available options, but still quite powerful.

It simply ensures that the return result will only contain unique values.

```elixir
employees = [
  %{
    name: "Eric",
    status: :active,
    hobbies: [%{name: "Text Adventures", type: :gaming}, %{name: "Chickens", type: :animals}]
  },
  %{
    name: "Mitch",
    status: :former,
    hobbies: [%{name: "Woodworking", type: :making}, %{name: "Homebrewing", type: :making}]
  },
  %{
    name: "Greg",
    status: :active,
    hobbies: [
      %{name: "Dungeons & Dragons", type: :gaming},
      %{name: "Woodworking", type: :making}
    ]
  }
]

for employee <- employees, hobby <- employee.hobbies, uniq: true do
  hobby.name
end

# ["Text Adventures", "Chickens", "Woodworking", "Homebrewing", "Dungeons & Dragons"]
```

You can see benchmarks of all of these styles of "map uniq" [here](https://github.com/mhanberg/notebooks/blob/ae5362fded45465e22e74b9d310715e7852502d8/notebooks/list_benchmarks.livemd#results-mapuniq).

### :into

`:into` is where things start to get interesting.

The default behavior for a list comprehension behaves more or less like a "map" operation, meaning that the expression evaluates to a list.

The `:into` option allows you to instead push the value returned by each iteration into a _collectable_. A data structure is collectable if it implements the [Collectable](https://hexdocs.pm/elixir/Collectable.html) protocol.

If you aren't familiar with protocols, you have already been using them! The `Enum` module is a set of functions that operate on data structures that implement the [Enumerable](https://hexdocs.pm/elixir/Enumerable.html) protocol. The builtin data structures that implement the `Enumerable` protocol are the `List`, `Range`, and `Map` types.

The builtin data structures that implement the `Collectable` protocol are `List`, `Map`, and `BitString`. The `Enum` function that you would use to take advantage of this protocol is [Enum.into/2](https://hexdocs.pm/elixir/Enum.html#into/3).

Let's take a look at some examples.

#### List

Using a list as the `:into` actually doesn't change the behavior at all!


```elixir
employees = [
  %{
    name: "Eric",
    status: :active,
    hobbies: [%{name: "Text Adventures", type: :gaming}, %{name: "Chickens", type: :animals}]
  },
  %{
    name: "Mitch",
    status: :former,
    hobbies: [%{name: "Woodworking", type: :making}, %{name: "Homebrewing", type: :making}]
  },
  %{
    name: "Greg",
    status: :active,
    hobbies: [
      %{name: "Dungeons & Dragons", type: :gaming},
      %{name: "Woodworking", type: :making}
    ]
  }
]

for employee <- employees,
    employee.status == :active,
    hobby <- employee.hobbies,
    hobby.type == :gaming,
    into: [] do
  {employee.name, hobby}
end

# [
#   {"Eric", %{name: "Text Adventures", type: :gaming}},
#   {"Greg", %{name: "Dungeons & Dragons", type: :gaming}}
# ]
```

#### Map

But if we use a map, we can see that it pushes each key/value pair into the map that you pass for the option. Usually I use this with an empty map (`%{}` or `Map.new()`), but let's look at an example using a non-empty map.

```elixir
employees = [
  %{
    name: "Eric",
    status: :active,
    hobbies: [%{name: "Text Adventures", type: :gaming}, %{name: "Chickens", type: :animals}]
  },
  %{
    name: "Mitch",
    status: :former,
    hobbies: [%{name: "Woodworking", type: :making}, %{name: "Homebrewing", type: :making}]
  },
  %{
    name: "Greg",
    status: :active,
    hobbies: [
      %{name: "Dungeons & Dragons", type: :gaming},
      %{name: "Woodworking", type: :making}
    ]
  }
]

base_map = %{
  "Mitch" => %{
    name: "Reading",
    type: :learning
  },
  "Greg" => %{
    name: "Traveling",
    type: :expensive
  }
}

for employee <- employees,
    employee.status == :active,
    hobby <- employee.hobbies,
    hobby.type == :gaming,
    into: base_map do
  {employee.name, hobby}
end

# %{
#   "Eric" => %{name: "Text Adventures", type: :gaming},
#   "Greg" => %{name: "Dungeons & Dragons", type: :gaming},
#   "Mitch" => %{name: "Reading", type: :learning}
# }
```

Here we can observe three things.

- The comprehension evaluates to a map.
- The `"Mitch"` key and its value were preserved in the final output.
- The `"Greg"` key's value in the `base_map` was overwritten by the value yielded during the comprehension with the same key. If our comprehension were to have returned multiple key/value pairs with identical keys, the last one would have won.

This option is very useful for transforming maps, since iterating over a map with an `Enum` function turns it into a list of 2-tuples, you always need to pipe the return value into `Enum.into/2` or `Map.new/1`.

```elixir
base_map = %{
  "Mitch" => %{
    name: "Reading",
    type: :learning
  },
  "Greg" => %{
    name: "Traveling",
    type: :expensive
  }
}

base_map
|> Enum.map(fn {key, value} ->
  {String.downcase(key), value}
end)
|> Map.new()
# or |> Enum.into(%{})


# %{
#   "greg" => %{name: "Traveling", type: :expensive},
#   "mitch" => %{name: "Reading", type: :learning}
# }
```

#### Strings and BitStrings

You can build strings and bitstrings with the `:into` option as well!

This is useful when you want to build a string or a binary out of a list or map all in one pass. Let's take a look at an example of creating an "attribute string" for use with HTML.

```elixir
attributes = [
  class: "font-bold text-red-500 underline",
  id: "error-text",
  data_controller: "error-controller"
]

for {property, value} <- attributes, into: "" do
  property =
    property
    |> to_string()
    |> String.replace("_", "-")

  ~s| #{property}="#{value}"|
end

# " class=\"font-bold text-red-500 underline\" id=\"error-text\" data-controller=\"error-controller\""
```

### :reduce

My favorite option to the comprehension is `:reduce`!

Reduce allows us to change the comprehension from behaving like a "map" operation to a "reduce" operation. This means that it will loop over an enumerable, but collect an "accumulator" instead.

Let's take a look at the first example in the `Enum.reduce/3` documentation and then convert it to a comprehension. This example produces the sum of a list of integers.

```elixir
Enum.reduce([1, 2, 3], 0, fn x, acc ->
  x + acc
end)

# 6
```

We can express this as a comprehension like so:

```elixir
for x <- [1, 2, 3], reduce: 0 do
  acc ->
    x + acc
end

# 6
```

There are two immediate things we can observe.

First, the `:reduce` option takes a value that is to be used as the first value of the accumulator.

Second, the comprehension in this mode includes a slightly different syntax. Here the inside of the block includes the "arg(s) and right arrow" syntax that you see in anonymous functions and case expressions. This is the syntax that allows the comprehensions to yield the accumulator to the block on every iteration.

The additional syntax is the same as the other places you have probably seen it, you can pattern match and pass additional clauses!

```elixir
directions = [
  left: 2,
  up: 1,
  down: 5,
  right: 6
]

# You can't move below or to the left of 0.
starting_position = {0, 0}

for {dir, movement} <- directions, reduce: starting_position  do
  {x, y} when dir == :left and x - movement > 0 ->
    {x - movement, y}

  {x, y} when dir == :down and y - movement > 0 ->
    {x, y - movement}

  {x, y} when dir == :up ->
    {x, y + movement}

  {x, y} when dir == :right ->
    {x + movement, y}

  position ->
    IO.puts("Not possible to move #{dir} by #{movement} when you care located at #{inspect(position)}")

    position
end

# {6, 1}
```

Above we can observe that we've written 5 different clauses, pattern match on the shape of the data, as well as add guard clauses that capture the data in the generator as well as the accumulator.

The beauty of using a comprehension as a reducer is the ability to use multiple generators and act on them as if they are one level of iteration.

```elixir
friends = [
  %{name: "Derek", hobbies: ["Movies", "Hot Sauce"]},
  %{name: "Joe", hobbies: ["Yu-Gi-Oh!", "Tattoos"]},
  %{name: "Andres", hobbies: ["Photoshop", "Oreos", "Cereal"]},
]

for %{hobbies: hobbies, name: name} <- friends, hobby <- hobbies, reduce: [] do
  tagged_hobbies ->
    [{name, hobby} | tagged_hobbies]
end

# [
#   {"Andres", "Cereal"},
#   {"Andres", "Oreos"},
#   {"Andres", "Photoshop"},
#   {"Joe", "Tattoos"},
#   {"Joe", "Yu-Gi-Oh!"},
#   {"Derek", "Hot Sauce"},
#   {"Derek", "Movies"}
# ]
```

To write this without a comprehension it would look something like:

```elixir
Enum.reduce(friends, [], fn %{name: name, hobbies: hobbies}, tagged_hobbies ->
  new_hobbies = Enum.map(hobbies, fn hobby -> {name, hobby} end)

  new_hobbies ++ tagged_hobbies
end)
```

## Conclusion

If you've made it this far, congrats! The comprehension packs a lot of features into a tiny programming construct and demonstrating all of them is a lot of work!

The comprehension is one of my favorite features of the Elixir programming language and it was a pleasure to write about every feature in as much depth as I could.

If you have any questions about comprehensions or want to suggest examples or features that I've missed, feel free to reach out on [Twitter](https://twitter.com/mitchhanberg) or [email](mailto:contact@mitchellhanberg.com).
