# WsClient

A websocket client that uses [websocat](https://github.com/vi/websocat) via a Port.
In case of a crash of `websocat` it will be restarted and submit the same commands as before to get back to the state before the crash.

## Dependencies

* [websocat](https://github.com/vi/websocat)

If
```elixir
iex> System.find_executable("websocat")
```
returns a valid path you are good to go!

## Installation

```elixir
def deps do
  [
    {:ws_client, "~> 0.1.0"}
  ]
end
```

## Usage

### Without a supervisor

```elixir
# create callback on how to handle the received data from the server
cb = fn data -> data |> IO.inspect end
# the server to connect to
url = "wss://echo.websocket.org"

# start the worker (GenServer)
{:ok, _} =
  GenServer.start_link(WsClient.Worker, %{cb: cb, url: url, port: "", commands: []}, name: EchoWorker)

# send from the client to the server, the callback defined above will handle the answer message.
WsClient.send(TestWorker, "hi\n")
```
### With a supervisor (single worker)

```elixir
def start(_type, _args) do
  children = [
    {WsClient.Worker,
     args: %{
       cb: &IO.inspect/1,
       url: "wss://echo.websocket.org",
       port: "",
       commands: []
     },
     name: EchoWorker}
  ]

  opts = [strategy: :one_for_one, name: Test.Supervisor]
  Supervisor.start_link(children, opts)
end
```
### With a supervisor (and multiple workers)

This may be useful in case you want to connect to multiple websocket endpoints at the same time.

```elixir
@impl true
def start(_type, _args) do
  children = [
    Supervisor.child_spec(
      {WsClient.Worker,
       args: %{
         cb: &IO.inspect/1,
         url: "wss://echo.websocket.org",
         port: "",
         commands: []
       },
       name: FirstWorker},
      id: :my_worker_1
    ),
    Supervisor.child_spec(
      {WsClient.Worker,
       args: %{
         cb: &IO.inspect/1,
         url: "wss://echo.websocket.org",
         port: "",
         commands: []
       },
       name: SecondWorker},
      id: :my_worker_2
    )
  ]

  opts = [strategy: :one_for_one, name: Test.Supervisor]
  Supervisor.start_link(children, opts)
end
```

### Usage
After the connection you can use
```elixir
WsClient.send(pid, message)
```
to send a message to the web server you are connected to, e.g.
```elixir
WsClient.send(TestWorker, "hi\n")
```

To change the handling callback at runtime use
```elixir
WsClient.callback(pid, fun)
```
Example with Elixir 1.18 and the new internal JSON function:
```elixir
cb = fn data -> JSON.decode(data) end
WsClient.callback(Worker, cb)
```

To close the port (will otherwise be handled automatically on exit of the GenServer)
```elixir
WsClient.disconnect(pid)
```
