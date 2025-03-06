defmodule BentoSdk.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/abradburne/bento-elixir-sdk"

  def project do
    [
      app: :bento_sdk,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      homepage_url: "https://bentonow.com/",
      package: package(),
      name: "BentoSDK",
      source_url: @source_url
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:httpoison, "~> 2.0"},
      {:jason, "~> 1.4"},
      {:ex_doc, "~> 0.29", only: :dev, runtime: false},
      {:mox, "~> 1.0", only: :test}
    ]
  end

  defp description do
    """
    A client SDK for the Bento marketing platform (bentonow.com).
    """
  end

  defp package do
    [
      name: "bento_sdk",
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Documentation" => "https://hexdocs.pm/bento_sdk"
      },
      maintainers: ["Alan Bradburne"],
      files: ~w(lib mix.exs README.md LICENSE.md CHANGELOG.md)
    ]
  end
end
