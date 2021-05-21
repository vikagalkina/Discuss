defmodule Discuss.Repo.Migrations.AddUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :token, :string
      add :email, :string
      add :provider, :string

      timestamps()
    end
  end
end
