---
layout: Blog.PostLayout
title: Implementing API Authentication with Guardian in Phoenix
date: 2017-11-28 09:00:00 EST
categories: post
desc: Guide on implementing authentication in an API-only Phoenix 1.3 application using Guardian 1.0.
permalink: /post/2017/11/28/implementing-api-authentication-with-guardian/
---

Most applications need some sort of authentication and authorization, and REST API's are no different. If you are familiar with web development but have never worked on one that does not have a front end (like me), then the authentication functionality might stump you at first.

### What is Guardian?

> Guardian is a token based authentication library for use with Elixir applications.

* More can be learned by reading its [documentation](https://github.com/ueberauth/guardian), which I highly recommend.
* Keep in mind that the "tokens" that Guardians refers to are [JSON Web Tokens](https://jwt.io/introduction/).

---

### Installation and Configuration

Add Guardian 1.0 as a dependency in `mix.exs`.

```elixir
{:guardian, "~> 1.0"}
```

And install

```shell
$ mix deps.get
```

Guardian requires that you add an implementation module, I added mine to an `auth` folder in my web directory.

```elixir
# lib/my_app_web/auth/guardian.ex

defmodule MyAppWeb.Guardian do
  use Guardian, otp_app: :my_app

  def subject_for_token(resource, _claims) do
    # You can use any value for the subject of your token but
    # it should be useful in retrieving the resource later, see
    # how it being used on `resource_from_claims/1` function.
    # A unique `id` is a good subject, a non-unique email address
    # is a poor subject.

    sub = to_string(resource.id)
    {:ok, sub}
  end

  def resource_from_claims(claims) do
    # Here we'll look up our resource from the claims, the subject can be
    # found in the `"sub"` key. In `above subject_for_token/2` we returned
    # the resource id so here we'll rely on that to look it up.

    id = claims["sub"]
    resource = MyApp.get_resource_by_id(id)
    {:ok,  resource}
  end
end
```

There are two functions that you are required to implement, `subject_for_token/2` and `resource_for_claims/2`. The compiler will complain if they are not implemented.

The `resource` refers to a user, and the `sub` (subject) is the user's primary key (or another unique identifier). The function `MyApp.get_resource_by_id(id)`, that is called in `resource_from_claims/2`, is just a placeholder. You will need to implement that function (the name is not important, it can be whatever you want) and it should retrieve the user based on the `sub` (subject).

* This is taken directly from Guardian's example code.
* More can be learned about claims by reading the [JSON Web Token documentation](https://jwt.io/introduction/)

Finally, we add a config to `config.exs`

```elixir
config :my_app, MyAppWeb.Guardian,
       issuer: "my_app",
       secret_key: "Secret key. You can use `mix guardian.gen.secret` to get one"
```

You will need to create a secret key using the method above. If you're writing a production application, you should use an environment variable.

* The atom `:my_app` corresponds to the atom in the implementation module and the namespacing of the module also corresponds to the implementation module.
* The value for the key `issuer` can be whatever you want.

---

### Authentication

Our next step will be to perform the authentication of the credentials that the client has sent to our API.

```elixir
def authenticate(%{user: user, password: password}) do
  # Does password match the one stored in the database?
  case Comeonin.Bcrypt.checkpw(password, user.password_digest) do
    true ->
      # Yes, create and return the token
      MyAppWebWeb.Guardian.encode_and_sign(user)
    _ ->
      # No, return an error
      {:error, :unauthorized}
  end
end
```

This is my authentication function, it takes the User struct that I located in the database based on the unique identifier that was passed by the request (in my case can be either an email address or a username) and the password attempt.

I am using the password hashing library [Comeonin](https://github.com/riverrun/comeonin) to hash my passwords, so here I use the `checkpw/2` function to check the password attempt against the digest (AKA a hash) stored in the database. This function returns either true or false, so if the password is correct, we fall into the true case and we create our token (JSON Web Token, or JWT) and return it.

Otherwise we return the tuple `{:error, :unauthorized}` to signify that the authentication attempt failed.

---

### The Controller

Let's expose this functionality to our public API by making a controller endpoint to sign in a user.

```elixir
def sign_in(conn, params) do
  # Find the user in the database based on the credentials sent with the request
  with %User{} = user <- Accounts.find(params.email) do
    # Attempt to authenticate the user
    with {:ok, token, _claims} <- Accounts.authenticate(%{user: user, password: login_cred.password}) do
      # Render the token
      render conn, "token.json", token: token
    end
  end
end
```

Here we find the user in the database and authenticate the user. If the authentication is successful, we render the token back to the consumer.

Note: Here I am using the `with` syntax along with Phoenix's [`action_fallback`](http://phoenixframework.org/blog/phoenix-1-3-0-released) functionality.

---

### Authorization

In the context of a web application, this is the process of fencing off most of the routes from unauthenticated visitors. However, there are two routes that should ___not___ be fenced off, the route to sign in a user and the route to create a user.

```elixir
# router.ex

pipeline :api do
  plug :accepts, ["json"]
end

pipeline :api_auth do
  plug MyAppWeb.Guardian.AuthPipeline
end

scope "/api", MyAppWeb.Api do
  pipe_through :api

  resources "/users", UserController, only: [:create]
  post "/users/sign_in", UserController, :sign_in
end

scope "/api", MyAppWeb.Api do
  pipe_through [:api, :api_auth]

  resources "/users", UserController, only: [:update, :show, :delete]
end
```

For those unfamiliar with `pipelines`, please reference the [Phoenix guides](https://hexdocs.pm/phoenix/routing.html#pipelines).

We define a new pipeline called `api_auth` for routes that require authorization, which in my case will be all routes except for `UserController#sign_in` and `UserController#create`.

Phoenix lets us define the same scopes multiple times without overwriting them. Here I define the `api` and `v1` scopes twice, piping the first only through the `api` pipeline and piping the second through the `api` ___and___ `api_auth` pipelines.

The `api_auth` pipeline consists of a custom plug I defined in `/lib/my_app_web/auth/auth_pipeline.ex`.

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

The first line of this plug defines some boiler plate that Guardian will use. The last two lines are what we want to check the authorization of the user. `VerifyHeader` will look for the the Authorization header in the request, which should contain `Bearer <your token>`, and `EnsureAuthenticated` will make sure that the token is valid.

In the first line of boiler plate, we defined an error handler, `MyAppWeb.Guardian.AuthErrorHandler`, mine consists of the example code from the Guardian documentation.

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

---

### Testing

At first I was unsure of how to test this functionality, but the solution turned out to be rather simple.

I've organized my test file to have two `describe` blocks, one for tests that require authentication and one for tests that don't require it. I have a top level `setup` block that adds the headers to the request that are common to all tests.

In the describe block for the tests requiring authentication, I wrote another `setup` block.

```elixir
setup %{conn: conn} do
  # create a user
  user = insert(:user, email: "user@email.com", username: "user")

  # create the token
  {:ok, token, _claims} = MyAppWeb.Guardian.encode_and_sign(user)

  # add authorization header to request
  conn = conn |> put_req_header("authorization", "Bearer #{token}")

  # pass the connection and the user to the test
  {:ok, conn: conn, user: user}
end
```

Any requests you make in your tests should now have the appropriate headers!

* I am using the [ExUnit](https://hexdocs.pm/ex_unit/ExUnit.html) testing framework (comes with Elixir).

---

If you found this helpful, please let me know! You can find me on twitter as [@mitchhanberg](https://twitter.com/mitchhanberg) or you can shoot me an email.

