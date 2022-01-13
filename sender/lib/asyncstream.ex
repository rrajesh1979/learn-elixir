defmodule AsyncStream do
  def send_email(email) do
    Process.sleep(3000)
    IO.puts("Email to #{email} sent")
    {:ok, "email_sent"}
  end

  def notify_all(emails) do
    emails
    |> Task.async_stream(&send_email/1, ordered: false)
    |> Enum.to_list()
  end
end
