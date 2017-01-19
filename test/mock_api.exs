defmodule Napper.MockAPI do

  alias Napper.{Transform, Error}
  alias TestResource.{App, Dyno}

  @myapp %App{
    id: "app-uuid",
    name: "myapp",
    created_at: {{2012, 1, 1}, {12, 0, 0}}
  }

  @mydyno %Dyno{
    id: "dyno-uuid",
    name: "mydyno",
    app: @myapp,
    created_at: {{2012, 1, 1}, {12, 0, 0}}
  }

  def get(_client, "/apps") do
    Transform.encode! [@myapp]
  end
  def get(client, "/apps/no-such-app") do
    %Error{code: 404, message: "Resource not found", url: "#{client.base_url}#{App.endpoint_url}"}
  end
  def get(_client, "/apps/myapp/dynos") do
    Transform.encode! [@mydyno]
  end
  def get(_client, "/apps/myapp/dynos/" <> dyno_name) do
    Transform.encode! %Dyno{@mydyno | name: dyno_name}
  end
  def get(_client, "/apps/" <> app_name) do
    Transform.encode! %App{@myapp | name: app_name}
  end
end
