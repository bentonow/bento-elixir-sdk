defmodule BentoSdk.Client do
  @moduledoc """
  HTTP client for the Bento API.
  """

  @behaviour BentoSdk.ClientBehaviour

  @base_url "https://app.bentonow.com/api/v1"

  # Get the HTTP client to use (allows for mocking in tests)
  defp http_client do
    Application.get_env(:bento_sdk, :http_client, HTTPoison)
  end

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

    case http_client().get(url, headers) do
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

    case http_client().post(url, payload, headers) do
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

    case http_client().post(url, payload, headers) do
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

    case http_client().post(url, payload, headers) do
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

  # Broadcast methods

  @doc """
  Get a list of broadcasts.
  """
  @impl true
  def get_broadcasts do
    config = get_config()
    site_uuid = Keyword.fetch!(config, :site_uuid)

    url = "#{@base_url}/fetch/broadcasts?site_uuid=#{site_uuid}"

    headers = get_headers()

    case http_client().get(url, headers) do
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
  Create new broadcasts.
  """
  @impl true
  def create_broadcasts(broadcasts) when is_list(broadcasts) do
    config = get_config()
    site_uuid = Keyword.fetch!(config, :site_uuid)

    url = "#{@base_url}/batch/broadcasts?site_uuid=#{site_uuid}"

    headers = get_headers()

    payload = Jason.encode!(%{broadcasts: broadcasts})

    case http_client().post(url, payload, headers) do
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

  # Event methods

  @doc """
  Track an event in Bento.
  """
  @impl true
  def track_event(email, type, fields \\ %{}, details \\ %{}) do
    config = get_config()
    site_uuid = Keyword.fetch!(config, :site_uuid)

    url = "#{@base_url}/batch/events?site_uuid=#{site_uuid}"

    headers = get_headers()

    event = %{
      email: email,
      type: type
    }

    event = if Enum.empty?(fields), do: event, else: Map.put(event, :fields, fields)
    event = if Enum.empty?(details), do: event, else: Map.put(event, :details, details)

    payload = Jason.encode!(%{events: [event]})

    case http_client().post(url, payload, headers) do
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

    case http_client().post(url, payload, headers) do
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
  def send_email(to, from, subject, html_body, personalizations \\ %{}, transactional \\ false) do
    url = "#{@base_url}/batch/emails"

    payload = %{
      "emails" => [
        %{
          "to" => to,
          "from" => from,
          "subject" => subject,
          "html_body" => html_body,
          "personalizations" => personalizations
        }
      ],
      "transactional" => transactional
    }

    case post(url, payload) do
      {:ok, response} -> {:ok, response}
      {:error, reason} -> {:error, reason}
    end
  end

  @impl true
  def send_transactional_email(to, from, subject, html_body, personalizations \\ %{}) do
    send_email(to, from, subject, html_body, personalizations, true)
  end

  @impl true
  def send_bulk_emails(emails) when is_list(emails) do
    url = "#{@base_url}/batch/emails"

    # Convert atom keys to strings for the API
    formatted_emails = Enum.map(emails, fn email ->
      email
      |> Enum.map(fn {k, v} -> {to_string(k), v} end)
      |> Enum.into(%{})
    end)

    payload = %{
      "emails" => formatted_emails
    }

    # If any email in the batch is transactional, mark the whole batch as transactional
    transactional = Enum.any?(emails, fn email ->
      Map.get(email, :transactional, false) || Map.get(email, "transactional", false)
    end)

    payload = Map.put(payload, "transactional", transactional)

    case post(url, payload) do
      {:ok, response} -> {:ok, response}
      {:error, reason} -> {:error, reason}
    end
  end

  # Spam API methods

  @doc """
  Check if an email is valid.
  """
  def email_valid?(email) do
    config = get_config()
    site_uuid = Keyword.fetch!(config, :site_uuid)

    url = "#{@base_url}/fetch/spam/valid?site_uuid=#{site_uuid}&email=#{URI.encode_www_form(email)}"

    headers = get_headers()

    case http_client().get(url, headers) do
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
  def email_risky?(email) do
    config = get_config()
    site_uuid = Keyword.fetch!(config, :site_uuid)

    url = "#{@base_url}/fetch/spam/risky?site_uuid=#{site_uuid}&email=#{URI.encode_www_form(email)}"

    headers = get_headers()

    case http_client().get(url, headers) do
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
  def jesses_ruleset(email, opts) do
    config = get_config()
    site_uuid = Keyword.fetch!(config, :site_uuid)

    url = "#{@base_url}/experimental/jesses_ruleset"

    headers = get_headers()

    # Start with required parameters
    payload = %{
      site_uuid: site_uuid,
      email: email
    }

    # Add optional parameters if provided
    payload = if Keyword.has_key?(opts, :block_free_providers),
      do: Map.put(payload, :block_free_providers, opts[:block_free_providers]),
      else: payload

    payload = if Keyword.has_key?(opts, :wiggleroom),
      do: Map.put(payload, :wiggleroom, opts[:wiggleroom]),
      else: payload

    case http_client().post(url, Jason.encode!(payload), headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"data" => data}} when is_map(data) ->
            reasons = Map.get(data, "reasons", [])
            {:ok, reasons}

          {:ok, %{"reasons" => reasons}} ->
            {:ok, reasons}

          {:ok, response} ->
            if is_list(response) do
              {:ok, response}
            else
              {:ok, []}
            end

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
  Check if a domain or IP address is on any blacklists.

  Returns a map with blacklist check results.
  """
  @impl true
  def check_blacklist(params) do
    config = get_config()
    site_uuid = Keyword.fetch!(config, :site_uuid)

    url = "#{@base_url}/experimental/blacklist"

    headers = get_headers()

    # Start with required parameters
    payload = Map.put(params, :site_uuid, site_uuid)

    case http_client().post(url, Jason.encode!(payload), headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"data" => data}} ->
            {:ok, data}

          {:ok, response} ->
            {:ok, response}

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
  Moderate content for profanity and other inappropriate content.

  Returns a map with moderation results.
  """
  @impl true
  def moderate_content(content) do
    config = get_config()
    site_uuid = Keyword.fetch!(config, :site_uuid)

    url = "#{@base_url}/experimental/content_moderation"

    headers = get_headers()

    payload = %{
      site_uuid: site_uuid,
      content: content
    }

    case http_client().post(url, Jason.encode!(payload), headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"data" => data}} ->
            {:ok, data}

          {:ok, response} ->
            {:ok, response}

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

    url = "#{@base_url}/experimental/gender"

    headers = get_headers()

    payload = %{
      site_uuid: site_uuid,
      name: name
    }

    case http_client().post(url, Jason.encode!(payload), headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"data" => data}} ->
            {:ok, data}

          {:ok, response} ->
            {:ok, response}

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
    url = "#{@base_url}/experimental/geolocation?ip=#{URI.encode_www_form(ip_address)}"

    headers = get_headers()

    case http_client().get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"data" => data}} ->
            {:ok, data}

          {:ok, response} ->
            {:ok, response}

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
  Validate an email address using Bento's validation service.

  Returns a map with validation results.
  """
  @impl true
  def validate_email(email, opts) do
    config = get_config()
    site_uuid = Keyword.fetch!(config, :site_uuid)

    url = "#{@base_url}/experimental/validation"

    headers = get_headers()

    # Start with required parameters
    payload = %{
      site_uuid: site_uuid,
      email: email
    }

    # Add optional parameters if provided
    payload = if Keyword.has_key?(opts, :name), do: Map.put(payload, :name, opts[:name]), else: payload
    payload = if Keyword.has_key?(opts, :user_agent), do: Map.put(payload, :user_agent, opts[:user_agent]), else: payload
    payload = if Keyword.has_key?(opts, :ip), do: Map.put(payload, :ip, opts[:ip]), else: payload

    case http_client().post(url, Jason.encode!(payload), headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"data" => data}} ->
            {:ok, data}

          {:ok, response} ->
            {:ok, response}

          error ->
            {:error, "Failed to parse response: #{inspect(error)}"}
        end

      {:ok, %HTTPoison.Response{status_code: code, body: body}} ->
        {:error, "API error: #{code}, #{body}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "HTTP error: #{inspect(reason)}"}
    end
  end

  # Stats API methods

  @doc """
  Get site statistics.

  Returns basic statistics about your Bento site, including user count,
  subscriber count, and unsubscriber count.
  """
  @impl true
  def get_site_stats do
    config = get_config()
    site_uuid = Keyword.fetch!(config, :site_uuid)

    url = "#{@base_url}/stats/site?site_uuid=#{site_uuid}"

    headers = get_headers()

    case http_client().get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, data} ->
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
  Get segment statistics.

  Returns statistics for a specific segment, including user count,
  subscriber count, and unsubscriber count.
  """
  @impl true
  def get_segment_stats(segment_id) do
    config = get_config()
    site_uuid = Keyword.fetch!(config, :site_uuid)

    url = "#{@base_url}/stats/segment?site_uuid=#{site_uuid}&segment_id=#{segment_id}"

    headers = get_headers()

    case http_client().get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, data} ->
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
  Get report statistics.

  Returns data for a specific report.
  """
  @impl true
  def get_report_stats(report_id) do
    config = get_config()
    site_uuid = Keyword.fetch!(config, :site_uuid)

    url = "#{@base_url}/stats/report?site_uuid=#{site_uuid}&report_id=#{report_id}"

    headers = get_headers()

    case http_client().get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, data} ->
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
  Get subscriber growth statistics.

  Returns subscriber growth statistics for a specific time period.
  """
  @impl true
  def get_subscriber_growth(start_date, end_date) do
    config = get_config()
    site_uuid = Keyword.fetch!(config, :site_uuid)

    url = "#{@base_url}/stats/subscriber_growth?site_uuid=#{site_uuid}&start_date=#{start_date}&end_date=#{end_date}"

    headers = get_headers()

    case http_client().get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, data} ->
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
  Get email statistics for a time period.

  Returns a map with email statistics.
  """
  def get_email_stats(start_date, end_date) do
    config = get_config()
    site_uuid = Keyword.fetch!(config, :site_uuid)

    url = "#{@base_url}/stats/email?site_uuid=#{site_uuid}&start_date=#{start_date}&end_date=#{end_date}"

    headers = get_headers()

    case http_client().get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, data} ->
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
  Get tag statistics.

  Returns statistics for a specific tag over a time period.
  """
  def get_tag_stats(tag_name, start_date, end_date) do
    config = get_config()
    site_uuid = Keyword.fetch!(config, :site_uuid)

    url = "#{@base_url}/stats/tag?site_uuid=#{site_uuid}&tag=#{URI.encode_www_form(tag_name)}&start_date=#{start_date}&end_date=#{end_date}"

    headers = get_headers()

    case http_client().get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, data} ->
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
  Get broadcast statistics.

  Returns statistics for a specific broadcast.
  """
  def get_broadcast_stats(broadcast_id) do
    config = get_config()
    site_uuid = Keyword.fetch!(config, :site_uuid)

    url = "#{@base_url}/stats/broadcast?site_uuid=#{site_uuid}&broadcast_id=#{broadcast_id}"

    headers = get_headers()

    case http_client().get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, data} ->
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
  Get all tags in your account.
  """
  @impl true
  def get_tags do
    config = get_config()
    site_uuid = Keyword.fetch!(config, :site_uuid)

    url = "#{@base_url}/fetch/tags?site_uuid=#{site_uuid}"

    headers = get_headers()

    case http_client().get(url, headers) do
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
  Create a new tag in your account.
  """
  @impl true
  def create_tag(name) do
    config = get_config()
    site_uuid = Keyword.fetch!(config, :site_uuid)

    url = "#{@base_url}/fetch/tags?site_uuid=#{site_uuid}"

    headers = get_headers()

    payload = Jason.encode!(%{tag: %{name: name}})

    case http_client().post(url, payload, headers) do
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
  Get all fields in your account.

  Returns a list of fields.
  """
  @impl true
  def get_fields do
    config = get_config()
    site_uuid = Keyword.fetch!(config, :site_uuid)

    url = "#{@base_url}/fetch/fields?site_uuid=#{site_uuid}"

    headers = get_headers()

    case http_client().get(url, headers) do
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
  Create a new field in your account.

  Returns the details of the created field.
  """
  @impl true
  def create_field(key) do
    config = get_config()
    site_uuid = Keyword.fetch!(config, :site_uuid)

    url = "#{@base_url}/fetch/fields?site_uuid=#{site_uuid}"

    headers = get_headers()

    payload = Jason.encode!(%{field: %{key: key}})

    case http_client().post(url, payload, headers) do
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

  defp post(url, payload) do
    config = get_config()
    site_uuid = Keyword.fetch!(config, :site_uuid)

    headers = get_headers()

    case http_client().post("#{url}?site_uuid=#{site_uuid}", Jason.encode!(payload), headers) do
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
        {:error, "HTTP error: #{inspect(reason)}"}
    end
  end

  # Get the configuration for the SDK
  defp get_config do
    Application.get_env(:bento_sdk, :config) ||
      Application.get_env(:bento_sdk, BentoSdk) ||
      []
  end
end
