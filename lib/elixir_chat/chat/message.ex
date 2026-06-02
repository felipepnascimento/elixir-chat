defmodule ElixirChat.Chat.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :username, :string
    field :body, :string
    field :is_agent, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  def changeset(message, attrs) do
    message
    |> cast(attrs, [:username, :body, :is_agent])
    |> validate_required([:username, :body])
    |> validate_length(:body, min: 1, max: 2000)
  end
end
