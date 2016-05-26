defmodule Meter do
  require Logger

  @moduledoc """
  Meter
  ============

  Track your elixir functions on Google Analytics
  """


  @doc "Track a function with his own arguments, use a param_generator function from configuration "
  @spec track(atom, Keyword.t) :: any
  def track(function_name, kwargs) do
    pg = Application.get_env(:meter, :param_generator)
    track(function_name, kwargs, pg)
  end

  def track(function_name, kwargs, param_generator) do
    tid = Application.get_env(:meter, :tid)

    if tid != nil do
      Logger.info("Tracking inspect #{function_name}(#{inspect(kwargs)})")

      body = {:form, [
                 v: 1,
                 tid: tid] ++ param_generator.(function_name, kwargs)}

               #   cid: kwargs[mapping[:cid]],
               #   t: "pageview",
               #   ds: "bot",
               #   dt: "#{function_name}",
               #   dp: "/#{function_name}"
               # ] ++ custom_dimensions(dimensions, kwargs)}

      Logger.info("form #{inspect(body)}")

      send_request(body)
    end
  end

  defp send_request(body) do
    spawn fn ->
      case HTTPoison.post("https://www.google-analytics.com/collect", body) do
        {:ok, resp} -> Logger.info("sent #{inspect(resp)}")
        {:error, error} -> Logger.warn("Error #{inspect(error)}")
      end
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
