defmodule PrEEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :preex,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: [
        main: "PrEEx.Engine"
      ],
      package: [
        description: "An EEx engine optimized for preformatted text",
        licenses: ["MIT"],
        links: %{"GitHub" => "https://github.com/schrockwell/preex"}
      ],
      name: "PrEEx",
      source_url: "https://github.com/schrockwell/preex"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:mix_test_watch, "~> 1.2", only: :dev, runtime: false},
      {:ex_doc, "~> 0.32", only: :dev, runtime: false}
    ]
  end
end
