defmodule Shapeshifter.Shared do
  @moduledoc false

  @doc """
  Returns a Bitcoin address string from the given script pattern.
  """
  @spec script_address(list) :: String.t | false
  def script_address([:OP_DUP, :OP_HASH160, hash, :OP_EQUALVERIFY, :OP_CHECKSIG | _rest]) do
    %BSV.Address{hash: hash}
    |> BSV.Address.to_string
  end

  def script_address([_sig, pubkey]) do
    cond do
      byte_size(pubkey) == 33 ->
        pubkey
        |> BSV.Address.from_public_key
        |> BSV.Address.to_string
      true ->
        false
    end
  end

  def script_address(_), do: false

end
