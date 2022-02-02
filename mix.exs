defmodule KinoLab.MixProject do
  use Mix.Project

  @version "0.1.0-dev"

  def project do
    [
      app: :kino_lab,
      version: @version,
      elixir: "~> 1.13",
      deps: deps(),
      docs: docs()
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:kino, "~> 0.5.0"},
      {:ex_doc, "~> 0.24", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      main: "examples",
      source_url: "https://github.com/jonatanklosko/kino_lab",
      source_ref: "main",
      extras: [
        {:"notebooks/examples.livemd", [title: "Examples"]}
      ]
    ]
  end
end
