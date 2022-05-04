---
layout: post
title: "The Comprehensive Guide to Elixir's List Comprehension"
date: 2022-04-15 01:00:00 -04:00
categories: post
permalink: /:title/

---

- what is it
- the generators
    - ✅ multiple generators
    - ✅ you can use a lhs value from generator A in the rhs of generator B
    - ✅ filters non matching items
    - ✅ works with anything enumerable, lists, maps
    - ✅ bitstring generator
- the filter
- option: into
    - collectables
- option: uniq
- option: reduce

## What is it?

The `for` special form, also known as a list comprehension, is a construct designed for concise and powerful enumerable transformation in Elixir.

It looks very similar to a "for loop" in other languages like JavaScript and C, but rather than being a language construct, it is an expression (like everything else in Elixir). This means that it evaluates to a value that can be bound to a variable.

```elixir
last_names = 
  for friend <- friends do
    friend.last_name
  end
```

Before reading this rest of this article, I suggest you read the list comprehension guide on [elixir-lang.org](https://elixir-lang.org/getting-started/comprehensions.html). I will go over some of the same details, but hopefully will go much more in depth.

## Generators

The primary ingredient in a comprehension is the generator. The only other place you will see this "left arrow" syntax (`lhs <- rhs`) is in the `with` special form.

The right hand side is the enumerable you want to loop over and the left hand side is the intermediate pattern you want to match on each iteration. This is a normal pattern, so you can pattern match like you would anywhere else.

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

The counter example using [`Enum.map/2`](TODO) is not nearly as readable and demonstrates that you need to remember to flatten the outer loop, or else you'll get a list of lists.

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

List comprehensions allow you to chain generators together by using a `lhs` value from a generator in the `rhs` of a subsequent generator.

Here's an example of getting a list of all of your friends hobbies:

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

### Generators filter non-matching `lhs` values

If the match expression in the `lhs` of a generator does not match no the value yielded from the `rhs`, it will be rejected and the list comprehension will move on to the next element in the enumerable.

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

If you were to have written this program using `Enum.map/2`, you would have run into a function clause error.

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

This behaviour can be useful! If you only wanted to enumerated configuration options that are enabled, you could write something like this:

```elixir
configs = [
  %{name: :feature_a, enabled: true},
  %{name: :feature_b, enabled: false},
  %{name: :feature_c, enabled: true},
]

for %{enabled: true} = config <- configs do
  config
end

# [%{name: :feature_a, enabled: true}, %{name: :feature_c, enabled: true}]
```

## Filters

Now that we've talked about _generator filtering_, let's talk about _Filters_.
