defmodule SendServer do
  use GenServer

  def init(args) do
    IO.puts("Received arguments: #{inspect(args)}")
    max_retries = Keyword.get(args, :max_retries, 5)
    state = %{emails: [], max_retries: max_retries}
    IO.puts("Initial state: #{inspect(state)}")
    {:ok, state}
  end

  def handle_continue(:fetch_from_database, state) do
    # called after init/1

    # get `users` from the database
    # {:noreply, Map.put(state, :users, users)}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:send, email}, state) do
    status =
      case SlowSender.send_email(email) do
        {:ok, "email_sent"} -> "sent"
        :error -> "failed"
      end

    emails = [%{email: email, status: "sent", retries: 0}] ++ state.emails
    {:noreply, %{state | emails: emails}}
  end

  def send_email(email) do
    Process.sleep(3000)
    IO.puts("Email to #{email} sent")
    {:ok, "email_sent"}
  end
end

# Commands
# {:ok, pid} = GenServer.start(SendServer, [max_retries: 1])
# GenServer.call(pid, :get_state)
# GenServer.cast(pid, {:send, "hello@email.com"})
# GenServer.call(pid, :get_state)
