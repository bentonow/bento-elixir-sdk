defmodule BentoSdkTest do
  use ExUnit.Case
  doctest BentoSdk

  import Mox

  # Make sure mocks are verified when the test exits
  setup :verify_on_exit!
end
