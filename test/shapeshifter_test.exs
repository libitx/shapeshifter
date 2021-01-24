defmodule ShapeshifterTest do
  use ExUnit.Case


  describe "new/1" do
    test "handles valid rawtx in hex format" do
      assert {:ok, %Shapeshifter{format: :tx} = shifter} = Shapeshifter.new(TestTx.rawtx)
      assert %BSV.Transaction{} = shifter.src
    end

    test "handles valid rawtx in binary format" do
      rawtx = Base.decode16!(TestTx.rawtx, case: :mixed)
      assert {:ok, %Shapeshifter{format: :tx} = shifter} = Shapeshifter.new(rawtx)
      assert %BSV.Transaction{} = shifter.src
    end

    test "returns error when given invalid hex" do
      assert {:error, %ArgumentError{}} = Shapeshifter.new("8813a685c9fb0c07020411fcf4f990d1c7dff602")
    end

    test "returns error when given invalid binary" do
      assert {:error, %ArgumentError{}} = Shapeshifter.new(<<0, 4, 5, 112, 222, 232, 11>>)
    end

    test "handles BSV.Transaction struct" do
      assert {:ok, %Shapeshifter{format: :tx} = shifter} = Shapeshifter.new(TestTx.tx)
      assert %BSV.Transaction{} = shifter.src
    end

    test "handles valid TXO map" do
      assert {:ok, %Shapeshifter{format: :txo} = shifter} = Shapeshifter.new(TestTx.txo)
      assert shifter.src == TestTx.txo
    end

    test "handles valid BOB map" do
      assert {:ok, %Shapeshifter{format: :bob} = shifter} = Shapeshifter.new(TestTx.bob)
      assert shifter.src == TestTx.bob
    end

    test "returns error when given invalid map" do
      assert {:error, %ArgumentError{}} = Shapeshifter.new(%{})
    end
  end


  describe "to_raw/2" do
    test "handles rawtx to rawtx" do
      assert {:ok, res} = Shapeshifter.to_raw(TestTx.rawtx, encoding: :hex)
      assert res == TestTx.rawtx
    end

    test "converts BSV.Transaction struct to rawtx" do
      assert {:ok, res} = Shapeshifter.to_raw(TestTx.tx)
      assert res == Base.decode16!(TestTx.rawtx, case: :mixed)
    end

    test "converts BSV.Transaction struct to rawtx with hex encoding" do
      assert {:ok, res} = Shapeshifter.to_raw(TestTx.tx, encoding: :hex)
      assert res == TestTx.rawtx
    end

    test "converts TXO map to rawtx" do
      assert {:ok, res} = Shapeshifter.to_raw(TestTx.txo, encoding: :hex)
      assert res == TestTx.rawtx
    end

    test "converts BOB map to rawtx" do
      assert {:ok, res} = Shapeshifter.to_raw(TestTx.bob, encoding: :hex)
      assert res == TestTx.rawtx
    end

    test "returns error when given src tx" do
      assert {:error, %ArgumentError{}} = Shapeshifter.to_raw(%{})
    end
  end


  describe "to_tx/1" do
    test "converts rawtx to BSV.Transaction struct" do
      assert {:ok, res} = Shapeshifter.to_tx(TestTx.rawtx)
      assert res == TestTx.tx
    end

    test "handles BSV.Transaction struct to BSV.Transaction struct" do
      assert {:ok, res} = Shapeshifter.to_tx(TestTx.tx)
      assert res == TestTx.tx
    end

    test "converts TXO map to BSV.Transaction struct" do
      assert {:ok, res} = Shapeshifter.to_tx(TestTx.txo)
      assert length(res.inputs) == length(TestTx.tx.inputs)
      assert length(res.outputs) == length(TestTx.tx.outputs)
      assert BSV.Transaction.get_txid(res) == get_in(TestTx.txo, ["tx", "h"])
    end

    test "converts BOB map to BSV.Transaction struct" do
      assert {:ok, res} = Shapeshifter.to_tx(TestTx.bob)
      assert length(res.inputs) == length(TestTx.tx.inputs)
      assert length(res.outputs) == length(TestTx.tx.outputs)
      assert BSV.Transaction.get_txid(res) == get_in(TestTx.bob, ["tx", "h"])
    end

    test "returns error when given src tx" do
      assert {:error, %ArgumentError{}} = Shapeshifter.to_tx(%{})
    end
  end


  describe "to_txo/1" do
    # Could do with some better tests here to test the txo attributes
    test "converts rawtx to TXO map" do
      assert {:ok, res} = Shapeshifter.to_txo(TestTx.rawtx)
      assert res["tx"] == TestTx.txo["tx"]
      assert length(res["in"]) == length(TestTx.txo["in"])
      assert length(res["out"]) == length(TestTx.txo["out"])
      assert List.first(res["in"]) |> get_in(["e", "a"]) == List.first(TestTx.txo["in"]) |> get_in(["e", "a"])
      assert List.first(res["out"]) |> get_in(["e", "a"]) == List.first(TestTx.txo["out"]) |> get_in(["e", "a"])
    end

    # Could do with some better tests here to test the txo attributes
    test "converts BSV.Transaction struct to TXO map" do
      assert {:ok, res} = Shapeshifter.to_txo(TestTx.tx)
      assert res["tx"] == TestTx.txo["tx"]
      assert length(res["in"]) == length(TestTx.txo["in"])
      assert length(res["out"]) == length(TestTx.txo["out"])
      assert List.first(res["in"]) |> get_in(["e", "a"]) == List.first(TestTx.txo["in"]) |> get_in(["e", "a"])
      assert List.first(res["out"]) |> get_in(["e", "a"]) == List.first(TestTx.txo["out"]) |> get_in(["e", "a"])
    end

    test "handles TXO map to TXO map" do
      assert {:ok, res} = Shapeshifter.to_txo(TestTx.txo)
      assert res == TestTx.txo
    end

    test "converts BOB map to TXO map" do
      assert {:ok, res} = Shapeshifter.to_txo(TestTx.bob)
      assert res == Map.delete(TestTx.txo, "_id")
    end

    test "returns error when given src tx" do
      assert {:error, %ArgumentError{}} = Shapeshifter.to_txo(%{})
    end
  end


  describe "to_bob/1" do
    # Could do with some better tests here to test the txo attributes
    test "converts rawtx to BOB map" do
      assert {:ok, res} = Shapeshifter.to_bob(TestTx.rawtx)
      assert res["tx"] == TestTx.bob["tx"]
      assert length(res["in"]) == length(TestTx.bob["in"])
      assert length(res["out"]) == length(TestTx.bob["out"])
      assert List.first(res["in"]) |> get_in(["e", "a"]) == List.first(TestTx.bob["in"]) |> get_in(["e", "a"])
      assert List.first(res["out"]) |> get_in(["e", "a"]) == List.first(TestTx.bob["out"]) |> get_in(["e", "a"])
    end

    # Could do with some better tests here to test the bob attributes
    test "converts BSV.Transaction struct to BOB map" do
      assert {:ok, res} = Shapeshifter.to_bob(TestTx.tx)
      assert res["tx"] == TestTx.bob["tx"]
      assert length(res["in"]) == length(TestTx.bob["in"])
      assert length(res["out"]) == length(TestTx.bob["out"])
      assert List.first(res["in"]) |> get_in(["e", "a"]) == List.first(TestTx.bob["in"]) |> get_in(["e", "a"])
      assert List.first(res["out"]) |> get_in(["e", "a"]) == List.first(TestTx.bob["out"]) |> get_in(["e", "a"])
    end

    test "converts TXO map to BOB map" do
      assert {:ok, res} = Shapeshifter.to_bob(TestTx.txo)
      assert res == Map.delete(TestTx.bob, "_id")
    end

    test "handles BOB map to BOB map" do
      assert {:ok, res} = Shapeshifter.to_bob(TestTx.bob)
      assert res == TestTx.bob
    end

    test "returns error when given src tx" do
      assert {:error, %ArgumentError{}} = Shapeshifter.to_bob(%{})
    end

    test "currectly indexes piped cells from tx" do
      assert {:ok, res} = Shapeshifter.to_bob(TestPipeTx.rawtx)
      assert res["out"] |> Enum.at(0) |> Map.get("tape") |> Enum.at(1) |> Map.get("cell") |> Enum.map(& Map.take(&1, ["i", "ii"])) == TestPipeTx.bob["out"] |> Enum.at(0) |> Map.get("tape") |> Enum.at(1) |> Map.get("cell") |> Enum.map(& Map.take(&1, ["i", "ii"]))
      assert res["out"] |> Enum.at(0) |> Map.get("tape") |> Enum.at(2) |> Map.get("cell") |> Enum.map(& Map.take(&1, ["i", "ii"])) == TestPipeTx.bob["out"] |> Enum.at(0) |> Map.get("tape") |> Enum.at(2) |> Map.get("cell") |> Enum.map(& Map.take(&1, ["i", "ii"]))
      assert res["out"] |> Enum.at(0) |> Map.get("tape") |> Enum.at(3) |> Map.get("cell") |> Enum.map(& Map.take(&1, ["i", "ii"])) == TestPipeTx.bob["out"] |> Enum.at(0) |> Map.get("tape") |> Enum.at(3) |> Map.get("cell") |> Enum.map(& Map.take(&1, ["i", "ii"]))
    end

    test "currectly indexes piped cells from txo" do
      assert {:ok, res} = Shapeshifter.to_bob(TestPipeTx.txo)
      assert res["out"] |> Enum.at(0) |> Map.get("tape") |> Enum.at(1) |> Map.get("cell") |> Enum.map(& Map.take(&1, ["i", "ii"])) == TestPipeTx.bob["out"] |> Enum.at(0) |> Map.get("tape") |> Enum.at(1) |> Map.get("cell") |> Enum.map(& Map.take(&1, ["i", "ii"]))
      assert res["out"] |> Enum.at(0) |> Map.get("tape") |> Enum.at(2) |> Map.get("cell") |> Enum.map(& Map.take(&1, ["i", "ii"])) == TestPipeTx.bob["out"] |> Enum.at(0) |> Map.get("tape") |> Enum.at(2) |> Map.get("cell") |> Enum.map(& Map.take(&1, ["i", "ii"]))
      assert res["out"] |> Enum.at(0) |> Map.get("tape") |> Enum.at(3) |> Map.get("cell") |> Enum.map(& Map.take(&1, ["i", "ii"])) == TestPipeTx.bob["out"] |> Enum.at(0) |> Map.get("tape") |> Enum.at(3) |> Map.get("cell") |> Enum.map(& Map.take(&1, ["i", "ii"]))
    end
  end

end
