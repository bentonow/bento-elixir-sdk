defmodule BentoSdk.TagsTest do
  use ExUnit.Case, async: true
  import Mox

  # Make sure mocks are verified when the test exits
  setup :verify_on_exit!

  setup do
    # Set up the mock client
    BentoSdk.configure(client: BentoSdk.ClientMock)
    :ok
  end

  describe "get/0" do
    test "gets all tags" do
      tags = [
        %{
          "id" => "1234",
          "type" => "tags",
          "attributes" => %{
            "name" => "example_tag",
            "created_at" => "2024-08-06T05:44:04.444Z",
            "discarded_at" => nil
          }
        }
      ]

      BentoSdk.ClientMock
      |> expect(:get_tags, fn ->
        {:ok, tags}
      end)

      assert {:ok, ^tags} = BentoSdk.Tags.get()
    end

    test "returns error when client returns error" do
      BentoSdk.ClientMock
      |> expect(:get_tags, fn ->
        {:error, "API error"}
      end)

      assert {:error, "API error"} = BentoSdk.Tags.get()
    end
  end

  describe "create/1" do
    test "creates a new tag" do
      tag = %{
        "id" => "1234",
        "type" => "tags",
        "attributes" => %{
          "name" => "new_tag",
          "created_at" => "2024-08-06T05:44:04.444Z",
          "discarded_at" => nil
        }
      }

      BentoSdk.ClientMock
      |> expect(:create_tag, fn name ->
        assert name == "new_tag"
        {:ok, tag}
      end)

      assert {:ok, ^tag} = BentoSdk.Tags.create("new_tag")
    end

    test "returns error when client returns error" do
      BentoSdk.ClientMock
      |> expect(:create_tag, fn _name ->
        {:error, "API error"}
      end)

      assert {:error, "API error"} = BentoSdk.Tags.create("new_tag")
    end
  end
end
