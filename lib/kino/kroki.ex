defmodule Kino.Kroki do
  @moduledoc ~S'''
  A widget rendering various diagram types using the
  [Kroki](https://kroki.io) API.

  ## Examples

      Kino.Kroki.nwdiag("""
      nwdiag {
        network dmz {
          address = "210.x.x.x/24"

          web01 [address = "210.x.x.1"];
          web02 [address = "210.x.x.2"];
        }
        network internal {
          address = "172.x.x.x/24";

          web01 [address = "172.x.x.1"];
          web02 [address = "172.x.x.2"];
          db01;
          db02;
        }
      }
      """)
  '''

  use Kino.JS

  @type t :: Kino.JS.t()

  @types ~w(
    actdiag blockdiag bpmn bytefield c4withplantuml ditaa erd excalidraw
    graphviz mermaid nomnoml nwdiag packetdiag pikchr plantuml rackdiag
    seqdiag svgbob umlet vega vegalite wavedrom
  )a

  for type <- @types do
    @doc """
    Creates a new #{type} graph.
    """
    @spec unquote(type)(String.t()) :: t()
    def unquote(type)(graph) do
      new(unquote(type), graph)
    end
  end

  defp new(type, graph) do
    Kino.JS.new(__MODULE__, %{type: type, graph: graph})
  end

  asset "main.js" do
    """
    export function init(ctx, { type, graph }) {
      fetch(`https://kroki.io/${type}/svg`, {
        method: "POST",
        headers: {
          "content-type": "text/plain",
        },
        body: graph,
      })
      .then((resp) => resp.text())
      .then((svg) => {
        ctx.root.innerHTML = svg;
      });
    }
    """
  end
end
