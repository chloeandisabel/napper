# Napper

Napper is a REST API client written in [Elixir](http://elixir-lang.org/).

Napper lets you define structs for resources exposed by an API, and it
defines the functions `list/2`, `get/3`, `create/3`, `update/3`, and
`delete/3` for your modules.

## Installation

The package can be installed by adding Napper to your list of dependencies
in `mix.exs`:

```elixir
def deps do
  [{:napper, git: "https://github.com/chloeandisabel/napper.git"}]
end
```

## Configuration

See "Options" below for an explanation of each of the config values.

```elixir
config :napper,
  url: "https://api.example.com",
  auth: "Token some-long-token-value",
  accept: "application/json",
  master_prefix: "/master",
  master_id: "our-master-id",
  remove_wrapper: false,
  api: Napper.API
```

An example for Heroku:

```elixir
config :napper,
  url: "https://api.heroku.com",
  auth: "Bearer #{System.get_env("HEROKU_API_KEY")}",
  accept: "application/vnd.heroku+json; version=3",
  master_prefix: "/apps",
  master_id: "some-app-name"
```

An example for HireFire:

```elixir
config :napper,
  url: "https://api.hirefire.io",
  auth: "Token #{System.get_env("HIREFIRE_API_KEY")}",
  accept: "application/vnd.hirefire.v1+json",
  remove_wrapper: true
```

## Options

These options can be passed in to `Napper.api_client/1` or defined in the
config file. Any values passed in to `api_client/1` override the config
values.

* `:url` - The base URL of the API. Must not end in "/". This is the only
  required config value or parameter.

* `:auth` - The value of the "Authorization" HTTP header, if needed.

* `:accept` - The value of the "Accept" HTTP header, if needed. If is
  not passed in, the string "application/json" is used.

* `:master_id` - A master resource name or id string. See below for a
  discussion of master resources.

* `:master_prefix` - A master resource URL prefix such as "/apps".

* `:remove_wrapper` - Some APIs wrap responses in an outer wrapper. For
  example, HireFire returns applications as JSON like `{"applications:
  [...]}`. Setting `:remove_wrapper` to `true` tells Napper to remove the
  outer object and return whatever is inside (in this case, the array).

* `:api` - The API module that actually makes the get/patch/post/etc. calls.
  Allowing this to be configured lets us specify a mock API module to use
  during testing. The default is `Napper.API`.

## Defining Resources

See the `examples` subdirectory for a sample Heroku configuration and some
resource definitions. As a bonus, the `Dyno` module contains a few functions
specific to Heroku dyno endpoints.

A REST resource is defined as an Elixir struct. Let's look at a simple
example.

```elixir
defmodule SomeAPI.Thing do
  use Napper.Resource
  @derive [Poison.Encoder]
  defstruct ...
  @type t :: %__MODULE___{...}
end

defimpl Napper.Endpoint, for: SomeAPI.Thing do
  def under_master_resource?(_), do: false
  def endpoint_url(_), do: "/thing"
end
```

`use Napper.Resource` defines the `list/2`, `get/3`, `create/3`, and
`update/3`, functions for this module. Optional `:only` and `:except`
options let you specify which funtions you want.

By deriving from `Poison.Encoder`, `Napper` can turn your struct into JSON
to send to the API.

`Napper.Endpoint` is a protocol that defines two functions.
`under_master_resource?` determines if this resource is "under" another. For
example, the Heroku Dyno type is under an App. `endpoint_url` is the REST
API path. If the resource is under the master, then the full path will be
"/master-path/master-id/thing".

A simple struct like Heroku's `Ref` does not have its own endpoint.
Therefore it doesn't need to use `Napper.Resource` or define a protocol
implementation for `Napper.Endpoint`.

## Using Napper

First we create a client. In this example, we'll assume we have configured
everything we need to in the config file.

```elixir
iex> client = Napper.api_client()
```

`api_client/1` returns a `Napper.t` struct. The `url` is the only required
value.

### Master Resource

The client struct also optionally contains an id string and a request prefix
which will be used to retrieve resources that are owned by some other
"master" resource. For example, many of the resources in Heroku's API are
owned by an application, so storing a prefix of "/apps" and an id that
identifies the application and can be used to build URLs for the resources
owned by the app. Since the client is a struct, it's easy to switch the
master resource by specifying another id and/or prefix.

## Using the Client

These examples are written as if the modules in the `examples/heroku`
directory were in `lib/heroku`. They won't work if you just fire up `iex -S
mix` because Napper isn't tied to any one API.

What applications do we have?

```elixir
iex> client |> Napper.Heroku.App.list
#=> [%Napper.Heroku.App{...}]
```

What dynos does the "some-app-name" application have? (The app name is
assumed to be defined in the config file or shoved into the client.)

```elixir
iex> ds = client |> Napper.Heroku.Dyno.list
#=> [%Napper.Heroku.Dyno{...}]
```

Note that we didn't have to pass in the app name or id because it's already
stored in the client in the `:master_id` field.

Let's fetch a particular dyno.

```elixir
iex> d = client |> Napper.Heroku.Dyno.get("my_dyno_name.1")
#=> %Napper.Heroku.Dyno{...}
```

How many dynos do we have of each dyno type? We use our `Dyno` module here
and `Enum.reduce/3`. You'd probably want to use Heroku's `Formation`
resource instead, which contains each type's count.

```elixir
iex> client |> Napper.Heroku.Dyno.list |> Enum.reduce(%{}, fn d, m ->
...>   Map.put(m, d.type, Map.get(m, d.type, 0) + 1)
...> end
#=> %{"web" => 2, "schedule_workers" => 2, "others" => 5}
```

## Low-Level Queries

Heroku's API limits the number of requests per hour. Let's find out how many
we have left:

```elixir
iex> client
...> |> client.api.get("/account/rate-limits")
...> |> Poison.decode!
...> |> Map.get("remaining")
#=> 2400
```

## To Do

- Use callbacks instead of Protocol for Endpoint, and define default
  implementations.
- Use DateTime instead of Erlang `date()` tuples.
