defmodule Napper.Mixfile do
  use Mix.Project

  def project do
    [app: :napper,
     version: "1.0.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),

     # for docs
     name: "Napper",
     source_url: "https://github.com/chloeandisabel/napper",
     homepage_url: "https://github.com/chloeandisabel/napper",
     docs: [main: "readme",
            # logo: "",
            extras: ["README.md"]]]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :httpoison],
     env: [{:api, Napper.API}]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:httpoison, "~> 0.10.0"},
     {:poison, "~> 2.0"},
     {:ex_doc, "~> 0.14", only: :dev}]
  end
end
