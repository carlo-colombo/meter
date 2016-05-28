defmodule MeterTest do
  use ExUnit.Case
  import Mock
  import TestHelper
  alias Meter.Utils

  doctest Meter

  defp mocks, do: [post: fn (_,_) -> {:ok, :resp} end]

  test "if tid is not defined no request is made" do
    Meter.track(:fn, [arg1: 1])

    refute_receive({:track_sent})
  end

  test "send a track request to ga" do
    with_env([meter: [tid: "UA-123-1"]]) do
      with_mock HTTPoison, mocks do
        Meter.track(:fn, [arg1: 1])

        assert_receive({:track_sent, request})
        assert {:form, body} = request
        assert "UA-123-1" = body[:tid]
      end
    end
  end

  test "use the default param_generator if not set into envs" do
    with_env([meter: [tid: "UA-123-1"]]) do
      with_mock HTTPoison, mocks do
        Meter.track(:fn, [arg1: 1])

        assert_receive({:track_sent, request})
        assert {:form, body} = request
        assert body == Utils.param_generator(:fn, [arg1: 1], "UA-123-1", [], [])
      end
    end
  end

  test "use custom param_generator function" do
    defmodule Custom do
      def param_generator(_,_,_,_,_), do: [kw: "val"]
    end

    with_env([meter: [tid: "UA-123-1", param_generator: &Custom.param_generator/5]]) do
      with_mock HTTPoison, mocks do
        Meter.track(:fn, [arg1: 1])

        assert_receive({:track_sent, request})
        assert {:form, body} = request
        assert body == [kw: "val"]
      end
    end
  end

  test "defmeter macro" do
    defmodule TestMacro do
      import Meter
      defmeter function(arg1,arg2) do
        {arg1, arg2}
      end
    end

    with_env([meter: [tid: "UA-123-1"]]) do
      with_mock HTTPoison, mocks do
        assert {1, 2} == TestMacro.function(1, 2)

        assert_receive({:track_sent, request})
        assert {:form, body} = request
        assert body == Utils.param_generator(:function, [arg1: 1, arg2: 2], "UA-123-1", [], [])
      end
    end
  end

  test "use the mapping from the configuration" do
    with_env([meter: [tid: "UA-123-1", mapping: [cid: :arg1]]]) do
      with_mock HTTPoison, mocks do
        Meter.track(:fn, [arg1: 1])

        assert_receive({:track_sent, request})
        assert {:form, body} = request
        assert body == Utils.param_generator(:fn, [arg1: 1], "UA-123-1", [cid: :arg1], [])
      end
    end
  end

  test "use the custom_dimensions from the configuration" do
    with_env([meter: [tid: "UA-123-1", custom_dimensions: [:arg1]]]) do
      with_mock HTTPoison, mocks do
        Meter.track(:fn, [arg1: 1])

        assert_receive({:track_sent, request})
        assert {:form, body} = request
        assert body == Utils.param_generator(:fn, [arg1: 1], "UA-123-1", [], [:arg1])
      end
    end
  end
end
