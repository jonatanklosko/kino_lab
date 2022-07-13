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
  def new(video_url) when is_binary(video_url) do
    video_id = format_video_url(video_url)
    Kino.JS.new(__MODULE__, video_id)
  end

  def format_video_url(video_url) do
    video_url =
      Regex.replace(~r/\?t=(\d+)/, video_url, fn _, time ->
        "?start=#{time}"
      end)

    case video_url do
      "https://youtu.be/" <> video_id ->
        video_id

      "https://www.youtube.com/watch?v=" <> video_id ->
        video_id

      video_id ->
        video_id
    end
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
