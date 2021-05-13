defmodule Logman.Handler do

  def share_log(data) do
    timestamp = :os.system_time(:millisecond)
    message = "#{timestamp} #{data}\n"

    # Log to this node
    log(message)

    # Log to other nodes in cluster
    Node.list()
    |> Enum.each(fn node ->
      {Logman.Tasks, node}
      |> Task.Supervisor.async(Logman.Handler, :log, [message])
      |> Task.await()
    end)
    # TODO: return a meaningful value, indicating if
    # share_log operation has failed or succeeded
  end

  def log(message) do
    path = get_log_file_path()
    # TODO: may be better to put log file creation at
    # app initialization to keep this function idempotent
    unless File.exists?(path) do
      File.mkdir_p!(get_log_file_dir())
      File.touch!(path)
    end

    case File.open(path, [:append, :utf8]) do
      {:ok, file}      ->
        IO.binwrite(file, message)
        File.close(file)
      {:error, reason} ->
        IO.inspect(reason, label: "File open error")
    end
    # TODO: return a meaningful value, indicating if
    # log operation has failed or succeeded
  end

  def get_log_file_path() do
    get_log_file_dir() <> "/events.log"
  end

  def get_log_file_dir() do
    node_id = Application.get_env(:logman, :node_id)
    "logs/#{Mix.env}/#{node_id}/data"
  end
end
