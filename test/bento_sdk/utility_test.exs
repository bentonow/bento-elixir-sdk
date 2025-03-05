defmodule BentoSdk.UtilityTest do
  use ExUnit.Case
  # doctest BentoSdk.Utility

  import Mox

  # Make sure mocks are verified when the test exits
  setup :verify_on_exit!

  describe "utility API methods" do
    test "moderate_content/1" do
      BentoSdk.ClientMock
      |> expect(:moderate_content, fn content ->
        assert content == "This is a test content"
        {:ok, %{
          "valid" => true,
          "reasons" => [],
          "safe_original_content" => "This is a test content"
        }}
      end)

      assert {:ok, result} = BentoSdk.Utility.moderate_content("This is a test content")
      assert result["valid"] == true
      assert result["reasons"] == []
      assert result["safe_original_content"] == "This is a test content"
    end

    test "guess_gender/1" do
      BentoSdk.ClientMock
      |> expect(:guess_gender, fn name ->
        assert name == "John"
        {:ok, %{"gender" => "male", "confidence" => 0.95}}
      end)

      assert {:ok, result} = BentoSdk.Utility.guess_gender("John")
      assert result["gender"] == "male"
      assert result["confidence"] == 0.95
    end

    test "geolocate/1" do
      BentoSdk.ClientMock
      |> expect(:geolocate, fn ip_address ->
        assert ip_address == "8.8.8.8"
        {:ok, %{
          "country_name" => "United States",
          "city_name" => "Mountain View",
          "latitude" => 37.4056,
          "longitude" => -122.0775
        }}
      end)

      assert {:ok, result} = BentoSdk.Utility.geolocate("8.8.8.8")
      assert result["country_name"] == "United States"
      assert result["city_name"] == "Mountain View"
    end

    test "validate_email/1" do
      BentoSdk.ClientMock
      |> expect(:validate_email, fn email, _opts ->
        assert email == "test@example.com"
        {:ok, %{"valid" => true}}
      end)

      assert {:ok, result} = BentoSdk.Utility.validate_email("test@example.com")
      assert result["valid"] == true
    end

    test "validate_email/2 with options" do
      BentoSdk.ClientMock
      |> expect(:validate_email, fn email, opts ->
        assert email == "test@example.com"
        assert opts[:name] == "John Doe"
        assert opts[:ip] == "8.8.8.8"
        {:ok, %{"valid" => true}}
      end)

      assert {:ok, result} = BentoSdk.Utility.validate_email("test@example.com", name: "John Doe", ip: "8.8.8.8")
      assert result["valid"] == true
    end

    test "jesses_ruleset/1" do
      BentoSdk.ClientMock
      |> expect(:jesses_ruleset, fn email, _opts ->
        assert email == "test@example.com"
        {:ok, []}
      end)

      assert {:ok, reasons} = BentoSdk.Utility.jesses_ruleset("test@example.com")
      assert reasons == []
    end

    test "jesses_ruleset/2 with options" do
      BentoSdk.ClientMock
      |> expect(:jesses_ruleset, fn email, opts ->
        assert email == "test@gmail.com"
        assert opts[:block_free_providers] == true
        {:ok, ["Free email provider"]}
      end)

      assert {:ok, reasons} = BentoSdk.Utility.jesses_ruleset("test@gmail.com", block_free_providers: true)
      assert reasons == ["Free email provider"]
    end

    test "check_blacklist/1 with domain" do
      BentoSdk.ClientMock
      |> expect(:check_blacklist, fn params ->
        assert params.domain == "example.com"
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
      end)

      assert {:ok, result} = BentoSdk.Utility.check_blacklist(%{domain: "example.com"})
      assert result["query"] == "example.com"
      assert result["results"]["spamhaus"] == false
    end

    test "check_blacklist/1 with IP address" do
      BentoSdk.ClientMock
      |> expect(:check_blacklist, fn params ->
        assert params.ip_address == "8.8.8.8"
        {:ok, %{
          "query" => "8.8.8.8",
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
      end)

      assert {:ok, result} = BentoSdk.Utility.check_blacklist(%{ip_address: "8.8.8.8"})
      assert result["query"] == "8.8.8.8"
      assert result["results"]["spamhaus"] == false
    end
  end
end
