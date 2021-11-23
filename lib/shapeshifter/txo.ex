defmodule Shapeshifter.TXO do
  @moduledoc """
  Module for converting to and from [`TXO`](`t:Shapeshifter.txo/0`) structured
  maps.

  Usually used internally, although can be used directly for specific use cases
  such as converting single inputs and outputs to and from [`TXO`](`t:Shapeshifter.txo/0`)
  formatted maps.
  """
  import Shapeshifter.Shared


  @doc """
  Creates a new [`TXO`](`t:Shapeshifter.txo/0`) formatted map from the given
  [`Shapeshifter`](`t:Shapeshifter.t/0`) struct.
  """
  @spec new(Shapeshifter.t) :: Shapeshifter.txo
  def new(%Shapeshifter{src: tx, format: :tx} = _shifter) do
    txid = BSV.Tx.get_txid(tx)

    ins = tx.inputs
    |> Enum.with_index()
    |> Enum.map(&cast_input/1)

    outs = tx.outputs
    |> Enum.with_index()
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
  Converts the given input parameters to a [`TXO`](`t:Shapeshifter.txo/0`)
  formatted input.

  Accepts either a [`BSV Input`](`t:BSV.TxIn.t/0`) struct or a
  [`BOB`](`t:Shapeshifter.bob/0`) formatted input.
  """
  @spec cast_input({BSV.TxIn.t | map, integer}) :: map
  def cast_input({%BSV.TxIn{} = src, index}) do
    input = %{
      "i" => index,
      "seq" => src.sequence,
      "e" => %{
        "h" => BSV.OutPoint.get_txid(src.outpoint),
        "i" => src.outpoint.vout,
        "a" => script_address(src.script.chunks)
      },
      "len" => length(src.script.chunks)
    }

    src.script.chunks
    |> Enum.with_index()
    |> Enum.reduce(input, &from_script_chunk/2)
  end

  def cast_input(%{"tape" => _tape} = src),
    do: from_bob_tape(src)


  @doc """
  Converts the given output parameters to a [`TXO`](`t:Shapeshifter.txo/0`)
  formatted output.

  Accepts either a [`BSV Output`](`t:BSV.TxOut.t/0`) struct or a
  [`BOB`](`t:Shapeshifter.bob/0`) formatted output.
  """
  @spec cast_output({BSV.TxOut.t | map, integer}) :: map
  def cast_output({%BSV.TxOut{} = src, index}) do
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
    |> Enum.with_index()
    |> Enum.reduce(output, &from_script_chunk/2)
  end

  def cast_output(%{"tape" => _tape} = src),
    do: from_bob_tape(src)


  @doc """
  Converts the given [`TXO`](`t:Shapeshifter.txo/0`) formatted transaction back
  to a [`BSV Transaction`](`t:BSV.Tx.t/0`) struct.
  """
  @spec to_tx(%Shapeshifter{
    src: Shapeshifter.txo,
    format: :txo
  } | Shapeshifter.txo) :: BSV.Tx.t
  def to_tx(%Shapeshifter{src: src, format: :txo}),
    do: to_tx(src)

  def to_tx(%{"in" => ins, "out" => outs} = src) do
    %BSV.Tx{
      inputs: Enum.map(ins, &to_tx_input/1),
      outputs: Enum.map(outs, &to_tx_output/1),
      lock_time: src["lock"]
    }
  end


  @doc """
  Converts the given [`TXO`](`t:Shapeshifter.txo/0`) formatted input back to a
  [`BSV Input`](`t:BSV.TxIn.t/0`) struct.
  """
  @spec to_tx_input(map) :: BSV.TxIn.t
  def to_tx_input(%{} = src) do
    %BSV.TxIn{
      outpoint: %BSV.OutPoint{
        hash: get_in(src, ["e", "h"]) |> BSV.Util.decode!(:hex) |> BSV.Util.reverse_bin(),
        vout: get_in(src, ["e", "i"])
      },
      sequence: src["seq"],
      script: to_tx_script(src)
    }
  end


  @doc """
  Converts the given [`TXO`](`t:Shapeshifter.txo/0`) formatted output back to a
  [`BSV Output`](`t:BSV.TxOut.t/0`) struct.
  """
  @spec to_tx_output(map) :: BSV.TxOut.t
  def to_tx_output(%{} = src) do
    %BSV.TxOut{
      satoshis: get_in(src, ["e", "v"]),
      script: to_tx_script(src)
    }
  end


  # Converts a BSV Script chunk to TXO parameters. The index is given with the
  # script chunk.
  defp from_script_chunk({opcode, index}, target) when is_atom(opcode),
    do: Map.put(target, "o#{index}", Atom.to_string(opcode))

  defp from_script_chunk({data, index}, target) when is_binary(data) do
    Map.merge(target, %{
      "s#{index}" => data,
      "b#{index}" => Base.encode64(data),
      "h#{index}" => Base.encode16(data, case: :lower),
    })
  end


  # Converts a BOB formatted tape to TXO parameters.
  defp from_bob_tape(%{"tape" => tape} = src) do
    target = src
    |> Map.delete("tape")
    |> Map.put("len", 0)

    tape
    |> Enum.flat_map(& &1["cell"])
    |> Enum.reduce(target, &from_bob_cell/2)
  end


  # Converts a BOB formatted cell to TXO parameters.
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


  # Checks the expected index when iterrating over a BOB tape. If the expected
  # index is less, then we know to add a pipe character into the TXO map.
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


  # Converts TXO formatted attributes into a BSV Script struct.
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

end
