defmodule TaskTracker do
  def main do
    available_list_choices = ["todo", "done", "in-progress"]

    IO.puts("Welcome to Task Tracker")
    name = IO.gets("Please enter your name: ") |> String.trim()

    if name == "" do
      IO.puts("Invalid name")
    end

    IO.puts("Hello #{name}, what would you like to do?")
    IO.puts("1. Add a task: add 'task'")
    IO.puts("2. List tasks: list 'todo' or 'done' or 'in-progress'")
    IO.puts("3. Update a task: update 'task_id'")
    IO.puts("4. Exit: exit app")
    IO.puts("-----------------------------")
    input = IO.gets("")

    [choice | task] = String.split(input, " ")

    case choice do
      "add" -> add_task(Enum.join(task, " "))
      # ["list", list_choice] -> list_tasks(list_choice)
      "update" -> update_task("")
      "exit" -> IO.puts("Goodbye")
      _ -> IO.puts("Invalid choice")
    end
  end

  defp add_task(task) do
    generated_id = generate_id()

    new_task = %{
      "id" => generated_id,
      "description" => task,
      "status" => "todo",
      "created_at" => DateTime.utc_now(),
      "updated_at" => DateTime.utc_now()
    }

    store_task(new_task)
    IO.puts("Task added successfully with id: #{generated_id}")
  end

  defp update_task(task_id) do
    IO.puts("Updating task with id: #{task_id}")
  end

  defp store_task(task) do
    case File.read("./records.json") do
      {:ok, body} ->
        existing_tasks = Jason.decode!(body)
        updated_tasks = [task | existing_tasks]
        write_tasks(updated_tasks)

      {:error, _reason} ->
        write_tasks([task])
    end
  end

  defp write_tasks(tasks) do
    result = File.write("./records.json", Jason.encode!(tasks), [:write])

    case result do
      :ok -> IO.puts("")
      {:error, reason} -> IO.puts("Error storing task: #{inspect(reason)}")
    end
  end

  defp list_tasks(list_choice) do
    IO.puts("Listing tasks")

    case File.read("./records.json") do
      {:ok, body} -> IO.inspect(body)
      {:error, _error} -> IO.puts("No tasks found")
    end
  end

  defp generate_id do
    case File.read("./records.json") do
      {:ok, body} ->
        existing_tasks = Jason.decode!(body)
        Enum.max_by(existing_tasks, & &1["id"])["id"] + 1

      {:error, _reason} ->
        1
    end
  end
end

# id
# description
# status
# created_at
# updated_at
