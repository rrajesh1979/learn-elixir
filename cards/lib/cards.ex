defmodule Cards do
  require Logger

  @moduledoc """
  This module provides a simple interface to create and handle deck of cards.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Cards.hello()
      "Hello Elixir!"

  """
  def hello do
    "Hello Elixir!"
  end

  @doc """
  Create a deck of cards.
  """
  def create_deck do
    Logger.info("Creating a deck of cards")
    values = ["Ace", "2", "3", "4", "5", "6", "7", "8", "9", "10", "Jack", "Queen", "King"]
    suits = ["Hearts", "Diamonds", "Clubs", "Spades"]

    deck =
      for suit <- suits, value <- values do
        "#{value} of #{suit}"
      end

    Logger.info("Deck created")
    deck
  end

  @doc """
  Returns the number of cards in a deck.
  """
  def deck_size do
    52
  end

  @doc """
  Shuffles the cards in a deck.
  """
  def shuffle(deck) do
    Enum.shuffle(deck)
  end

  def contains?(deck, card) do
    Enum.member?(deck, card)
  end

  def deal(deck, hand_size) do
    Enum.split(deck, hand_size)
  end

  def save_deck(deck, filename) do
    binary = :erlang.term_to_binary(deck)
    File.write(filename, binary)
  end

  def load_deck(filename) do

    case File.read(filename) do
      { :ok, binary } ->
        :erlang.binary_to_term binary
      { :error, _ } ->
        raise "Error reading file"
    end

  end

  def create_hand(hand_size) do
    Cards.create_deck
    |> Cards.shuffle
    |> Cards.deal(hand_size)
  end

end
