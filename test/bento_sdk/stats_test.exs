defmodule BentoSdk.StatsTest do
  use ExUnit.Case
  # Temporarily disable doctests until we have proper mocking set up
  # doctest BentoSdk.Stats

  import Mox

  # Make sure mocks are verified when the test exits
  setup :verify_on_exit!

  setup do
    # Set up the mock client
    BentoSdk.configure(client: BentoSdk.ClientMock)
    :ok
  end

  describe "get_site/0" do
    test "returns site statistics" do
      BentoSdk.ClientMock
      |> expect(:get_site_stats, fn ->
        {:ok, %{
          "user_count" => 1000,
          "subscriber_count" => 800,
          "unsubscriber_count" => 200
        }}
      end)

      assert {:ok, stats} = BentoSdk.Stats.get_site()
      assert stats["user_count"] == 1000
      assert stats["subscriber_count"] == 800
      assert stats["unsubscriber_count"] == 200
    end

    test "returns error when client returns error" do
      BentoSdk.ClientMock
      |> expect(:get_site_stats, fn ->
        {:error, "API error"}
      end)

      assert {:error, "API error"} = BentoSdk.Stats.get_site()
    end
  end

  describe "get_segment/1" do
    test "returns segment statistics" do
      segment_id = "seg_123"

      BentoSdk.ClientMock
      |> expect(:get_segment_stats, fn id ->
        assert id == segment_id
        {:ok, %{
          "user_count" => 500,
          "subscriber_count" => 400,
          "unsubscriber_count" => 100
        }}
      end)

      assert {:ok, stats} = BentoSdk.Stats.get_segment(segment_id)
      assert stats["user_count"] == 500
      assert stats["subscriber_count"] == 400
      assert stats["unsubscriber_count"] == 100
    end

    test "returns error when client returns error" do
      BentoSdk.ClientMock
      |> expect(:get_segment_stats, fn _id ->
        {:error, "API error"}
      end)

      assert {:error, "API error"} = BentoSdk.Stats.get_segment("seg_123")
    end
  end

  describe "get_report/1" do
    test "returns report statistics" do
      report_id = "rep_123"

      BentoSdk.ClientMock
      |> expect(:get_report_stats, fn id ->
        assert id == report_id
        {:ok, %{
          "report_data" => %{
            "data" => %{},
            "chart_style" => "count",
            "report_type" => "Reporting::Reports::VisitorCountReport",
            "report_name" => "New Subscribers"
          }
        }}
      end)

      assert {:ok, stats} = BentoSdk.Stats.get_report(report_id)
      assert stats["report_data"]["chart_style"] == "count"
      assert stats["report_data"]["report_name"] == "New Subscribers"
    end

    test "returns error when client returns error" do
      BentoSdk.ClientMock
      |> expect(:get_report_stats, fn _id ->
        {:error, "API error"}
      end)

      assert {:error, "API error"} = BentoSdk.Stats.get_report("rep_123")
    end
  end
end
