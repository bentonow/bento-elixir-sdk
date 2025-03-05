defmodule BentoSdk.Events do
  @moduledoc """
  Functions for tracking events in Bento.

  The Events API allows you to track user behavior and trigger automations in Bento.
  Events will create new users if they don't already exist in your account.
  """

  @doc """
  Track an event for a subscriber.

  ## Parameters

    * `email` - The email address of the subscriber
    * `type` - The type of event (e.g., "page_viewed", "product_added_to_cart")
    * `fields` - Key-value pairs of data for the event (should not be nested)
    * `details` - Key-value pairs of data for the event (can be nested)

  ## Examples

      # Basic event
      BentoSdk.Events.track("user@example.com", "page_viewed")
      {:ok, %{
        "results" => 1,
        "failed" => 0
      }}

      # Event with fields
      BentoSdk.Events.track(
        "user@example.com",
        "page_viewed",
        %{
          "page" => "/products",
          "referrer" => "https://google.com"
        }
      )
      {:ok, %{
        "results" => 1,
        "failed" => 0
      }}

      # Complex event with fields and details
      BentoSdk.Events.track(
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
      {:ok, %{
        "results" => 1,
        "failed" => 0
      }}
  """
  def track(email, type, fields \\ %{}, details \\ %{}) do
    validate_email(email)
    validate_type(type)
    validate_fields(fields)
    validate_details(details)

    event = %{
      email: email,
      type: type
    }

    event = if Enum.empty?(fields), do: event, else: Map.put(event, :fields, fields)
    event = if Enum.empty?(details), do: event, else: Map.put(event, :details, details)

    import_events([event])
  end

  @doc """
  Import events in bulk.

  ## Parameters

    * `events` - A list of event maps, each with the following keys:
      * `email` - The email address of the subscriber
      * `type` - The type of event
      * `fields` - Key-value pairs of data for the event (optional, should not be nested)
      * `details` - Key-value pairs of data for the event (optional, can be nested)

  ## Examples

      BentoSdk.Events.import_events([
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
      {:ok, %{
        "results" => 2,
        "failed" => 0
      }}
  """
  def import_events(events) when is_list(events) do
    # Validate all events in the batch
    Enum.each(events, &validate_event/1)

    client().import_events(events)
  end

  @doc """
  Validates an email address.
  Raises an ArgumentError if the email is invalid.

  ## Parameters

    * `email` - The email address to validate
  """
  def validate_email(nil), do: raise(ArgumentError, "Email is required")
  def validate_email(""), do: raise(ArgumentError, "Email is required")

  def validate_email(email) when is_binary(email) do
    email_regex = ~r/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

    unless Regex.match?(email_regex, email) do
      raise ArgumentError, "Invalid email format"
    end

    :ok
  end

  @doc """
  Validates an event type.
  Raises an ArgumentError if the type is invalid.

  ## Parameters

    * `type` - The event type to validate
  """
  def validate_type(nil), do: raise(ArgumentError, "Event type is required")
  def validate_type(""), do: raise(ArgumentError, "Event type is required")
  def validate_type(_type), do: :ok

  @doc """
  Validates event fields.
  Raises an ArgumentError if the fields are invalid.

  ## Parameters

    * `fields` - The event fields to validate
  """
  def validate_fields(fields) when not is_map(fields) do
    raise ArgumentError, "Fields must be a map"
  end

  def validate_fields(_fields), do: :ok

  @doc """
  Validates event details.
  Raises an ArgumentError if the details are invalid.

  ## Parameters

    * `details` - The event details to validate
  """
  def validate_details(details) when not is_map(details) do
    raise ArgumentError, "Details must be a map"
  end

  def validate_details(details) do
    if Map.has_key?(details, "unique") || Map.has_key?(details, :unique) do
      validate_unique(Map.get(details, "unique") || Map.get(details, :unique))
    end

    if Map.has_key?(details, "value") || Map.has_key?(details, :value) do
      validate_value(Map.get(details, "value") || Map.get(details, :value))
    end

    if Map.has_key?(details, "cart") || Map.has_key?(details, :cart) do
      validate_cart(Map.get(details, "cart") || Map.get(details, :cart))
    end

    :ok
  end

  @doc """
  Validates an event.
  Raises an ArgumentError if the event is invalid.

  ## Parameters

    * `event` - The event to validate
  """
  def validate_event(event) do
    validate_email(event[:email])
    validate_type(event[:type])

    if Map.has_key?(event, :fields) do
      validate_fields(event[:fields])
    end

    if Map.has_key?(event, :details) do
      validate_details(event[:details])
    end

    :ok
  end

  # Private validation functions

  defp validate_unique(nil), do: :ok
  defp validate_unique(""), do: :ok
  defp validate_unique(unique) when not is_map(unique), do: raise(ArgumentError, "Unique must be a map")
  defp validate_unique(%{key: _}), do: :ok
  defp validate_unique(%{"key" => _}), do: :ok
  defp validate_unique(_), do: raise(ArgumentError, "Unique must have a key")

  defp validate_value(nil), do: :ok
  defp validate_value(""), do: :ok
  defp validate_value(value) when not is_map(value), do: raise(ArgumentError, "Value must be a map")

  defp validate_value(value) do
    currency = Map.get(value, :currency) || Map.get(value, "currency")
    amount = Map.get(value, :amount) || Map.get(value, "amount")

    if is_nil(currency) || currency == "" do
      raise ArgumentError, "Value must have a currency"
    end

    if is_nil(amount) do
      raise ArgumentError, "Value must have an amount"
    end

    :ok
  end

  defp validate_cart(nil), do: :ok
  defp validate_cart(""), do: :ok
  defp validate_cart(cart) when not is_map(cart), do: raise(ArgumentError, "Cart must be a map")
  
  defp validate_cart(cart) do
    # Validate items if present
    if Map.has_key?(cart, "items") || Map.has_key?(cart, :items) do
      items = Map.get(cart, "items") || Map.get(cart, :items)
      validate_cart_items(items)
    end
    
    # Other cart fields like abandoned_checkout_url are optional according to the API docs
    
    :ok
  end
  
  defp validate_cart_items(items) when not is_list(items), do: raise(ArgumentError, "Cart items must be a list")
  
  defp validate_cart_items(items) do
    Enum.each(items, &validate_cart_item/1)
    :ok
  end
  
  defp validate_cart_item(item) when not is_map(item), do: raise(ArgumentError, "Cart item must be a map")
  
  defp validate_cart_item(item) do
    # According to the API docs, these fields are required for cart items
    product_sku = Map.get(item, "product_sku") || Map.get(item, :product_sku)
    
    if is_nil(product_sku) || product_sku == "" do
      raise ArgumentError, "Product SKU is required in cart item"
    end
    
    product_name = Map.get(item, "product_name") || Map.get(item, :product_name)
    
    if is_nil(product_name) || product_name == "" do
      raise ArgumentError, "Product name is required in cart item"
    end
    
    quantity = Map.get(item, "quantity") || Map.get(item, :quantity)
    
    if is_nil(quantity) do
      raise ArgumentError, "Quantity is required in cart item"
    end
    
    :ok
  end

  defp client do
    config = Application.get_env(:bento_sdk, :config, [])
    Keyword.get(config, :client, BentoSdk.Client)
  end
end
