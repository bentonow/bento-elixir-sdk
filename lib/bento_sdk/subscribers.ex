defmodule BentoSdk.Subscribers do
  @moduledoc """
  Functions for managing subscribers in Bento.
  """

  @doc """
  Find a subscriber by email.

  ## Examples

      BentoSdk.Subscribers.find("user@example.com")
      {:ok, %{
        "email" => "user@example.com",
        "first_name" => "John",
        "last_name" => "Doe"
      }}

      BentoSdk.Subscribers.find("nonexistent@example.com")
      {:ok, nil}
  """
  def find(email) do
    client().find_subscriber(email)
  end

  @doc """
  Create a subscriber with the given email.

  ## Examples

      BentoSdk.Subscribers.create("user@example.com")
      {:ok, %{
        "email" => "user@example.com"
      }}
  """
  def create(email) do
    client().create_subscriber(email)
  end

  @doc """
  Find a subscriber by email, or create one if it doesn't exist.

  ## Examples

      BentoSdk.Subscribers.find_or_create("user@example.com")
      {:ok, %{
        "email" => "user@example.com"
      }}
  """
  def find_or_create(email) do
    client().find_or_create_subscriber(email)
  end

  @doc """
  Update a subscriber with the given attributes.
  
  This uses the Import Subscribers endpoint to update a single subscriber.

  ## Examples

      BentoSdk.Subscribers.update("user@example.com", %{first_name: "John", last_name: "Doe"})
      {:ok, %{
        "imported" => 1,
        "errors" => []
      }}
  """
  def update(email, attributes) do
    # Create a subscriber map with email and attributes
    subscriber = Map.put(attributes, :email, email)
    
    # Use the import_subscribers endpoint with a single subscriber
    client().import_subscribers([subscriber])
  end

  @doc """
  Subscribe a user.

  ## Examples

      BentoSdk.Subscribers.subscribe("user@example.com")
      {:ok, %{
        "success" => true
      }}
  """
  def subscribe(email) do
    client().subscribe(email)
  end

  @doc """
  Unsubscribe a user.

  ## Examples

      BentoSdk.Subscribers.unsubscribe("user@example.com")
      {:ok, %{
        "success" => true
      }}
  """
  def unsubscribe(email) do
    client().unsubscribe(email)
  end

  @doc """
  Change a subscriber's email.

  ## Examples

      BentoSdk.Subscribers.change_email("old@example.com", "new@example.com")
      {:ok, %{
        "success" => true
      }}
  """
  def change_email(old_email, new_email) do
    client().change_email(old_email, new_email)
  end

  @doc """
  Add a tag to a subscriber.

  ## Examples

      BentoSdk.Subscribers.add_tag("user@example.com", "vip")
      {:ok, %{
        "success" => true
      }}
  """
  def add_tag(email, tag) do
    client().add_tag(email, tag)
  end

  @doc """
  Add a tag to a subscriber via an event.

  ## Examples

      BentoSdk.Subscribers.add_tag_via_event("user@example.com", "vip")
      {:ok, %{
        "success" => true
      }}
  """
  def add_tag_via_event(email, tag) do
    client().add_tag_via_event(email, tag)
  end

  @doc """
  Remove a tag from a subscriber.

  ## Examples

      BentoSdk.Subscribers.remove_tag("user@example.com", "vip")
      {:ok, %{
        "success" => true
      }}
  """
  def remove_tag(email, tag) do
    client().remove_tag(email, tag)
  end

  @doc """
  Add a field to a subscriber.

  ## Examples

      BentoSdk.Subscribers.add_field("user@example.com", "company", "Acme Inc.")
      {:ok, %{
        "success" => true
      }}
  """
  def add_field(email, key, value) do
    client().add_field(email, key, value)
  end

  @doc """
  Remove a field from a subscriber.

  ## Examples

      BentoSdk.Subscribers.remove_field("user@example.com", "company")
      {:ok, %{
        "success" => true
      }}
  """
  def remove_field(email, field) do
    client().remove_field(email, field)
  end

  defp client do
    config = Application.get_env(:bento_sdk, :config, [])
    Keyword.get(config, :client, BentoSdk.Client)
  end
end
