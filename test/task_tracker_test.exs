defmodule TaskTrackerTest do
  use ExUnit.Case
  doctest TaskTracker

  test "greets the world" do
    assert TaskTracker.hello() == :world
  end
end
