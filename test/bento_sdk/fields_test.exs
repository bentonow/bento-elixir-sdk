defmodule BentoSdk.FieldsTest do
  use ExUnit.Case
  import Mox

  setup :verify_on_exit!

  describe "Fields" do
    test "get/0" do
      BentoSdk.ClientMock
      |> expect(:get_fields, fn ->
        {:ok, [
          %{
            "id" => "1234",
            "type" => "visitors-fields",
            "attributes" => %{
              "name" => "Last Name",
              "key" => "last_name",
              "whitelisted" => nil
            }
          }
        ]}
      end)

      assert BentoSdk.Fields.get() ==
               {:ok, [
                 %{
                   "id" => "1234",
                   "type" => "visitors-fields",
                   "attributes" => %{
                     "name" => "Last Name",
                     "key" => "last_name",
                     "whitelisted" => nil
                   }
                 }
               ]}
    end

    test "create/1" do
      BentoSdk.ClientMock
      |> expect(:create_field, fn key ->
        assert key == "example_field"

        {:ok, %{
          "id" => "1234",
          "type" => "visitors-fields",
          "attributes" => %{
            "name" => "Example Field",
            "key" => "example_field",
            "whitelisted" => nil
          }
        }}
      end)

      assert BentoSdk.Fields.create("example_field") ==
               {:ok, %{
                 "id" => "1234",
                 "type" => "visitors-fields",
                 "attributes" => %{
                   "name" => "Example Field",
                   "key" => "example_field",
                   "whitelisted" => nil
                 }
               }}
    end
  end
end
