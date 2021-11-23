defmodule TestTx do
  # Random txid for test cases bd6b24195f978a7c54c89d379566a5260284b16fc549516408db18bd157663d1
  @rawtx "010000000115c0fffa734cdf9ec922d2bb5bfe64e4600bfbbf30bd5391f5e147212219fa4a000000006b48304502210098c8b9614394115f40a0f76ca6e952dc2808e851ca31f8813a9685ce9fb06c070220411fcdf4f9960d1c87dfaf60257c6d0ce4f90f9949d64538a156d067c949185541210236e4d6d01eae5c3c140f25ae17b03ba11ca7082bf4104d83927c734b0cddcf3fffffffff0422020000000000001976a914cbb23f1ded779b83199f969511ce42c29f35b5c988ac22020000000000001976a9146be162a1158bfe888084d458bbc44273c036bba588ac22020000000000001976a914d3ae0b1175fb49ee9bd0ede71faaf596aaf880a988ac00000000000000005f006a02bd0009746f6b656e697a6564041a0254324a0a3e12034355521a20c83ba405f34dbd99604be78e404eb71163e994b6e5a51214cb2035a48ce1d7bd2200220a080110918d90c0a2de162207080210c2a2b06e10b899f1f2b1e8bd941600000000"

  @tx %BSV.Tx{
    inputs: [
      %BSV.TxIn{
        outpoint: %BSV.OutPoint{
          hash: <<21, 192, 255, 250, 115, 76, 223, 158, 201, 34, 210, 187, 91, 254, 100, 228, 96, 11, 251, 191, 48, 189, 83, 145, 245, 225, 71, 33, 34, 25, 250, 74>>,
          vout: 0
        },
        script: %BSV.Script{
          chunks: [
            <<48, 69, 2, 33, 0, 152, 200, 185, 97, 67, 148, 17, 95, 64, 160, 247, 108, 166, 233, 82, 220, 40, 8, 232, 81, 202, 49, 248, 129, 58, 150, 133, 206, 159, 176, 108, 7, 2, 32, 65, 31, 205, 244, 249, 150, 13, 28, 135, 223, 175, 96, 37, 124, 109, 12, 228, 249, 15, 153, 73, 214, 69, 56, 161, 86, 208, 103, 201, 73, 24, 85, 65>>,
            <<2, 54, 228, 214, 208, 30, 174, 92, 60, 20, 15, 37, 174, 23, 176, 59, 161, 28, 167, 8, 43, 244, 16, 77, 131, 146, 124, 115, 75, 12, 221, 207, 63>>
          ]
        },
        sequence: 4294967295
      }
    ],
    lock_time: 0,
    outputs: [
      %BSV.TxOut{
        satoshis: 546,
        script: %BSV.Script{
          chunks: [
            :OP_DUP,
            :OP_HASH160,
            <<203, 178, 63, 29, 237, 119, 155, 131, 25, 159, 150, 149, 17, 206, 66, 194, 159, 53, 181, 201>>,
            :OP_EQUALVERIFY,
            :OP_CHECKSIG
          ]
        }
      },
      %BSV.TxOut{
        satoshis: 546,
        script: %BSV.Script{
          chunks: [
            :OP_DUP,
            :OP_HASH160,
            <<107, 225, 98, 161, 21, 139, 254, 136, 128, 132, 212, 88, 187, 196, 66, 115, 192, 54, 187, 165>>,
            :OP_EQUALVERIFY,
            :OP_CHECKSIG
          ]
        }
      },
      %BSV.TxOut{
        satoshis: 546,
        script: %BSV.Script{
          chunks: [
            :OP_DUP,
            :OP_HASH160,
            <<211, 174, 11, 17, 117, 251, 73, 238, 155, 208, 237, 231, 31, 170, 245, 150, 170, 248, 128, 169>>,
            :OP_EQUALVERIFY,
            :OP_CHECKSIG
          ]
        }
      },
      %BSV.TxOut{
        satoshis: 0,
        script: %BSV.Script{
          chunks: [
            :OP_FALSE,
            :OP_RETURN,
            <<189, 0>>,
            "tokenized",
            <<26, 2, 84, 50>>,
            <<10, 62, 18, 3, 67, 85, 82, 26, 32, 200, 59, 164, 5, 243, 77, 189, 153, 96, 75, 231, 142, 64, 78, 183, 17, 99, 233, 148, 182, 229, 165, 18, 20, 203, 32, 53, 164, 140, 225, 215, 189, 34, 0, 34, 10, 8, 1, 16, 145, 141, 144, 192, 162, 222, 22, 34, 7, 8, 2, 16, 194, 162, 176, 110, 16, 184, 153, 241, 242, 177, 232, 189, 148, 22>>
          ]
        }
      }
    ],
    version: 1
  }

  @txo %{
    "_id" => "5f2d346290f3f8328cd1cb2d",
    "tx" => %{
      "h" => "bd6b24195f978a7c54c89d379566a5260284b16fc549516408db18bd157663d1"
    },
    "in" => [
      %{
        "i" => 0,
        "seq" => 4294967295,
        "e" => %{
          "h" => "4afa19222147e1f59153bd30bffb0b60e464fe5bbbd222c99edf4c73faffc015",
          "i" => 0,
          "a" => "16f1F6ygYqkQ1eEtdi3mTWpSzQ9eZKzM1"
        },
        "len" => 2,
        "s0" => "0E\u0002!\u0000�ȹaC�\u0011_@��l��R�(\b�Q�1��:��Ο�l\u0007\u0002 A\u001f����\r\u001c�߯`%|m\f��\u000f�I�E8�V�g�I\u0018UA",
        "b0" => "MEUCIQCYyLlhQ5QRX0Cg92ym6VLcKAjoUcox+IE6loXOn7BsBwIgQR/N9PmWDRyH369gJXxtDOT5D5lJ1kU4oVbQZ8lJGFVB",
        "h0" => "304502210098c8b9614394115f40a0f76ca6e952dc2808e851ca31f8813a9685ce9fb06c070220411fcdf4f9960d1c87dfaf60257c6d0ce4f90f9949d64538a156d067c949185541",
        "s1" => "\u00026���\u001e�\\<\u0014\u000f%�\u0017�;�\u001c�\b+�\u0010M��|sK\f��?",
        "b1" => "Ajbk1tAerlw8FA8lrhewO6Ecpwgr9BBNg5J8c0sM3c8/",
        "h1" => "0236e4d6d01eae5c3c140f25ae17b03ba11ca7082bf4104d83927c734b0cddcf3f"
      }
    ],
    "out" => [
      %{
        "i" => 0,
        "e" => %{
          "v" => 546,
          "i" => 0,
          "a" => "1Ka3hjHR4nTU8FwbrV8jqyh7G6xxMu83ze"
        },
        "len" => 5,
        "o0" => "OP_DUP",
        "o1" => "OP_HASH160",
        "s2" => "˲?\u001d�w��\u0019���\u0011�B5��",
        "b2" => "y7I/He13m4MZn5aVEc5Cwp81tck=",
        "h2" => "cbb23f1ded779b83199f969511ce42c29f35b5c9",
        "o3" => "OP_EQUALVERIFY",
        "o4" => "OP_CHECKSIG"
      },
      %{
        "i" => 1,
        "e" => %{
          "v" => 546,
          "i" => 1,
          "a" => "1AqRJa14kHsEL2mn6hCNYs2criRE4sytL2"
        },
        "len" => 5,
        "o0" => "OP_DUP",
        "o1" => "OP_HASH160",
        "s2" => "k�b�\u0015������X��Bs�6��",
        "b2" => "a+FioRWL/oiAhNRYu8RCc8A2u6U=",
        "h2" => "6be162a1158bfe888084d458bbc44273c036bba5",
        "o3" => "OP_EQUALVERIFY",
        "o4" => "OP_CHECKSIG"
      },
      %{
        "i" => 2,
        "e" => %{
          "v" => 546,
          "i" => 2,
          "a" => "1LJG5DJqYe4GibJpfTkycsGnpypR1bHbFm"
        },
        "len" => 5,
        "o0" => "OP_DUP",
        "o1" => "OP_HASH160",
        "s2" => "Ӯ\u000b\u0011u�I����\u001f�������",
        "b2" => "064LEXX7Se6b0O3nH6r1lqr4gKk=",
        "h2" => "d3ae0b1175fb49ee9bd0ede71faaf596aaf880a9",
        "o3" => "OP_EQUALVERIFY",
        "o4" => "OP_CHECKSIG"
      },
      %{
        "i" => 3,
        "e" => %{
          "v" => 0,
          "i" => 3,
          "a" => "false"
        },
        "len" => 6,
        "o0" => "OP_0",
        "o1" => "OP_RETURN",
        "s2" => "�\u0000",
        "b2" => "vQA=",
        "h2" => "bd00",
        "s3" => "tokenized",
        "b3" => "dG9rZW5pemVk",
        "h3" => "746f6b656e697a6564",
        "s4" => "\u001a\u0002T2",
        "b4" => "GgJUMg==",
        "h4" => "1a025432",
        "s5" => "\n>\u0012\u0003CUR\u001a �;�\u0005�M��`K�@N�\u0011c锶�\u0012\u0014� 5���׽\"\u0000\"\n\b\u0001\u0010������\u0016\"\u0007\b\u0002\u0010¢�n\u0010����轔\u0016",
        "b5" => "Cj4SA0NVUhogyDukBfNNvZlgS+eOQE63EWPplLblpRIUyyA1pIzh170iACIKCAEQkY2QwKLeFiIHCAIQwqKwbhC4mfHysei9lBY=",
        "h5" => "0a3e12034355521a20c83ba405f34dbd99604be78e404eb71163e994b6e5a51214cb2035a48ce1d7bd2200220a080110918d90c0a2de162207080210c2a2b06e10b899f1f2b1e8bd9416"
      }
    ],
    "lock" => 0,
    "i" => 6,
    "blk" => %{
      "i" => 647084,
      "h" => "00000000000000000164ee1658007aa040481eeba2d80c1aac9e79949009e31d",
      "t" => 1596798033
    }
  }

  @bob %{
    "_id" => "5f2d3462b7e4f66f64d57249",
    "tx" => %{
      "h" => "bd6b24195f978a7c54c89d379566a5260284b16fc549516408db18bd157663d1"
    },
    "in" => [
      %{
        "i" => 0,
        "seq" => 4294967295,
        "tape" => [
          %{
            "cell" => [
              %{
                "s" => "0E\u0002!\u0000�ȹaC�\u0011_@��l��R�(\b�Q�1��:��Ο�l\u0007\u0002 A\u001f����\r\u001c�߯`%|m\f��\u000f�I�E8�V�g�I\u0018UA",
                "h" => "304502210098c8b9614394115f40a0f76ca6e952dc2808e851ca31f8813a9685ce9fb06c070220411fcdf4f9960d1c87dfaf60257c6d0ce4f90f9949d64538a156d067c949185541",
                "b" => "MEUCIQCYyLlhQ5QRX0Cg92ym6VLcKAjoUcox+IE6loXOn7BsBwIgQR/N9PmWDRyH369gJXxtDOT5D5lJ1kU4oVbQZ8lJGFVB",
                "i" => 0,
                "ii" => 0
              },
              %{
                "s" => "\u00026���\u001e�\\<\u0014\u000f%�\u0017�;�\u001c�\b+�\u0010M��|sK\f��?",
                "h" => "0236e4d6d01eae5c3c140f25ae17b03ba11ca7082bf4104d83927c734b0cddcf3f",
                "b" => "Ajbk1tAerlw8FA8lrhewO6Ecpwgr9BBNg5J8c0sM3c8/",
                "i" => 1,
                "ii" => 1
              }
            ],
            "i" => 0
          }
        ],
        "e" => %{
          "h" => "4afa19222147e1f59153bd30bffb0b60e464fe5bbbd222c99edf4c73faffc015",
          "i" => 0,
          "a" => "16f1F6ygYqkQ1eEtdi3mTWpSzQ9eZKzM1"
        }
      }
    ],
    "out" => [
      %{
        "i" => 0,
        "tape" => [
          %{
            "cell" => [
              %{
                "op" => 118,
                "ops" => "OP_DUP",
                "i" => 0,
                "ii" => 0
              },
              %{
                "op" => 169,
                "ops" => "OP_HASH160",
                "i" => 1,
                "ii" => 1
              },
              %{
                "s" => "˲?\u001d�w��\u0019���\u0011�B5��",
                "h" => "cbb23f1ded779b83199f969511ce42c29f35b5c9",
                "b" => "y7I/He13m4MZn5aVEc5Cwp81tck=",
                "i" => 2,
                "ii" => 2
              },
              %{
                "op" => 136,
                "ops" => "OP_EQUALVERIFY",
                "i" => 3,
                "ii" => 3
              },
              %{
                "op" => 172,
                "ops" => "OP_CHECKSIG",
                "i" => 4,
                "ii" => 4
              }
            ],
            "i" => 0
          }
        ],
        "e" => %{
          "v" => 546,
          "i" => 0,
          "a" => "1Ka3hjHR4nTU8FwbrV8jqyh7G6xxMu83ze"
        }
      },
      %{
        "i" => 1,
        "tape" => [
          %{
            "cell" => [
              %{
                "op" => 118,
                "ops" => "OP_DUP",
                "i" => 0,
                "ii" => 0
              },
              %{
                "op" => 169,
                "ops" => "OP_HASH160",
                "i" => 1,
                "ii" => 1
              },
              %{
                "s" => "k�b�\u0015������X��Bs�6��",
                "h" => "6be162a1158bfe888084d458bbc44273c036bba5",
                "b" => "a+FioRWL/oiAhNRYu8RCc8A2u6U=",
                "i" => 2,
                "ii" => 2
              },
              %{
                "op" => 136,
                "ops" => "OP_EQUALVERIFY",
                "i" => 3,
                "ii" => 3
              },
              %{
                "op" => 172,
                "ops" => "OP_CHECKSIG",
                "i" => 4,
                "ii" => 4
              }
            ],
            "i" => 0
          }
        ],
        "e" => %{
          "v" => 546,
          "i" => 1,
          "a" => "1AqRJa14kHsEL2mn6hCNYs2criRE4sytL2"
        }
      },
      %{
        "i" => 2,
        "tape" => [
          %{
            "cell" => [
              %{
                "op" => 118,
                "ops" => "OP_DUP",
                "i" => 0,
                "ii" => 0
              },
              %{
                "op" => 169,
                "ops" => "OP_HASH160",
                "i" => 1,
                "ii" => 1
              },
              %{
                "s" => "Ӯ\u000b\u0011u�I����\u001f�������",
                "h" => "d3ae0b1175fb49ee9bd0ede71faaf596aaf880a9",
                "b" => "064LEXX7Se6b0O3nH6r1lqr4gKk=",
                "i" => 2,
                "ii" => 2
              },
              %{
                "op" => 136,
                "ops" => "OP_EQUALVERIFY",
                "i" => 3,
                "ii" => 3
              },
              %{
                "op" => 172,
                "ops" => "OP_CHECKSIG",
                "i" => 4,
                "ii" => 4
              }
            ],
            "i" => 0
          }
        ],
        "e" => %{
          "v" => 546,
          "i" => 2,
          "a" => "1LJG5DJqYe4GibJpfTkycsGnpypR1bHbFm"
        }
      },
      %{
        "i" => 3,
        "tape" => [
          %{
            "cell" => [
              %{
                "op" => 0,
                "ops" => "OP_0",
                "i" => 0,
                "ii" => 0
              },
              %{
                "op" => 106,
                "ops" => "OP_RETURN",
                "i" => 1,
                "ii" => 1
              }
            ],
            "i" => 0
          },
          %{
            "cell" => [
              %{
                "s" => "�\u0000",
                "h" => "bd00",
                "b" => "vQA=",
                "i" => 0,
                "ii" => 2
              },
              %{
                "s" => "tokenized",
                "h" => "746f6b656e697a6564",
                "b" => "dG9rZW5pemVk",
                "i" => 1,
                "ii" => 3
              },
              %{
                "s" => "\u001a\u0002T2",
                "h" => "1a025432",
                "b" => "GgJUMg==",
                "i" => 2,
                "ii" => 4
              },
              %{
                "s" => "\n>\u0012\u0003CUR\u001a �;�\u0005�M��`K�@N�\u0011c锶�\u0012\u0014� 5���׽\"\u0000\"\n\b\u0001\u0010������\u0016\"\u0007\b\u0002\u0010¢�n\u0010����轔\u0016",
                "h" => "0a3e12034355521a20c83ba405f34dbd99604be78e404eb71163e994b6e5a51214cb2035a48ce1d7bd2200220a080110918d90c0a2de162207080210c2a2b06e10b899f1f2b1e8bd9416",
                "b" => "Cj4SA0NVUhogyDukBfNNvZlgS+eOQE63EWPplLblpRIUyyA1pIzh170iACIKCAEQkY2QwKLeFiIHCAIQwqKwbhC4mfHysei9lBY=",
                "i" => 3,
                "ii" => 5
              }
            ],
            "i" => 1
          }
        ],
        "e" => %{
          "v" => 0,
          "i" => 3,
          "a" => "false"
        }
      }
    ],
    "lock" => 0,
    "i" => 6,
    "blk" => %{
      "i" => 647084,
      "h" => "00000000000000000164ee1658007aa040481eeba2d80c1aac9e79949009e31d",
      "t" => 1596798033
    }
  }

  def rawtx, do: @rawtx
  def tx, do: @tx
  def txo, do: @txo
  def bob, do: @bob
end
