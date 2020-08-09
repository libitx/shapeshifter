defmodule Shapeshifter do
  @moduledoc """
  ![Shapeshifter lets you quickly and simply switch between Bitcoin transaction formats](https://github.com/libitx/shapeshifter/raw/master/media/poster.png)

  ![GitHub](https://img.shields.io/github/license/libitx/shapeshifter?color=informational)

  Shapeshifter is an Elixir library for switching between Bitcoin transaction
  formats. Quickly and simply shift between raw tx, [`BSV Transaction`](`t:BSV.Transaction.t/0`),
  [`TXO`](`t:txo/0`) and [`BOB`](`t:bob/0`) transaction formats.

  ## Installation

  The package can be installed by adding `shapeshifter` to your list of dependencies in `mix.exs`:

      def deps do
        [
          {:shapeshifter, "~> 0.1.0"}
        ]
      end

  ## Usage

  Using Shapeshifter couldn't be simpler. Under the hood Shapeshifter uses
  pattern matching to automatically determine the source format, so all you need
  to do is pass a transaction object of any format to the appropriate function
  of the format you want to convert to (from: `to_raw/2`, `to_tx/1`, `to_txo/1`
  or `to_bob/1`).

      # Convert to raw tx
      iex> Shapeshifter.to_raw(tx)
      <<1, 0, 0, 0, ...>>

      # Convert to raw tx with hex encoding
      iex> Shapeshifter.to_raw(tx, encoding: :hex)
      "01000000..."

      # Convert to BSV.Transaction struct
      iex> Shapeshifter.to_tx(tx)
      %BSV.Transaction{}

      # Convert to TXO map
      iex> Shapeshifter.to_txo(tx)
      %{"in" => [...], "out" => [...], ...}

      # Convert to BOB map
      iex> Shapeshifter.to_bob(tx)
      %{"in" => [...], "out" => [...], ...}

  For more advanced use, Shapeshifter can also be used to convert individual
  inputs and outputs between the supported formats. Refer to `Shapeshifter.TXO`
  and `Shapeshifter.BOB` for more details.
  """
  defstruct [:src, :format]

  @typedoc "Shapeshifter struct"
  @type t :: %__MODULE__{
    src: BSV.Transaction.t | txo | bob,
    format: :tx | :txo | :bob
  }

  @typedoc """
  Source transaction

  Shapeshifter accepts and effortlessly switches between the following
  transaction formats:

  * Raw tx binary (with or without hex encoding)
  * [`BSV Transaction`](`t:BSV.Transaction.t/0`) struct
  * [`TXO`](`t:txo/0`) formatted map
  * [`BOB`](`t:bob/0`) formatted map
  """
  @type tx :: binary | BSV.Transaction.t | txo | bob

  @typedoc """
  Transaction Object format

  Tranaction objects as given by [Bitbus](https://bitbus.network) or [Bitsocket](https://bitsocket.network)
  using the [Transaction Object](https://bitquery.planaria.network/#/?id=txo) format.
  """
  @type txo :: %{
    required(String.t) => String.t | integer | list
  }

  @typedoc """
  Bitcoin OP_RETURN Bytecode format

  Tranaction objects as given by [Bitbus](https://bitbus.network) or [Bitsocket](https://bitsocket.network)
  using the [Bitcoin OP_RETURN Bytecode](https://bitquery.planaria.network/#/?id=bob) format.
  """
  @type bob :: %{
    required(String.t) => String.t | integer | list
  }

  @doc """
  Creates a new [`Shapeshifter`](`t:t/o`) from the given transaction.

  Accepts either a raw tx binary (with or without hex encoding),
  [`BSV Transaction`](`t:BSV.Transaction.t/0`) struct, or [`TXO`](`t:txo/0`) or
  [`BOB`](`t:bob/0`) formatted maps.

  Returns the [`Shapeshifter`](`t:t/o`) struct in an `:ok` tuple pair, or returns
  an `:error` tuple pair if the given transaction format is not recognised.
  """
  @spec new(tx) :: {:ok, t} | {:error, Exception.t}
  def new(tx) when is_binary(tx) do
    try do
      {%BSV.Transaction{} = tx, ""} = cond do
        rem(byte_size(tx), 2) == 0 && String.match?(tx, ~r/^[a-f0-9]+$/i) ->
          BSV.Transaction.parse(tx, encoding: :hex)
        true ->
          BSV.Transaction.parse(tx)
      end
      validate(%__MODULE__{src: tx, format: :tx})
    rescue
      _ ->
        {:error, %ArgumentError{message: "The source tx is not a valid Bitcoin transaction."}}
    end
  end

  def new(%BSV.Transaction{} = tx),
    do: validate(%__MODULE__{src: tx, format: :tx})

  def new(%{"in" => ins, "out" => outs} = tx)
    when is_list(ins) and is_list(outs)
  do
    format = cond do
      Enum.any?(ins ++ outs, & is_list(&1["tape"])) ->
        :bob
      true ->
        :txo
    end

    validate(%__MODULE__{src: tx, format: format})
  end

  def new(src) when is_map(src),
    do: validate(%__MODULE__{src: src, format: :txo})


  @doc """
  Converts the given transaction to a raw tx binary, with or without hex encoding.

  Accepts either a [`BSV Transaction`](`t:BSV.Transaction.t/0`) struct, or
  [`TXO`](`t:txo/0`) or [`BOB`](`t:bob/0`) formatted maps.

  Returns the result in an `:ok` or `:error` tuple pair.

  ## Options

  The accepted options are:

  * `:encoding` - Set `:hex` for hex encoding
  """
  @spec to_raw(t | tx, keyword) :: {:ok, binary} | {:error, Exception.t}
  def to_raw(tx, options \\ [])

  def to_raw(%__MODULE__{format: :tx} = tx, options) do
    encoding = Keyword.get(options, :encoding)
    {:ok, BSV.Transaction.serialize(tx.src, encoding: encoding)}
  end

  def to_raw(%__MODULE__{} = tx, options) do
    encoding = Keyword.get(options, :encoding)
    with {:ok, tx} <- to_tx(tx) do
      {:ok, BSV.Transaction.serialize(tx, encoding: encoding)}
    end
  end

  def to_raw(tx, options) do
    with {:ok, tx} <- new(tx), do: to_raw(tx, options)
  end


  @doc """
  Converts the given transaction to a [`BSV Transaction`](`t:BSV.Transaction.t/0`) struct.

  Accepts either a raw tx binary, or [`TXO`](`t:txo/0`) or [`BOB`](`t:bob/0`)
  formatted maps.

  Returns the result in an `:ok` or `:error` tuple pair.
  """
  @spec to_tx(t | tx) :: {:ok, BSV.Transaction.t} | {:error, Exception.t}
  def to_tx(tx)

  def to_tx(%__MODULE__{format: :tx} = tx),
    do: {:ok, tx.src}

  def to_tx(%__MODULE__{format: :txo} = tx),
    do: {:ok, Shapeshifter.TXO.to_tx(tx)}

  def to_tx(%__MODULE__{format: :bob} = tx),
    do: {:ok, Shapeshifter.BOB.to_tx(tx)}

  def to_tx(tx) do
    with {:ok, tx} <- new(tx), do: to_tx(tx)
  end


  @doc """
  Converts the given transaction to the [`TXO`](`t:txo/0`) transaction format.

  Accepts either a raw tx binary, [`BSV Transaction`](`t:BSV.Transaction.t/0`)
  struct, or [`BOB`](`t:bob/0`) formatted map.

  Returns the result in an `:ok` or `:error` tuple pair.
  """
  @spec to_txo(t | tx) :: {:ok, txo} | {:error, Exception.t}
  def to_txo(%__MODULE__{} = tx) do
    {:ok, Shapeshifter.TXO.new(tx)}
  end

  def to_txo(tx) do
    with {:ok, tx} <- new(tx), do: to_txo(tx)
  end


  @doc """
  Converts the given transaction to the [`BOB`](`t:bob/0`) transaction format.

  Accepts either a raw tx binary, [`BSV Transaction`](`t:BSV.Transaction.t/0`)
  struct, or [`TXO`](`t:txo/0`) formatted map.

  Returns the result in an `:ok` or `:error` tuple pair.
  """
  @spec to_bob(t | tx) :: {:ok, bob} | {:error, Exception.t}
  def to_bob(%__MODULE__{} = tx) do
    {:ok, Shapeshifter.BOB.new(tx)}
  end

  def to_bob(tx) do
    with {:ok, tx} <- new(tx), do: to_bob(tx)
  end


  # Validates the given `Shapeshifter.t\0` struct.
  defp validate(%__MODULE__{format: :tx} = shifter) do
    case shifter.src do
      %BSV.Transaction{} ->
        {:ok, shifter}
      _ ->
        {:error, %ArgumentError{message: "The src tx is not a BSV.Transaction type."}}
    end
  end

  defp validate(%__MODULE__{format: fmt} = shifter)
    when fmt in [:txo, :bob]
  do
    case Enum.all?(["tx", "in", "out"], & Map.has_key?(shifter.src, &1)) do
      true ->
        {:ok, shifter}
      false ->
        {:error, %ArgumentError{message: "The src tx is not a valid TXO or BOB map"}}
    end
  end

end
