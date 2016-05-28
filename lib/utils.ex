defmodule Meter.Utils do

  @doc """
    Generate a list of 2-element tuple, the first element is the name of the parameter (cd1, cd2, cd ...) and the second is the value. This function is used in to the default param_generator function providing the values from the application configuration. It could be used in a custom param_generator.

```
  iex> Meter.Utils.custom_dimensions([], [key: "value"])
  []

  iex> Meter.Utils.custom_dimensions([:key], [])
  []

  iex> Meter.Utils.custom_dimensions([:key], [key: "value"])
  [{"cd1", "value"}]

  iex> Meter.Utils.custom_dimensions([:key, :key2], [key: "value"])
  [{"cd1", "value"}, {"cd2", nil}]

  iex> Meter.Utils.custom_dimensions([:key, :key2], [key: "value", key3: 12])
  [{"cd1", "value"}, {"cd2", nil}]

```
  """
  @spec custom_dimensions(list(atom), Keyword.t) :: Keyword.t
  def custom_dimensions([], _), do: []
  def custom_dimensions(_, []), do: []
  def custom_dimensions(dimensions, kwargs) do
    1..length(dimensions)
    |> Enum.map(fn i -> "cd#{i}" end)
    |> Enum.zip(dimensions)
    |> Enum.map(fn {cdi,argname} -> {cdi, kwargs[argname]} end )
  end

  @doc """
  ```
    iex>Meter.Utils.param_generator(:fn, [arg1: 3, arg2: 5], "UA-123", [cid: :arg2], [:arg2, :arg1])
    [v: 1,
     tid: "UA-123",
     cid: 5,
     ds: "server",
     t: "pageview",
     dt: "fn",
     dp: "/fn"] ++
    [{"cd1", 5},{"cd2", 3}]

  ```
  """
  def param_generator(function_name, kwargs, tid, mapping, custom_dimensions) do
      [v: 1,
       tid: tid,
       cid: kwargs[mapping[:cid]],
       ds: "server",
       t: "pageview",
       dt: "#{function_name}",
       dp: "/#{function_name}"
      ] ++
      custom_dimensions(custom_dimensions, kwargs)
  end
end
