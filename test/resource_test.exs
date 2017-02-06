defmodule Napper.ResourceTest do
  use ExUnit.Case
  doctest Napper.Resource

  test "`only: [:get, :list]` works as expected" do
    assert TestResource.App.__info__(:functions)[:list] == 1
    assert TestResource.App.__info__(:functions)[:get] == 2
    assert TestResource.App.__info__(:functions)[:create] == nil
    assert TestResource.App.__info__(:functions)[:update] == nil
    assert TestResource.App.__info__(:functions)[:delete] == nil
  end

  test "`except: [:create]` works as expected" do
    assert TestResource.Dyno.__info__(:functions)[:list] == 1
    assert TestResource.Dyno.__info__(:functions)[:get] == 2
    assert TestResource.Dyno.__info__(:functions)[:create] == nil
    assert TestResource.Dyno.__info__(:functions)[:update] == 2
    assert TestResource.Dyno.__info__(:functions)[:delete] == 2
  end
end
