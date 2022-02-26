defmodule CanvasWeb.Socket do
  @moduledoc false
  use Phoenix.Socket, log: :debug

  use Absinthe.Phoenix.Socket,
    schema: CanvasWeb.Schemas.Public.Schema

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.

  def connect(_, socket) do
    {:ok, socket}
  end

  def id(_socket), do: nil
end
