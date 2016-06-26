defmodule Meter do
  require Logger

  alias Meter.Utils

  @moduledoc """
  Meter
  ============

  Track your elixir functions on Google Analytics

  This module define one function to track function calls on google analtycs. The functions load parameters from the configuration. Minimum parameter to enable the tracking is :tid (that is the monitoring id from google analytics eg ```UA-12456132-1```). A default ```param_generator``` function is provided to generate the request to google analtycs.

  ### Configure the module

      config :meter,
        tid: "UA-123123123-1",  #to track functions this is requested
        param_generator: &Meter.Utils.param_generator/5 # the default function, could be replaced,
        mapping: [
          cid: :arg1, # a value to identify the user, is extracted from the function arguments, if not provided GA generate one for each request
          ds: "server", # data source, "server" is the default
          t: "pageview" # hit type, default is "pageview" ],
        custom_dimensions: [:arg1, :arg2] # custom dimensions to send to ga, it mantain the order, to be used need additional configuration on ga

  """

  @doc "Track a function and its own arguments.

  Get ```:tid```, ```:mapping``` and ```:custom_dimension``` from configuration. If ```:tid``` is not defined does nothing.
  The request to google analytycs is send asynchronously.
  "
  @spec track(atom, Keyword.t, (atom, Keyword.t, String.t, Keyword.t, [atom, ...] -> Keyword.t)) :: any
  def track(function_name, kwargs,
            param_generator \\ Application.get_env(:meter, :param_generator, &Utils.param_generator/5)) do

    tid = Application.get_env(:meter, :tid)

    if tid != nil do
      mapping = Application.get_env(:meter, :mapping, [])
      custom_dimensions = Application.get_env(:meter, :custom_dimensions, [])

      body = {:form, param_generator.(function_name, kwargs, tid, mapping, custom_dimensions)}

      send_request(self, body)
    end
  end

  @spec track_error(atom, Keyword.t, map, (atom, Keyword.t, String.t, Keyword.t, [atom, ...] -> Keyword.t)) :: any
  def track_error(function_name, kwargs, error,
            param_generator \\ Application.get_env(:meter, :param_generator, &Utils.param_generator/6)) do
    tid = Application.get_env(:meter, :tid)

    if tid != nil do
      mapping = Application.get_env(:meter, :mapping, [])
      custom_dimensions = Application.get_env(:meter, :custom_dimensions, [])

      body = {:form, param_generator.(function_name, kwargs, tid,
                                      mapping, custom_dimensions, error)}
      send_request(self, body)
    end
  end

  @doc """
  Replace a function definition, automatically tracking every call to the function on google analytics. It also track exception with the function track_error.

  This macro intended use is with a set of uniform functions that can be concettualy mapped to pageviews (eg: messaging bot commands).

  Example:

      defmeter function(arg1, arg2), do: IO.inspect({arg1,arg2})

      function(1,2)

  will call track with this parameters

      track(:function, [arg1: 1, arg2: 2])

  Additional parameters will be loaded from the configurationd
  """
  defmacro defmeter({function,_,args} = fundef, [do: body]) do
    names = args
    |> Enum.map(fn {arg_name, _,_} -> arg_name end)

    metered = quote do
      values = unquote(
        args
        |> Enum.map(fn arg ->  quote do
            var!(unquote(arg))
          end
        end)
      )
      map = Enum.zip(unquote(names), values)

      try do
        to_return = unquote(body)
        track(unquote(function), map)
        to_return
      rescue
        e ->
          track_error(unquote(function), map, e)
          raise e
      end
    end

    quote do
      def(unquote(fundef),unquote([do: metered]))
    end
  end

  defp send_request(pid, body) do
    spawn fn ->
      case HTTPoison.post("https://www.google-analytics.com/collect", body) do
        {:ok, resp} -> :ok
        {:error, error} -> Logger.warn("Error #{inspect(error)}")
      end
      send(pid, {:track_sent, body})
    end
  end
end
