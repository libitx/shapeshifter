defmodule Shapeshifter do
  @moduledoc """
  Documentation for `Shapeshifter`.
  """
  defstruct [:src, :src_format]

  @typedoc "TODO"
  @type t :: %{
    src: BSV.Transaction.t | map,
    src_format: :tx | :txo | :bob
  }


  @doc """
  TODO
  """
  @spec from(binary | BSV.Transaction.t | map) :: {:ok, t} | {:error, Exception.t}
  def from(src)

  def from(rawtx) when is_binary(rawtx) do
    try do
      {%BSV.Transaction{} = tx, ""} = cond do
        rem(byte_size(rawtx), 2) == 0 && String.match?(rawtx, ~r/^[a-f0-9]+$/i) ->
          BSV.Transaction.parse(rawtx, encoding: :hex)
        true ->
          BSV.Transaction.parse(rawtx)
      end
      validate(%__MODULE__{src: tx, src_format: :tx})
    rescue
      _ ->
        {:error, %ArgumentError{message: "The src value is not a valid Bitcoin transaction."}}
    end
  end

  def from(%BSV.Transaction{} = src),
    do: validate(%__MODULE__{src: src, src_format: :tx})

  def from(%{"in" => ins, "out" => outs} = src) do
    format = cond do
      Enum.any?(ins ++ outs, & is_list(&1["tape"])) ->
        :bob
      true ->
        :txo
    end

    validate(%__MODULE__{src: src, src_format: format})
  end

  def from(src) when is_map(src),
    do: validate(%__MODULE__{src: src, src_format: :txo})


  @doc """
  TODO
  """
  @spec to_raw(t, keyword) :: binary
  def to_raw(shifter, options \\ [])

  def to_raw(%__MODULE__{src_format: :tx} = shifter, opts) do
    encoding = Keyword.get(opts, :encoding)
    BSV.Transaction.serialize(shifter.src, encoding: encoding)
  end

  def to_raw(%__MODULE__{} = shifter, opts) do
    encoding = Keyword.get(opts, :encoding)
    BSV.Transaction.serialize(to_tx(shifter), encoding: encoding)
  end



  @doc """
  TODO
  """
  @spec to_tx(t) :: BSV.Transaction.t
  def to_tx(shifter)

  def to_tx(%__MODULE__{src_format: :tx} = shifter),
    do: shifter.src

  def to_tx(%__MODULE__{src_format: :txo} = shifter),
    do: Shapeshifter.Txo.to_tx(shifter.src)

  def to_tx(%__MODULE__{src_format: :bob} = shifter),
    do: Shapeshifter.Bob.to_tx(shifter.src)


  @doc """
  TODO
  """
  @spec to_txo(t) :: map
  def to_txo(shifter)

  def to_txo(%__MODULE__{src_format: :txo} = shifter),
    do: shifter.src

  def to_txo(%__MODULE__{} = shifter) do
    Shapeshifter.Txo.from(shifter)
  end


  @doc """
  TODO
  """
  @spec to_bob(t) :: map
  def to_bob(shifter)

  def to_bob(%__MODULE__{src_format: :bob} = shifter),
    do: shifter.src

  def to_bob(%__MODULE__{} = shifter) do
    Shapeshifter.Bob.from(shifter)
  end



  #def to({:error, reason}, _format, _opts), do: {:error, reason}



  # TODO
  defp validate(%__MODULE__{src_format: :tx} = shifter) do
    case shifter.src do
      %BSV.Transaction{} ->
        {:ok, shifter}
      _ ->
        {:error, %ArgumentError{message: "The src value is not a BSV.Transaction type."}}
    end
  end

  defp validate(%__MODULE__{src_format: fmt} = shifter)
    when fmt in [:txo, :bob]
  do
    case Enum.all?(["tx", "in", "out"], & Map.has_key?(shifter.src, &1)) do
      true ->
        {:ok, shifter}
      false ->
        {:error, %ArgumentError{message: "The src value is not a valid TXO or BOB map"}}
    end
  end

end
