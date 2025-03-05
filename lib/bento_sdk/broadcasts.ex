defmodule BentoSdk.Broadcasts do
  @moduledoc """
  Functions for managing broadcasts in Bento.

  This module provides functions to interact with the Bento Broadcasts API,
  allowing you to get and create broadcasts.
  """

  # This module is a placeholder for future broadcast-related functionality.
  # The current Bento API doesn't have specific broadcast endpoints documented,
  # but this module will be expanded when those endpoints are available.

  @doc """
  Get a list of broadcasts.

  Returns a list of all broadcasts in your Bento account.

  ## Examples

      BentoSdk.Broadcasts.get()
      {:ok, [
        %{
          "id" => "broadcast_123",
          "type" => "broadcast",
          "attributes" => %{
            "name" => "Campaign #1",
            "share_url" => "https://example.com/share/broadcast_123",
            "template" => %{
              "subject" => "Hello World",
              "to" => "Subscribers",
              "html" => "<p>Hi {{ visitor.first_name }}</p>"
            },
            "created_at" => "2024-08-06T05:44:04.433Z",
            "sent_final_batch_at" => "2024-08-06T05:44:04.433Z",
            "send_at" => "2024-08-06T05:44:04.433Z",
            "stats" => %{
              "open_rate" => 0.25
            }
          }
        }
      ]}
  """
  def get do
    client().get_broadcasts()
  end

  @doc """
  Create new broadcasts.

  Creates one or more new broadcasts to be sent to your subscribers.

  ## Parameters

  - `broadcasts` - A list of broadcast maps with the following keys:
    - `name` - Name of the broadcast (e.g., campaign name)
    - `subject` - Subject line of the broadcast email
    - `content` - Broadcast body content (supports liquid tags)
    - `type` - Email type ("plain" for Bento's CSS or "raw" to use your own)
    - `from` - Map with `email` and `name` keys for the sender
    - `inclusive_tags` - Comma-separated list of tags to send to (optional)
    - `exclusive_tags` - Comma-separated list of tags to exclude (optional)
    - `segment_id` - Segment ID for the campaign (optional)
    - `batch_size_per_hour` - Number of emails to send per hour (optional)
    - `send_at` - Date and time to send the broadcast (optional, format: "2024-04-23T18:30:00Z")
    - `approved` - Whether the broadcast is approved to be sent (optional, boolean)

  ## Examples

      broadcasts = [
        %{
          name: "Campaign #1 — Plain Text Example",
          subject: "Hello Plain World",
          content: "<p>Hi {{ visitor.first_name }}</p>",
          type: "plain",
          from: %{
            email: "sender@example.com",
            name: "John Doe"
          },
          inclusive_tags: "lead,mql",
          exclusive_tags: "customers",
          segment_id: "segment_123456789",
          batch_size_per_hour: 1500
        }
      ]

      BentoSdk.Broadcasts.create(broadcasts)
      {:ok, %{"results" => 1}}
  """
  def create(broadcasts) when is_list(broadcasts) do
    client().create_broadcasts(broadcasts)
  end

  defp client do
    config = Application.get_env(:bento_sdk, :config, [])
    Keyword.get(config, :client, BentoSdk.Client)
  end
end
