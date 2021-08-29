---
layout: Blog.Layouts.Post
title: "CI/CD with Phoenix, GitHub Actions, and Gigalixir"
date: 2020-03-03T09:00:00-04:00
categories: post
permalink: /:title/
img: https://res.cloudinary.com/mhanberg/image/upload/v1583173677/ci-cd-with-phoenix-github-actions-gigalixir-hero-image.png
---

I like to start my side projects by immediately configuring them with a CI pipeline and automatic deployments. I normally go with Heroku, but Heroku has some drawbacks when deploying Elixir applications. 

Luckily, another PaaS solution exists and is designed specifically for Elixir, [Gigalixir](https://www.gigalixir.com)! Let's build a project called "Pipsqueak" and learn how to automatically test and deploy a new Phoenix application to Gigalixir.

**Note**: This article will assume that you already know how to install Elixir/Erlang and will reference tools like [hub](https://github.com/github/hub) that I actually used while implementing the application that I describe below.

## Create a new Phoenix project

Our first step is to create a new Phoenix application. We'll then immediately initialize our `git` repository and push it up to GitHub.

I like to make the first commit right after generating the project so you don't get lost when making your initial changes. This way, when you look at the second commit, you'll see the first changes that the developer made.

```shell
$ mix phx.new pipsqueak && cd pipsqueak

$ git add . && git commit -m "Initial Commit"

$ hub create

$ git push -u origin master
```

## Switch to Yarn

I like to use Yarn instead of NPM to manage my JavaScript packages, so we'll re-install the packages using Yarn to create our `yarn.lock` file.

If you don't use Yarn, you can skip this step.

```shell
$ rm assets/package-lock.json

$ (cd assets && yarn install)

$ git add . && git commit -m "Switch to Yarn"
```

## Continuous Integration with GitHub Actions

[GitHub Actions](https://www.github.com/actions) is a new product by GitHub that is used to run arbitrary workflows and CI pipelines in response to events emitted by GitHub. Let's run our new test suite by implementing a Workflow.

Our workflow will run on every push, check that our code is formatted, and run our test suite.

Notable pieces of this workflow are:

- We use the matrix strategy even though we are only using a single combination. This way we can use our version in our cache keys, so that we update cache will invalidate when we inevitably update our language versions.
- We boot up our Postgres server as a service container. Make sure the user/password/db match your application's test config.
- We cache our Elixir and JavaScript dependencies so that we only install them if we really have to.
- We cache our Elixir build so that the compiler only has to compile the files that have changed.

```yaml{% raw %}
# .github/workflows/verify.yml

on: push

jobs:
  verify:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        otp: [22.2.7]
        elixir: [1.10.1]

    services:
      db:
        image: postgres:12
        env:
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: pipsqueak_test
        ports: ['5432:5432']
        options: --health-cmd pg_isready --health-interval 10s --health-timeout 5s --health-retries 5

    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-elixir@v1
        with:
          otp-version: ${{ matrix.otp }}
          elixir-version: ${{ matrix.elixir }}

      - name: Setup Node
        uses: actions/setup-node@v1
        with:
          node-version: 13.8.0

      - uses: actions/cache@v1
        id: deps-cache
        with:
          path: deps
          key: ${{ runner.os }}-mix-${{ hashFiles(format('{0}{1}', github.workspace, '/mix.lock')) }}

      - uses: actions/cache@v1
        id: build-cache
        with:
          path: _build
          key: ${{ runner.os }}-build-${{ matrix.otp }}-${{ matrix.elixir }}-${{ hashFiles(format('{0}{1}', github.workspace, '/mix.lock')) }}

      - name: Find yarn cache location
        id: yarn-cache
        run: echo "::set-output name=dir::$(yarn cache dir)"

      - uses: actions/cache@v1
        with:
          path: ${{ steps.yarn-cache.outputs.dir }}
          key: ${{ runner.os }}-yarn-${{ hashFiles('**/yarn.lock') }}
          restore-keys: |
            ${{ runner.os }}-yarn-

      - name: Install deps
        run: |
          mix deps.get
          (cd assets && yarn)

      - run: mix format --check-formatted
      - run: mix test{% endraw %}
```

To test our workflow, let's commit and push to GitHub.

```shell
$ git add . && git commit -m "Verify workflow"

$ git push origin master
```

## Create a new Gigalixir app

Before proceeding with this section, please refer to the [Gigalixir Getting Started Guide](https://gigalixir.readthedocs.io/en/latest/main.html#getting-started-guide) to create an account and install the `gigalixir` command line tool.

Our application will deploy using mix releases, so we need to add a `config/releases.exs` file. Gigalixir will detect this file and assume we are using a mix release.

The following will ensure that our server is started and URLs will be properly constructed.

```elixir
# config/releases.exs

import Config

config :pipsqueak, PipsqueakWeb.Endpoint,
  server: true,
  http: [port: {:system, "PORT"}],
  url: [host: System.get_env("APP_NAME") <> ".gigalixirapp.com", port: 443]
```

Next, let's configure the Elixir, Erlang, Node, and Yarn versions to be used with our deployment. We'll use the latest version that are available at the time of writing.

Create the following files in the root of repository.

```config
# elixir_buildpack.config

elixir_version=1.10.2
erlang_version=22.2.8

# phoenix_static_buildpack.config

node_version=13.8.0
yarn_version=1.22.0
```

Time to commit the changes we've made.

```shell
$ git add . && git commit -m "Configure for Gigalixir"
```

Before we can deploy our application, we'll have to create an app and a database using the `gigalixir` command line tool.

```shell
$ gigalixir create

$ gigalixir pg:create --free
```

Now we have somewhere to deploy our code. Like Heroku, Gigalixir uses git for deployments. Running `gigalixir create` added a git remote named `gigalixir` and now we can push to it. 

```shell
$ git push gigalixir master
```

You should now be able to visit `<your app name>.gigalixirapp.com` and see our stock Phoenix application!

![https://pipsqueak.gigalixirapp.com](https://res.cloudinary.com/mhanberg/image/upload/v1583205573/pipsqueak-gigalixirapp.png)

While this is quick and easy when first starting out, it can be tedious and error prone in the long run.

This is where Gigalixir falls short compared to Heroku. Heroku connects to GitHub and automatically deploys when all of your [checks](https://developer.github.com/v3/checks/) have passed. Checks are GitHub integrations that run some sort of test on your code and then either pass or fail. 

Since we're using GitHub Actions, we have an entire marketplace of actions at our disposal. I saw that there wasn't an existing action for Gigalixir, so I decided to write my own!

## Gigalixir Action

Check out the source code for this action [here](https://github.com/mhanberg/gigalixir-action).

This action has a few features:

- Deploy our application to Gigalixir.
- Run our migrations upon a successful deployment.
- If our migrations fail, it will rollback our deployment to the last version.

Running migrations requires ssh access to the deployment, so before we can get started we need to generate a new public/private key pair, upload the public key to Gigalixir, and add the private key to GitHub as a secret. 

Let's generate an SSH key pair (without a passphrase) called `gigalixir_rsa` in our current directory and add it to Gigalixir.

```shell
$ ssh-keygen -t rsa -b 4096 -C "Gigalixir SSH Key"

$ gigalixir account:ssh_keys:add "$(cat gigalixir_rsa.pub)"

$ cat gigalixir_rsa | pbcopy
```

We also copied our private key to the clipboard so that we can add it as a GitHub secret.

![Adding our SSH_PRIVATE_KEY as a secret](https://res.cloudinary.com/mhanberg/image/upload/v1583210165/pipsqueak-ssh-private-key.png)

We also need to need to add our `GIGALIXIR_USERNAME` and `GIGALIXIR_PASSWORD` as secrets in the same way we added the `SSH_PRIVATE_KEY`.

For now you can use the same account that you used to create the app, but in the future you should create a separate user for added security.

We can now configure the `gigalixir-action` to deploy our code.

```yaml
{% raw %}# .github/workflows/verify.yml

jobs: 
  verify:
    ...

  deploy:
    # only run this job if the verify job succeeds
    needs: verify

    # only run this job if the workflow is running on the master branch
    if: github.ref == 'refs/heads/master'

    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v2
        
        # actions/checkout@v2 only checks out the latest commit,
        # so we need to tell it to check out the entire master branch
        with:
          ref: master
          fetch-depth: 0

      # configure the gigalixir-actions with our credentials and app name
      - uses: mhanberg/gigalixir-action@v0.1.0
        with:
          GIGALIXIR_USERNAME: ${{ secrets.GIGALIXIR_USERNAME }}
          GIGALIXIR_PASSWORD: ${{ secrets.GIGALIXIR_PASSWORD }}
          GIGALIXIR_APP: <your app name>
          SSH_PRIVATE_KEY: ${{ secrets.SSH_PRIVATE_KEY }}{% endraw %}
```

Now all we have to do is commit and push our code!

```shell
$ git add . && git commit -m "Automatically deploy to Gigalixir"
```

## What's next?

Now there's nothing holding you back from moving forward with your next project 😄.

If this article has helped you deploy your latest project, please [let me know](https://twitter.com/mitchhanberg) on Twitter!
