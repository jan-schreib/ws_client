defmodule WsClient do
  alias WsClient.Worker

  @moduledoc """
  WsClient
  A web socket client that uses websocat via a Port.
  In case of a crash of websocat it will be restarted
  and submit the same commands as before to get back
  to the state before the crash.

  """

  @doc """
  Sends a message to the connected web server via the client.
  The server's response data will be used in the provided callback function.

  Make sure to include a newline '\\n' character to submit the request.

  Returns `:ok`.

  ## Examples

      iex> WsClient.send(DocuClient, "hello world\\n")
      :ok
  """
  def send(worker, command) do
    Worker.send(worker, command)
  end

  @doc """
  Starts `websocat` and connect to the given URL.

  Returns `:ok` or `{:error, "Already connected"}`.

  ## Examples

      iex> WsClient.connect(DocuClient, "wss://echo.websocket.org")
      {:error, "Already connected"}
      iex> WsClient.disconnect(DocuClient)
      :ok
      iex> WsClient.connect(DocuClient, "wss://echo.websocket.org")
      :ok
  """
  def connect(worker, url) do
    Worker.connect(worker, url)
  end

  @doc """
  Disconnects and stops the underlying `websocat` connection and application.
  Returns `:ok`.

  ## Examples

      iex> WsClient.disconnect(DocuClient)
      :ok
  """
  def disconnect(worker) do
    Worker.disconnect(worker)
  end

  @doc """
  Sets the callback function that gets called with the
  received data from the connected web socket.

  ## Examples

  You could use the Phoenix PubSub system to handle the data.


      defp cb(json) do
        with {:ok, data} <- JSON.decode(json |> to_string) do
          Phoenix.PubSub.broadcast!(Jip.PubSub, "topic", data)
        else
          err -> IO.inspect(err)
        end
      end

      WsClient.callback(DocuClient, cb)

  It is also possible to change the callback at runtime.

      iex> cb = fn data -> data |> IO.inspect end
      #<Function<...>
      iex> WsClient.callback(DocuClient, cb)
      :ok
  """
  def callback(worker, cb) do
    Worker.callback(worker, cb)
  end
end
