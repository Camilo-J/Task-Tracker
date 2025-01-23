defmodule TaskTracker do
  def main do
    IO.puts("Welcome to Task Tracker")
    name = IO.gets("Please enter your name: ") |> String.trim()

    if name == "", do: IO.puts("Invalid name")

    IO.puts("-----------------------------")
    IO.puts("Hello #{name}, what would you like to do?")
    IO.puts("1. Add a task: add 'task'")
    IO.puts("2. List tasks: list 'todo' or 'done' or 'in-progress'")
    IO.puts("3. Update a task: update 'task_id'")
    IO.puts("4. Delete a task: delete 'task_id'")
    IO.puts("4. Exit: exit app")
    IO.puts("-----------------------------")
    input = IO.gets("") |> String.trim()

    case String.split(input, " ") do
      ["add" | task] ->
        add_task(Enum.join(task, " "))

      ["list", list_choice] ->
        list_tasks(list_choice)

      ["update", task_id | new_description] ->
        update_task(task_id, Enum.join(new_description, " "))

      ["delete", task_id] ->
        delete_task(task_id)

      ["mark-in-progress", task_id] ->
        update_task_status(task_id, "in-progress")

      ["mark-done", task_id] ->
        update_task_status(task_id, "done")

      ["exit" | _] ->
        IO.puts("Goodbye")

      _ ->
        IO.puts("Invalid choice")
    end
  end

  defp list_tasks(list_choice) do
    available_list_choices = ["todo", "done", "in-progress"]
    tasks = read_tasks()

    if Enum.find(available_list_choices, fn x -> x == list_choice end) do
      IO.puts("Listing tasks with status: #{list_choice}")
      Enum.filter(tasks, fn task -> task["status"] == list_choice end)
    else
      IO.puts("Invalid list choice")
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

    is_task_created = store_task(new_task)

    if is_task_created, do: IO.puts("Task added successfully with id: #{generated_id}")
    if is_task_created == nil, do: nil
  end

  defp update_task(task_id, description) do
    tasks = read_tasks()

    task_found = Enum.find(tasks, fn task -> task["id"] === String.to_integer(task_id) end)

    if task_found !== nil do
      IO.puts("Updating task with id: #{task_id}")

      updated_tasks =
        Enum.map(tasks, fn task ->
          if task["id"] === String.to_integer(task_id) do
            Map.put(task, "description", description)
            Map.put(task, "updated_at", DateTime.utc_now())
          else
            task
          end
        end)

      write_tasks(updated_tasks)
    end

    if task_found == nil do
      IO.puts("Task not found")
      nil
    end
  end

  defp delete_task(task_id) do
    tasks = read_tasks()

    task_selected = Enum.find(tasks, fn task -> task["id"] === String.to_integer(task_id) end)

    if task_selected == nil, do: IO.puts("Task not found")

    if task_selected !== nil do
      IO.puts("Deleting task with id: #{task_id}")
      updated_tasks = Enum.reject(tasks, fn task -> task["id"] === String.to_integer(task_id) end)
      write_tasks(updated_tasks)
    end
  end

  defp update_task_status(task_id, status) do
    tasks = read_tasks()
    IO.puts("Updating task with id: #{task_id}")

    task_selected = Enum.find(tasks, fn task -> task["id"] === String.to_integer(task_id) end)

    if task_selected !== nil do
      updated_tasks =
        Enum.map(tasks, fn task ->
          if task["id"] === String.to_integer(task_id) do
            Map.put(task, "status", status)
            Map.put(task, "updated_at", DateTime.utc_now())
          else
            task
          end
        end)

      write_tasks(updated_tasks)
    end

    if task_selected == nil, do: IO.puts("Task not found")
    :ok
  end

  defp read_tasks do
    case File.read("./records.json") do
      {:ok, body} -> Jason.decode!(body)
      {:error, _error} -> []
    end
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
      :ok ->
        IO.puts("")
        :ok

      {:error, reason} ->
        IO.puts("Error storing task: #{inspect(reason)}")
        nil
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
