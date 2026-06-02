defmodule ElixirChatWeb.ChatLive do
  use ElixirChatWeb, :live_view

  alias ElixirChat.Chat

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Chat.subscribe()

    {:ok,
     socket
     |> assign(:username, nil)
     |> assign(:messages, [])
     |> assign(:message_form, to_form(%{"body" => ""}))}
  end

  @impl true
  def handle_event("set_username", %{"username" => username}, socket) do
    username = String.trim(username)

    if username == "" do
      {:noreply, socket}
    else
      messages = Chat.list_messages()
      {:noreply, socket |> assign(:username, username) |> assign(:messages, messages)}
    end
  end

  @impl true
  def handle_event("send_message", %{"body" => body}, socket) do
    body = String.trim(body)

    if body != "" do
      Chat.create_message(socket.assigns.username, body)
    end

    {:noreply, assign(socket, :message_form, to_form(%{"body" => ""}))}
  end

  @impl true
  def handle_info({:new_message, message}, socket) do
    {:noreply, update(socket, :messages, &(&1 ++ [message]))}
  end
end
