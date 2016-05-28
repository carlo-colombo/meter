defmodule Meter.Mixfile do
  use Mix.Project

  def project do
    [app: :meter,
     version: "0.1.0",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,
     description: "Track your elixir application on google analytycs",
     name: "Meter",
     source_url: "https://github.com/carlo-colombo/Meter",
     # test_coverage: [tool: Coverex.Task, coveralls: true],
     docs: [
       main: Meter
     ],
     package: [
       licenses: ["MIT"],
       mainteiners: ["Carlo Colombo"],
       links: %{
         "Github" => "https://github.com/carlo-colombo/meter",
         "docs" => "http://hexdocs.pm/meter"
       }
     ]]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger,
                    :httpoison]]
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
    [{:httpoison, "~> 0.8"},
     {:earmark, "~> 0.2", only: :dev},
     {:ex_doc, "~> 0.11", only: :dev},
     {:mock, "~> 0.1.1", only: :test},
     {:credo, "~> 0.3", only: [:test, :dev]}
    ]
  end
end
