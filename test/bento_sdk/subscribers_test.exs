defmodule BentoSdk.SubscribersTest do
  use ExUnit.Case, async: true
  import Mox

  setup :verify_on_exit!

  describe "subscriber methods" do
    test "find/1" do
      BentoSdk.ClientMock
      |> expect(:find_subscriber, fn email ->
        assert email == "test@example.com"
        {:ok, %{"email" => email}}
      end)

      assert BentoSdk.Subscribers.find("test@example.com") == {:ok, %{"email" => "test@example.com"}}
    end

    test "create/1" do
      BentoSdk.ClientMock
      |> expect(:create_subscriber, fn email ->
        assert email == "test@example.com"
        {:ok, %{"email" => email}}
      end)

      assert BentoSdk.Subscribers.create("test@example.com") == {:ok, %{"email" => "test@example.com"}}
    end

    test "find_or_create/1" do
      BentoSdk.ClientMock
      |> expect(:find_or_create_subscriber, fn email ->
        assert email == "test@example.com"
        {:ok, %{"email" => email}}
      end)

      assert BentoSdk.Subscribers.find_or_create("test@example.com") ==
               {:ok, %{"email" => "test@example.com"}}
    end

    test "update/2" do
      BentoSdk.ClientMock
      |> expect(:import_subscribers, fn subscribers ->
        assert length(subscribers) == 1
        subscriber = List.first(subscribers)
        assert subscriber.email == "test@example.com"
        assert subscriber.first_name == "Test"
        {:ok, %{"imported" => 1, "errors" => []}}
      end)

      assert BentoSdk.Subscribers.update("test@example.com", %{first_name: "Test"}) ==
               {:ok, %{"imported" => 1, "errors" => []}}
    end

    test "subscribe/1" do
      BentoSdk.ClientMock
      |> expect(:subscribe, fn email ->
        assert email == "test@example.com"
        {:ok, %{"success" => true}}
      end)

      assert BentoSdk.Subscribers.subscribe("test@example.com") == {:ok, %{"success" => true}}
    end

    test "unsubscribe/1" do
      BentoSdk.ClientMock
      |> expect(:unsubscribe, fn email ->
        assert email == "test@example.com"
        {:ok, %{"success" => true}}
      end)

      assert BentoSdk.Subscribers.unsubscribe("test@example.com") == {:ok, %{"success" => true}}
    end

    test "change_email/2" do
      BentoSdk.ClientMock
      |> expect(:change_email, fn old_email, new_email ->
        assert old_email == "old@example.com"
        assert new_email == "new@example.com"
        {:ok, %{"success" => true}}
      end)

      assert BentoSdk.Subscribers.change_email("old@example.com", "new@example.com") ==
               {:ok, %{"success" => true}}
    end

    test "add_tag/2" do
      BentoSdk.ClientMock
      |> expect(:add_tag, fn email, tag ->
        assert email == "test@example.com"
        assert tag == "test_tag"
        {:ok, %{"success" => true}}
      end)

      assert BentoSdk.Subscribers.add_tag("test@example.com", "test_tag") ==
               {:ok, %{"success" => true}}
    end

    test "add_tag_via_event/2" do
      BentoSdk.ClientMock
      |> expect(:add_tag_via_event, fn email, tag ->
        assert email == "test@example.com"
        assert tag == "test_tag"
        {:ok, %{"success" => true}}
      end)

      assert BentoSdk.Subscribers.add_tag_via_event("test@example.com", "test_tag") ==
               {:ok, %{"success" => true}}
    end

    test "remove_tag/2" do
      BentoSdk.ClientMock
      |> expect(:remove_tag, fn email, tag ->
        assert email == "test@example.com"
        assert tag == "test_tag"
        {:ok, %{"success" => true}}
      end)

      assert BentoSdk.Subscribers.remove_tag("test@example.com", "test_tag") ==
               {:ok, %{"success" => true}}
    end

    test "add_field/3" do
      BentoSdk.ClientMock
      |> expect(:add_field, fn email, key, value ->
        assert email == "test@example.com"
        assert key == "test_field"
        assert value == "test_value"
        {:ok, %{"success" => true}}
      end)

      assert BentoSdk.Subscribers.add_field("test@example.com", "test_field", "test_value") ==
               {:ok, %{"success" => true}}
    end

    test "remove_field/2" do
      BentoSdk.ClientMock
      |> expect(:remove_field, fn email, field ->
        assert email == "test@example.com"
        assert field == "test_field"
        {:ok, %{"success" => true}}
      end)

      assert BentoSdk.Subscribers.remove_field("test@example.com", "test_field") ==
               {:ok, %{"success" => true}}
    end
  end
end
