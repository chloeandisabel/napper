defmodule Napper.Transform do
  @moduledoc """
  Functions that help with conversion between JSON and our structs.
  """

  @datetime_regex ~r{^(\d\d\d\d)-(\d\d)-(\d\d)T(\d\d):(\d\d):(\d\d)Z$}
  @datetime_format "~4..0B-~2..0B-~2..0BT~2..0B:~2..0B:~2..0BZ"

  alias Napper.Error

  @doc """
  Given either an API response JSON string or an `Error`, either parses the
  JSON as `decode_type` and returns that struct or returns the `Error`
  struct.

  If `wrapped` is true, strips off the outer wrapper that an API has put
  around every response.

  Converts datetime strings into Erlang `date()` tuples.

  ## Examples

      iex> ~s({"a": 1, "created_at": "2016-04-01T15:16:17Z"})
      ...> |> Napper.Transform.decode!(%{}, false)
      %{"a" => 1, "created_at" => {{2016, 4, 1}, {15, 16, 17}}}

      iex> ~s({"thing": {"a": 1, "inner": {"created_at": "2016-04-01T15:16:17Z", "dinner_time": "2016-04-01T15:16:17Z"}}})
      ...> |> Napper.Transform.decode!(%{}, true)
      %{"a" => 1, "inner" => %{"created_at" => {{2016, 4, 1}, {15, 16, 17}}, "dinner_time" => {{2016, 4, 1}, {15, 16, 17}}}}

      iex> ~s({"a": 1, "created_at": null})
      ...> |> Napper.Transform.decode!(%{}, false)
      %{"a" => 1, "created_at" => nil}
  """
  @spec decode!(String.t | Error.t, module | Enum.t, boolean) :: map
  def decode!(%Error{} = err, _) do
    err
  end
  def decode!(body, decode_type, wrapped) do
    body
    |> remove_outer_wrapper(wrapped)
    |> Poison.decode!(as: decode_type)
    |> datetime_strings_to_timestamps
  end

  @doc """
  Given a `Napper.HireFire.*` struct, return JSON.

  Converts Erlang `date()` tuples into strings.
  """
  @spec encode!(map) :: String.t
  def encode!(data) do
    data |> timestamps_to_datetime_strings |> Poison.encode!
  end

  # ================ Private helpers ================

  defp remove_outer_wrapper(s, false), do: s
  defp remove_outer_wrapper(s, true) do
    s |> String.replace(~r{^{"\w+":\s*}, "") |> String.replace(~r/\s*}$/, "")
  end

  defp datetime_strings_to_timestamps(data) do
    data |> transform(fn
      (_key, nil) ->
        nil
      (_key, val) ->
        matches = Regex.run(@datetime_regex, val)
        if matches do
          [_ | ts_strs] = matches
          [y, m, d, h, n, s] = ts_strs |> Enum.map(&String.to_integer/1)
          {{y, m, d}, {h, n, s}}
        else
          val
        end
    end)
  end

  defp timestamps_to_datetime_strings(data) do
    data |> transform(fn
      (_, {{y, m, d}, {h, n, s}}) ->
        :io_lib.format(@datetime_format, [y, m, d, h, n, s])
        |> IO.iodata_to_binary
      (_, val) ->
        val
    end)
  end

  # Updates a map or list of maps by calling `f` on each datetime value
  # (keys that end with "_at" or "_time"). `f` must take two arguments: key
  # and value. Works recursively.
  defp transform(data, f) when is_list(data) do
    data |> Enum.map(&(transform(&1, f)))
  end
  defp transform(data, f) do
    data
    |> Map.keys
    |> Enum.reduce(data, fn(k, m) ->
      v = Map.get(m, k)
      cond do
        datetime_key?(k) ->
          Map.update!(m, k, &(f.(k, &1)))
        is_map(v) ->
          Map.update!(m, k, &(transform(&1, f)))
        true ->
          m
      end
    end)
  end

  # Returns true if `key`, when converted to a string, ends in "_at" or
  # "_time".
  defp datetime_key?(key) do
    s = key |> to_string
    String.ends_with?(s, "_at") || String.ends_with?(s, "_time")
  end
end
