defmodule Kino.YouTube do
  @moduledoc """
  A widget embedding a YouTube video.

  ## Examples

      Kino.YouTube.new("2OHFgjuy3DI")
  """

  use Kino.JS

  @type t :: Kino.JS.t()

  @doc """
  Creates a new video widget.
  """
  @spec new(String.t()) :: t()
  def new(video_id) when is_binary(video_id) do
    Kino.JS.new(__MODULE__, video_id)
  end

  asset "main.js" do
    """
    export function init(ctx, videoId) {
      ctx.importCSS("./main.css");

      ctx.root.innerHTML = `
        <div class="root">
          <iframe width="560" height="315"
            src="https://www.youtube.com/embed/${videoId}"
            frameborder="0"
            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen>
          </iframe>
        </div>
      `;
    }
    """
  end

  asset "main.css" do
    """
    .root {
      display: flex;
      justify-content: center;
    }
    """
  end
end
