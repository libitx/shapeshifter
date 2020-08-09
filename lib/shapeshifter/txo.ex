defmodule Shapeshifter.Txo do
  @moduledoc """
  TODO
  """


  @doc """
  TODO
  """
  @spec new(Shapeshifter.t) :: map
  def new(%Shapeshifter{src: tx, format: :tx} = _shifter) do
    txid = BSV.Transaction.get_txid(tx)

    ins = tx.inputs
    |> Enum.with_index
    |> Enum.map(&cast_input/1)

    outs = tx.outputs
    |> Enum.with_index
    |> Enum.map(&cast_output/1)

    %{
      "tx" => %{"h" => txid},
      "in" => ins,
      "out" => outs,
      "lock" => 0
    }
  end

  def new(%Shapeshifter{src: src, format: :txo}), do: src

  def new(%Shapeshifter{src: src, format: :bob}) do
    ins = Enum.map(src["in"], &cast_input/1)
    outs = Enum.map(src["out"], &cast_output/1)

    src
    |> Map.delete("_id")
    |> Map.put("in", ins)
    |> Map.put("out", outs)
  end


  @doc """
  TODO
  """
  @spec cast_input({BSV.Transaction.Input.t | map, integer}) :: map
  def cast_input({%BSV.Transaction.Input{} = src, index}) do
    input = %{
      "i" => index,
      "seq" => src.sequence,
      "e" => %{
        "h" => src.output_txid,
        "i" => src.output_index,
        "a" => script_address(src.script.chunks)
      },
      "len" => length(src.script.chunks)
    }

    src.script.chunks
    |> Enum.with_index
    |> Enum.reduce(input, &from_script_chunk/2)
  end

  def cast_input(%{"tape" => _tape} = src),
    do: from_bob_tape(src)


  @doc """
  TODO
  """
  @spec cast_output({BSV.Transaction.Output.t | map, integer}) :: map
  def cast_output({%BSV.Transaction.Output{} = src, index}) do
    output = %{
      "i" => index,
      "e" => %{
        "v" => src.satoshis,
        "i" => index,
        "a" => script_address(src.script.chunks)
      },
      "len" => length(src.script.chunks)
    }

    src.script.chunks
    |> Enum.with_index
    |> Enum.reduce(output, &from_script_chunk/2)
  end

  def cast_output(%{"tape" => _tape} = src),
    do: from_bob_tape(src)


  @doc """
  TODO
  """
  @spec to_tx(%Shapeshifter{
    src: map,
    format: :txo
  }) :: BSV.Transaction.t
  def to_tx(%Shapeshifter{
    src: %{"in" => ins, "out" => outs} = src,
    format: :txo
  }) do
    %BSV.Transaction{
      inputs: Enum.map(ins, &to_tx_input/1),
      outputs: Enum.map(outs, &to_tx_output/1),
      lock_time: src["lock"]
    }
  end


  @doc """
  TODO
  """
  @spec to_tx_input(map) :: BSV.Transaction.Input.t
  def to_tx_input(%{} = src) do
    %BSV.Transaction.Input{
      output_index: get_in(src, ["e", "i"]),
      output_txid: get_in(src, ["e", "h"]),
      sequence: src["seq"],
      script: to_tx_script(src)
    }
  end


  @doc """
  TODO
  """
  @spec to_tx_output(map) :: BSV.Transaction.Output.t
  def to_tx_output(%{} = src) do
    %BSV.Transaction.Output{
      satoshis: get_in(src, ["e", "v"]),
      script: to_tx_script(src)
    }
  end


  # TODO
  defp from_script_chunk({opcode, index}, target) when is_atom(opcode),
    do: Map.put(target, "o#{index}", Atom.to_string(opcode))

  defp from_script_chunk({data, index}, target) when is_binary(data) do
    Map.merge(target, %{
      "s#{index}" => data,
      "b#{index}" => Base.encode64(data),
      "h#{index}" => Base.encode16(data, case: :lower),
    })
  end


  # TODO
  defp from_bob_tape(%{"tape" => tape} = src) do
    target = src
    |> Map.delete("tape")
    |> Map.put("len", 0)

    tape
    |> Enum.flat_map(& &1["cell"])
    |> Enum.reduce(target, &from_bob_cell/2)
  end


  # TODO
  defp from_bob_cell(%{"ops" => opcode, "ii" => index}, target) do
    target
    |> check_expected_index(index)
    |> Map.put("o#{index}", opcode)
  end

  defp from_bob_cell(%{"ii" => index} = cell, target) do
    target
    |> check_expected_index(index)
    |> Map.merge(%{
      "s#{index}" => cell["s"],
      "b#{index}" => cell["b"],
      "h#{index}" => cell["h"]
    })
  end


  # TODO
  defp check_expected_index(%{"len" => expected_index} = target, index)
    when expected_index == index,
    do: Map.put(target, "len", expected_index+1)

  defp check_expected_index(%{"len" => expected_index} = target, index)
    when expected_index < index
  do
    Map.merge(target, %{
      "s#{expected_index}" => "|",
      "b#{expected_index}" => Base.encode64("|"),
      "h#{expected_index}" => Base.encode16("|", case: :lower),
      "len" => expected_index+1
    })
    |> check_expected_index(index)
  end


  # TODO
  defp to_tx_script(%{} = src) do
    0..src["len"]-1
    |> Enum.reduce(%BSV.Script{}, fn i, script ->
      data = cond do
        Map.has_key?(src, "o#{i}") ->
          Map.get(src, "o#{i}") |> String.to_atom
        Map.has_key?(src, "b#{i}") ->
          Map.get(src, "b#{i}") |> Base.decode64!
        Map.has_key?(src, "h#{i}") ->
          Map.get(src, "h#{i}") |> Base.decode16!(case: :mixed)
      end
      BSV.Script.push(script, data)
    end)
  end


  # TODO
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
