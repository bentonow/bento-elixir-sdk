defmodule BentoSdk.Tags do
  @moduledoc """
  Functions for managing tags in Bento.

  The Tags API allows you to:
  - Get all tags in your account
  - Create new tags

  Tags are a simple named data point you can use to tag subscribers.
  """

  @doc """
  Get all tags in your account.

  ## Examples

      BentoSdk.Tags.get()
      {:ok, [
        %{
          "id" => "1234",
          "type" => "tags",
          "attributes" => %{
            "name" => "example_tag",
            "created_at" => "2024-08-06T05:44:04.444Z",
            "discarded_at" => nil
          }
        }
      ]}
  """
  def get do
    client().get_tags()
  end

  @doc """
  Create a new tag in your account.

  ## Examples

      BentoSdk.Tags.create("new_tag")
      {:ok, %{
        "id" => "1234",
        "type" => "tags",
        "attributes" => %{
          "name" => "new_tag",
          "created_at" => "2024-08-06T05:44:04.444Z",
          "discarded_at" => nil
        }
      }}
  """
  def create(name) do
    client().create_tag(name)
  end

  defp client do
    config = Application.get_env(:bento_sdk, :config, [])
    Keyword.get(config, :client, BentoSdk.Client)
  end
end
