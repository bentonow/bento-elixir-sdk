defmodule BentoSdk.Stats do
  @moduledoc """
  Functions for retrieving statistics from Bento.
  
  The Stats API allows you to:
  - Get site statistics
  - Get segment statistics
  - Get report statistics
  
  These statistics provide insights into your Bento account's performance.
  """

  @doc """
  Get site statistics.
  
  Returns basic statistics about your Bento site.
  
  ## Examples
  
      iex> BentoSdk.Stats.get_site()
      {:ok, %{
        "user_count" => 1000,
        "subscriber_count" => 800,
        "unsubscriber_count" => 200
      }}
  
  """
  @spec get_site() :: {:ok, map()} | {:error, String.t()}
  def get_site do
    client().get_site_stats()
  end

  @doc """
  Get segment statistics.
  
  Returns statistics for a specific segment.
  
  ## Parameters
  
    * `segment_id` - The ID of the segment to get statistics for
  
  ## Examples
  
      iex> BentoSdk.Stats.get_segment("123")
      {:ok, %{
        "user_count" => 500,
        "subscriber_count" => 400,
        "unsubscriber_count" => 100
      }}
  
  """
  @spec get_segment(String.t()) :: {:ok, map()} | {:error, String.t()}
  def get_segment(segment_id) do
    client().get_segment_stats(segment_id)
  end

  @doc """
  Get report statistics.
  
  Returns data for a specific report.
  
  ## Parameters
  
    * `report_id` - The ID of the report to get data for
  
  ## Examples
  
      iex> BentoSdk.Stats.get_report("456")
      {:ok, %{
        "report_data" => %{
          "data" => %{},
          "chart_style" => "count",
          "report_type" => "Reporting::Reports::VisitorCountReport",
          "report_name" => "New Subscribers"
        }
      }}
  
  """
  @spec get_report(String.t()) :: {:ok, map()} | {:error, String.t()}
  def get_report(report_id) do
    client().get_report_stats(report_id)
  end

  defp client do
    config = Application.get_env(:bento_sdk, :config, [])
    Keyword.get(config, :client, BentoSdk.Client)
  end
end
