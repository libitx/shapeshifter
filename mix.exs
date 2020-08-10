defmodule Shapeshifter.MixProject do
  use Mix.Project

  def project do
    [
      app: :shapeshifter,
      version: "0.1.0",
      elixir: "~> 1.10",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "Shapeshifter",
      description: "Shapeshifter lets you quickly and simply switch between Bitcoin transaction formats.",
      source_url: "https://github.com/libitx/shapeshifter",
      docs: [
        main: "Shapeshifter"
      ],
      package: [
        name: "shapeshifter",
        files: ~w(lib .formatter.exs mix.exs README.md LICENSE),
        licenses: ["Apache-2.0"],
        links: %{
          "GitHub" => "https://github.com/libitx/shapeshifter"
        }
      ]
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
      {:bsv, "~> 0.2.6"},
      {:ex_doc, "~> 0.22", only: :dev, runtime: false}
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
