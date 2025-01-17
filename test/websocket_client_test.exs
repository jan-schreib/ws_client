defmodule WsClientTest do
  use ExUnit.Case
  alias WsClient.Worker

  test "echo server connection" do
    pid = self()
    cb = fn data -> send(pid, data |> to_string) end
    url = "wss://echo.websocket.org"

    {:ok, _} =
      GenServer.start_link(Worker, %{cb: cb, url: url, port: "", commands: []}, name: TestWorker)

    receive do
      data ->
        assert(String.contains?(data, "Request served by"))
    end

    WsClient.send(TestWorker, "hi\n")

    receive do
      data ->
        assert(data == "hi\n")
    end

    assert(WsClient.connect(TestWorker, url) == {:error, "Already connected"})
    WsClient.disconnect(TestWorker)
  end
end
