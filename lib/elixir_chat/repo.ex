defmodule ElixirChat.Repo do
  use Ecto.Repo,
    otp_app: :elixir_chat,
    adapter: Ecto.Adapters.SQLite3
end
