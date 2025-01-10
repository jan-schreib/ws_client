defmodule WsClient.Core do
  defp websocat do
    System.find_executable("websocat")
  end

  def start_client(url) do
    Port.open(
      {:spawn_executable, websocat()},
      [:stderr_to_stdout, args: [url]]
    )
  end

  def quit_client(port) do
    Port.close(port)
  end

  def send(client, command) when is_binary(command) do
    Port.command(client, command)
  end
end
