#!/usr/bin/env elixir
{:ok, socket} = :gen_tcp.listen(5566, [:binary, active: false, reuseaddr: true])
for i <- 0..9 do
  fn ->
    Stream.resource(
      fn -> :gen_tcp.accept(socket) end,
      fn {:ok, client} ->
        with {:ok, data} <- :gen_tcp.recv(client, 0) do
          IO.inspect(data, label: i)
          :gen_tcp.send(client, data)
          {[], {:ok, client}}
        else
          _ -> {:halt, client}
        end
      end,
      &:gen_tcp.close/1
    )
    |> Stream.run()
  end
  |> Task.async()
end
|> Task.await_many(:infinity)

