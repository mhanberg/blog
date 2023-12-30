---
layout: Blog.PostLayout
title: Encoding Ecto Validation Errors in Phoenix 1.3
date: 2017-10-23 09:00:00 -04:00
categories: post
desc: With a recent change to Ecto, rendering database validation errors requires some extra TLC to get the job done.
permalink: /post/2017/10/23/encoding-ecto-validation-errors-in-phoenix/
---
# Problem

I recently ran into this error while implementing the first endpoint of my Phoenix JSON API.


```shell
** (Poison.EncodeError) unable to encode value: {:username, {"has already been taken", []}}
```

After a bit of googling and detective work, I found the offending piece of code, located in my `error_view.ex` file.

```elixir
def render("409.json", %{changeset: changeset}) do
  %{
    status: "failure",
    errors: changeset.errors # this line causes the error
  }
end
```
This function handles rendering the JSON payload that the controller sends back to the client when there is an error.

The `errors` property of the `changeset` struct is a [keyword list](https://elixir-lang.org/getting-started/keywords-and-maps.html#keyword-lists)* of `error`'s, with `error` being  a type defined in the [Changeset module](https://github.com/elixir-ecto/ecto/blob/v2.2.6/lib/ecto/changeset.ex#L250).

```elixir
@type error :: {String.t, Keyword.t}
```

[Poison](https://github.com/devinus/poison) is not able to encode this, so a `Poison.EncodeError` error is raised.

\* It's important to remember that a keyword list is a list of 2-item tuples with the first item of the tuple being an atom. So the error we originally saw was the key-value pair that couldn't be encoded, shown in tuple form.

---

# Solution

If you created your Phoenix app when Phoenix was at v1.3, then you should have this function in the `/lib/your_app_web/views/error_helpers.ex` file. If not, go ahead and paste it in that file.

```elixir
@doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # Because error messages were defined within Ecto, we must
    # call the Gettext module passing our Gettext backend. We
    # also use the "errors" domain as translations are placed
    # in the errors.po file.
    # Ecto will pass the :count keyword if the error message is
    # meant to be pluralized.
    # On your own code and templates, depending on whether you
    # need the message to be pluralized or not, this could be
    # written simply as:
    #
    #     dngettext "errors", "1 file", "%{count} files", count
    #     dgettext "errors", "is invalid"
    #
    if count = opts[:count] do
      Gettext.dngettext(ContactWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(ContactWeb.Gettext, "errors", msg, opts)
    end
  end
```

And then we make the following change.

```diff
def render("409.json", %{changeset: changeset}) do
  %{
    status: "failure",
-   errors: changeset.errors # this line causes the error
+   errors: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
  }
end
```

Here we use the [Ecto.Changeset.traverse_errors/2](https://hexdocs.pm/ecto/Ecto.Changeset.html#traverse_errors/2) function to apply the `translate_errors/1` function to each error, which will return a map that can then be encoded by Poison.

Here is the JSON that we can now render and send to the client!

```json
{
  "status": "failure",
  "errors": {
    "email": [
        "has already been taken"
    ]
  }
}
```

---

If you found this helpful, please let me know! You can find me on twitter as [@mitchhanberg](https://twitter.com/mitchhanberg) or you can shoot me an email.
