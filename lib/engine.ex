defmodule PrEEx.Engine do
  @moduledoc """
  A thin wrapper around `EEx.SmartEngine` that makes it nicer to write preformatted text templates.

  ## Usage

      EEx.eval_string(template, bindings, engine: PrEEx.Engine)

  ## Options

  None at the moment.

  ## Newline trimming around blocks

  When interpolating block expressions such as `if` or `for`, newlines are trimmed to avoid undesired whitespace in
  the rendered template.

  Up to two extraneous newlines are removed: the first immediate `\\n` within the block, and the `\\n` immediately following the
  block. For example, the template

  ```eex
  hello
  <%= if condition() do %>
  to the
  <% end %>
  world
  ```

  will result in

  ```eex
  hello
  to the
  world
  ```

  when the condition is true, and

  ```eex
  hello
  world
  ```

  when the condition is false, effectively making the lines of EEx invisible.

  Loops are also more conveinent to write:

  ```eex
  How many licks to the center of a Tootsie Pop?
  <%= for i <- 1..3 do %>
  <%= i %>...
  <% end %>
  3!
  ```

  will result in

  ```eex
  How many licks to the center of a Tootsie Pop?
  1...
  2...
  3...
  3!
  ```

  No trimming occurs if the block expression is in the middle of a line. For example,

  ```eex
  hello <%= if condition() do %>to the <% end %>world
  ```

  will result in `"hello to the world"` or `"hello world"`, depending on the condition.
  """

  @behaviour EEx.Engine

  @impl true
  defdelegate init(opts), to: EEx.SmartEngine

  @impl true
  def handle_body(state) do
    trimmed_binary = trim_after_blocks(state, state.binary)
    state = %{state | binary: trimmed_binary}

    state
    |> EEx.SmartEngine.handle_body()
    |> trim_block_start()
  end

  defp trim_after_blocks(state, binary, acc \\ [])

  defp trim_after_blocks(
         state,
         [
           next,
           {:"::", [], [{arg, [], EEx.Engine}, {:binary, [], EEx.Engine}]} = interp,
           prev | rest
         ],
         acc
       )
       when is_binary(prev) and is_binary(next) do
    if arg_is_block?(state, arg) and String.ends_with?(prev, "\n") and
         String.starts_with?(next, "\n") do
      next_trimmed = String.replace_prefix(next, "\n", "")
      trim_after_blocks(state, [prev | rest], [interp, next_trimmed | acc])
    else
      trim_after_blocks(state, [interp, prev | rest], [next | acc])
    end
  end

  defp trim_after_blocks(state, [expr | rest], acc),
    do: trim_after_blocks(state, rest, [expr | acc])

  defp trim_after_blocks(_state, [], acc), do: Enum.reverse(acc)

  defp arg_is_block?(state, arg) do
    Enum.any?(state.dynamic, fn
      {_, [],
       [
         {^arg, [], EEx.Engine},
         {_, _,
          [
            {_, _, [_, [do: {:__block__, _, _}]]}
          ]}
       ]} ->
        true

      _ ->
        false
    end)
  end

  @impl true
  defdelegate handle_begin(state), to: EEx.SmartEngine

  @impl true
  def handle_end(state) do
    handle_body(state)
  end

  defp trim_block_start({:__block__, meta, exprs}) do
    trimmed =
      Enum.map(exprs, fn
        {:<<>>, m, [<<"\n", str::binary>> | rest]} ->
          {:<<>>, m, [str | rest]}

        expr ->
          expr
      end)

    {:__block__, meta, trimmed}
  end

  @impl true
  defdelegate handle_text(state, meta, text), to: EEx.SmartEngine

  @impl true
  defdelegate handle_expr(state, marker, expr), to: EEx.SmartEngine
end
