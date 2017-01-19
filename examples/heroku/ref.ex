defmodule Heroku.Ref do
  @moduledoc """
  Heroku id/name reference structure.
  """
  
  @derive [Poison.Encoder]
  
  defstruct id: "", name: ""

  @type t :: Heroku.Ref{id: String.t, name: String.t}
end
