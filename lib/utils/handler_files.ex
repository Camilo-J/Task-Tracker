defmodule Utils.HandlerFiles do
  def read_tasks do
    case File.read("./records.json") do
      {:ok, body} -> Jason.decode!(body)
      {:error, _error} -> []
    end
  end

  @spec store_task(any()) :: nil | :ok
  def store_task(task) do
    case File.read("./records.json") do
      {:ok, body} ->
        existing_tasks = Jason.decode!(body)
        updated_tasks = [task | existing_tasks]
        write_tasks(updated_tasks)

      {:error, _reason} ->
        write_tasks([task])
    end
  end

  def write_tasks(tasks) do
    result = File.write("./records.json", Jason.encode!(tasks), [:write])

    case result do
      :ok ->
        IO.puts("")
        :ok

      {:error, reason} ->
        IO.puts("Error storing task: #{inspect(reason)}")
        nil
    end
  end
end
