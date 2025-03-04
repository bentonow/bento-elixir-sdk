# BentoSdk

An Elixir SDK for the [Bento](https://bentonow.com/) marketing platform.

## Installation

Add `bento_sdk` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:bento_sdk, "~> 0.1.0"}
  ]
end
```

## Configuration

Configure the SDK in your `config.exs` (or environment-specific config file) using environment variables:

```elixir
config :bento_sdk,
  site_uuid: System.get_env("BENTO_SITE_UUID", "your_site_uuid"),
  username: System.get_env("BENTO_USERNAME", "your_username"),
  password: System.get_env("BENTO_PASSWORD", "your_password")
```

You can set these environment variables in your system or use a tool like [dotenv](https://github.com/avdi/dotenv_elixir) to load them from a `.env` file.

Alternatively, you can set the configuration at runtime:

```elixir
BentoSdk.configure(
  site_uuid: "your-site-uuid",
  username: "your-username",
  password: "your-password"
)
```

## Usage

### Subscriber Methods

```elixir
# Find a subscriber
{:ok, subscriber} = BentoSdk.find_subscriber("user@example.com")

# Create a subscriber
{:ok, subscriber} = BentoSdk.create_subscriber("user@example.com", %{
  first_name: "John",
  last_name: "Doe"
})

# Find or create a subscriber
{:ok, subscriber} = BentoSdk.find_or_create_subscriber("user@example.com", %{
  first_name: "John",
  last_name: "Doe"
})

# Import subscribers in bulk
{:ok, result} = BentoSdk.import_subscribers([
  %{email: "user1@example.com", first_name: "John", last_name: "Doe"},
  %{email: "user2@example.com", first_name: "Jane", last_name: "Smith"}
])

# Add a tag to a subscriber
{:ok, result} = BentoSdk.add_tag("user@example.com", "vip")

# Add a tag via an event
{:ok, result} = BentoSdk.add_tag_via_event("user@example.com", "vip")

# Remove a tag from a subscriber
{:ok, result} = BentoSdk.remove_tag("user@example.com", "vip")

# Add a field to a subscriber
{:ok, result} = BentoSdk.add_field("user@example.com", "company", "Acme Inc.")

# Remove a field from a subscriber
{:ok, result} = BentoSdk.remove_field("user@example.com", "company")

# Subscribe a user
{:ok, result} = BentoSdk.subscribe("user@example.com")

# Unsubscribe a user
{:ok, result} = BentoSdk.unsubscribe("user@example.com")

# Change a subscriber's email
{:ok, result} = BentoSdk.change_email("old@example.com", "new@example.com")

# Run a custom command
{:ok, result} = BentoSdk.run_command("custom_command", "user@example.com", %{key: "value"})
```

### Event Methods

```elixir
# Track an event
{:ok, result} = BentoSdk.track_event("user@example.com", "page_viewed", %{
  page: "/products"
}, %{
  browser: "Chrome"
})

# Import events in bulk
{:ok, result} = BentoSdk.import_events([
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
```

### Email Methods

```elixir
# Send an email
{:ok, result} = BentoSdk.send_email(
  "user@example.com",
  "noreply@yourdomain.com",
  "Welcome to our service",
  "<h1>Welcome!</h1><p>Thanks for signing up.</p>",
  %{
    "first_name" => "John"
  }
)

# Send a transactional email
{:ok, result} = BentoSdk.send_transactional_email(
  "user@example.com",
  "noreply@yourdomain.com",
  "Your order has shipped",
  "<h1>Order Shipped</h1><p>Your order #123 has shipped.</p>",
  %{
    "first_name" => "John",
    "order_number" => "123"
  }
)
```

### Spam API Methods

```elixir
# Check if an email is valid
{:ok, valid} = BentoSdk.email_valid?("user@example.com")

# Check if an email is risky
{:ok, risky} = BentoSdk.email_risky?("user@example.com")

# Check against Jesse's ruleset
{:ok, reasons} = BentoSdk.jesses_ruleset_reasons("user@example.com", block_free_providers: true)
```

### Utility API Methods

```elixir
# Moderate content for profanity and inappropriate content
{:ok, result} = BentoSdk.moderate_content("This is some content to check")

# Guess the gender of a name
{:ok, result} = BentoSdk.guess_gender("Alex")

# Geolocate an IP address
{:ok, result} = BentoSdk.geolocate("8.8.8.8")
```

## Testing with Mocks

The SDK is designed to be easily mockable for testing. It uses the [Mox](https://github.com/dashbitco/mox) library for mocking.

```elixir
# In your test_helper.exs
Mox.defmock(BentoSdk.ClientMock, for: BentoSdk.ClientBehaviour)

# Configure the SDK to use the mock in test environment
Application.put_env(:bento_sdk, :config, client: BentoSdk.ClientMock)

# In your test
test "find_subscriber/1" do
  BentoSdk.ClientMock
  |> expect(:find_subscriber, fn email ->
    assert email == "test@example.com"
    {:ok, %{"email" => email, "first_name" => "Test", "last_name" => "User"}}
  end)

  assert {:ok, subscriber} = BentoSdk.find_subscriber("test@example.com")
  assert subscriber["email"] == "test@example.com"
  assert subscriber["first_name"] == "Test"
  assert subscriber["last_name"] == "User"
end
```

## Interactive Documentation

The SDK includes comprehensive Livebook files for interactive documentation and examples:

### General
- `livebook/index.livemd`: Directory of all Livebook resources
- `livebook/bento_sdk_demo.livemd`: Basic usage examples
- `livebook/bento_sdk_with_mocks.livemd`: Mocking and testing demonstrations

### API-Specific Documentation
- `livebook/subscribers_api.livemd`: Working with subscribers
- `livebook/events_api.livemd`: Tracking and importing events
- `livebook/emails_api.livemd`: Sending emails and transactional emails
- `livebook/tags_api.livemd`: Managing subscriber tags
- `livebook/fields_api.livemd`: Managing subscriber fields
- `livebook/broadcasts_api.livemd`: Working with broadcasts
- `livebook/stats_api.livemd`: Retrieving statistics
- `livebook/spam_api.livemd`: Email validation and risk assessment

Each Livebook provides interactive examples with forms that allow you to experiment with the API in real-time.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
