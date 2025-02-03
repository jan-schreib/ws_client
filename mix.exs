defmodule WsClient.MixProject do
  use Mix.Project

  def project do
    [
      app: :ws_client,
      version: "0.3.1",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      name: "WsClient",
      docs: [
        main: "WsClient",
        extras: ["README.md"]
      ],
      source_url: "https://github.com/jan-schreib/ws_client"
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp description do
    "A websocket client that uses websocat."
  end

  defp package do
    [
      maintainers: ["Jan Schreiber"],
      licenses: ["ISC"],
      links: %{"Github" => "https://github.com/jan-schreib/ws_client"}
    ]
  end
end
