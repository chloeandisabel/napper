defmodule Heroku.Release do
  @moduledoc """
  Heroku release description.
  """
  
  defstruct id: "", version: 0

  @type t :: %__MODULE__{id: String.t, version: integer}
end
