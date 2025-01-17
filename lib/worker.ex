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
    GenServer.call(pid, :disconnect)
  end

  def connect(pid, url) do
    GenServer.call(pid, {:connect, url})
  end

  def callback(pid, cb) do
    GenServer.call(pid, {:cb, cb})
  end

  defp start_client(%{url: url} = args) do
    port = Core.start_client(url)
    ref = Core.monitor(port)
    Map.merge(args, %{port: port, port_ref: ref})
  end

  @impl true
  def init(args) do
    args = start_client(args)

    {:ok, args}
  end

  @impl true
  def handle_call({:cb, new_cb}, _from, state) do
    new_state = Map.replace(state, :cb, new_cb)
    {:reply, :ok, new_state}
  end

  @impl true
  def handle_call({:connect, url}, _from, state) do
    case Map.has_key?(state, :port) || Map.has_key?(state, :port_ref) do
      true ->
        {:reply, {:error, "Already connected"}, state}

      _ ->
        new_state = Map.merge(state, %{url: url}) |> start_client
        {:reply, :ok, new_state}
    end
  end

  @impl true
  def handle_call(:disconnect, _from, %{port: port, port_ref: port_ref} = state) do
    Core.demonitor(port_ref)
    Core.quit_client(port)

    state =
      state
      |> Map.delete(:port)
      |> Map.delete(:port_ref)

    {:reply, :ok, state}
  end

  @impl true
  def handle_cast({:comm, command}, state) do
    Core.send(state.port, command)

    new_state = Map.replace(state, :commands, [command] ++ state.commands)
    {:noreply, new_state}
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
