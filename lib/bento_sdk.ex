defmodule BentoSdk do
  @moduledoc """
  BentoSdk is an Elixir client for the Bento API.

  ## Configuration

  Add the following to your config.exs (or environment specific config file) to use environment variables:

      config :bento_sdk,
        site_uuid: System.get_env("BENTO_SITE_UUID", "your_site_uuid"),
        username: System.get_env("BENTO_USERNAME", "your_username"),
        password: System.get_env("BENTO_PASSWORD", "your_password")

  Alternatively, you can set the configuration at runtime:

      BentoSdk.configure(
        site_uuid: "your-site-uuid",
        username: "your-username",
        password: "your-password"
      )

  ## Usage

  ```elixir
  # Find a subscriber
  {:ok, subscriber} = BentoSdk.find_subscriber("user@example.com")

  # Create a subscriber
  {:ok, subscriber} = BentoSdk.create_subscriber("user@example.com")

  # Find or create a subscriber
  {:ok, subscriber} = BentoSdk.find_or_create_subscriber("user@example.com")
  ```
  """

  @doc """
  Configure the BentoSdk at runtime.

  ## Options

    * `:site_uuid` - Your Bento site UUID
    * `:username` - Your Bento API username
    * `:password` - Your Bento API password
    * `:client` - A module that implements `BentoSdk.ClientBehaviour`

  ## Examples

      BentoSdk.configure(
        site_uuid: "your-site-uuid",
        username: "your-username",
        password: "your-password"
      )

      # Or with a custom client
      BentoSdk.configure(
        site_uuid: "your-site-uuid",
        username: "your-username",
        password: "your-password",
        client: MyCustomClient
      )
  """
  def configure(opts) do
    Application.put_env(:bento_sdk, :config, opts)
  end

  # Subscriber methods

  @doc """
  Find a subscriber by email.

  ## Examples

      BentoSdk.find_subscriber("user@example.com")
      {:ok, %{
        "email" => "user@example.com",
        "first_name" => "John",
        "last_name" => "Doe"
      }}

      BentoSdk.find_subscriber("nonexistent@example.com")
      {:ok, nil}
  """
  def find_subscriber(email) do
    client().find_subscriber(email)
  end

  @doc """
  Create a subscriber with the given email.

  ## Examples

      BentoSdk.create_subscriber("user@example.com")
      {:ok, %{
        "email" => "user@example.com"
      }}
  """
  def create_subscriber(email) do
    client().create_subscriber(email)
  end

  @doc """
  Find a subscriber by email, or create one if it doesn't exist.

  ## Examples

      BentoSdk.find_or_create_subscriber("user@example.com")
      {:ok, %{
        "email" => "user@example.com"
      }}
  """
  def find_or_create_subscriber(email) do
    client().find_or_create_subscriber(email)
  end

  @doc """
  Import or update subscribers in bulk.

  ## Examples

      BentoSdk.import_subscribers([
        %{email: "user1@example.com", first_name: "John", last_name: "Doe"},
        %{email: "user2@example.com", first_name: "Jane", last_name: "Smith"}
      ])
      {:ok, %{
        "imported" => 2,
        "errors" => []
      }}
  """
  def import_subscribers(subscribers) do
    client().import_subscribers(subscribers)
  end

  @doc """
  Run a command to change a subscriber's data.

  ## Examples

      BentoSdk.run_command("add_tag", "user@example.com", "vip")
      {:ok, %{
        "success" => true
      }}
  """
  def run_command(command, email, query) do
    client().run_command(command, email, query)
  end

  @doc """
  Add a tag to a subscriber.

  ## Examples

      BentoSdk.add_tag("user@example.com", "vip")
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

      BentoSdk.add_tag_via_event("user@example.com", "vip")
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

      BentoSdk.remove_tag("user@example.com", "vip")
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

      BentoSdk.add_field("user@example.com", "company", "Acme Inc.")
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

      BentoSdk.remove_field("user@example.com", "company")
      {:ok, %{
        "success" => true
      }}
  """
  def remove_field(email, field) do
    client().remove_field(email, field)
  end

  @doc """
  Subscribe a user.

  ## Examples

      BentoSdk.subscribe("user@example.com")
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

      BentoSdk.unsubscribe("user@example.com")
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

      BentoSdk.change_email("old@example.com", "new@example.com")
      {:ok, %{
        "success" => true
      }}
  """
  def change_email(old_email, new_email) do
    client().change_email(old_email, new_email)
  end

  # Event methods

  @doc """
  Track an event in Bento.

  ## Examples

      BentoSdk.track_event("user@example.com", "page_viewed", %{
        page: "/products"
      })
      {:ok, %{
        "success" => true
      }}
  """
  def track_event(email, type, fields \\ %{}, details \\ %{}) do
    client().track_event(email, type, fields, details)
  end

  @doc """
  Import events in bulk.

  ## Examples

      BentoSdk.import_events([
        %{
          email: "user1@example.com",
          type: "page_viewed",
          fields: %{page: "/products"}
        },
        %{
          email: "user2@example.com",
          type: "product_added_to_cart",
          fields: %{product_id: "123"}
        }
      ])
      {:ok, %{
        "imported" => 2,
        "errors" => []
      }}
  """
  def import_events(events) do
    client().import_events(events)
  end

  # Email methods

  @doc """
  Send an email through Bento.

  ## Examples

      BentoSdk.send_email(
        "user@example.com",
        "noreply@yourdomain.com",
        "Welcome to our service",
        "<h1>Welcome!</h1><p>Thanks for signing up.</p>",
        %{
          "first_name" => "John"
        }
      )
      {:ok, %{
        "success" => true
      }}
  """
  def send_email(to, from, subject, html_body, personalizations \\ %{}) do
    client().send_email(to, from, subject, html_body, personalizations)
  end

  @doc """
  Send a transactional email through Bento.

  ## Examples

      BentoSdk.send_transactional_email(
        "user@example.com",
        "noreply@yourdomain.com",
        "Your order has shipped",
        "<h1>Order Shipped</h1><p>Your order #123 has shipped.</p>",
        %{
          "first_name" => "John",
          "order_number" => "123"
        }
      )
      {:ok, %{
        "success" => true
      }}
  """
  def send_transactional_email(to, from, subject, html_body, personalizations \\ %{}) do
    client().send_transactional_email(to, from, subject, html_body, personalizations)
  end

  # Spam API methods

  @doc """
  Check if an email is valid.

  ## Examples

      BentoSdk.email_valid?("user@example.com")
      {:ok, true}

      BentoSdk.email_valid?("invalid-email")
      {:ok, false}
  """
  def email_valid?(email) do
    client().email_valid?(email)
  end

  @doc """
  Check if an email is risky.

  ## Examples

      BentoSdk.email_risky?("user@example.com")
      {:ok, false}

      BentoSdk.email_risky?("suspicious@example.com")
      {:ok, true}
  """
  def email_risky?(email) do
    client().email_risky?(email)
  end

  @doc """
  Check if an email is valid against Jesse's ruleset.

  ## Options

    * `:block_free_providers` - Whether to block free email providers (default: false)
    * `:wiggleroom` - Whether to allow some wiggle room in the rules (default: false)
    * `:ruleset` - The ruleset to use. Can be "standard" or "strict". Defaults to "standard".

  ## Examples

      BentoSdk.jesses_ruleset_reasons("user@example.com")
      {:ok, []}

      BentoSdk.jesses_ruleset_reasons("suspicious@example.com", block_free_providers: true)
      {:ok, ["Free email provider"]}

      {:ok, reasons} = BentoSdk.jesses_ruleset_reasons("user@example.com", ruleset: "strict")
  """
  def jesses_ruleset_reasons(email, opts \\ []) do
    client().jesses_ruleset_reasons(email, opts)
  end

  # Utility API methods

  @doc """
  Moderate content for profanity and other inappropriate content.

  Returns a map with moderation results including whether the content is safe,
  and if not, what categories of inappropriate content were detected.

  ## Examples

      {:ok, result} = BentoSdk.moderate_content("This is some content to check")
  """
  def moderate_content(content) do
    client().moderate_content(content)
  end

  @doc """
  Guess the gender of a name.

  Returns a map with gender probability information.

  ## Examples

      {:ok, result} = BentoSdk.guess_gender("Alex")
  """
  def guess_gender(name) do
    client().guess_gender(name)
  end

  @doc """
  Geolocate an IP address.

  Returns a map with geolocation information including country, region, city, etc.

  ## Examples

      {:ok, result} = BentoSdk.geolocate("8.8.8.8")
  """
  def geolocate(ip_address) do
    client().geolocate(ip_address)
  end

  # Private helpers

  defp client do
    Application.get_env(:bento_sdk, :config, [])
    |> Keyword.get(:client, BentoSdk.Client)
  end
end
