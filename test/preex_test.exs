defmodule PrEExTest do
  use ExUnit.Case

  test "trims empty newlines" do
    # GIVEN
    template = """
    one
    <%= if true do %>
    true1
    <%= if true do %>
    true2
    <% end %>
    <% end %>
    two
    <%= if false do %>
    false
    <% end %>

    <%= if true do %>
    true3
    <% end %>

    <%= "meow" %>

    <%= for x <- [1, 3, 5] do %>
    * <%= x %>
    * <%= x + 1 %>!
    <% end %>
    """

    # WHEN
    result = EEx.eval_string(template, [], engine: PrEEx.Engine)

    # THEN
    assert result == """
           one
           true1
           true2
           two

           true3

           meow

           * 1
           * 2!
           * 3
           * 4!
           * 5
           * 6!
           """
  end

  test "does not trim inline" do
    # GIVEN
    template = "foo <%= if true do %>true <% end %>bar"

    # WHEN
    result = EEx.eval_string(template, [], engine: PrEEx.Engine)

    # THEN
    assert result == "foo true bar"
  end

  test "does not trim at the end of a line" do
    # GIVEN
    template = """
    foo <%= if true do %>true<% end %>
    bar
    """

    # WHEN
    result = EEx.eval_string(template, [], engine: PrEEx.Engine)

    # THEN
    assert result == """
           foo true
           bar
           """
  end

  test "does not trim at the start of a line" do
    # GIVEN
    template = """
    foo
    <%= if true do %>true<% end %> bar
    """

    # WHEN
    result = EEx.eval_string(template, [], engine: PrEEx.Engine)

    # THEN
    assert result == """
           foo
           true bar
           """
  end

  test "trims when the block is all on one line" do
    # GIVEN
    template = """
    foo
    <%= if false do %>false<% end %>
    bar
    """

    # WHEN
    result = EEx.eval_string(template, [], engine: PrEEx.Engine)

    # THEN
    assert result == """
           foo
           bar
           """
  end
end
