defmodule Heroku.App do
  @moduledoc """
  Heroku Application.
  """

  alias Heroku.{Ref, User}
  use Napper.Resource

  @derive [Poison.Encoder]

  defstruct id: "",
    name: "app",
    buildpack_provided_description: "",
    build_stack: %Ref{},
    git_url: "",
    maintenance: false,
    owner: %User{},
    region: %Ref{},
    repo_size: 0,
    slug_size: 0,
    space: %Ref{},
    stack: %Ref{},
    web_url: "",
    released_at: nil,
    archived_at: nil,
    created_at: nil,
    updated_at: nil

  @type t :: %__MODULE__{
    id: String.t,
    name: String.t,
    buildpack_provided_description: String.t,
    build_stack: Ref.t,
    git_url: String.t,
    maintenance: false,
    owner: User.t,
    region: Ref.t,
    repo_size: integer,
    slug_size: integer,
    space: Ref.t,
    stack: Ref.t,
    web_url: String.t,
    released_at: String.t,
    archived_at: String.t,
    created_at: String.t,
    updated_at: String.t
  }
end

defimpl Napper.Endpoint, for: Heroku.App do
  def under_master_resource?(_), do: false
  def endpoint_url(_), do: "/apps"
end
