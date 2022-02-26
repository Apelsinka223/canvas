defmodule CanvasWeb.AbsintheHelpers do
  @moduledoc """
  Helpers for testing GraphQL endpoints.
  """

  def query_skeleton(query, variables \\ %{}, params \\ %{}) do
    Map.merge(
      %{
        "operationName" => "",
        "query" => "#{query}",
        "variables" => variables
      },
      params
    )
  end

  defmacro post_query(conn, query, variables \\ Macro.escape(%{}), params \\ Macro.escape(%{})) do
    quote do
      conn = unquote(conn)
      query = unquote(query)
      variables = unquote(variables)
      params = unquote(params)

      post(conn, "/api", query_skeleton(query, variables, params))
    end
  end
end
