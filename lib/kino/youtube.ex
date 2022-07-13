defmodule Kino.YouTube do
  @moduledoc """
  A widget embedding a YouTube video.

  ## Examples

      Kino.YouTube.new("https://www.youtube.com/watch?v=2OHFgjuy3DI")
  """

  use Kino.JS

  @type t :: Kino.JS.t()

  @doc """
  Creates a new video widget.

  ## Examples

    Provide the video URL in either `https://www.youtube.com/watch?v={id}` or
    `https://youtu.be/{id}` format.

        Kino.YouTube.new("https://www.youtu.be/2OHFgjuy3DI")

        Kino.YouTube.new("https://www.youtube.com/watch?v=2OHFgjuy3DI")

    Optionally provide a timestamp using the `t` query parameter.

        Kino.YouTube.new("https://www.youtube.com/watch?v=2OHFgjuy3DI?t=3600")
  """
  @spec new(String.t()) :: t()
  def new(video_url) when is_binary(video_url) do
    {video_id, time} = parse_url(video_url)
    Kino.JS.new(__MODULE__, %{id: video_id, time: time})
  end

  defp parse_url(url) do
    uri = URI.parse(url)
    query = URI.decode_query(uri.query || "")

    video_id =
      case {uri, query} do
        {%{host: "www.youtube.com", path: "/watch"}, %{"v" => id}} -> id
        {%{host: "www.youtu.be", path: "/" <> id}, %{}} -> id
        _ -> raise ArgumentError, "expected a YouTube URL, got: #{inspect(url)}"
      end

    time = if query["t"], do: String.to_integer(query["t"]), else: 0

    {video_id, time}
  end

  asset "main.js" do
    """
    export function init(ctx, video) {
      ctx.importCSS("./main.css");

      ctx.root.innerHTML = `
        <div class="root">
          <iframe width="560" height="315"
            src="https://www.youtube.com/embed/${video.id}?start=${video.time}"
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
