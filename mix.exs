defmodule BentoSdk.MixProject do
  use Mix.Project

  def project do
    [
      app: :bento_sdk,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      name: "BentoSdk",
      source_url: "https://github.com/abradburne/bento_elixir_sdk"
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
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/abradburne/bento_elixir_sdk"}
    ]
  end
end
