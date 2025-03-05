defmodule BentoSdk.EventsTest do
  use ExUnit.Case
  # doctest BentoSdk.Events

  import Mox

  # Make sure mocks are verified when the test exits
  setup :verify_on_exit!

  describe "event methods" do
    test "track/4" do
      BentoSdk.ClientMock
      |> expect(:import_events, fn events ->
        assert length(events) == 1
        event = List.first(events)
        assert event.email == "test@example.com"
        assert event.type == "page_viewed"
        assert event.fields == %{page: "/products"}
        assert event.details == %{browser: "Chrome"}
        {:ok, %{"results" => 1, "failed" => 0}}
      end)

      assert {:ok, result} = BentoSdk.Events.track("test@example.com", "page_viewed", %{page: "/products"}, %{browser: "Chrome"})
      assert result["results"] == 1
      assert result["failed"] == 0
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
        {:ok, %{"results" => 2, "failed" => 0}}
      end)

      assert {:ok, result} = BentoSdk.Events.import_events(events)
      assert result["results"] == 2
      assert result["failed"] == 0
    end
    
    test "validate_email/1 with valid email" do
      assert :ok = BentoSdk.Events.validate_email("test@example.com")
    end
    
    test "validate_email/1 with invalid email" do
      assert_raise ArgumentError, "Invalid email format", fn ->
        BentoSdk.Events.validate_email("invalid-email")
      end
      
      assert_raise ArgumentError, "Email is required", fn ->
        BentoSdk.Events.validate_email("")
      end
      
      assert_raise ArgumentError, "Email is required", fn ->
        BentoSdk.Events.validate_email(nil)
      end
    end
    
    test "validate_type/1 with valid type" do
      assert :ok = BentoSdk.Events.validate_type("page_viewed")
    end
    
    test "validate_type/1 with invalid type" do
      assert_raise ArgumentError, "Event type is required", fn ->
        BentoSdk.Events.validate_type("")
      end
      
      assert_raise ArgumentError, "Event type is required", fn ->
        BentoSdk.Events.validate_type(nil)
      end
    end
    
    test "validate_fields/1 with valid fields" do
      assert :ok = BentoSdk.Events.validate_fields(%{})
      assert :ok = BentoSdk.Events.validate_fields(%{page: "/products"})
    end
    
    test "validate_fields/1 with invalid fields" do
      assert_raise ArgumentError, "Fields must be a map", fn ->
        BentoSdk.Events.validate_fields("not a map")
      end
      
      assert_raise ArgumentError, "Fields must be a map", fn ->
        BentoSdk.Events.validate_fields(["not", "a", "map"])
      end
    end
    
    test "validate_details/1 with valid details" do
      assert :ok = BentoSdk.Events.validate_details(%{})
      assert :ok = BentoSdk.Events.validate_details(%{browser: "Chrome"})
      
      # Test with valid unique
      assert :ok = BentoSdk.Events.validate_details(%{
        unique: %{key: "order_123"}
      })
      
      # Test with valid value
      assert :ok = BentoSdk.Events.validate_details(%{
        value: %{currency: "USD", amount: 8000}
      })
      
      # Test with valid cart
      assert :ok = BentoSdk.Events.validate_details(%{
        cart: %{
          items: [
            %{
              product_sku: "SKU123",
              product_name: "Test Product",
              quantity: 1
            }
          ]
        }
      })
    end
    
    test "validate_details/1 with invalid details" do
      assert_raise ArgumentError, "Details must be a map", fn ->
        BentoSdk.Events.validate_details("not a map")
      end
      
      # Test with invalid unique
      assert_raise ArgumentError, "Unique must be a map", fn ->
        BentoSdk.Events.validate_details(%{unique: "not a map"})
      end
      
      assert_raise ArgumentError, "Unique must have a key", fn ->
        BentoSdk.Events.validate_details(%{unique: %{}})
      end
      
      # Test with invalid value
      assert_raise ArgumentError, "Value must be a map", fn ->
        BentoSdk.Events.validate_details(%{value: "not a map"})
      end
      
      assert_raise ArgumentError, "Value must have a currency", fn ->
        BentoSdk.Events.validate_details(%{value: %{amount: 8000}})
      end
      
      assert_raise ArgumentError, "Value must have an amount", fn ->
        BentoSdk.Events.validate_details(%{value: %{currency: "USD"}})
      end
      
      # Test with invalid cart
      assert_raise ArgumentError, "Cart must be a map", fn ->
        BentoSdk.Events.validate_details(%{cart: "not a map"})
      end
      
      assert_raise ArgumentError, "Cart items must be a list", fn ->
        BentoSdk.Events.validate_details(%{cart: %{items: "not a list"}})
      end
      
      assert_raise ArgumentError, "Cart item must be a map", fn ->
        BentoSdk.Events.validate_details(%{cart: %{items: ["not a map"]}})
      end
      
      assert_raise ArgumentError, "Product SKU is required in cart item", fn ->
        BentoSdk.Events.validate_details(%{
          cart: %{
            items: [
              %{
                product_name: "Test Product",
                quantity: 1
              }
            ]
          }
        })
      end
      
      assert_raise ArgumentError, "Product name is required in cart item", fn ->
        BentoSdk.Events.validate_details(%{
          cart: %{
            items: [
              %{
                product_sku: "SKU123",
                quantity: 1
              }
            ]
          }
        })
      end
      
      assert_raise ArgumentError, "Quantity is required in cart item", fn ->
        BentoSdk.Events.validate_details(%{
          cart: %{
            items: [
              %{
                product_sku: "SKU123",
                product_name: "Test Product"
              }
            ]
          }
        })
      end
    end
  end
end
