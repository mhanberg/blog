---
layout: Blog.PostLayout
title: "Peeling Away Complexity"
date: 2025-06-14 01:00:00 EST
permalink: /:title/
---


- programs increase in complexity the deeper they become
    - deep means the top level function calls a function, which calls a function, which calls a function, etc.
- the deeper they become, the harder they become to change
    - when a program becomes really deep, changing functionality at a deep level becomes harder and unrelated parts of the codebase are less resilient to changes. If you need a new value at level 7, but that value comes from an HTTP request, so it must be passed through levels 0-6 to make it to level 7
- the deeper the become, the harder they become to test
    - similar to the ability to change, the deeper they are, the more tests that have to change when making a small change at a deeper level.

- the more global state that is used, the harder the programs are to test and understand
    - in Elixir, global state can be
        - Application config
        - Environment variables
        - single global process (SGP)
            - processes that are started in an Application tree and are are interacted with by a static name.
        - ETS
        - persistent term
        - database

- programs increase in complexity as the number of dead-end/shallow layers are created
  - dead-ends are short, non-reusable procedures that are created that obscure functionality and further increase the depth.
  - the don't add much value


---


pass things in instead of fetching via a side effect (global state, database, config)

makes testing easier
makes code more flexible

makes dependencies explicit

in practice, this hoists side effects up the call stack

pass in dependent data as parameters to your function
    - this might lead to "prop drilling", or "parameter drilling" in our case, where you pass some data along a long call stack, making it hard to know where it originates from or is mutated
        - well, this is a call to "flatten" your call stack.
            - instead of nesting functions like a Russian (?) nesting doll, you can invert the call structure
                - instead of
                  Foo(a)
                  ↳ Bar(a)
                    ↳ Baz(a)
                      ↳ Quz(a)
                - you do
                  r1 = Foo()
                  r2 = Bar()
                  r3 = Baz()
                  Quz(r3, a)
    - avoiding prop drilling allows you to avoid passing unrelated data to functions called earlier

- parameterize your program, not just your functions, making it easier to test
  - stop relying on global state
    - examples: controllers can have things put into the private in the conn in order to pass in test data that would normally get 
      accessed via config or a singleton process
- parameters are good, but dont keep adding more

- nesting dolls can mask side effects, often leading to hard to test code bad performance
- prop drilling makes software hard to change and easy to mess up
- prop drilling makes testing hard, especially integration testing
- doing this often times leads you to rely on global state, which ruins your tests and slows them down
- prop drilling can be caused by building your software like a nesting doll
