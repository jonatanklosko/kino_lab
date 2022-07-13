defmodule Kino.YouTubeTest do
  use ExUnit.Case
  doctest Kino.YouTube
  alias Kino.YouTube

  test "format_video_url/1 full video url" do
    assert Kino.YouTube.format_video_url("https://www.youtube.com/watch?v=2OHFgjuy3DI") ==
             "2OHFgjuy3DI"
  end

  test "format_video_url/1 full video url with time" do
    assert Kino.YouTube.format_video_url("https://www.youtube.com/watch?v=2OHFgjuy3DI?t=10") ==
             "2OHFgjuy3DI?start=10"
  end

  test "format_video_url/1 shortened video url" do
    assert Kino.YouTube.format_video_url("https://youtu.be/2OHFgjuy3DI") ==
             "2OHFgjuy3DI"
  end

  test "format_video_url/1 shortened video url with time" do
    assert Kino.YouTube.format_video_url("https://youtu.be/2OHFgjuy3DI?t=10") ==
             "2OHFgjuy3DI?start=10"
  end

  test "format_video_url/1 video id" do
    assert Kino.YouTube.format_video_url("2OHFgjuy3DI") ==
             "2OHFgjuy3DI"
  end

  test "format_video_url/1 video id with time" do
    assert Kino.YouTube.format_video_url("2OHFgjuy3DI?t=10") ==
             "2OHFgjuy3DI?start=10"
  end
end
