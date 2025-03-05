defmodule BentoSdk.Fields do
  @moduledoc """
  Functions for managing fields in Bento.

  The Fields API allows you to:
  - Get all fields in your account
  - Create new fields

  Fields are simple named key-value pairs, think of them as form fields.
  """

  @doc """
  Get all fields in your account.

  ## Examples

      BentoSdk.Fields.get()
      {:ok, [
        %{
          "id" => "1234",
          "type" => "fields",
          "attributes" => %{
            "key" => "company",
            "created_at" => "2024-08-06T05:44:04.444Z",
            "discarded_at" => nil
          }
        }
      ]}
  """
  def get do
    client().get_fields()
  end

  @doc """
  Create a new field in your account.

  ## Examples

      BentoSdk.Fields.create("company")
      {:ok, %{
        "id" => "1234",
        "type" => "fields",
        "attributes" => %{
          "key" => "company",
          "created_at" => "2024-08-06T05:44:04.444Z",
          "discarded_at" => nil
        }
      }}
  """
  def create(key) do
    client().create_field(key)
  end

  defp client do
    config = Application.get_env(:bento_sdk, :config, [])
    Keyword.get(config, :client, BentoSdk.Client)
  end
end
