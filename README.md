# Shapeshifter

![Shapeshifter lets you quickly and simply switch between Bitcoin transaction formats](https://github.com/libitx/shapeshifter/raw/master/media/poster.png)

![Hex.pm](https://img.shields.io/hexpm/v/shapeshifter?color=informational)
![GitHub](https://img.shields.io/github/license/libitx/shapeshifter?color=informational)
![Build Status](https://img.shields.io/github/workflow/status/libitx/shapeshifter/Elixir%20CI)

Shapeshifter is an Elixir library for switching between Bitcoin transaction formats. Quickly and simply shift between raw tx binaries, `BSV.Tx` structs, and `TXO` and `BOB` transaction formats.

## Sponsors

<p align="center">Supported by:</p>
<p align="center">
  <a href="https://coingeek.com" target="_blank" rel="noopener noreferrer">
    <img src="https://www.chronoslabs.net/img/badges/coingeek.png" width="180" alt="Coingeek">
  </a>
</p>

Your sponsorship will help us continue to release and maintain software that Bitcoin businesses and developers depend on.

#### 👉 [Sponsor Chronos Labs' open source work](https://www.chronoslabs.net/sponsor/)

## Installation

The package can be installed by adding `shapeshifter` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:shapeshifter, "~> 0.2"}
  ]
end
```

## Usage

Using Shapeshifter couldn't be simpler. Under the hood Shapeshifter uses pattern matching to automatically determine the source format, so all you need to do is pass a transaction object of any format to the appropriate function of the format you want to convert to (from: `to_raw/2`, `to_tx/1`, `to_txo/1` or `to_bob/1`).

```elixir
# Convert to raw tx
Shapeshifter.to_raw(tx)
# => <<1, 0, 0, 0, ...>>

# Convert to raw tx with hex encoding
Shapeshifter.to_raw(tx, encoding: :hex)
# => "01000000..."

# Convert to BSV.Tx struct
Shapeshifter.to_tx(tx)
# => %BSV.Tx{}

# Convert to TXO map
Shapeshifter.to_txo(tx)
# => %{"in" => [...], "out" => [...], ...}

# Convert to BOB map
Shapeshifter.to_bob(tx)
# => %{"in" => [...], "out" => [...], ...}
```

For more advanced use, Shapeshifter can also be used to convert individual inputs and outputs between the supported formats.

For more examples, refer to the [full documentation](https://hexdocs.pm/shapeshifter).

## License

Shapeshifter is open source and released under the [Apache-2 License](https://github.com/libitx/shapeshifter/blob/master/LICENSE).

© Copyright 2020-2021 Chronos Labs Ltd.

