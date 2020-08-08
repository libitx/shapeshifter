defmodule ShapeshifterTest do
  use ExUnit.Case
  doctest Shapeshifter


  describe "from/1 with rawtx" do
    test "parses valid rawtx in hex format" do
      assert {:ok, %Shapeshifter{src_format: :tx} = shifter} = Shapeshifter.from(TestTx.rawtx)
      assert %BSV.Transaction{} = shifter.src
    end

    test "parses valid rawtx in binary format" do
      rawtx = Base.decode16!(TestTx.rawtx, case: :mixed)
      assert {:ok, %Shapeshifter{src_format: :tx} = shifter} = Shapeshifter.from(rawtx)
      assert %BSV.Transaction{} = shifter.src
    end

    test "returns error when given invalid hex" do
      assert {:error, %ArgumentError{}} = Shapeshifter.from("8813a685c9fb0c07020411fcf4f990d1c7dff602")
    end

    test "returns error when given invalid binary" do
      assert {:error, %ArgumentError{}} = Shapeshifter.from(<<0, 4, 5, 112, 222, 232, 11>>)
    end
  end


  describe "from/1 with tx" do
    test "returns valid shapeshifter with BSV.Transaction struct" do
      assert {:ok, %Shapeshifter{src_format: :tx} = shifter} = Shapeshifter.from(TestTx.tx)
      assert %BSV.Transaction{} = shifter.src
    end
  end


  describe "from/1 with txo" do
    test "returns valid shapeshifter with TXO map" do
      assert {:ok, %Shapeshifter{src_format: :txo} = shifter} = Shapeshifter.from(TestTx.txo)
      assert shifter.src == TestTx.txo
    end

    test "returns error when given invalid map" do
      assert {:error, %ArgumentError{}} = Shapeshifter.from(%{})
    end
  end


  describe "from/1 with bob" do
    test "returns valid shapeshifter with BOB map" do
      assert {:ok, %Shapeshifter{src_format: :bob} = shifter} = Shapeshifter.from(TestTx.bob)
      assert shifter.src == TestTx.bob
    end

    test "returns error when given invalid map" do
      assert {:error, %ArgumentError{}} = Shapeshifter.from(%{})
    end
  end


  describe "transform with rawtx" do
    setup do
      {:ok, shifter} = Shapeshifter.from(TestTx.rawtx)
      %{shifter: shifter}
    end

    test "to_raw/1 returns the raw binary", ctx do
      res = Shapeshifter.to_raw(ctx.shifter)
      assert res == Base.decode16!(TestTx.rawtx, case: :mixed)
    end

    test "to_raw/2 returns the hex format", ctx do
      res = Shapeshifter.to_raw(ctx.shifter, encoding: :hex)
      assert res == TestTx.rawtx
    end

    test "to_tx/1 returns the tx struct", ctx do
      res = Shapeshifter.to_tx(ctx.shifter)
      assert res == TestTx.tx
    end

    # Could do with some better tests here to test the txo attributes
    test "to_txo/1 returns the txo map", ctx do
      res = Shapeshifter.to_txo(ctx.shifter)
      assert length(res["in"]) == length(TestTx.txo["in"])
      assert length(res["out"]) == length(TestTx.txo["out"])
      assert List.first(res["in"]) |> get_in(["e", "a"]) == List.first(TestTx.txo["in"]) |> get_in(["e", "a"])
      assert List.first(res["out"]) |> get_in(["e", "a"]) == List.first(TestTx.txo["out"]) |> get_in(["e", "a"])
    end

    # Could do with some better tests here to test the bob attributes
    test "to_bob/1 returns the bob map", ctx do
      res = Shapeshifter.to_bob(ctx.shifter)
      assert res["tx"] == TestTx.bob["tx"]
      assert length(res["in"]) == length(TestTx.bob["in"])
      assert length(res["out"]) == length(TestTx.bob["out"])
      assert List.first(res["in"]) |> get_in(["e", "a"]) == List.first(TestTx.txo["in"]) |> get_in(["e", "a"])
      assert List.first(res["out"]) |> get_in(["e", "a"]) == List.first(TestTx.txo["out"]) |> get_in(["e", "a"])
    end
  end


  describe "transform with tx" do
    setup do
      {:ok, shifter} = Shapeshifter.from(TestTx.tx)
      %{shifter: shifter}
    end

    test "to_raw/1 returns the raw binary", ctx do
      res = Shapeshifter.to_raw(ctx.shifter)
      assert res == Base.decode16!(TestTx.rawtx, case: :mixed)
    end

    test "to_raw/2 returns the hex format", ctx do
      res = Shapeshifter.to_raw(ctx.shifter, encoding: :hex)
      assert res == TestTx.rawtx
    end

    test "to_tx/1 returns the tx struct", ctx do
      res = Shapeshifter.to_tx(ctx.shifter)
      assert res == TestTx.tx
    end

    # Could do with some better tests here to test the txo attributes
    test "to_txo/1 returns the txo map", ctx do
      res = Shapeshifter.to_txo(ctx.shifter)
      assert res["tx"] == TestTx.txo["tx"]
      assert length(res["in"]) == length(TestTx.txo["in"])
      assert length(res["out"]) == length(TestTx.txo["out"])
      assert List.first(res["in"]) |> get_in(["e", "a"]) == List.first(TestTx.txo["in"]) |> get_in(["e", "a"])
      assert List.first(res["out"]) |> get_in(["e", "a"]) == List.first(TestTx.txo["out"]) |> get_in(["e", "a"])
    end

    # Could do with some better tests here to test the bob attributes
    test "to_bob/1 returns the bob map", ctx do
      res = Shapeshifter.to_bob(ctx.shifter)
      assert res["tx"] == TestTx.bob["tx"]
      assert length(res["in"]) == length(TestTx.bob["in"])
      assert length(res["out"]) == length(TestTx.bob["out"])
      assert List.first(res["in"]) |> get_in(["e", "a"]) == List.first(TestTx.txo["in"]) |> get_in(["e", "a"])
      assert List.first(res["out"]) |> get_in(["e", "a"]) == List.first(TestTx.txo["out"]) |> get_in(["e", "a"])
    end
  end


  describe "transform with txo" do
    setup do
      {:ok, shifter} = Shapeshifter.from(TestTx.txo)
      %{shifter: shifter}
    end

    test "to_raw/1 returns the raw binary", ctx do
      res = Shapeshifter.to_raw(ctx.shifter)
      assert res == Base.decode16!(TestTx.rawtx, case: :mixed)
    end

    test "to_raw/2 returns the hex format", ctx do
      res = Shapeshifter.to_raw(ctx.shifter, encoding: :hex)
      assert res == TestTx.rawtx
    end

    test "to_tx/1 returns the tx struct", ctx do
      res = Shapeshifter.to_tx(ctx.shifter)
      assert length(res.inputs) == length(TestTx.tx.inputs)
      assert length(res.outputs) == length(TestTx.tx.outputs)
      assert BSV.Transaction.get_txid(res) == get_in(TestTx.txo, ["tx", "h"])
    end

    test "to_txo/1 returns the txo map", ctx do
      res = Shapeshifter.to_txo(ctx.shifter)
      assert res == TestTx.txo
    end

    test "to_bob/1 returns the bob map", ctx do
      res = Shapeshifter.to_bob(ctx.shifter)
      assert res == Map.delete(TestTx.bob, "_id")
    end
  end


  describe "transform with bob" do
    setup do
      {:ok, shifter} = Shapeshifter.from(TestTx.bob)
      %{shifter: shifter}
    end

    test "to_raw/1 returns the raw binary", ctx do
      res = Shapeshifter.to_raw(ctx.shifter)
      assert res == Base.decode16!(TestTx.rawtx, case: :mixed)
    end

    test "to_raw/2 returns the hex format", ctx do
      res = Shapeshifter.to_raw(ctx.shifter, encoding: :hex)
      assert res == TestTx.rawtx
    end

    test "to_tx/1 returns the tx struct", ctx do
      res = Shapeshifter.to_tx(ctx.shifter)
      assert length(res.inputs) == length(TestTx.tx.inputs)
      assert length(res.outputs) == length(TestTx.tx.outputs)
      assert BSV.Transaction.get_txid(res) == get_in(TestTx.txo, ["tx", "h"])
    end

    test "to_txo/1 returns the txo map", ctx do
      res = Shapeshifter.to_txo(ctx.shifter)
      assert res == Map.delete(TestTx.txo, "_id")
    end

    test "to_bob/1 returns the bob map", ctx do
      res = Shapeshifter.to_bob(ctx.shifter)
      assert res == TestTx.bob
    end
  end
end
