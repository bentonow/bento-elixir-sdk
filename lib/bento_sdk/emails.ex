defmodule BentoSdk.Emails do
  @moduledoc """
  Functions for sending emails through Bento.
  """

  @email_regex ~r/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

  @doc """
  Send a single email to a subscriber.
  This respects subscription status - unsubscribed users won't receive the email.

  ## Parameters

    * `to` - The email address of the recipient
    * `from` - The email address of the sender (must be an author in your account)
    * `subject` - The subject of the email
    * `html_body` - The HTML body of the email
    * `personalizations` - Key-value pairs of custom data to be injected into the email

  ## Examples

      BentoSdk.Emails.send(
        "user@example.com",
        "noreply@yourdomain.com",
        "Welcome to our service",
        "<h1>Welcome!</h1><p>Thanks for signing up.</p>",
        %{
          "first_name" => "John"
        }
      )
      {:ok, %{
        "results" => 1
      }}
  """
  def send(to, from, subject, html_body, personalizations \\ %{}) do
    validate_email(to)
    validate_email(from)

    payload = %{
      to: to,
      from: from,
      subject: subject,
      html_body: html_body,
      personalizations: personalizations
    }

    send_bulk([payload])
  end

  @doc """
  Send a transactional email to a subscriber.
  This will always send, even if the user is unsubscribed.

  ## Parameters

    * `to` - The email address of the recipient
    * `from` - The email address of the sender (must be an author in your account)
    * `subject` - The subject of the email
    * `html_body` - The HTML body of the email
    * `personalizations` - Key-value pairs of custom data to be injected into the email

  ## Examples

      BentoSdk.Emails.send_transactional(
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
        "results" => 1
      }}
  """
  def send_transactional(to, from, subject, html_body, personalizations \\ %{}) do
    validate_email(to)
    validate_email(from)

    payload = %{
      to: to,
      from: from,
      subject: subject,
      html_body: html_body,
      personalizations: personalizations,
      transactional: true
    }

    send_bulk([payload])
  end

  @doc """
  Send multiple emails in a single batch.

  ## Parameters

    * `emails` - A list of email maps, each with the following keys:
      * `to` - The email address of the recipient
      * `from` - The email address of the sender
      * `subject` - The subject of the email
      * `html_body` - The HTML body of the email
      * `personalizations` - Key-value pairs of custom data (optional)
      * `transactional` - Whether this is a transactional email (optional)

  ## Examples

      BentoSdk.Emails.send_bulk([
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
      {:ok, %{
        "results" => 2
      }}
  """
  def send_bulk(emails) when is_list(emails) do
    # Validate all emails in the batch
    Enum.each(emails, fn email ->
      validate_email(email[:to])
      validate_email(email[:from])
    end)

    client().send_bulk_emails(emails)
  end

  @doc """
  Validates that an email address is properly formatted.
  Raises an ArgumentError if the email is invalid.

  ## Parameters

    * `email` - The email address to validate

  ## Examples

      BentoSdk.Emails.validate_email("user@example.com")
      :ok

      BentoSdk.Emails.validate_email("invalid-email")
      ** (ArgumentError) Invalid email format
  """
  def validate_email(nil), do: raise(ArgumentError, "Email is required")
  def validate_email(""), do: raise(ArgumentError, "Email is required")

  def validate_email(email) when is_binary(email) do
    unless Regex.match?(@email_regex, email) do
      raise ArgumentError, "Invalid email format"
    end

    :ok
  end

  defp client do
    config = Application.get_env(:bento_sdk, :config, [])
    Keyword.get(config, :client, BentoSdk.Client)
  end
end
