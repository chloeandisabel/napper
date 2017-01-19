defmodule Heroku.Dyno do
  @moduledoc """
  Heroku Dyno.
  """
  
  alias Heroku.{Ref, Release}
  use Napper.Resource

  @derive [Poison.Encoder]
  
  defstruct id: "",
    attach_url: nil,
    command: "",
    name: "",
    app: %Ref{},
    release: %Release{},
    size: "",
    state: "",
    type: "",
    created_at: nil,
    updated_at: nil

  @type t :: %__MODULE__{
    id: String.t,
    attach_url: String.t,
    command: String.t,
    name: String.t,
    app: Ref.t,
    release: Release.t,
    size: String.t,
    state: String.t,
    type: String.t,
    created_at: String.t,
    updated_at: String.t
  }

  @spec restart(t, String.t) :: :ok
  def restart(client, id_or_name) do
    client
    |> client.api.delete("/apps/#{client.app.name}/dynos/#{id_or_name}")
    :ok                         # TODO handle error return codes
  end

  @spec restart_all(t) :: :ok
  def restart_all(client) do
    client
    |> client.api.delete("/apps/#{client.app.name}/dynos")
    :ok                         # TODO handle error return codes
  end
end

defimpl Napper.Endpoint, for: Heroku.Dyno do
  def under_master_resource?(_), do: true
  def endpoint_url(_), do: "/dynos"
end
