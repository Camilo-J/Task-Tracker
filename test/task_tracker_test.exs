defmodule TaskTrackerTest do
  use ExUnit.Case
  doctest TaskTracker

  setup do
    File.write("./records.json", Jason.encode!([]))
    :ok
  end

  test "Should add a new task" do
    TaskTracker.add_task("Test task")
    tasks = read_file("./records.json")
    assert length(tasks) == 1
    assert Enum.at(tasks, 0)["description"] == "Test task"
  end

  test "Should not add a task without a description" do
    TaskTracker.add_task("")
    tasks = read_file("./records.json")
    assert length(tasks) == 0
  end

  test "Should return all the task available" do
    TaskTracker.add_task("Test task")
    tasks = TaskTracker.list_tasks("todo")

    assert length(tasks) == 1
    assert Enum.at(tasks, 0)["description"] == "Test task"
  end

  test "Should return the done task" do
    TaskTracker.add_task("Test task 2")
    TaskTracker.update_task_status("1", "done")
    tasks = TaskTracker.list_tasks("done")
    IO.inspect(tasks)
    assert length(tasks) == 1
    assert Enum.at(tasks, 0)["description"] == "Test task 2"
  end

  def read_file(file_path) do
    case File.read(file_path) do
      {:ok, body} -> Jason.decode!(body)
      {:error, _reason} -> []
    end
  end
end
