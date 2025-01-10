defmodule WsClient do
  alias WsClient.Worker

  def send(worker, command) do
    Worker.send(worker, command)
  end

  def disconnect(worker) do
    Worker.disconnect(worker)
  end

  def callback(worker, cb) do
    Worker.callback(worker, cb)
  end
end
