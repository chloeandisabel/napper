defprotocol Napper.Endpoint do
  @moduledoc """
  This protocol defines two methods that together determine the URL for a
  resource.
  """

  @type t :: Napper.Endpoint.t

  @doc """
  Returns `true` if the endpoint's URL is under
  "<master-prefix>/<master-id>". That is, when generating a URL for this
  resource the full URL path will be prefixed by that string if this
  function returns `true`.
  """
  @spec under_master_resource?(t) :: boolean
  def under_master_resource?(struct)

  @doc """
  Returns the endpoint URL path for all get/post/etc. requests to the API
  for the resource that implements this protocol. Must return a string
  beginning with "/".

  If `under_master_resource?` returns `true` then the full URL path will be
  "/<master-prefix>/<master-id><endpoint-url>", where master-id is the
  `master` value stored in the `Napper` client struct.
  """
  @spec endpoint_url(t) :: String.t
  def endpoint_url(struct)
end
