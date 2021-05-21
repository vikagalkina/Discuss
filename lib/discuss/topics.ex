defmodule Discuss.Topics do
  @moduledoc """
  The Topics context.
  """

  import Ecto.Query, warn: false
  alias Discuss.Repo

  alias Discuss.Topics.Topic

  @topic inspect(__MODULE__)

  def subscribe do
    Phoenix.PubSub.subscribe(Discuss.PubSub, @topic)
  end

  def subscribe(topic_id) do
    Phoenix.PubSub.subscribe(Discuss.PubSub, @topic <> "#{topic_id}")
  end

  @doc """
  Returns the list of topics.

  ## Examples

      iex> list_topics()
      [%Topic{}, ...]

  """
  def list_topics do
    Topic
    |> order_by(desc: :updated_at)
    |> Repo.all()
  end

  def get_comments_count do
    from(p in Topic,
      join: c in assoc(p, :comments)
    )
    |> Repo.all()
  end

  @doc """
  Gets a single topic.

  Raises `Ecto.NoResultsError` if the Topic does not exist.

  ## Examples

      iex> get_topic!(123)
      %Topic{}

      iex> get_topic!(456)
      ** (Ecto.NoResultsError)

  """
  def get_topic!(id), do: Repo.get!(Topic, id)

  def get_comments(topic), do: Repo.preload(topic, comments: [:user])
  @doc """
  Creates a topic.

  ## Examples

      iex> create_topic(%{field: value})
      {:ok, %Topic{}}

      iex> create_topic(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_topic(user, attrs \\ %{}) do
    user
    |> Ecto.build_assoc(:topics)
    |> Topic.changeset(attrs)
    |> Repo.insert()
    |> broadcast_change([:topic, :created])
  end

  @doc """
  Updates a topic.

  ## Examples

      iex> update_topic(topic, %{field: new_value})
      {:ok, %Topic{}}

      iex> update_topic(topic, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_topic(%Topic{} = topic, attrs) do
    topic
    |> Topic.changeset(attrs)
    |> Repo.update()
    |> broadcast_change([:topic, :updated])
  end

  @doc """
  Deletes a topic.

  ## Examples

      iex> delete_topic(topic)
      {:ok, %Topic{}}

      iex> delete_topic(topic)
      {:error, %Ecto.Changeset{}}

  """
  def delete_topic(%Topic{} = topic) do
    topic
    |> Repo.delete()
    |> broadcast_change([:topic, :deleted])
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking topic changes.

  ## Examples

      iex> change_topic(topic)
      %Ecto.Changeset{data: %Topic{}}

  """
  def change_topic(%Topic{} = topic, attrs \\ %{}) do
    Topic.changeset(topic, attrs)
  end

  defp broadcast_change({:error, result}) do
    {:error, result}
  end

  defp broadcast_change({:ok, result}, event) do
    Phoenix.PubSub.broadcast(Discuss.PubSub, @topic, {__MODULE__, event, result})
    Phoenix.PubSub.broadcast(Discuss.PubSub, @topic <> "#{result.id}", {__MODULE__, event, result})
  end
end
