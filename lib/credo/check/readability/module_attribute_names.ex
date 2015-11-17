defmodule Credo.Check.Readability.ModuleAttributeNames do
  @moduledoc """
  Module attribute names are always written in snake_case in Elixir.

      # snake_case:

      @inbox_name "incoming"

      # not snake_case

      @inboxName "incoming"

  Like all `Readability` issues, this one is not a technical concern.
  But you can improve the odds of others reading and liking your code by making
  it easier to follow.
  """

  @explanation [check: @moduledoc]

  alias Credo.Code.Name

  use Credo.Check, base_priority: :high

  def run(source_file, params \\ []) do
    issue_meta = IssueMeta.for(source_file, params)

    Credo.Code.traverse(source_file, &traverse(&1, &2, issue_meta))
  end

  defp traverse({:@, _meta, [{name, meta, _arguments}]} = ast, issues, issue_meta) do
    case issue_for_name(name, meta, issue_meta) do
      nil -> {ast, issues}
      val -> {ast, issues ++ [val]}
    end
  end
  defp traverse(ast, issues, _source_file) do
    {ast, issues}
  end

  defp issue_for_name(name, meta, issue_meta) do
    unless name |> to_string |> Name.snake_case? do
      issue_for(meta[:line], "@#{name}", issue_meta)
    end
  end

  defp issue_for(line_no, trigger, issue_meta) do
    format_issue issue_meta,
      message: "Module attribute names should be written in snake_case.",
      trigger: trigger,
      line_no: line_no
  end
end