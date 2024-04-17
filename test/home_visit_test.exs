defmodule HomeVisitTest do
  use ExUnit.Case
  doctest HomeVisit

  test "greets the world" do
    assert HomeVisit.hello() == :world
  end
end
