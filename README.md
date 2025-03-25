
# BentoSdk for Elixir
<img align="right" src="https://app.bentonow.com/brand/logoanim.gif">

> [!TIP]
> Need help? Join our [Discord](https://discord.gg/ssXXFRmt5F) or email jesse@bentonow.com for personalized support.

The Bento Elixir SDK makes it quick and easy to send emails and track events in your Elixir applications. We provide powerful and customizable APIs that can be used out-of-the-box to manage subscribers, track events, and send transactional emails. We also expose low-level APIs so that you can build fully custom experiences.

❤️ Thank you [@abradburne](https://github.com/abradburne) for your contribution.

Get started with our [📚 integration guides](https://docs.bentonow.com), or [📘 browse the SDK reference](https://docs.bentonow.com/subscribers).

[![Hex.pm](https://img.shields.io/hexpm/v/bento_sdk.svg)](https://hex.pm/packages/bento_sdk)
[![Hex.pm](https://img.shields.io/hexpm/dt/bento_sdk.svg)](https://hex.pm/packages/bento_sdk)
[![Hex.pm](https://img.shields.io/hexpm/l/bento_sdk.svg)](https://github.com/bentonow/bento-elixir-sdk/blob/main/LICENSE.md)

Table of contents
=================

<!--ts-->
* [Features](#features)
* [Requirements](#requirements)
* [Getting started](#getting-started)
    * [Installation](#installation)
    * [Configuration](#configuration)
* [Modules](#modules)
    * [Subscriber Management](#subscriber-management)
    * [Tag Management](#tag-management)
    * [Field Management](#field-management)
    * [Event Tracking](#event-tracking)
    * [Email Sending](#email-sending)
    * [Broadcasts](#broadcasts)
    * [Stats](#stats)
    * [Utility Functions](#utility-functions)
* [Things to Know](#things-to-know)
* [Contributing](#contributing)
* [License](#license)
<!--te-->

## Features

* **Subscriber Management**: Import and manage subscribers directly from your Elixir app.
* **Event Tracking**: Easily track custom events and user behavior in your application.
* **Email Sending**: Send both standard and transactional emails through Bento.
* **API Access**: Full access to Bento's REST API for advanced operations.
* **Utility Functions**: Helpful utilities for content moderation, email validation, and more.
* **Broadcast Management**: Create and manage broadcast campaigns.

## Requirements

- Elixir ~> 1.14
- Erlang/OTP compatible with your Elixir version
- Bento API Keys

## Getting started

### Installation

Add `bento_sdk` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:bento_sdk, "~> 0.1.1"}
  ]
end
```

### Configuration

Configure the SDK in your `config.exs` (or environment-specific config file) using environment variables:

```elixir
config :bento_sdk,
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

## Modules

### Subscriber Management

#### Find a subscriber

```elixir
{:ok, subscriber} = BentoSdk.Subscribers.find("user@example.com")
```

#### Create a subscriber

```elixir
{:ok, subscriber} = BentoSdk.Subscribers.create("user@example.com")
```

#### Find or create a subscriber

```elixir
{:ok, subscriber} = BentoSdk.Subscribers.find_or_create("user@example.com")
```

#### Update a subscriber

```elixir
{:ok, result} = BentoSdk.Subscribers.update("user@example.com", %{first_name: "John", last_name: "Doe"})
```

#### Import multiple subscribers

```elixir
subscribers = [
  %{
    email: "user1@example.com",
    first_name: "John",
    last_name: "Doe"
  },
  %{
    email: "user2@example.com",
    first_name: "Jane",
    last_name: "Smith"
  }
]

{:ok, result} = BentoSdk.Subscribers.import(subscribers)
```

#### Subscribe a user

```elixir
{:ok, result} = BentoSdk.Subscribers.subscribe("user@example.com")
```

#### Unsubscribe a user

```elixir
{:ok, result} = BentoSdk.Subscribers.unsubscribe("user@example.com")
```

#### Change a subscriber's email

```elixir
{:ok, result} = BentoSdk.Subscribers.change_email("old@example.com", "new@example.com")
```

#### Add a tag to a subscriber

```elixir
{:ok, result} = BentoSdk.Subscribers.add_tag("user@example.com", "vip")
```

#### Add multiple tags to a subscriber

```elixir
{:ok, result} = BentoSdk.Subscribers.add_tags("user@example.com", ["vip", "new"])
```

#### Add a tag via an event

```elixir
{:ok, result} = BentoSdk.Subscribers.add_tag_via_event("user@example.com", "vip")
```

#### Remove a tag from a subscriber

```elixir
{:ok, result} = BentoSdk.Subscribers.remove_tag("user@example.com", "vip")
```

#### Add a field to a subscriber

```elixir
{:ok, result} = BentoSdk.Subscribers.add_field("user@example.com", "company", "Acme Inc.")
```

#### Remove a field from a subscriber

```elixir
{:ok, result} = BentoSdk.Subscribers.remove_field("user@example.com", "company")
```

### Tag Management

#### Get all tags

```elixir
{:ok, tags} = BentoSdk.Tags.get()
```

#### Create a new tag

```elixir
{:ok, tag} = BentoSdk.Tags.create("new_tag")
```

### Field Management

#### Get all fields

```elixir
{:ok, fields} = BentoSdk.Fields.get()
```

#### Create a new field

```elixir
{:ok, field} = BentoSdk.Fields.create("company")
```

### Event Tracking

#### Track an event

```elixir
{:ok, result} = BentoSdk.Events.track(
  "user@example.com",
  "page_viewed",
  %{
    "page" => "/products",
    "referrer" => "https://google.com"
  }
)
```

#### Track a purchase event

```elixir
{:ok, result} = BentoSdk.Events.track(
  "user@example.com",
  "$purchase",
  %{
    "first_name" => "Jesse"
  },
  %{
    "unique" => %{
      "key" => "order_123"
    },
    "value" => %{
      "currency" => "USD",
      "amount" => 8000
    },
    "cart" => %{
      "items" => [
        %{
          "product_sku" => "SKU123",
          "product_name" => "Test Product",
          "quantity" => 1
        }
      ],
      "abandoned_checkout_url" => "https://example.com/cart"
    }
  }
)
```

#### Import events in bulk

```elixir
{:ok, result} = BentoSdk.Events.import_events([
  %{
    email: "user1@example.com",
    type: "page_viewed",
    fields: %{
      "page" => "/products",
      "referrer" => "https://google.com"
    }
  },
  %{
    email: "user2@example.com",
    type: "$purchase",
    fields: %{
      "first_name" => "Jane"
    },
    details: %{
      "value" => %{
        "currency" => "USD",
        "amount" => 4999
      }
    }
  }
])
```

### Email Sending

#### Send an email

```elixir
{:ok, result} = BentoSdk.Emails.send(
  "user@example.com",
  "noreply@yourdomain.com",
  "Welcome to our service",
  "<h1>Welcome!</h1><p>Thanks for signing up.</p>",
  %{
    "first_name" => "John"
  }
)
```

#### Send a transactional email

```elixir
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

#### Send multiple emails in bulk

```elixir
{:ok, result} = BentoSdk.Emails.send_bulk([
  %{
    to: "user1@example.com",
    from: "noreply@yourdomain.com",
    subject: "Welcome to our service",
    html_body: "<h1>Welcome!</h1><p>Thanks for signing up.</p>",
    personalizations: %{"first_name" => "John"}
  },
  %{
    to: "user2@example.com",
    from: "noreply@yourdomain.com",
    subject: "Your order has shipped",
    html_body: "<h1>Order Shipped</h1><p>Your order #123 has shipped.</p>",
    personalizations: %{"first_name" => "Jane", "order_number" => "123"},
    transactional: true
  }
])
```

### Broadcasts

#### Get all broadcasts

```elixir
{:ok, broadcasts} = BentoSdk.Broadcasts.get()
```

#### Create broadcasts

```elixir
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

{:ok, result} = BentoSdk.Broadcasts.create(broadcasts)
```

### Stats

#### Get site statistics

```elixir
{:ok, stats} = BentoSdk.Stats.get_site()
```

#### Get segment statistics

```elixir
{:ok, stats} = BentoSdk.Stats.get_segment("segment_id")
```

#### Get report statistics

```elixir
{:ok, stats} = BentoSdk.Stats.get_report("report_id")
```

#### Get subscriber growth

```elixir
{:ok, stats} = BentoSdk.Client.get_subscriber_growth("2023-01-01", "2023-12-31")
```

### Utility Functions

#### Moderate content

```elixir
{:ok, result} = BentoSdk.Utility.moderate_content("This is some content to check")
```

#### Guess gender from name

```elixir
{:ok, result} = BentoSdk.Utility.guess_gender("John")
```

#### Geolocate an IP address

```elixir
{:ok, result} = BentoSdk.Utility.geolocate("8.8.8.8")
```

#### Validate an email address

```elixir
{:ok, result} = BentoSdk.Utility.validate_email("user@example.com")
```

#### Validate with additional options

```elixir
{:ok, result} = BentoSdk.Utility.validate_email("user@example.com", 
  name: "John Doe",
  ip: "8.8.8.8"
)
```

#### Check against Jesse's ruleset

```elixir
{:ok, reasons} = BentoSdk.Utility.jesses_ruleset("user@example.com", 
  block_free_providers: true,
  wiggleroom: true
)
```

#### Check blacklist status

```elixir
# Check domain
{:ok, result} = BentoSdk.Utility.check_blacklist(%{domain: "example.com"})

# Check IP address
{:ok, result} = BentoSdk.Utility.check_blacklist(%{ip_address: "8.8.8.8"})
```

## Things to Know

1. The SDK provides full access to Bento's API for managing subscribers, tracking events, and sending emails.
2. All API requests return `{:ok, result}` or `{:error, reason}` tuples for better error handling.
3. For event tracking with purchase details, make sure to follow the structure shown in the examples.
4. Email validation is available both through the Subscribers module and the Utility module.
5. Bento does not support `no-reply` sender addresses for transactional emails. You MUST use an author you have configured as your sender address.
6. The SDK includes validation for inputs like email addresses, event fields, and cart details.
7. For more advanced usage, refer to the [Bento API Documentation](https://docs.bentonow.com).


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

## Contributing

We welcome contributions! Please feel free to submit pull requests, report issues, or suggest improvements.

## License

The Bento SDK for Elixir is available as open source under the terms of the [MIT License](LICENSE.md).