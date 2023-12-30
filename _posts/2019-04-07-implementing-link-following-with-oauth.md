---
layout: Blog.PostLayout
title: Implementing link following with OAuth
date: 2019-04-07 9:00:00 -04:00
categories: post
permalink: /:title/
---

**Link following** is the process for dynamically redirecting a user after successful authentication.

Disclaimer: I'm not sure what this is actually called, so I made up "Link following." If you know the actual name, [let me know!](https://twitter.com/mitchhanberg)

If you are new to using OAuth to handle authentication, implementing link following won't be as intuitive as it would be if you were hand rolling your own.

The trouble comes with remembering the link that the user clicked. If you were to write your own auth, this would all be handled within your own application and it would be easy to maintain that state. With OAuth, authentication is actually split between your application and the OAuth service that you don't control.

So how are you supposed to remember where the user wanted to go after the OAuth service authenticates the user?

The OAuth protocol specifies a [state](https://auth0.com/docs/protocols/oauth2/oauth-state) parameter that can be sent along with the authentication request and is returned with the response. 

## Implementation

I recently implemented link following with the [Elixir](https://elixir-lang.org/) libraries [Phoenix](https://phoenixframework.org/) and [Ueberauth](https://github.com/ueberauth/ueberauth), but these principles apply to any language or library.

When the request comes in, we need to determine if the user is logged in. If they aren't we will need to redirect them to the log in page and take note of the original request path. Let's define a plug to do this for us.

(The code snippets here are stripped down for brevity)

```elixir
defmodule MyAppWeb.LoggedIn do
  def call(conn, _opts) do
    case current_user(conn) do
      nil ->
        conn
        |> Phoenix.Controller.redirect(to:
          Routes.some_controller_path(
            conn,
            :login,
            path: conn.request_path
          )
        )
        |> halt()

      _ ->
        conn
    end
  end
end
```

Now that we are sending the original request path along with the redirect to the login page, we'll want to use that information to form our OAuth link.

```elixir
link(
  to: Routes.auth_path(conn,
    :request,
    "oauth service",
    state: path
  )
)
```

If the user is able to authenticate with the OAuth service, we'll be able to take advantage of the state parameter that is sent back with the response in our controller action.

The `User.find_or_create/1` function attempts to find an existing user and will create one if it can't, returning the user.

`handle_find_for_create/2` will handle the response from the previous function, such as putting the user in the session and setting the flash message, returning the conn.

`redirect/2` will send the user to their original destination based on the state parameter returned by the OAuth service. 

```elixir
def callback(
    %{assigns: %{ueberauth_auth: auth}} = conn,
    %{"state" => path}
  ) do
  conn =
    auth
    |> User.find_or_create()
    |> handle_find_or_create(conn)

  redirect conn, to: path
end
```

## Wrapping up

The OAuth protocol takes a state parameter that allows you to maintain a piece of data during the authentication handshake, we can use this to remember what link the user was attempting to access, and redirect them after a successful handshake.
