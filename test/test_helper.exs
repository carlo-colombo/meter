ExUnit.start([
  assert_receive_timeout: 500,
  refute_receive_timeout: 500
])

defmodule TestHelper do

  @doc """
  Add configuration to the envs and after executing the code remove it from the configuration
  """
  defmacro with_env(confs, do: body) do
    configs = for {app, envs} <- confs do
      for {key, value} <- envs do
        {app, key, value}
      end
    end
    |> List.flatten
    |> Enum.map(fn t -> Tuple.to_list(t) end)

    quote do
      unquote(configs)
      |> Enum.map(fn args -> apply(Application, :put_env, args) end)

      unquote(body)

      unquote(configs)
      |> Enum.map(fn args -> apply(Application, :delete_env, Enum.slice(args, 0..1)) end)
    end

  end
end
