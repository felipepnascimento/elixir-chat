defmodule ElixirChatWeb.PageController do
  use ElixirChatWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
