defmodule Napper do
  @moduledoc """
  Napper is a JSON REST API client.

  It defines a struct that describes the API connection (URL, auth key, and
  such) and a standard list of REST methods: list, get, create, update, and
  delete.
  """

  @api_module Application.get_env(:napper, :api, Napper.API)
  @default_accept_header "application/json"

  alias Napper.{Endpoint, Transform}

  defstruct base_url: nil,
            accept: @default_accept_header,
            auth: nil,
            api: Napper.API,
            master_id: nil,
            master_prefix: nil,
            remove_wrapper: false

  @type t :: %Napper{
          base_url: String.t(),
          accept: String.t(),
          auth: String.t(),
          api: module,
          master_id: String.t(),
          master_prefix: String.t(),
          remove_wrapper: boolean
        }

  # ================ Client creation ================

  @doc """
  Returns a client struct that can be used for further requests to an
  API. The client contains information needed to connect.

  The client struct also optionally contains an id string and a request
  prefix which will be used to retrieve resources that are owned by some
  other "master" resource. For example, many of the resources in Heroku's
  API are owned by an application, so storing a prefix of "/apps" and an id
  that identifies the application and can be used to build URLs for the
  resources owned by the app.

  To retrieve app resources from a different master resource, create a new
  client containing the other master id, or simply replace the id in the
  client you have. (Of course, since Elixir is immutable under the hood,
  you're really creating a new client struct anyway.) See the example below.

  ## Configuration

      config :my_app, Napper,
        url: "https://api.example.com",
        auth: "Token some-long-token-value",
        accept: "application/json",
        master_prefix: "/app",
        master_id: "our-application-id",
        remove_wrapper: true

  ## Options

     These options can be passed in to `Napper.api_client/1` or defined in
     the config file. Any values passed in override the config values.

     * `:url` - The base URL of the API. Must not end in a "/". This is the
       only required config value or parameter.

     * `:auth` - The value of the "Authorization" HTTP header, if needed.

     * `:accept` - The value of the "Accept" HTTP header, if needed. If is
       not passed in, the string "application/json" is used.

     * `:master_id` - A master resource name or id string.

     * `:master_prefix` - A master resource URL prefix such as "/apps".

     * `:remove_wrapper` - Some APIs wrap responses in an outer wrapper. For
       example, HireFire returns applications as JSON like `{"applications:
       [...]}`. Setting `:remove_wrapper` to `true` tells Napper to remove
       the outer object and return whatever is inside (in this case, the
       array).

  ## Examples

     (The API module is set to `Napper.MockAPI` in these examples because
     that's what is used in the test environment when these examples are run
     as tests.)

     iex> Napper.api_client(url: "https://api.example.com")
     %Napper{accept: "application/json", api: Napper.MockAPI, auth: nil,
             base_url: "https://api.example.com", master_id: nil,
             master_prefix: nil}

     Here's an example of building a client struct for another master
     resource, given an existing client struct.

     iex> client = Napper.api_client(url: "https://api.example.com")
     ...> client = %{client | master_prefix: "/apps", master_id: "some-uuid"}
     ...> client
     %Napper{accept: "application/json", api: Napper.MockAPI, auth: nil,
             base_url: "https://api.example.com", master_id: "some-uuid",
             master_prefix: "/apps"}
  """
  @spec api_client(Keyword.t()) :: t
  def api_client(options \\ []) do
    base_url = config(:url, options)
    if base_url == nil, do: raise("missing :url")

    %Napper{
      base_url: base_url,
      accept: config(:accept, options) || @default_accept_header,
      auth: config(:auth, options),
      api: @api_module,
      master_id: config(:master_id, options),
      master_prefix: config(:master_prefix, options),
      remove_wrapper: config(:remove_wrapper, options) || false
    }
  end

  # ================ Napper.Endpoint REST calls ================

  @doc """
  Gets a list of resources.
  """
  @spec list(t, module) :: [map]
  def list(client, module) do
    client
    |> client.api.get(url_for(client, module))
    |> Transform.decode!([struct(module)], client.remove_wrapper)
  end

  @doc """
  Gets a list of resources, given a map of GET params.
  """
  @spec list(t, module, map) :: [map]
  def list(client, module, params) do
    client
    |> client.api.get(url_for(client, module, params))
    |> Transform.decode!([struct(module)], client.remove_wrapper)
  end

  @doc """
  Gets a single resource, given an id string or a map of GET params.
  """
  @spec get(t, module, String.t() | map) :: map
  def get(client, module, id) when is_binary(id) do
    client
    |> client.api.get(url_for(client, module, id))
    |> Transform.decode!(struct(module), client.remove_wrapper)
  end

  def get(client, module, params) when is_map(params) do
    client
    |> client.api.get(url_for(client, module, params))
    |> Transform.decode!(struct(module), client.remove_wrapper)
  end

  @doc """
  Creates a resource.
  """
  @spec create(t, module, map) :: map
  def create(client, module, data) do
    client
    |> client.api.post(url_for(client, module), Transform.encode!(data))
    |> Transform.decode!(struct(module), client.remove_wrapper)
  end

  @doc """
  Updates a resource.
  """
  @spec update(t, module, map) :: map
  def update(client, module, data) do
    client
    |> client.api.patch(url_for(client, module), Transform.encode!(data))
    |> Transform.decode!(struct(module), client.remove_wrapper)
  end

  @doc """
  Updates a resource, given an id.
  """
  @spec update(t, module, String.t(), map) :: map
  def update(client, module, id, data) do
    client
    |> client.api.patch(url_for(client, module, id), Transform.encode!(data))
    |> Transform.decode!(struct(module), client.remove_wrapper)
  end

  @doc """
  Deletes a resource.
  """
  @spec delete(t, module, String.t()) :: map
  def delete(client, module, id) do
    client
    |> client.api.delete(url_for(client, module, id))
    |> Transform.decode!(struct(module), client.remove_wrapper)
  end

  # ================ Private helpers ================

  @spec config(atom, map) :: String.t() | nil
  defp config(key, options) do
    Keyword.get(options, key) || Application.get_env(:napper, key)
  end

  @spec url_for(t, module, String.t() | map) :: String.t()
  defp url_for(client, module, id) when is_binary(id) do
    url_for(client, module) <> "/#{id}"
  end

  defp url_for(client, module, params) when is_map(params) do
    url_for(client, module) <> "?#{URI.encode_query(params)}"
  end

  @spec url_for(t, module) :: String.t()
  defp url_for(client, module) do
    s = struct(module)
    url = Endpoint.endpoint_url(s)

    if Endpoint.under_master_resource?(s) do
      "#{client.master_prefix}/#{client.master_id}#{url}"
    else
      url
    end
  end
end
