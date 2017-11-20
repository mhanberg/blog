---
layout: post
title: Implementing API Authentication with Guardian 1.0
date: 2017-11-18 09:00:00 -04:00
categories: post
permalink: /:categories/:year/:month/:day/:title/
---

### Installing Guardian

Let's add Guardian as a dependency and install it.

```elixir
# mix.exs

defp deps do
  [
    ...
    {:guardian, "~> 1.0-beta"}
  ]
end
```

```shell
$ mix deps.get
```

Guardian requires that you add an implementation module, I added mine to an `auth` folder in my web directory.

```elixir
# lib/my_app_web/auth/guardian.ex

defmodule MyAppWeb.Guardian do
  use Guardian, otp_app: :my_app

  def subject_for_token(resource, _claims) do
    {:ok, to_string(resource.id)}
  end

  def subject_for_token(_, _) do
    {:error, :reason_for_error}
  end

  def resource_from_claims(claims) do
    {:ok, find_me_a_resource(claims["sub"])}
  end

  def resource_from_claims(_claims) do
    {:error, :reason_for_error}
  end
end
```

There are two functions that are required to implement, `subject_for_token/2` and `resource_for_claims/2`

The function `find_me_a_resource/1`, that is called in `resource_from_claims/2`, is just a placeholder. You will need to implement that function (the name is not important, it can be whatever you want).

### Authentication

Our next step will be to perform the authentication of the credentials that the client has sent to our API. 

```elixir
def authenticate(%{user: user, password: password}) do
  case Comeonin.Bcrypt.checkpw(password, user.password_digest) do
    true ->
      MyAppWebWeb.Guardian.encode_and_sign(user)
    _ ->
      {:error, :unauthorized}
  end
end
```

This is my authentication function, it takes the User struct that I located in the database based on the unique identifier that was passed by the request (in my case can be either an email address or a username) and the password attempt. 

I am using the password hashing library Comeonin to hash my passwords, so here I use one of its functions to check the password attempt with the digest (AKA a hash) stored in the database. This function returns either true or false, so if the password is correct, we fall into the true case and we create our token (JSON Web Token, or JWT) and return it. 

Otherwise we return the tuple `{:error, :unauthorized}` to signify that that authentication attempt failed.

### The Controller

Let's expose this functionality to our public API by making a controller endpoint to sign in a user.

```elixir
def sign_in(conn, %{"data" => data}) do
  attrs = JaSerializer.Params.to_attributes(data)

  login_cred = case attrs do
    %{"username" => username, "password" => password} ->
      %{login: username, password: password}
    %{"email" => email, "password" => password} ->
      %{login: email, password: password}
  end

  with %User{} = user <- Accounts.find(login_cred.login) do
    with {:ok, token, _claims} <- Accounts.authenticate(%{user: user, password: login_cred.password}) do
      render conn, "token.json-api", token: token
    end
  end
end
```

Here we deserialize our JSON payload, find the user in the database, and authenticate the user. If the authentication is successful, we render the token back to the consumer. 

### Authorization

Great, we can sign in a user. Now we should start looking for this token in our requests before responding to them. We're going to rework our router.

```elixir
# router.ex

pipeline :api_auth do
  plug MyAppWeb.Guardian.AuthPipeline
end

scope "/api", MyAppWeb.Api do
  pipe_through :api

  scope "/v1", V1 do
    resources "/users", UserController, only: [:create]
    post "/users/sign_in", UserController, :sign_in
  end
end

scope "/api", MyAppWeb.Api do
  pipe_through [:api, :api_auth]

  scope "/v1", V1 do
    resources "/users", UserController, only: [:update, :show, :delete]
  end
end
```


We define a new pipeline called `api_auth` to pipe routes through that require authorization, which in my case will be all routes except for the `UserController#sign_in` and `UserController#create` routes. 

Phoenix lets us define the same scopes multiple times without overwriting them. Here I define the 'api' and 'v1' scopes twice, piping the first only through the 'api' pipeline and piping the second through the 'api' and 'api_auth' pipelines. 

The 'api_auth' pipeline consists of a custom plug I defined in '/lib/my_app_web/auth/auth_pipeline.ex'.

```elixir
# /lib/my_app_web/auth/auth_pipeline.ex

defmodule MyAppWeb.Guardian.AuthPipeline do
  use Guardian.Plug.Pipeline, otp_app: :my_app,
                              module: MyAppWeb.Guardian,
                              error_handler: MyAppWeb.Guardian.AuthErrorHandler

  plug Guardian.Plug.VerifyHeader
  plug Guardian.Plug.EnsureAuthenticated
end
```

The first line of this plug defines some boiler plate that Guardian will use. The last two lines are what we want to check the authorization of the user. `VerifyHeader` will look for the the Authorization header in the request. This should contain "Bearer <your token>". `EnsureAuthenticated` will make sure that the token is valid. 

In the first line of boiler plate, we defined an error_handler, `MyAppWeb.Guardian.AuthErrorHandler`, mine currently is the example code from Guardian's README.

```elixir
# /lib/my_app_web/auth/auth_error_handler.ex

defmodule MyAppWeb.Guardian.AuthErrorHandler do
  import Plug.Conn

  def auth_error(conn, {type, _reason}, _opts) do
    body = Poison.encode!(%{message: to_string(type)})
    send_resp(conn, 401, body)
  end
end
```

### Testing

At first I got tripped up on testing this functionality, but the solution turned out to be rather simple. 

ExUnit doesn't allow `describe` blocks to be nested, so I reorganized my test file to have two `describe` blocks, one for tests that require authentication and one for tests that don't require it. I have a top level `setup` block that adds the headers to the request that are common to all tests. 

In the describe block for the tests requiring authentication, I wrote another `setup` block. 

```elixir
setup %{conn: conn} do
  user = insert(:user, email: "user@email.com", username: "user") # syntax for the library ExMachina

  {:ok, token, _claims} = MyAppWeb.Guardian.encode_and_sign(user)
  conn =
    conn
    |> put_req_header("authorization", "Bearer #{token}")

  {:ok, conn: conn, user: user} # I return the user as well due to needing it in the tests
end
```
