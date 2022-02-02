defmodule Kino.CameraProcessor do
  @moduledoc """
  A widget for processing feed from the web camera.

  Frames are provided as binary PNG images and processed with
  the given function. The widget displays live camera feed as
  well as the processed frames.

  This widget supports multiple users by displaying all of the
  feeds at once.

  ## Examples

  We can verify the camera works by providing an empty processor:

      Kino.CameraProcessor.new(fn binary -> binary end)

  This widget is primarily useful when working on image processing,
  which usually involves an external library. Below is a simple
  example using `Evision`:

      alias Evision, as: CV

      Kino.CameraProcessor.new(fn binary ->
        binary
        |> CV.imdecode!(CV.cv_IMREAD_UNCHANGED())
        |> CV.cvtColor!(CV.cv_COLOR_BGR2GRAY())
        |> CV.blur!([10, 10])
        |> then(&CV.imencode!(".png", &1))
        |> IO.iodata_to_binary()
      end)
  """

  use Kino.JS, assets_path: "lib/assets/camera_processor"
  use Kino.JS.Live

  @type t :: Kino.JS.Live.t()

  @doc """
  Creates a new camera processor widget.

  Expects a function that synchronously processes a binary image
  in the PNG format.

  ## Options

    * `:max_fps` - the upper limit on processed frames per second
  """
  @spec new((binary() -> binary()), keyword()) :: t()
  def new(process_fun, opts \\ []) when is_function(process_fun, 1) and is_list(opts) do
    opts = Keyword.validate!(opts, max_fps: 30)
    Kino.JS.Live.new(__MODULE__, {process_fun, opts[:max_fps]})
  end

  @impl true
  def init({process_fun, max_fps}, ctx) do
    {:ok, assign(ctx, process_fun: process_fun, max_fps: max_fps, clients: [])}
  end

  @impl true
  def handle_connect(ctx) do
    client_id = random_id()

    info = %{
      client_id: client_id,
      clients: ctx.assigns.clients,
      max_fps: ctx.assigns.max_fps
    }

    broadcast_event(ctx, "client_join", %{client_id: client_id})

    {:ok, info, update(ctx, :clients, &(&1 ++ [client_id]))}
  end

  @impl true
  def handle_event("frame", %{"data" => data, "client_id" => client_id}, ctx) do
    # Don't send the original data if there's only a single client
    original = if length(ctx.assigns.clients) == 1, do: nil, else: data

    processed =
      data
      |> Base.decode64!()
      |> ctx.assigns.process_fun.()
      |> Base.encode64()

    broadcast_event(ctx, "frame", %{
      client_id: client_id,
      original: original,
      processed: processed
    })

    {:noreply, ctx}
  end

  defp random_id() do
    :crypto.strong_rand_bytes(5) |> Base.encode32(case: :lower)
  end
end
