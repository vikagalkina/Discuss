defmodule DiscussWeb.TopicLive.TopicFormComponent do
  use DiscussWeb, :live_component

  alias Discuss.Topics
  alias Discuss.Topics.Topic
  alias DiscussWeb.TopicLive


  def handle_event("validate", %{"topic" => params}, socket) do
    changeset = %Topic{}
                |> Topics.change_topic(params)
                |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"topic" => params}, socket) do
    case Topics.create_topic(socket.assigns.user, params) do
      :ok ->
        {:noreply, socket
                   |> put_flash(:info, "Topic created")
                   |> push_redirect(to: Routes.live_path(socket, TopicLive.Index))}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}

    end
  end

  def handle_event("update", %{"topic" => params}, socket) do
    if socket.assigns.topic.user_id == socket.assigns.user.id do
      save_topic(socket.assigns.topic, params, socket)
    else
      {:noreply, socket
                 |> put_flash(:error, "You cannot edit that")
                 |> push_redirect(to: Routes.live_path(socket, TopicLive.Index))}
    end
  end



  def render(assigns) do
    ~L"""
    <%= f = form_for @changeset, "#", [phx_target: @myself, phx_change: :validate, phx_submit: @submit_event, phx_hook: "SavedForm"] %>
    <div class="form-group">
    <%= text_input f, :title, placeholder: "Title", phx_debounce: "blur", class: "form-control" %>
    <%= error_tag f, :title %>
    </div>

    <%= submit "Save Topic", phx_disable_with: "Saving...", class: "btn btn-primary" %>
    </form>
    """
  end

  defp save_topic(topic, params, socket) do
    case Topics.update_topic(topic, params) do
      :ok ->
        {:noreply, socket
                   |> put_flash(:info, "Topic updated")
                   |> push_redirect(to: Routes.live_path(socket, TopicLive.Index))}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}

    end
  end

end