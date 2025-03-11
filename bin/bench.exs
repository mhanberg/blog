defmodule Bench do
  @moduledoc false
  def main do
    Benchee.run(
      %{
        "current" => fn ->
          Mix.Task.reenable("tableau.build")
          Mix.Task.run("tableau.build")
        end,
        "split" => fn ->
          Mix.Task.reenable("tableau.build2")
          Mix.Task.run("tableau.build2")
        end
      },
      memory_time: 10,
      time: 10
    )
  end
end

Bench.main()
