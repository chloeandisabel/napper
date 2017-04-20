defmodule Napper.ResourceTest do
  use ExUnit.Case
  doctest Napper.Resource

  test "`only: [:get, :list]` works as expected" do
    fs = TestResource.App.__info__(:functions)
    assert Keyword.get_values(fs, :list) == [1, 2]
    assert fs[:get] == 2
    assert fs[:create] == nil
    assert fs[:update] == nil
    assert fs[:delete] == nil
  end

  test "`except: [:create]` works as expected" do
    fs = TestResource.Dyno.__info__(:functions)
    assert Keyword.get_values(fs, :list) == [1, 2]
    assert fs[:get] == 2
    assert fs[:create] == nil
    assert fs[:update] == 2
    assert fs[:delete] == 2
  end
end
