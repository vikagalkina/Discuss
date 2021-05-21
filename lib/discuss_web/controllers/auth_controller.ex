defmodule DiscussWeb.AuthController do
  use DiscussWeb, :controller
  plug Ueberauth

  alias Discuss.Users
  alias Discuss.Users.User
  alias Discuss.Repo
  alias DiscussWeb.Router.Helpers


  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, %{"provider" => provider}) do
    user_params = %{token: auth.credentials.token, email: auth.info.email, provider: provider}
    changeset = Users.change_user(%User{}, user_params)

    signin(conn, changeset)
  end

  def signout(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: Helpers.live_path(conn, DiscussWeb.TopicLive.Index))
  end

  defp signin(conn, changeset) do
    case insert_or_update_user(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Welcome back!")
        |> put_session(:user_id, user.id)
        |> redirect(to: Helpers.live_path(conn, DiscussWeb.TopicLive.Index))
      {:error, _reason} ->
        conn
        |> put_flash(:error, "Error signing in")
        |> redirect(to: Helpers.live_path(conn, DiscussWeb.TopicLive.Index))
    end
  end

  defp insert_or_update_user(changeset) do
    case Users.get_user_by_email(changeset.changes.email) do
      nil -> Repo.insert(changeset)
      user -> {:ok, user}
    end
  end
end