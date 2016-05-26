defmodule Meter.Utils do

  @doc """
    Generate a list of 2-element tuple, the first element is the name of the parameter (cd1, cd2, cd ...) and the second is the value. This function is used in to the default param_generator function providing the values from the application configuration. It could be used in a custom param_generator.

```
  iex> Meter.Utils.custom_dimensions([], [key: "value"])
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
  def custom_dimensions(dimensions, kwargs) do
    1..length(dimensions)
    |> Enum.map(fn i -> "cd#{i}" end)
    |> Enum.zip(dimensions)
    |> Enum.map(fn {cdi,argname} -> {cdi, kwargs[argname]} end )
  end
end
