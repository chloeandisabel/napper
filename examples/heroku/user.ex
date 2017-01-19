defmodule Heroku.User do
  @moduledoc """
  Heroku id/name reference structure.
  """
  
  @derive [Poison.Encoder]
  
  defstruct id: "", email: "", full_name: nil

  @type t :: Heroku.User{id: String.t, email: String.t, full_name: String.t}
end
