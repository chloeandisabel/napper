defmodule Napper.Resource do
  @moduledoc """
  Provides functions that call the Napper `list`, `get`, `create`, `update`,
  and `delete` functions by passing in the module that uses this one.

  After defining a module that uses this one, instead of having to call
  `Napper.list(client, MyModule)` you can call `MyModule.list(client)`.

  ## Options

     * `:only` - A list of atoms specifying which functions to define.
     * `:except` - A list of atoms specifying which functions to exclude.

     `:except` is processed first: a function name that is in an `:except`
     list will not be defined even if it is in the `:only` list.

  ## Using

      defmodule MyModule do
        use Napper.Resource, only: [:list, :get]
      end

      MyModule.list(client)
  """

  @resource_funcs [
    {:list, &__MODULE__.def_list/0},
    {:get, &__MODULE__.def_get/0},
    {:create, &__MODULE__.def_create/0},
    {:update, &__MODULE__.def_update/0},
    {:delete, &__MODULE__.def_delete/0}
  ]

  defmacro __using__(opts) do
    onlies = Keyword.get(opts, :only)
    exceptions = Keyword.get(opts, :except)

    @resource_funcs
    |> Enum.filter(fn {a, _} -> should_define?(onlies, exceptions, a) end)
    |> Enum.map(fn {_, f} -> f.() end)
  end

  def def_list do
    quote do
      def list(client), do: Napper.list(client, __MODULE__)
      def list(client, params), do: Napper.list(client, __MODULE__, params)
    end
  end

  def def_get do
    quote do
      def get(client, id_or_params), do: Napper.get(client, __MODULE__, id_or_params)
    end
  end

  def def_create do
    quote do
      def create(client, data), do: Napper.create(client, __MODULE__, data)
    end
  end

  def def_update do
    quote do
      def update(client, data), do: Napper.update(client, __MODULE__, data)
      def update(client, id, data), do: Napper.update(client, __MODULE__, id, data)
    end
  end

  def def_delete do
    quote do
      def delete(client, id), do: Napper.delete(client, __MODULE__, id)
    end
  end

  defp should_define?(onlies, exceptions, atom) do
    cond do
      exceptions && exceptions |> Enum.member?(atom) -> false
      onlies && !(onlies |> Enum.member?(atom)) -> false
      true -> true
    end
  end
end
