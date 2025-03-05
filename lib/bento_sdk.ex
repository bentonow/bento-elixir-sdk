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

  The SDK is organized into modules by functionality:

  ```elixir
  # Subscriber operations
  {:ok, subscriber} = BentoSdk.Subscribers.find("user@example.com")
  {:ok, subscriber} = BentoSdk.Subscribers.create("user@example.com")
  {:ok, subscriber} = BentoSdk.Subscribers.find_or_create("user@example.com")
  {:ok, subscriber} = BentoSdk.Subscribers.update("user@example.com", %{first_name: "John"})

  # Tag operations
  {:ok, tags} = BentoSdk.Tags.get()
  {:ok, tag} = BentoSdk.Tags.create("new_tag")
  {:ok, result} = BentoSdk.Subscribers.add_tag("user@example.com", "vip")
  {:ok, result} = BentoSdk.Subscribers.remove_tag("user@example.com", "vip")

  # Field operations
  {:ok, fields} = BentoSdk.Fields.get()
  {:ok, field} = BentoSdk.Fields.create("company")
  {:ok, result} = BentoSdk.Subscribers.add_field("user@example.com", "company", "Acme Inc.")
  {:ok, result} = BentoSdk.Subscribers.remove_field("user@example.com", "company")

  # Event operations
  {:ok, result} = BentoSdk.Events.track("user@example.com", "page_viewed", %{page: "/products"})
  {:ok, result} = BentoSdk.Events.import_events([%{email: "user@example.com", type: "page_viewed"}])

  # Email operations
  {:ok, result} = BentoSdk.Emails.send("user@example.com", "noreply@example.com", "Welcome", "<p>Welcome!</p>")

  # Stats operations
  {:ok, stats} = BentoSdk.Stats.get_site()
  {:ok, stats} = BentoSdk.Stats.get_segment("segment_id")
  {:ok, stats} = BentoSdk.Stats.get_report("report_id")

  # Utility operations
  {:ok, result} = BentoSdk.Utility.moderate_content("Some content")
  {:ok, result} = BentoSdk.Utility.guess_gender("Alex")
  {:ok, result} = BentoSdk.Utility.geolocate("8.8.8.8")
  {:ok, result} = BentoSdk.Utility.validate_email("user@example.com")
  {:ok, reasons} = BentoSdk.Utility.jesses_ruleset("user@example.com", block_free_providers: true)
  {:ok, result} = BentoSdk.Utility.check_blacklist(%{domain: "example.com"})

  # Broadcasts operations
  {:ok, broadcasts} = BentoSdk.Broadcasts.get()
  {:ok, broadcast} = BentoSdk.Broadcasts.create([%{name: "Campaign", subject: "Hello", content: "<p>Hi</p>"}])
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
end
