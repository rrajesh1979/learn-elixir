defmodule SendServer do
  use GenServer

  def init(args) do
    IO.puts("Received arguments: #{inspect(args)}")
    max_retries = Keyword.get(args, :max_retries, 5)
    state = %{emails: [], max_retries: max_retries}
    IO.puts("Initial state: #{inspect(state)}")
    Process.send_after(self(), :retry, 5000)
    {:ok, state}
  end

  def handle_continue(:fetch_from_database, state) do
    # called after init/1

    # get `users` from the database
    # {:noreply, Map.put(state, :users, users)}
  end

  def handle_call(:get_state, _from, state) do
    IO.puts("Inside handle_call: #{inspect(state)}")
    {:reply, state, state}
  end

  def handle_cast({:send, email}, state) do
    IO.puts("Inside handle_cast: #{inspect(email)}")

    status =
      case SlowSender.send_email(email) do
        {:ok, "email_sent"} -> "sent"
        :error -> "failed"
      end

    IO.puts("Status: #{inspect(status)}")

    emails = [%{email: email, status: status, retries: 0}] ++ state.emails
    {:noreply, %{state | emails: emails}}
  end

  def handle_info(:retry, state) do
    IO.puts("Inside handle_info: #{inspect(state)}")

    {failed, done} =
      Enum.split_with(state.emails, fn item ->
        item.status == "failed" && item.retries < state.max_retries
      end)

    retried =
      Enum.map(failed, fn item ->
        IO.puts("Retrying email #{item.email}...")

        new_status =
          case SlowSender.send_email(item.email) do
            {:ok, "email_sent"} -> "sent"
            :error -> "failed"
          end

        %{email: item.email, status: new_status, retries: item.retries + 1}
      end)

    Process.send_after(self(), :retry, 5000)

    {:noreply, %{state | emails: retried ++ done}}
  end

  def terminate(reason, _state) do
    IO.puts("Terminating with reason #{reason}")
  end
end

# Commands
# {:ok, pid} = GenServer.start(SendServer, [max_retries: 2])
# GenServer.call(pid, :get_state)
# GenServer.cast(pid, {:send, "hello@email.com"})
# GenServer.cast(pid, {:send, "aloha@world.com"})
# GenServer.cast(pid, {:send, "konnichiwa@world.com"})
# GenServer.call(pid, :get_state)
