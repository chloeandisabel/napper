# These are not good examples of resource modules. They don't use the
# `Napper.Endpoint` protocol, because at the time this code gets compiled
# it's too late.

defmodule TestResource.App do
  use Napper.Resource

  defstruct [:id, :name, :created_at]
  @type t :: %__MODULE__{id: String.t, name: String.t, created_at: tuple}

  def under_master_resource?(_), do: false
  def endpoint_url(_), do: "/apps"
end

defmodule TestResource.Dyno do
  use Napper.Resource

  defstruct [:id, :name, :app, :created_at]
  @type t :: %__MODULE__{id: String.t, name: String.t, app: App.t, created_at: tuple}

  def under_master_resource?(_), do: true
  def endpoint_url(_), do: "/dynos"
end
