defmodule ElixirChat.Chat do
  import Ecto.Query
  alias ElixirChat.Repo
  alias ElixirChat.Chat.Message

  @topic "chat:lobby"
  @message_limit 50

  def list_messages do
    Message
    |> order_by([m], asc: m.inserted_at)
    |> limit(@message_limit)
    |> Repo.all()
  end

  def create_message(username, body, is_agent \\ false) do
    %Message{}
    |> Message.changeset(%{username: username, body: body, is_agent: is_agent})
    |> Repo.insert()
    |> case do
      {:ok, message} ->
        Phoenix.PubSub.broadcast(ElixirChat.PubSub, @topic, {:new_message, message})
        {:ok, message}

      error ->
        error
    end
  end

  def subscribe do
    Phoenix.PubSub.subscribe(ElixirChat.PubSub, @topic)
  end
end
