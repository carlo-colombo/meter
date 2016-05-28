defmodule Meter do
  require Logger
  alias Meter.Utils

  @moduledoc """
  Meter
  ============

  Track your elixir functions on Google Analytics
  """

  @doc "Track a function with his own arguments, use a param_generator function from configuration "
  @spec track(atom, Keyword.t) :: any
  def track(function_name, kwargs) do
    pg = Application.get_env(:meter, :param_generator, &Utils.param_generator/5)
    track(function_name, kwargs, pg)
  end

  def track(function_name, kwargs, param_generator) do
    tid = Application.get_env(:meter, :tid)
    mapping = Application.get_env(:meter, :mapping, [])
    custom_dimensions = Application.get_env(:meter, :custom_dimensions, [])

    if tid != nil do
      Logger.info("Tracking inspect #{function_name}(#{inspect(kwargs)})")

      body = {:form, param_generator.(function_name, kwargs, tid, mapping, custom_dimensions)}

      Logger.info("form #{inspect(body)}")

      send_request(self, body)
    end
  end

  defp send_request(pid, body) do
    spawn fn ->
      case HTTPoison.post("https://www.google-analytics.com/collect", body) do
        {:ok, resp} -> Logger.info("sent #{inspect(resp)}")
        {:error, error} -> Logger.warn("Error #{inspect(error)}")
      end
      send(pid, {:track_sent, body})
    end
  end

  @doc """
  Replace a function definition, automatically tracking every call to the function on google analytics.
  """
  defmacro defmeter({function,_,args}=fundef, [do: body]) do
    names = args
    |> Enum.map(fn {arg_name, _,_} -> arg_name end)

    metered = {:__block__, [],
               [quote do
                 values= unquote(
                   args
                   |> Enum.map(fn arg ->  quote do
                       var!(unquote(arg))
                     end
                   end)
                 )
                 map = Enum.zip(unquote(names), values)
                 track(unquote(function), map)
               end, body]}

    quote do
      def(unquote(fundef),unquote([do: metered]))
    end
  end
end
