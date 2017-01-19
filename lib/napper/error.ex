defmodule Napper.Error do
  @moduledoc """
  API error response.
  """
  
  defstruct code: 0,
    message: "",
    url: ""

  @type t :: %__MODULE__{
    code: integer,
    message: String.t,
    url: String.t
  }
end
