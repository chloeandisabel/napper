defmodule Napper.API do
  @moduledoc """
  Functions that implement HTTP methods. Used by `Napper` functions. They all
  take a `Napper` struct as their first argument.

  All of these functions return either JSON or a `Napper.Error` struct. The
  caller needs to be able to handle either kind of response.
  """

  alias Napper.Error
  alias HTTPoison.{Response, AsyncResponse}

  @type httpfunc2 :: (String.t(), map -> Response.t() | AsyncResponse.t())
  @type httpfunc3 :: (String.t(), String.t(), map -> Response.t() | AsyncResponse.t())

  @doc """
  Performs a GET request to the REST API and returns the result body.
  Returns a `Napper.Error` if the API signals an error.
  """
  @spec get(Napper.t(), String.t()) :: String.t() | Error.t()
  def get(client, path) do
    call_method(client, path, &HTTPoison.get!/2)
  end

  @doc """
  Performs a PATCH request to the HireFire API and returns the result body.
  Returns a `Napper.Error` if the API signals an error.
  """
  @spec patch(Napper.t(), String.t(), String.t()) :: String.t() | Error.t()
  def patch(client, path, body) do
    call_method(client, path, body, &HTTPoison.patch!/3)
  end

  @doc """
  Performs a POST request to the HireFire API and returns the result body.
  Returns a `Napper.Error` if the API signals an error.
  """
  @spec post(Napper.t(), String.t(), String.t()) :: String.t() | Error.t()
  def post(client, path, body) do
    call_method(client, path, body, &HTTPoison.post!/3)
  end

  @doc """
  Performs a DELETE request to the HireFire API and returns the result body.
  Returns a `Napper.Error` if the API signals an error.
  """
  @spec delete(Napper.t(), String.t()) :: String.t() | Error.t()
  def delete(client, path) do
    call_method(client, path, &HTTPoison.delete!/2)
  end

  @doc """
  Performs a HEAD request to the HireFire API and returns the result body.
  Returns a `Napper.Error` if the API signals an error.
  """
  @spec head(Napper.t(), String.t()) :: String.t() | Error.t()
  def head(client, path) do
    call_method(client, path, &HTTPoison.head!/2)
  end

  @spec call_method(Napper.t(), String.t(), httpfunc2) :: String.t() | Error.t()
  defp call_method(client, path, f) do
    url = "#{client.base_url}#{path}"

    f.(url, headers(client))
    |> body_or_error(url)
  end

  @spec call_method(Napper.t(), String.t(), String.t(), httpfunc3) :: String.t() | Error.t()
  defp call_method(client, path, body, f) do
    url = "#{client.base_url}#{path}"
    f.(url, body, headers(client)) |> body_or_error(url)
  end

  @spec body_or_error(Response.t(), String.t()) :: String.t() | Error.t()
  defp body_or_error(%Response{status_code: c} = r, _) when c < 400 do
    r.body
  end

  defp body_or_error(%Response{status_code: c} = r, url) do
    %Error{code: c, message: r.body, url: url}
  end

  @spec headers(Napper.t()) :: map
  defp headers(client) do
    hs = %{
      Accept: client.accept,
      "Content-Type": "application/json",
      "User-Agent": "#{Mix.Project.config()[:app]}/#{Mix.Project.config()[:version]}"
    }

    auth = Map.get(client, :auth)

    if auth do
      Map.put(hs, "Authorization", auth)
    else
      hs
    end
  end
end
