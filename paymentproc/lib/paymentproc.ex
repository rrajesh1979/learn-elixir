defmodule Paymentproc do
  alias NimbleCSV.RFC4180, as: CSV

  @moduledoc """
  Documentation for `Paymentproc`.
  """

  def payments_csv() do
    Application.app_dir(:paymentproc, "/priv/test_data.csv")
  end

  def open_payments() do
    payments_csv()
    |> File.stream!()
    |> Flow.from_enumerable()
    |> Flow.map(fn row ->
      [row] = CSV.parse_string(row, skip_headers: false)

      %{
        id: Enum.at(row, 0),
        tenant: Enum.at(row, 1),
        type: Enum.at(row, 2),
        value: Enum.at(row, 3),
        created_at: Enum.at(row, 4),
        status: Enum.at(row, 5)
      }
    end)
    |> Flow.reject(&(&1.status == "CLOSED" || &1.status == "status"))
    # |> Flow.reduce(fn -> %{} end, fn item, acc ->
    #   Map.update(acc, item.tenant, 1, &(&1 + 1))
    # end)
    |> Enum.to_list()
  end

end
