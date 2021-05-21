defmodule DiscussWeb.TopicLive.Show do
  use DiscussWeb, :live_view
  alias Discuss.{Topics, Comments}
  alias Discuss.Comments.Comment
  alias Phoenix.LiveView.Socket
  alias DiscussWeb.TopicLive

  def mount(_params, session, socket) do
    changeset = Comments.change_comment(%Comment{})
    {:ok, assign(socket, changeset: changeset) |> assign_user(session)}
  end

  def handle_params(%{"id" => id}, _url, socket) do
    if connected?(socket), do: Topics.subscribe(id)
    {:noreply, socket |> assign(id: id) |> fetch}
  end

  def handle_event("validate_comment", %{"comment" => params}, socket) do
    changeset = %Comment{}
                |> Comments.change_comment(params)
                |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save_comment", %{"comment" => params}, socket) do
    if socket.assigns.user do
      save_comment(params, socket)
    else
      {:noreply, socket
                 |> put_flash(:error, "You must to log in")
                 |> push_redirect(to: Routes.live_path(socket, TopicLive.Show, socket.assigns.topic))}
    end
  end

  def handle_info({Topics, [:topic, :updated], _}, socket) do
    {:noreply, fetch(socket)
               |> put_flash(:info, "This topic has been updated.")
    }
  end

  def handle_info({Topics, [:comment, :created], _}, socket) do
    {:noreply, fetch(socket)
               |> put_flash(:info, "New comment added.")
    }
  end

  def handle_info({Topics, [:topic, :deleted], _}, socket) do
    {:noreply, socket
               |> put_flash(:error, "This topic has been deleted.")
               |> push_redirect(to: Routes.live_path(socket, TopicLive.Index))
    }
  end

  defp assign_user(socket, session) do
    if session["user"] do
      assign(socket, user: session["user"])
    else
      assign(socket, user: nil)
    end
  end

  defp fetch(%Socket{assigns: %{id: id}} = socket) do
    assign(socket, topic: Topics.get_topic!(id) |> Topics.get_comments())
  end

  defp save_comment(params, socket) do
    case Comments.create_comment(socket.assigns.user, socket.assigns.topic, params) do
      :ok ->
        {:noreply, socket
                   |> put_flash(:info, "Comment added")
                   |> push_redirect(to: Routes.live_path(socket, TopicLive.Show, socket.assigns.topic))}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}

    end
  end
end
