defmodule DiscussWeb.Plugs.SetUser do
  import Plug.Conn
  alias Discuss.Users

  def init(_params) do
  end

  def call(conn, _params) do
    user_id = get_session(conn, :user_id)

    cond do
      user = user_id && Users.get_user!(user_id) ->
        put_session(conn, :user, user)
      true ->
        put_session(conn, :user, nil)
    end
  end
end