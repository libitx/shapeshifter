defmodule Shapeshifter do
  @moduledoc """
  Documentation for `Shapeshifter`.
  """
  defstruct [:src, :format]

  @typedoc "TODO"
  @type t :: %__MODULE__{
    src: BSV.Transaction.t | txo | bob,
    format: :tx | :txo | :bob
  }

  @typedoc "TODO"
  @type tx :: binary | BSV.Transaction.t | txo | bob

  @typedoc "TODO"
  @type txo :: %{
    required(String.t) => String.t | integer | list
  }

  @typedoc "TODO"
  @type bob :: %{
    required(String.t) => String.t | integer | list
  }

  @doc """
  TODO
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
  TODO
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
  TODO
  """
  @spec to_tx(t | tx) :: {:ok, BSV.Transaction.t} | {:error, Exception.t}
  def to_tx(tx)

  def to_tx(%__MODULE__{format: :tx} = tx),
    do: {:ok, tx.src}

  def to_tx(%__MODULE__{format: :txo} = tx),
    do: {:ok, Shapeshifter.Txo.to_tx(tx)}

  def to_tx(%__MODULE__{format: :bob} = tx),
    do: {:ok, Shapeshifter.Bob.to_tx(tx)}

  def to_tx(tx) do
    with {:ok, tx} <- new(tx), do: to_tx(tx)
  end


  @doc """
  TODO
  """
  @spec to_txo(t | tx) :: {:ok, txo} | {:error, Exception.t}
  def to_txo(%__MODULE__{} = tx) do
    {:ok, Shapeshifter.Txo.new(tx)}
  end

  def to_txo(tx) do
    with {:ok, tx} <- new(tx), do: to_txo(tx)
  end


  @doc """
  TODO
  """
  @spec to_bob(t | tx) :: {:ok, bob} | {:error, Exception.t}
  def to_bob(%__MODULE__{} = tx) do
    {:ok, Shapeshifter.Bob.new(tx)}
  end

  def to_bob(tx) do
    with {:ok, tx} <- new(tx), do: to_bob(tx)
  end


  # TODO
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
