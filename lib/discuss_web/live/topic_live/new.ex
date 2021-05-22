defmodule DiscussWeb.TopicLive.New do
  use DiscussWeb, :live_view
  alias Discuss.Topics
  alias Discuss.Topics.Topic
  alias DiscussWeb.TopicLive

  def mount(_params, session, socket) do
    changeset = Topics.change_topic(%Topic{})
    {:ok, assign(socket, changeset: changeset) |> assign_user(session)}
  end

  defp assign_user(socket, session) do
    if session["user"] do
      assign(socket, user: session["user"])
    else
      assign(socket, user: nil)
      |> put_flash(:error, "You must be logged in.")
      |> redirect(to: Routes.live_path(socket, TopicLive.Index))
    end
  end
end
