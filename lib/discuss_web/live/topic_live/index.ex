defmodule DiscussWeb.TopicLive.Index do
  use DiscussWeb, :live_view

  alias Discuss.{Topics,Users}

  def mount(_params, session, socket) do
    Topics.subscribe()
    {:ok, fetch(socket) |> assign_user(session)}
  end

  def handle_event("delete_topic", %{"id" => topic_id}, socket) do
    topic = Topics.get_topic!(topic_id)
    if topic.user_id == socket.assigns.user.id do
      Topics.delete_topic(topic)
      {:noreply, socket
                 |> put_flash(:info, "Topic Deleted")}
    else
      socket
      |> put_flash(:error, "You cannot delete that")
      |> push_redirect(to: Routes.live_path(socket, TopicLive.Index))
    end
  end

  def handle_info({Topics, [:topic | _], _}, socket) do
    {:noreply, fetch(socket)}
  end

  defp fetch(socket) do
    assign(socket, topics: Topics.list_topics())
  end

  defp assign_user(socket, session) do
    if session["user"] do
      assign(socket, user: session["user"])
    else
      assign(socket, user: nil)
    end
  end
end
