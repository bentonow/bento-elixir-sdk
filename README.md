# BentoSdk

An Elixir SDK for the [Bento](https://bentonow.com/) email marketing and automation platform.

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
config :bento_sdk, :config,
  site_uuid: System.get_env("BENTO_SITE_UUID", "your_site_uuid"),
  username: System.get_env("BENTO_USERNAME", "your_username"),
  password: System.get_env("BENTO_PASSWORD", "your_password")
```

Alternatively, you can set the configuration at runtime:

```elixir
BentoSdk.configure(
  site_uuid: "your-site-uuid",
  username: "your-username",
  password: "your-password"
)
```

These credentials can be found under "Your Private API Keys" in your Bento account.

## Usage

The SDK is organized into modules by functionality:

### Subscriber Methods

```elixir
# Find a subscriber
{:ok, subscriber} = BentoSdk.Subscribers.find("user@example.com")

# Create a subscriber
{:ok, subscriber} = BentoSdk.Subscribers.create("user@example.com")

# Find or create a subscriber
{:ok, subscriber} = BentoSdk.Subscribers.find_or_create("user@example.com")

# Update a subscriber
{:ok, result} = BentoSdk.Subscribers.update("user@example.com", %{first_name: "John", last_name: "Doe"})

# Subscribe a user
{:ok, result} = BentoSdk.Subscribers.subscribe("user@example.com")

# Unsubscribe a user
{:ok, result} = BentoSdk.Subscribers.unsubscribe("user@example.com")

# Change a subscriber's email
{:ok, result} = BentoSdk.Subscribers.change_email("old@example.com", "new@example.com")
```

### Tag Methods

```elixir
# Get all tags
{:ok, tags} = BentoSdk.Tags.get()

# Create a new tag
{:ok, tag} = BentoSdk.Tags.create("new_tag")

# Add a tag to a subscriber
{:ok, result} = BentoSdk.Subscribers.add_tag("user@example.com", "vip")

# Add a tag via an event
{:ok, result} = BentoSdk.Subscribers.add_tag_via_event("user@example.com", "vip")

# Remove a tag from a subscriber
{:ok, result} = BentoSdk.Subscribers.remove_tag("user@example.com", "vip")
```

### Field Methods

```elixir
# Get all fields
{:ok, fields} = BentoSdk.Fields.get()

# Create a new field
{:ok, field} = BentoSdk.Fields.create("company")

# Add a field to a subscriber
{:ok, result} = BentoSdk.Subscribers.add_field("user@example.com", "company", "Acme Inc.")

# Remove a field from a subscriber
{:ok, result} = BentoSdk.Subscribers.remove_field("user@example.com", "company")
```

### Event Methods

```elixir
# Track an event
{:ok, result} = BentoSdk.Events.track("user@example.com", "page_viewed", %{
  page: "/products"
}, %{
  browser: "Chrome"
})

# Import events in bulk
{:ok, result} = BentoSdk.Events.import_events([
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
{:ok, result} = BentoSdk.Emails.send(
  "user@example.com",
  "noreply@yourdomain.com",
  "Welcome to our service",
  "<h1>Welcome!</h1><p>Thanks for signing up.</p>",
  %{
    "first_name" => "John"
  }
)

# Send a transactional email
{:ok, result} = BentoSdk.Emails.send_transactional(
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

### Stats API Methods

```elixir
# Get site statistics
{:ok, stats} = BentoSdk.Stats.get_site()

# Get segment statistics
{:ok, stats} = BentoSdk.Stats.get_segment("segment_id")

# Get report statistics
{:ok, stats} = BentoSdk.Stats.get_report("report_id")
```

### Utility API Methods

```elixir
# Moderate content for profanity and inappropriate content
{:ok, result} = BentoSdk.Utility.moderate_content("This is some content to check")

# Guess the gender of a name
{:ok, result} = BentoSdk.Utility.guess_gender("Alex")

# Geolocate an IP address
{:ok, result} = BentoSdk.Utility.geolocate("8.8.8.8")

# Validate an email
{:ok, result} = BentoSdk.Utility.validate_email("user@example.com")

# Check against Jesse's ruleset
{:ok, reasons} = BentoSdk.Utility.jesses_ruleset("user@example.com", block_free_providers: true)

# Check if a domain or IP is blacklisted
{:ok, result} = BentoSdk.Utility.check_blacklist(%{domain: "example.com"})
```

### Broadcasts API Methods

```elixir
# Get all broadcasts
{:ok, broadcasts} = BentoSdk.Broadcasts.get()

# Create a new broadcast
{:ok, broadcast} = BentoSdk.Broadcasts.create(%{
  name: "Welcome Email",
  subject: "Welcome to our service!",
  body: "<h1>Welcome!</h1><p>Thanks for signing up.</p>",
  from_email: "welcome@example.com",
  inclusive_tags: ["new_signup"],
  exclusive_tags: ["unsubscribed"],
  segment_id: "segment_123"
})
```

## Interactive Documentation

The SDK includes comprehensive Livebook files for interactive documentation and examples:

### General
- `livebook/index.livemd`: Directory of all Livebook resources

### API-Specific Documentation
- `livebook/subscribers_api.livemd`: Working with subscribers
- `livebook/events_api.livemd`: Tracking and importing events
- `livebook/emails_api.livemd`: Sending emails and transactional emails
- `livebook/tags_api.livemd`: Managing tags
- `livebook/fields_api.livemd`: Managing fields
- `livebook/broadcasts_api.livemd`: Working with broadcasts
- `livebook/stats_api.livemd`: Retrieving statistics
- `livebook/utility_api.livemd`: Content moderation, gender guessing, and geolocation

Each Livebook provides interactive examples with forms that allow you to experiment with the API in real-time.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
