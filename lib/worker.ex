defmodule WsClient.Worker do
  alias WsClient.Core
  use GenServer

  def start_link(args) do
    initial_state = Keyword.get(args, :args)

    GenServer.start_link(
      __MODULE__,
      %{cb: initial_state.cb, url: initial_state.url, port: "", commands: []},
      args
    )
  end

  def send(pid, command) do
    GenServer.cast(pid, {:comm, command})
  end

  def disconnect(pid) do
    GenServer.cast(pid, :disconnect)
  end

  def callback(pid, cb) do
    GenServer.cast(pid, {:cb, cb})
  end

  defp start_client(args) do
    port = Core.start_client(args.url)
    Port.monitor(port)
    Map.merge(args, %{port: port})
  end

  @impl true
  def init(args) do
    args = start_client(args)

    {:ok, args}
  end

  @impl true
  def handle_cast({:comm, command}, state) do
    Core.send(state.port, command)

    new_state = Map.replace(state, :commands, [command] ++ state.commands)
    {:noreply, new_state}
  end

  @impl true
  def handle_cast({:cb, new_cb}, state) do
    new_state = Map.replace(state, :cb, new_cb)
    {:noreply, new_state}
  end

  @impl true
  def handle_cast(:disconnect, state) do
    Core.quit_client(state.port)
  end

  @impl true
  def handle_info({_port, {:data, data}}, state) do
    state.cb.(data)
    {:noreply, state}
  end

  @impl true
  def handle_info({:DOWN, _ref, :port, _port, :normal}, state) do
    state = start_client(state)
    state.commands |> Enum.each(fn x -> Core.send(state.port, x) end)

    {:noreply, state}
  end
end
