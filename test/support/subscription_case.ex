defmodule CanvasWeb.SubscriptionCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use CanvasWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  alias Absinthe.Phoenix.SubscriptionTest
  import Phoenix.ChannelTest

  @endpoint CanvasWeb.Endpoint

  using(_opts) do
    quote do
      use Absinthe.Phoenix.SubscriptionTest, schema: CanvasWeb.Schema

      import Phoenix.ChannelTest
      import unquote(__MODULE__)

      @endpoint CanvasWeb.Endpoint
    end
  end

  @spec join_to_socket(socket_name :: atom, args :: map) :: {:ok, Phoenix.Socket.t()}
  def join_to_socket(socket_name, args \\ %{}) do
    with {:ok, socket} <- connect(socket_name, args),
         {:ok, socket} <- SubscriptionTest.join_absinthe(socket) do
      {:ok, socket}
    end
  end

  defmacro subscribe_on_query(socket, query, variables \\ nil) do
    quote do
      ref =
        SubscriptionTest.push_doc(
          unquote(socket),
          unquote(query),
          %{variables: unquote(variables)}
        )

      assert_reply ref, :ok, %{subscriptionId: subscription_id}

      subscription_id
    end
  end
end
