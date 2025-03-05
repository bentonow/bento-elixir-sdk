defmodule BentoSdk.EmailsTest do
  use ExUnit.Case, async: true
  import Mox

  setup :verify_on_exit!

  describe "validate_email/1" do
    test "validates a valid email" do
      assert :ok = BentoSdk.Emails.validate_email("test@example.com")
    end

    test "raises error for nil email" do
      assert_raise ArgumentError, "Email is required", fn ->
        BentoSdk.Emails.validate_email(nil)
      end
    end

    test "raises error for empty email" do
      assert_raise ArgumentError, "Email is required", fn ->
        BentoSdk.Emails.validate_email("")
      end
    end

    test "raises error for invalid email format" do
      assert_raise ArgumentError, "Invalid email format", fn ->
        BentoSdk.Emails.validate_email("invalid-email")
      end
    end
  end

  describe "send/5" do
    test "sends an email" do
      BentoSdk.ClientMock
      |> expect(:send_bulk_emails, fn emails ->
        assert length(emails) == 1
        email = hd(emails)
        assert email[:to] == "test@example.com"
        assert email[:from] == "sender@example.com"
        assert email[:subject] == "Test Subject"
        assert email[:html_body] == "<h1>Test</h1>"
        assert email[:personalizations] == %{"name" => "Test User"}
        
        {:ok, %{"results" => 1}}
      end)

      assert {:ok, %{"results" => 1}} =
               BentoSdk.Emails.send(
                 "test@example.com",
                 "sender@example.com",
                 "Test Subject",
                 "<h1>Test</h1>",
                 %{"name" => "Test User"}
               )
    end

    test "handles error response" do
      BentoSdk.ClientMock
      |> expect(:send_bulk_emails, fn _ ->
        {:error, "Failed to send email"}
      end)

      assert {:error, "Failed to send email"} =
               BentoSdk.Emails.send(
                 "test@example.com",
                 "sender@example.com",
                 "Test Subject",
                 "<h1>Test</h1>",
                 %{}
               )
    end

    test "validates email addresses" do
      assert_raise ArgumentError, "Invalid email format", fn ->
        BentoSdk.Emails.send(
          "invalid-email",
          "sender@example.com",
          "Test Subject",
          "<h1>Test</h1>",
          %{}
        )
      end

      assert_raise ArgumentError, "Invalid email format", fn ->
        BentoSdk.Emails.send(
          "test@example.com",
          "invalid-sender",
          "Test Subject",
          "<h1>Test</h1>",
          %{}
        )
      end
    end
  end

  describe "send_transactional/5" do
    test "sends a transactional email" do
      BentoSdk.ClientMock
      |> expect(:send_bulk_emails, fn emails ->
        assert length(emails) == 1
        email = hd(emails)
        assert email[:to] == "test@example.com"
        assert email[:from] == "sender@example.com"
        assert email[:subject] == "Test Subject"
        assert email[:html_body] == "<h1>Test</h1>"
        assert email[:personalizations] == %{"name" => "Test User"}
        assert email[:transactional] == true
        
        {:ok, %{"results" => 1}}
      end)

      assert {:ok, %{"results" => 1}} =
               BentoSdk.Emails.send_transactional(
                 "test@example.com",
                 "sender@example.com",
                 "Test Subject",
                 "<h1>Test</h1>",
                 %{"name" => "Test User"}
               )
    end

    test "handles error response" do
      BentoSdk.ClientMock
      |> expect(:send_bulk_emails, fn _ ->
        {:error, "Failed to send email"}
      end)

      assert {:error, "Failed to send email"} =
               BentoSdk.Emails.send_transactional(
                 "test@example.com",
                 "sender@example.com",
                 "Test Subject",
                 "<h1>Test</h1>",
                 %{}
               )
    end
  end

  describe "send_bulk/1" do
    test "sends multiple emails" do
      emails = [
        %{
          to: "user1@example.com",
          from: "sender@example.com",
          subject: "Test Subject 1",
          html_body: "<h1>Test 1</h1>",
          personalizations: %{"name" => "User 1"}
        },
        %{
          to: "user2@example.com",
          from: "sender@example.com",
          subject: "Test Subject 2",
          html_body: "<h1>Test 2</h1>",
          personalizations: %{"name" => "User 2"},
          transactional: true
        }
      ]

      BentoSdk.ClientMock
      |> expect(:send_bulk_emails, fn batch_emails ->
        assert length(batch_emails) == 2
        
        # Check first email
        assert Enum.at(batch_emails, 0)[:to] == "user1@example.com"
        assert Enum.at(batch_emails, 0)[:subject] == "Test Subject 1"
        
        # Check second email
        assert Enum.at(batch_emails, 1)[:to] == "user2@example.com"
        assert Enum.at(batch_emails, 1)[:subject] == "Test Subject 2"
        assert Enum.at(batch_emails, 1)[:transactional] == true
        
        {:ok, %{"results" => 2}}
      end)

      assert {:ok, %{"results" => 2}} = BentoSdk.Emails.send_bulk(emails)
    end

    test "validates emails in the batch" do
      emails = [
        %{
          to: "user1@example.com",
          from: "sender@example.com",
          subject: "Test Subject 1",
          html_body: "<h1>Test 1</h1>"
        },
        %{
          to: "invalid-email",
          from: "sender@example.com",
          subject: "Test Subject 2",
          html_body: "<h1>Test 2</h1>"
        }
      ]

      assert_raise ArgumentError, "Invalid email format", fn ->
        BentoSdk.Emails.send_bulk(emails)
      end
    end

    test "raises error if emails is not a list" do
      assert_raise FunctionClauseError, fn ->
        BentoSdk.Emails.send_bulk("not a list")
      end
    end
  end
end
