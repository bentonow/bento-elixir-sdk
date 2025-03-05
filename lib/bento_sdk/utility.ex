defmodule BentoSdk.Utility do
  @moduledoc """
  Utility functions provided by the Bento API.

  This module provides access to Bento's utility APIs for:
  - Content moderation
  - Gender guessing
  - IP geolocation
  - Email validation
  - Blacklist checking
  """

  @doc """
  Moderate content for profanity and inappropriate content.

  ## Examples

      BentoSdk.Utility.moderate_content("This is some content to check")
      {:ok, %{
        "valid" => true,
        "reasons" => [],
        "safe_original_content" => "This is some content to check"
      }}
  """
  def moderate_content(content) do
    client().moderate_content(content)
  end

  @doc """
  Guess the gender of a name.

  ## Examples

      BentoSdk.Utility.guess_gender("John")
      {:ok, %{
        "gender" => "male",
        "confidence" => 0.95
      }}
  """
  def guess_gender(name) do
    client().guess_gender(name)
  end

  @doc """
  Geolocate an IP address.

  ## Examples

      BentoSdk.Utility.geolocate("8.8.8.8")
      {:ok, %{
        "country_name" => "United States",
        "country_code2" => "US",
        "city_name" => "Mountain View",
        "latitude" => 37.4056,
        "longitude" => -122.0775
      }}
  """
  def geolocate(ip_address) do
    client().geolocate(ip_address)
  end

  @doc """
  Validate an email address using Bento's validation service.

  ## Parameters

  - `email` - The email address to validate
  - `opts` - Optional parameters:
    - `:name` - The contact's full name
    - `:user_agent` - The user agent string
    - `:ip` - The user's IP address

  ## Examples

      BentoSdk.Utility.validate_email("test@example.com")
      {:ok, %{"valid" => true}}

      BentoSdk.Utility.validate_email("test@example.com", name: "John Doe", ip: "8.8.8.8")
      {:ok, %{"valid" => true}}
  """
  def validate_email(email, opts \\ []) do
    client().validate_email(email, opts)
  end

  @doc """
  Check an email against Jesse's ruleset.

  Jesse's ruleset is a custom ruleset created by the founder of Bento that
  is extremely strict. It's recommended to log failures to monitor for false positives.

  ## Parameters

  - `email` - The email address to validate
  - `opts` - Optional parameters:
    - `:block_free_providers` - Whether to block free email providers
    - `:wiggleroom` - Set to true to reduce a few extremely opinionated checks

  ## Examples

      BentoSdk.Utility.jesses_ruleset("test@example.com")
      {:ok, []}

      BentoSdk.Utility.jesses_ruleset("test@example.com", block_free_providers: true)
      {:ok, ["Email provider is free"]}
  """
  def jesses_ruleset(email, opts \\ []) do
    client().jesses_ruleset(email, opts)
  end

  @doc """
  Check if a domain or IP address is on any blacklists.

  ## Parameters

  - `params` - A map containing either:
    - `:domain` - The domain to check (e.g., "example.com")
    - `:ip_address` - The IP address to check

  ## Examples

      BentoSdk.Utility.check_blacklist(%{domain: "example.com"})
      {:ok, %{
        "query" => "example.com",
        "description" => "If any of the following blacklist providers contains true you have a problem on your hand.",
        "results" => %{
          "just_registered" => false,
          "spamhaus" => false,
          "nordspam" => false,
          "spfbl" => false,
          "sorbs" => false,
          "abusix" => false
        }
      }}
  """
  def check_blacklist(params) do
    client().check_blacklist(params)
  end

  defp client do
    config = Application.get_env(:bento_sdk, :config, [])
    Keyword.get(config, :client, BentoSdk.Client)
  end
end
