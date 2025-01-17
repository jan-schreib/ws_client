defmodule WsClient do
  alias WsClient.Worker

  @doc """
  Send a message to the connected web server via the client.
  The server's respose will call the provided callback function.

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
  Starts `websocat` and connect to the given url.

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

      iex> cb = fn data -> data |> IO.inspect end
      #<Function<...>
      iex> WsClient.callback(DocuClient, cb)
      :ok
  """
  def callback(worker, cb) do
    Worker.callback(worker, cb)
  end
end
