defmodule DiscussWeb.TopicLive.Edit do
  use DiscussWeb, :live_view
  alias Discuss.Topics
  alias Phoenix.LiveView.Socket
  alias DiscussWeb.TopicLive


  def mount(_params, session, socket) do
    {:ok, socket |> assign_user(session)}
  end

  def handle_params(%{"id" => id}, _url, socket) do
    if connected?(socket), do: Topics.subscribe(id)
    {:noreply, socket |> assign(id: id) |> fetch}
  end

  defp fetch(%Socket{assigns: %{id: id}} = socket) do
    topic = Topics.get_topic!(id)
    if topic.user_id == socket.assigns.user.id do
      assign(socket, topic: topic, changeset: Topics.change_topic(topic))
    else
      socket
      |> put_flash(:error, "You cannot edit that")
      |> push_redirect(to: Routes.live_path(socket, TopicLive.Index))
    end
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
