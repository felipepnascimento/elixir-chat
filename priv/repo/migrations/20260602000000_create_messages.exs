defmodule ElixirChat.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :username, :string, null: false
      add :body, :text, null: false
      add :is_agent, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
