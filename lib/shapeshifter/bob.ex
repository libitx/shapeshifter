defmodule Shapeshifter.BOB do
  @moduledoc """
  Module for converting to and from [`BOB`](`t:Shapeshifter.bob/0`) structured
  maps.

  Usually used internally, although can be used directly for specific use cases
  such as converting single inputs and outputs to and from [`BOB`](`t:Shapeshifter.bob/0`)
  formatted maps.
  """
  import Shapeshifter.Shared


  @doc """
  Creates a new [`BOB`](`t:Shapeshifter.bob/0`) formatted map from the given
  [`Shapeshifter`](`t:Shapeshifter.t/0`) struct.
  """
  @spec new(Shapeshifter.t) :: map
  def new(%Shapeshifter{src: tx, format: :tx}) do
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

  def new(%Shapeshifter{src: src, format: :txo}) do
    ins = Enum.map(src["in"], &cast_input/1)
    outs = Enum.map(src["out"], &cast_output/1)

    src
    |> Map.delete("_id")
    |> Map.put("in", ins)
    |> Map.put("out", outs)
  end

  def new(%Shapeshifter{src: src, format: :bob}), do: src


  @doc """
  Converts the given input parameters to a [`BOB`](`t:Shapeshifter.bob/0`)
  formatted input.

  Accepts either a [`BSV Input`](`t:BSV.Transaction.Input.t/0`) struct or a
  [`TXO`](`t:Shapeshifter.txo/0`) formatted input.
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
      }
    }

    tape = src.script.chunks
    |> Enum.with_index
    |> Enum.reduce({[%{"i" => 0}], 0}, &from_script_chunk/2)
    |> elem(0)
    |> Enum.reject(& &1 == %{})
    |> Enum.map(fn t -> Map.update!(t, "cell", &Enum.reverse/1) end)
    |> Enum.reverse

    Map.put(input, "tape", tape)
  end

  def cast_input(%{"len" => _len} = src),
    do: from_txo_object(src)


  @doc """
  Converts the given output parameters to a [`BOB`](`t:Shapeshifter.bob/0`)
  formatted output.

  Accepts either a [`BSV Output`](`t:BSV.Transaction.Output.t/0`) struct or a
  [`TXO`](`t:Shapeshifter.txo/0`) formatted output.
  """
  @spec cast_output({BSV.Transaction.Output.t | map, integer}) :: map
  def cast_output({%BSV.Transaction.Output{} = src, index}) do
    output = %{
      "i" => index,
      "e" => %{
        "v" => src.satoshis,
        "i" => index,
        "a" => script_address(src.script.chunks)
      }
    }

    tape = src.script.chunks
    |> Enum.with_index
    |> Enum.reduce({[%{"i" => 0}], 0}, &from_script_chunk/2)
    |> elem(0)
    |> Enum.filter(& Map.has_key?(&1, "cell"))
    |> Enum.map(fn t -> Map.update!(t, "cell", &Enum.reverse/1) end)
    |> Enum.reverse

    Map.put(output, "tape", tape)
  end

  def cast_output(%{"len" => _len} = src),
    do: from_txo_object(src)


  @doc """
  Converts the given [`BOB`](`t:Shapeshifter.bob/0`) formatted transaction back
  to a [`BSV Transaction`](`t:BSV.Transaction.t/0`) struct.
  """
  @spec to_tx(%Shapeshifter{
    src: map,
    format: :bob
  }) :: BSV.Transaction.t
  def to_tx(%Shapeshifter{
    src: %{"in" => ins, "out" => outs} = src,
    format: :bob
  }) do
    %BSV.Transaction{
      inputs: Enum.map(ins, &to_tx_input/1),
      outputs: Enum.map(outs, &to_tx_output/1),
      lock_time: src["lock"]
    }
  end


  @doc """
  Converts the given [`BOB`](`t:Shapeshifter.bob/0`) formatted input back to a
  [`BSV Input`](`t:BSV.Transaction.Input.t/0`) struct.
  """
  @spec to_tx_input(map) :: BSV.Transaction.Input.t
  def to_tx_input(%{} = src) do
    %BSV.Transaction.Input{
      output_index: get_in(src, ["e", "i"]),
      output_txid: get_in(src, ["e", "h"]),
      sequence: src["seq"],
      script: to_tx_script(src["tape"])
    }
  end


  @doc """
  Converts the given [`BOB`](`t:Shapeshifter.bob/0`) formatted output back to a
  [`BSV Output`](`t:BSV.Transaction.Output.t/0`) struct.
  """
  @spec to_tx_output(map) :: BSV.Transaction.Output.t
  def to_tx_output(%{} = src) do
    %BSV.Transaction.Output{
      satoshis: get_in(src, ["e", "v"]),
      script: to_tx_script(src["tape"])
    }
  end


  # Converts a BSV Script chunk to BOB parameters. The index is given with the
  # script chunk.
  defp from_script_chunk({opcode, index}, {[%{"i" => i} = head | tape], t})
    when is_atom(opcode)
  do
    head = head
    |> Map.put_new("cell", [])
    |> Map.update!("cell", fn cells ->
      cell = %{
        "op" => BSV.Script.OpCode.get(opcode) |> elem(1),
        "ops" => Atom.to_string(opcode),
        "i" => index - t,
        "ii" => index
      }
      [cell | cells]
    end)

    case opcode do
      :OP_RETURN ->
        {[%{"i" => i+1} | [head | tape]], index}
      _ ->
        {[head | tape], t}
    end
  end

  defp from_script_chunk({"|", index}, {[%{"i" => i } = head | tape], _t}) do
    {[%{"i" => i+1} | [head | tape]], index}
  end

  defp from_script_chunk({data, index}, {[head | tape], t})
    when is_binary(data)
  do
    head = head
    |> Map.put_new("cell", [])
    |> Map.update!("cell", fn cells ->
      cell = %{
        "s" => data,
        "h" => Base.encode16(data, case: :lower),
        "b" => Base.encode64(data),
        "i" => index - t,
        "ii" => index
      }
      [cell | cells]
    end)

    {[head | tape], t}
  end


  # Converts a TXO formatted input/output to a BOB formatted tape.
  defp from_txo_object(%{"len" => len} = src) do
    target = Map.take(src, ["i", "seq", "e"])

    tape = 0..len-1
    |> Enum.reduce({[%{"i" => 0}], 0}, fn i, {tape, t} ->
      src
      |> Map.take(["o#{i}", "s#{i}", "h#{i}", "b#{i}"])
      |> Enum.map(fn {k, v} -> {String.replace(k, ~r/\d+$/, ""), v} end)
      |> Enum.into(%{"ii" => i})
      |> from_txo_attr({tape, t})
    end)
    |> elem(0)
    |> Enum.filter(& Map.has_key?(&1, "cell"))
    |> Enum.map(fn t -> Map.update!(t, "cell", &Enum.reverse/1) end)
    |> Enum.reverse

    Map.put(target, "tape", tape)
  end


  # Converts TXO formatted parameters to a BOB formatted cell.
  defp from_txo_attr(
    %{"o" => opcode, "ii" => index},
    {[%{"i" => i} = head | tape], t}
  ) do
    head = head
    |> Map.put_new("cell", [])
    |> Map.update!("cell", fn cells ->
      cell = %{
        "op" => BSV.Script.OpCode.get(opcode) |> elem(1),
        "ops" => opcode,
        "i" => index - t,
        "ii" => index
      }
      [cell | cells]
    end)

    case opcode do
      "OP_RETURN" ->
        {[%{"i" => i+1} | [head | tape]], index+1}
      _ ->
        {[head | tape], t}
    end
  end

  defp from_txo_attr(
    %{"s" => "|", "ii" => index},
    {[%{"i" => i} = head | tape], _t}
  ) do
    {[%{"i" => i+1} | [head | tape]], index+1}
  end

  defp from_txo_attr(%{"ii" => index} = cell, {[head | tape], t}) do
    head = head
    |> Map.put_new("cell", [])
    |> Map.update!("cell", fn cells ->
      cell = Map.put(cell, "i", index - t)
      [cell | cells]
    end)

    {[head | tape], t}
  end


  # Converts a BOB formatted tape into a BSV Script struct.
  defp to_tx_script(tape) when is_list(tape) do
    tape
    |> Enum.intersperse("|")
    |> Enum.reduce(%BSV.Script{}, &to_tx_script/2)
  end

  defp to_tx_script(%{"cell" => cells}, script) do
    Enum.reduce(cells, script, fn cell, script ->
      data = cond do
        Map.has_key?(cell, "ops") ->
          Map.get(cell, "ops") |> String.to_atom
        Map.has_key?(cell, "b") ->
          Map.get(cell, "b") |> Base.decode64!
        Map.has_key?(cell, "h") ->
          Map.get(cell, "h") |> Base.decode16!(case: :mixed)
      end
      BSV.Script.push(script, data)
    end)
  end

  defp to_tx_script("|", script) do
    case List.last(script.chunks) do
      :OP_RETURN -> script
      _ -> BSV.Script.push(script, "|")
    end
  end

end
