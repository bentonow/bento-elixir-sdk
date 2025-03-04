defmodule BentoSdkTest do
  use ExUnit.Case
  doctest BentoSdk

  import Mox

  # Make sure mocks are verified when the test exits
  setup :verify_on_exit!

  describe "subscriber methods" do
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

    test "create_subscriber/1" do
      BentoSdk.ClientMock
      |> expect(:create_subscriber, fn email ->
        assert email == "test@example.com"
        {:ok, %{"email" => email, "first_name" => "Test", "last_name" => "User"}}
      end)

      assert {:ok, subscriber} = BentoSdk.create_subscriber("test@example.com")
      assert subscriber["email"] == "test@example.com"
      assert subscriber["first_name"] == "Test"
      assert subscriber["last_name"] == "User"
    end

    test "find_or_create_subscriber/1" do
      BentoSdk.ClientMock
      |> expect(:find_or_create_subscriber, fn email ->
        assert email == "test@example.com"
        {:ok, %{"email" => email, "first_name" => "Test", "last_name" => "User"}}
      end)

      assert {:ok, subscriber} = BentoSdk.find_or_create_subscriber("test@example.com")
      assert subscriber["email"] == "test@example.com"
      assert subscriber["first_name"] == "Test"
      assert subscriber["last_name"] == "User"
    end

    test "import_subscribers/1" do
      subscribers = [
        %{email: "user1@example.com", first_name: "User", last_name: "One"},
        %{email: "user2@example.com", first_name: "User", last_name: "Two"}
      ]

      BentoSdk.ClientMock
      |> expect(:import_subscribers, fn subs ->
        assert subs == subscribers
        {:ok, %{"imported" => 2, "errors" => []}}
      end)

      assert {:ok, result} = BentoSdk.import_subscribers(subscribers)
      assert result["imported"] == 2
      assert result["errors"] == []
    end

    test "run_command/3" do
      BentoSdk.ClientMock
      |> expect(:run_command, fn command, email, query ->
        assert command == "add_tag"
        assert email == "test@example.com"
        assert query == "vip"
        {:ok, %{"success" => true}}
      end)

      assert {:ok, result} = BentoSdk.run_command("add_tag", "test@example.com", "vip")
      assert result["success"] == true
    end

    test "add_tag/2" do
      BentoSdk.ClientMock
      |> expect(:add_tag, fn email, tag ->
        assert email == "test@example.com"
        assert tag == "vip"
        {:ok, %{"success" => true}}
      end)

      assert {:ok, result} = BentoSdk.add_tag("test@example.com", "vip")
      assert result["success"] == true
    end

    test "add_tag_via_event/2" do
      BentoSdk.ClientMock
      |> expect(:add_tag_via_event, fn email, tag ->
        assert email == "test@example.com"
        assert tag == "vip"
        {:ok, %{"success" => true}}
      end)

      assert {:ok, result} = BentoSdk.add_tag_via_event("test@example.com", "vip")
      assert result["success"] == true
    end

    test "remove_tag/2" do
      BentoSdk.ClientMock
      |> expect(:remove_tag, fn email, tag ->
        assert email == "test@example.com"
        assert tag == "vip"
        {:ok, %{"success" => true}}
      end)

      assert {:ok, result} = BentoSdk.remove_tag("test@example.com", "vip")
      assert result["success"] == true
    end

    test "add_field/3" do
      BentoSdk.ClientMock
      |> expect(:add_field, fn email, key, value ->
        assert email == "test@example.com"
        assert key == "company"
        assert value == "Acme Inc."
        {:ok, %{"success" => true}}
      end)

      assert {:ok, result} = BentoSdk.add_field("test@example.com", "company", "Acme Inc.")
      assert result["success"] == true
    end

    test "remove_field/2" do
      BentoSdk.ClientMock
      |> expect(:remove_field, fn email, field ->
        assert email == "test@example.com"
        assert field == "company"
        {:ok, %{"success" => true}}
      end)

      assert {:ok, result} = BentoSdk.remove_field("test@example.com", "company")
      assert result["success"] == true
    end

    test "subscribe/1" do
      BentoSdk.ClientMock
      |> expect(:subscribe, fn email ->
        assert email == "test@example.com"
        {:ok, %{"success" => true}}
      end)

      assert {:ok, result} = BentoSdk.subscribe("test@example.com")
      assert result["success"] == true
    end

    test "unsubscribe/1" do
      BentoSdk.ClientMock
      |> expect(:unsubscribe, fn email ->
        assert email == "test@example.com"
        {:ok, %{"success" => true}}
      end)

      assert {:ok, result} = BentoSdk.unsubscribe("test@example.com")
      assert result["success"] == true
    end

    test "change_email/2" do
      BentoSdk.ClientMock
      |> expect(:change_email, fn old_email, new_email ->
        assert old_email == "old@example.com"
        assert new_email == "new@example.com"
        {:ok, %{"success" => true}}
      end)

      assert {:ok, result} = BentoSdk.change_email("old@example.com", "new@example.com")
      assert result["success"] == true
    end
  end

  describe "event methods" do
    test "track_event/4" do
      BentoSdk.ClientMock
      |> expect(:track_event, fn email, type, fields, details ->
        assert email == "test@example.com"
        assert type == "page_viewed"
        assert fields == %{page: "/products"}
        assert details == %{browser: "Chrome"}
        {:ok, %{"success" => true}}
      end)

      assert {:ok, result} = BentoSdk.track_event("test@example.com", "page_viewed", %{page: "/products"}, %{browser: "Chrome"})
      assert result["success"] == true
    end

    test "import_events/1" do
      events = [
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
      ]

      BentoSdk.ClientMock
      |> expect(:import_events, fn evts ->
        assert evts == events
        {:ok, %{"imported" => 2, "errors" => []}}
      end)

      assert {:ok, result} = BentoSdk.import_events(events)
      assert result["imported"] == 2
      assert result["errors"] == []
    end
  end

  describe "email methods" do
    test "send_email/5" do
      BentoSdk.ClientMock
      |> expect(:send_email, fn to, from, subject, html_body, personalizations ->
        assert to == "test@example.com"
        assert from == "noreply@example.com"
        assert subject == "Welcome"
        assert html_body == "<h1>Welcome!</h1>"
        assert personalizations == %{"first_name" => "Test"}
        {:ok, %{"success" => true}}
      end)

      assert {:ok, result} = BentoSdk.send_email(
        "test@example.com",
        "noreply@example.com",
        "Welcome",
        "<h1>Welcome!</h1>",
        %{"first_name" => "Test"}
      )
      assert result["success"] == true
    end

    test "send_transactional_email/5" do
      BentoSdk.ClientMock
      |> expect(:send_transactional_email, fn to, from, subject, html_body, personalizations ->
        assert to == "test@example.com"
        assert from == "noreply@example.com"
        assert subject == "Order Confirmation"
        assert html_body == "<h1>Order Confirmed</h1>"
        assert personalizations == %{"order_id" => "123"}
        {:ok, %{"success" => true}}
      end)

      assert {:ok, result} = BentoSdk.send_transactional_email(
        "test@example.com",
        "noreply@example.com",
        "Order Confirmation",
        "<h1>Order Confirmed</h1>",
        %{"order_id" => "123"}
      )
      assert result["success"] == true
    end
  end

  describe "spam API methods" do
    test "email_valid?/1" do
      BentoSdk.ClientMock
      |> expect(:email_valid?, fn email ->
        assert email == "test@example.com"
        {:ok, true}
      end)

      assert {:ok, valid} = BentoSdk.email_valid?("test@example.com")
      assert valid == true
    end

    test "email_risky?/1" do
      BentoSdk.ClientMock
      |> expect(:email_risky?, fn email ->
        assert email == "test@example.com"
        {:ok, false}
      end)

      assert {:ok, risky} = BentoSdk.email_risky?("test@example.com")
      assert risky == false
    end

    test "jesses_ruleset_reasons/2" do
      BentoSdk.ClientMock
      |> expect(:jesses_ruleset_reasons, fn email, opts ->
        assert email == "test@example.com"
        assert opts == [block_free_providers: true]
        {:ok, ["Free email provider"]}
      end)

      assert {:ok, reasons} = BentoSdk.jesses_ruleset_reasons("test@example.com", block_free_providers: true)
      assert reasons == ["Free email provider"]
    end
  end

  describe "utility API methods" do
    test "moderate_content/1" do
      BentoSdk.ClientMock
      |> expect(:moderate_content, fn content ->
        assert content == "This is a test content"
        {:ok, %{"is_appropriate" => true}}
      end)

      assert {:ok, result} = BentoSdk.moderate_content("This is a test content")
      assert result["is_appropriate"] == true
    end

    test "guess_gender/1" do
      BentoSdk.ClientMock
      |> expect(:guess_gender, fn name ->
        assert name == "John"
        {:ok, %{"gender" => "male", "probability" => 0.95}}
      end)

      assert {:ok, result} = BentoSdk.guess_gender("John")
      assert result["gender"] == "male"
      assert result["probability"] == 0.95
    end

    test "geolocate/1" do
      BentoSdk.ClientMock
      |> expect(:geolocate, fn ip_address ->
        assert ip_address == "8.8.8.8"
        {:ok, %{"country" => "United States", "city" => "Mountain View"}}
      end)

      assert {:ok, result} = BentoSdk.geolocate("8.8.8.8")
      assert result["country"] == "United States"
      assert result["city"] == "Mountain View"
    end
  end
end
