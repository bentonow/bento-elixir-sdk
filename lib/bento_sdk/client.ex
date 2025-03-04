defmodule BentoSdk.Client do
  @moduledoc """
  HTTP client for the Bento API.
  """

  @behaviour BentoSdk.ClientBehaviour

  @base_url "https://app.bentonow.com/api/v1"

  # Subscriber methods

  @doc """
  Find or create a subscriber in Bento.
  """
  @impl true
  def find_or_create_subscriber(email) do
    case find_subscriber(email) do
      {:ok, nil} -> create_subscriber(email)
      {:ok, subscriber} -> {:ok, subscriber}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Find a subscriber in Bento.
  """
  @impl true
  def find_subscriber(email) do
    config = get_config()
    site_uuid = Keyword.fetch!(config, :site_uuid)

    url = "#{@base_url}/fetch/subscribers?site_uuid=#{site_uuid}&email=#{URI.encode_www_form(email)}"

    headers = get_headers()

    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"data" => data}} when is_map(data) and map_size(data) > 0 ->
            {:ok, data}

          {:ok, _} ->
            # Subscriber not found
            {:ok, nil}

          error ->
            {:error, "Failed to parse response: #{inspect(error)}"}
        end

      {:ok, %HTTPoison.Response{status_code: code, body: body}} ->
        {:error, "API error: #{code}, #{body}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "HTTP request failed: #{inspect(reason)}"}
    end
  end

  @doc """
  Create a subscriber in Bento.
  """
  @impl true
  def create_subscriber(email) do
    config = get_config()
    site_uuid = Keyword.fetch!(config, :site_uuid)

    url = "#{@base_url}/fetch/subscribers?site_uuid=#{site_uuid}"

    headers = get_headers()

    # Only use email
    subscriber_data = %{email: email}

    payload = Jason.encode!(%{subscriber: subscriber_data})

    case HTTPoison.post(url, payload, headers) do
      {:ok, %HTTPoison.Response{status_code: code, body: body}} when code in 200..299 ->
        case Jason.decode(body) do
          {:ok, %{"data" => data}} ->
            {:ok, data}

          error ->
            {:error, "Failed to parse response: #{inspect(error)}"}
        end

      {:ok, %HTTPoison.Response{status_code: code, body: body}} ->
        {:error, "API error: #{code}, #{body}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "HTTP request failed: #{inspect(reason)}"}
    end
  end

  @doc """
  Import or update subscribers in bulk.
  """
  @impl true
  def import_subscribers(subscribers) do
    config = get_config()
    site_uuid = Keyword.fetch!(config, :site_uuid)

    url = "#{@base_url}/batch/subscribers?site_uuid=#{site_uuid}"

    headers = get_headers()

    payload = Jason.encode!(%{subscribers: subscribers})

    case HTTPoison.post(url, payload, headers) do
      {:ok, %HTTPoison.Response{status_code: code, body: body}} when code in 200..299 ->
        case Jason.decode(body) do
          {:ok, response} ->
            {:ok, response}

          error ->
            {:error, "Failed to parse response: #{inspect(error)}"}
        end

      {:ok, %HTTPoison.Response{status_code: code, body: body}} ->
        {:error, "API error: #{code}, #{body}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "HTTP request failed: #{inspect(reason)}"}
    end
  end

  @doc """
  Run a command to change a subscriber's data.
  """
  @impl true
  def run_command(command, email, query) do
    config = get_config()
    site_uuid = Keyword.fetch!(config, :site_uuid)

    url = "#{@base_url}/fetch/commands?site_uuid=#{site_uuid}"

    headers = get_headers()

    payload = Jason.encode!(%{
      command: [
        %{
          command: command,
          email: email,
          query: query
        }
      ]
    })

    case HTTPoison.post(url, payload, headers) do
      {:ok, %HTTPoison.Response{status_code: code, body: body}} when code in 200..299 ->
        case Jason.decode(body) do
          {:ok, response} ->
            {:ok, response}

          error ->
            {:error, "Failed to parse response: #{inspect(error)}"}
        end

      {:ok, %HTTPoison.Response{status_code: code, body: body}} ->
        {:error, "API error: #{code}, #{body}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "HTTP request failed: #{inspect(reason)}"}
    end
  end

  @doc """
  Add a tag to a subscriber.
  """
  @impl true
  def add_tag(email, tag) do
    run_command("add_tag", email, tag)
  end

  @doc """
  Add a tag to a subscriber via an event.
  """
  @impl true
  def add_tag_via_event(email, tag) do
    run_command("add_tag_via_event", email, tag)
  end

  @doc """
  Remove a tag from a subscriber.
  """
  @impl true
  def remove_tag(email, tag) do
    run_command("remove_tag", email, tag)
  end

  @doc """
  Add a field to a subscriber.
  """
  @impl true
  def add_field(email, key, value) do
    run_command("add_field", email, %{key: key, value: value})
  end

  @doc """
  Remove a field from a subscriber.
  """
  @impl true
  def remove_field(email, field) do
    run_command("remove_field", email, field)
  end

  @doc """
  Subscribe a user.
  """
  @impl true
  def subscribe(email) do
    run_command("subscribe", email, nil)
  end

  @doc """
  Unsubscribe a user.
  """
  @impl true
  def unsubscribe(email) do
    run_command("unsubscribe", email, nil)
  end

  @doc """
  Change a subscriber's email.
  """
  @impl true
  def change_email(old_email, new_email) do
    run_command("change_email", old_email, new_email)
  end

  # Event methods

  @doc """
  Track an event in Bento.
  """
  @impl true
  def track_event(email, type, fields \\ %{}, details \\ %{}) do
    config = get_config()
    site_uuid = Keyword.fetch!(config, :site_uuid)

    url = "#{@base_url}/fetch/events?site_uuid=#{site_uuid}"

    headers = get_headers()

    payload = Jason.encode!(%{
      event: %{
        email: email,
        type: type,
        fields: fields,
        details: details
      }
    })

    case HTTPoison.post(url, payload, headers) do
      {:ok, %HTTPoison.Response{status_code: code, body: body}} when code in 200..299 ->
        case Jason.decode(body) do
          {:ok, response} ->
            {:ok, response}

          error ->
            {:error, "Failed to parse response: #{inspect(error)}"}
        end

      {:ok, %HTTPoison.Response{status_code: code, body: body}} ->
        {:error, "API error: #{code}, #{body}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "HTTP request failed: #{inspect(reason)}"}
    end
  end

  @doc """
  Import events in bulk.
  """
  @impl true
  def import_events(events) do
    config = get_config()
    site_uuid = Keyword.fetch!(config, :site_uuid)

    url = "#{@base_url}/batch/events?site_uuid=#{site_uuid}"

    headers = get_headers()

    payload = Jason.encode!(%{events: events})

    case HTTPoison.post(url, payload, headers) do
      {:ok, %HTTPoison.Response{status_code: code, body: body}} when code in 200..299 ->
        case Jason.decode(body) do
          {:ok, response} ->
            {:ok, response}

          error ->
            {:error, "Failed to parse response: #{inspect(error)}"}
        end

      {:ok, %HTTPoison.Response{status_code: code, body: body}} ->
        {:error, "API error: #{code}, #{body}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "HTTP request failed: #{inspect(reason)}"}
    end
  end

  # Email methods

  @doc """
  Send an email through Bento.
  """
  @impl true
  def send_email(to, from, subject, html_body, personalizations \\ %{}) do
    config = get_config()
    site_uuid = Keyword.fetch!(config, :site_uuid)

    url = "#{@base_url}/fetch/emails?site_uuid=#{site_uuid}"

    headers = get_headers()

    payload = Jason.encode!(%{
      email: %{
        to: to,
        from: from,
        subject: subject,
        html_body: html_body,
        personalizations: personalizations
      }
    })

    case HTTPoison.post(url, payload, headers) do
      {:ok, %HTTPoison.Response{status_code: code, body: body}} when code in 200..299 ->
        case Jason.decode(body) do
          {:ok, response} ->
            {:ok, response}

          error ->
            {:error, "Failed to parse response: #{inspect(error)}"}
        end

      {:ok, %HTTPoison.Response{status_code: code, body: body}} ->
        {:error, "API error: #{code}, #{body}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "HTTP request failed: #{inspect(reason)}"}
    end
  end

  @doc """
  Send a transactional email through Bento.
  """
  @impl true
  def send_transactional_email(to, from, subject, html_body, personalizations \\ %{}) do
    config = get_config()
    site_uuid = Keyword.fetch!(config, :site_uuid)

    url = "#{@base_url}/fetch/transactional_emails?site_uuid=#{site_uuid}"

    headers = get_headers()

    payload = Jason.encode!(%{
      email: %{
        to: to,
        from: from,
        subject: subject,
        html_body: html_body,
        personalizations: personalizations
      }
    })

    case HTTPoison.post(url, payload, headers) do
      {:ok, %HTTPoison.Response{status_code: code, body: body}} when code in 200..299 ->
        case Jason.decode(body) do
          {:ok, response} ->
            {:ok, response}

          error ->
            {:error, "Failed to parse response: #{inspect(error)}"}
        end

      {:ok, %HTTPoison.Response{status_code: code, body: body}} ->
        {:error, "API error: #{code}, #{body}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "HTTP request failed: #{inspect(reason)}"}
    end
  end

  # Spam API methods

  @doc """
  Check if an email is valid.
  """
  @impl true
  def email_valid?(email) do
    config = get_config()
    site_uuid = Keyword.fetch!(config, :site_uuid)

    url = "#{@base_url}/fetch/spam/valid?site_uuid=#{site_uuid}&email=#{URI.encode_www_form(email)}"

    headers = get_headers()

    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"data" => %{"valid" => valid}}} ->
            {:ok, valid}

          error ->
            {:error, "Failed to parse response: #{inspect(error)}"}
        end

      {:ok, %HTTPoison.Response{status_code: code, body: body}} ->
        {:error, "API error: #{code}, #{body}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "HTTP request failed: #{inspect(reason)}"}
    end
  end

  @doc """
  Check if an email is risky.
  """
  @impl true
  def email_risky?(email) do
    config = get_config()
    site_uuid = Keyword.fetch!(config, :site_uuid)

    url = "#{@base_url}/fetch/spam/risky?site_uuid=#{site_uuid}&email=#{URI.encode_www_form(email)}"

    headers = get_headers()

    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"data" => %{"risky" => risky}}} ->
            {:ok, risky}

          error ->
            {:error, "Failed to parse response: #{inspect(error)}"}
        end

      {:ok, %HTTPoison.Response{status_code: code, body: body}} ->
        {:error, "API error: #{code}, #{body}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "HTTP request failed: #{inspect(reason)}"}
    end
  end

  @doc """
  Check against the special "Jesse's Ruleset".
  """
  @impl true
  def jesses_ruleset_reasons(email, opts \\ []) do
    ruleset = Keyword.get(opts, :ruleset, "standard")
    
    config = get_config()
    site_uuid = Keyword.fetch!(config, :site_uuid)

    url = "#{@base_url}/fetch/spam/jesses_ruleset_reasons?site_uuid=#{site_uuid}&email=#{URI.encode_www_form(email)}&ruleset=#{ruleset}"

    headers = get_headers()

    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"data" => data}} when is_list(data) ->
            {:ok, data}

          {:ok, _} ->
            {:ok, []}

          error ->
            {:error, "Failed to parse response: #{inspect(error)}"}
        end

      {:ok, %HTTPoison.Response{status_code: code, body: body}} ->
        {:error, "API error: #{code}, #{body}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "HTTP error: #{inspect(reason)}"}
    end
  end
  
  # Utility API methods
  
  @doc """
  Moderate content for profanity and other inappropriate content.
  
  Returns a map with moderation results.
  """
  @impl true
  def moderate_content(content) do
    config = get_config()
    site_uuid = Keyword.fetch!(config, :site_uuid)

    url = "#{@base_url}/utility/moderate_content"
    
    headers = get_headers()
    
    payload = %{
      site_uuid: site_uuid,
      content: content
    }
    
    case HTTPoison.post(url, Jason.encode!(payload), headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"data" => data}} ->
            {:ok, data}

          error ->
            {:error, "Failed to parse response: #{inspect(error)}"}
        end

      {:ok, %HTTPoison.Response{status_code: code, body: body}} ->
        {:error, "API error: #{code}, #{body}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "HTTP error: #{inspect(reason)}"}
    end
  end
  
  @doc """
  Guess the gender of a name.
  
  Returns a map with gender probability information.
  """
  @impl true
  def guess_gender(name) do
    config = get_config()
    site_uuid = Keyword.fetch!(config, :site_uuid)

    url = "#{@base_url}/utility/guess_gender"
    
    headers = get_headers()
    
    payload = %{
      site_uuid: site_uuid,
      name: name
    }
    
    case HTTPoison.post(url, Jason.encode!(payload), headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"data" => data}} ->
            {:ok, data}

          error ->
            {:error, "Failed to parse response: #{inspect(error)}"}
        end

      {:ok, %HTTPoison.Response{status_code: code, body: body}} ->
        {:error, "API error: #{code}, #{body}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "HTTP error: #{inspect(reason)}"}
    end
  end
  
  @doc """
  Geolocate an IP address.
  
  Returns a map with geolocation information.
  """
  @impl true
  def geolocate(ip_address) do
    config = get_config()
    site_uuid = Keyword.fetch!(config, :site_uuid)

    url = "#{@base_url}/utility/geolocate"
    
    headers = get_headers()
    
    payload = %{
      site_uuid: site_uuid,
      ip_address: ip_address
    }
    
    case HTTPoison.post(url, Jason.encode!(payload), headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"data" => data}} ->
            {:ok, data}

          error ->
            {:error, "Failed to parse response: #{inspect(error)}"}
        end

      {:ok, %HTTPoison.Response{status_code: code, body: body}} ->
        {:error, "API error: #{code}, #{body}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "HTTP error: #{inspect(reason)}"}
    end
  end

  # Private helpers

  defp get_headers do
    config = get_config()
    username = Keyword.fetch!(config, :username)
    password = Keyword.fetch!(config, :password)

    [
      {"Content-Type", "application/json"},
      {"Accept", "application/json"},
      {"Authorization", "Basic #{Base.encode64("#{username}:#{password}")}"}
    ]
  end

  # Get the configuration for the SDK
  defp get_config do
    Application.get_env(:bento_sdk, :config) ||
      Application.get_env(:bento_sdk, BentoSdk) ||
      []
  end
end
