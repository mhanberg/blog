---
layout: Blog.PostLayout
title: "Validate and Transform Your Data with Schematic"
date: 2024-07-12 01:00:00 EST
permalink: /:title/
---

I've recently seen talk of similar libraries to [Schematic](https://github.com/mhanberg/schematic) so I figured I'd share my take on the problem space!

## Schematic

Schematic is a library for validating and transforming data in Elixir, similar to [Ecto Changesets](https://hexdocs.pm/ecto/3.11.2/Ecto.Changeset.html#field_missing?/2?utm_source=thinkingelixir&utm_medium=shownotes) and [Norm](https://github.com/elixir-toniq/norm).

I created Schematic early in 2023 while developing the [GenLSP](https://github.com/elixir-tools/gen_lsp) library, which I developed to build [Next LS](https://www.elixir-tools.dev/docs/next-ls/quickstart/). I needed to be able to consume and produce data structures described by the Language Server Protocol JSON Schema specification, which describes data in terms of basic scalar types and certain compound types, similar to some algebraic data types.

I wanted a library that lends itself to expressibility, composition, and code generation.

## Basic schematics

Schematic provides... _schematics_ for basic primitive types in Elixir.

```elixir
import Schematic

unify(int(), 1)
#=> {:ok, 1}

unify(int(), "one")
#=> {:error, "expected an integer"}
```

These are just functions, so you can bind them to variables and return them from functions.

```elixir
defmodule Numbers do
  import Schematic

  def integer(), do: int()

  def validate(value), do: unify(integer(), value)
end

Numbers.validate(1)
#=> {:ok, 1}

Numbers.validate("one")
#=> {:error, "expected an integer"}
```

## List and Tuple schematics

We can also define schematics for lists and tuples.


```elixir
defmodule Hobbies do
  import Schematic
    
  def validate(values), do: unify(list(str()), values)
end

Hobbies.validate(["foosball", "cooking"])
#=> {:ok, ["foosball", "cooking"]}

Hobbies.validate([1, "cooking"])
#=> {:error, [error: "expected a string", ok: "cooking"]}

Hobbies.validate("foosball")
#=> {:error, "expected a list"}

```

## Map and Struct schematics

Map and struct (or `schema` in Schematic parlance) schematics are versatile and extendable.

```elixir
defmodule Animals do
  import Schematic

  def schematic() do
    map(%{
      species: str(),
      genus: str(),
      color: str()
    })
  end

  defmodule Cat do
    def schematic() do
      map(Animals.schematic(), %{
        breed: str(),
        declawed: bool()
      })
    end
  end
end

Schematic.unify(Animals.schematic(), %{})
#=> {:error,
# %{
#   color: "expected a string",
#   species: "expected a string",
#   genus: "expected a string"
# }}

Schematic.unify(Animals.schematic(), %{color: "black"})
#=> {:error, %{species: "expected a string", genus: "expected a string"}}

Schematic.unify(Animals.schematic(), %{color: "black", species: "lupus", genus: "canis"})
#=> {:ok, %{color: "black", species: "lupus", genus: "canis"}}

Schematic.unify(Animals.Cat.schematic(), %{color: "orange", species: "catus", genus: "felis"})
#=> {:error, %{breed: "expected a string", declawed: "expected a boolean"}}

Schematic.unify(Animals.Cat.schematic(), %{
  color: "orange",
  species: "catus",
  genus: "felis",
  breed: "shorthair",
  declawed: false
})
#=> {:ok,
# %{
#   color: "orange",
#   species: "catus",
#   genus: "felis",
#   breed: "shorthair",
#   declawed: false
# }}
```

Structs can be created from plain maps using the `schema` schematic. By default it looks for string keys and converts them to atom keys, but that can be disabled using the `convert: false` option.

```elixir
defmodule Animals do
  import Schematic

  defstruct [:species, :genus, :color]

  def schematic() do
    schema(__MODULE__, %{
      species: str(),
      genus: str(),
      color: str()
    })
  end
end

Schematic.unify(Animals.schematic(), %{"species" => "lupus", "genus" => "canis", "color" => "grey"})
#=> {:ok, %Animals{species: "lupus", genus: "canis", color: "grey"}}
```

### Optional keys and nullable fields

Optional keys and nullable values can be specified using the `optional` and `nullable` schematics. Combining this with a struct, you can create default values for certain keys.

`optional` keys do not have to be present, but if they are, the value must unify with the given schematic. 

```elixir
defmodule Animals do
  import Schematic

  defstruct [:species, :genus, color: "brown"]

  def schematic() do
    schema(__MODULE__, %{
      optional(:color) => str(),
      species: str(),
      genus: nullable(str())
    })
  end
end

Schematic.unify(Animals.schematic(), %{
  "species" => "lupus",
  "genus" => nil,
})
#=> {:ok, %Animals{species: "lupus", genus: nil, color: "brown"}}
```

### Tranforming keys

While `schema` will automatically convert string to atom keys, you can also use a tuple for the key specification for key transformation like camelCase to snake_case.


```elixir
defmodule JobPosting do
  import Schematic

  def schematic() do
    map(%{
      {"startDate", :start_date} => str(),
      optional({"salaryRange", :salary_range}) => str(),
      {"title", :title} => str()
    })
  end
end

Schematic.unify(JobPosting.schematic(), %{
  "startDate" => "Jan 1, 2025",
  "title" => "Chicken Tender Engineer"
})
#=> {:ok, %{title: "Chicken Tender Engineer", start_date: "Jan 1, 2025"}}
```

You can also use the `dump` function to transform keys in reverse.

```elixir
Schematic.dump(JobPosting.schematic(), %{
  title: "Chicken Tender Engineer",
  start_date: "Jan 1, 2025"
})
#=> {:ok, %{"startDate" => "Jan 1, 2025", "title" => "Chicken Tender Engineer"}}
```

## Advanced schematics

Most of your data is rather complex and can be specified further than just a "string", you might have an enumeration, you might actually say a value can be either a `Mammal` or a `Reptile`, or convert an ISO timestamp into an Elixir DateTime struct.

### `oneof`

If you want to say a value is "one of" a list of schematics, you can use the `oneof` schematic. I believe the semantics are similar to an enum or union type from other languages. 

In this example, we also demonstrate using literals as schematics.

```elixir
defmodule HousePet do
  import Schematic

  def schematic() do
    map(%{
      name: str(),
      type:
        oneof([
          "Dog",
          "Cat",
          "Hamster",
          "Fish"
        ])
    })
  end
end
```

Making an enum of strings is nice, but for a proper union type style schematic, we can use other schematics, even map schematics.

```elixir
defmodule HousePet do
  import Schematic

  def dog, do: map(%{type: "dog"})
  def cat, do: map(%{type: "cat"})
  def hamster, do: map(%{type: "hamster"})
  def fish, do: map(%{type: "fish"})

  def schematic() do
    oneof([
      dog(),
      cat(),
      hamster(),
      fish()
    ])
  end
end

Schematic.unify(HousePet.schematic(), %{type: "cat"})
#=> {:ok, %{type: "cat"}}
```

Unfortunately the error message for these kind of failure case is not very good, but will be improved in a future version Schematic.

```elixir
Schematic.unify(HousePet.schematic(), %{type: "snake"})
#=> {:error, "expected either a map, a map, a map, or a map"}
```

## Value based validations

So far we've covered more _structural_ style of data validation, but we can also do more value based validations that you are probably used to in your `Ecto.Changeset` code.

We can use the `all` and `raw` schematics to accomplish this!

```elixir
defmodule SpecialNumber do
  def schematic do
    all([
      int(),
      raw(&Kernel.<(&1, 10), message: "must be less than 10"),
      raw(&(Kernel.rem(&1, 2) == 0), message: "must be divisible by 2")
    ])
  end
end

Schematic.unify(SpecialNumber.schematic(), 8)
#=> {:ok, 8}

Schematic.unify(SpecialNumber.schematic(), 15)
#=> {:error, ["must be less than 10", "must be divisible by 2"]}

Schematic.unify(SpecialNumber.schematic(), "15")
#=> {:error, ["expected an integer", "must be less than 10", "is invalid"]}
```

## Transforming Data

You can also use the `raw` schematic to transform the data as you parse and validate it. Here we read a ISO8601 timestamp and turn it into a `DateTime` struct.

```elixir
defmodule Datetime do
  import Schematic

  def schematic() do
    raw(
      fn
        i, :to -> is_binary(i) and match?({:ok, _, _}, DateTime.from_iso8601(i))
        i, :from -> match?(%DateTime{}, i)
      end,
      transform: fn
        i, :to ->
          {:ok, dt, _} = DateTime.from_iso8601(i)
          dt

        i, :from ->
          DateTime.to_iso8601(i)
      end
    )
  end
end

Schematic.unify(Datetime.schematic(), "2024-07-11T17:48:41.972851Z")
#=> {:ok, ~U[2024-07-11 17:48:41.972851Z]}
```

## Dumping Data

Not only can you parse and validate external data into your internal format, you can also _dump_ that data back into the external format.

This will respect any map key transformations that you've declared and as seen above, you can use a `raw` schematic to arbitrarily control how the data is transformed in each direction.

```elixir
Schematic.dump(Datetime.schematic(), ~U[2024-07-11 17:48:41.972851Z])
#=> {:ok, "2024-07-11T17:48:41.972851Z"}

Schematic.dump(Animals.schematic(), %Animals{
  species: "lupus",
  genus: "canis",
  color: "grey"
})
#=> {:ok, %{"color" => "grey", "genus" => "canis", "species" => "lupus"}}
```

## Future features

While the `oneof` schematic handles "union" types (typically represented like `Dog | Cat`), I would like to add "intersection" types (represented sometimes like `Dog & Cat`).

## Conclusion

I am pretty happy with what I've come up with, and it works for my use cases very well!

You can see Schematic in action in the [gen_lsp](https://github.com/elixir-tools/gen_lsp/blob/main/lib/gen_lsp/protocol/requests/initialize.ex) code base and for an example of how it works with code generation you can check out the [lsp_codegen](https://github.com/elixir-tools/lsp_codegen) project.

Happy hacking!
