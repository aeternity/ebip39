%%% Author      : Hans Svensson
%%% Description : Implement BIP0039
%%% Created     : 12 Jan 2022 by Hans Svensson
-module(ebip39).

-ifdef(TEST).
-export([read_wordlist/0, gen_mnemonic/2]).
-endif.

-export([generate_mnemonic/1,
         mnemonic_to_seed/2]).

-define(WORDLIST, "wordlist_en.txt").

mnemonic_to_seed(Mnemonic, PassPhrase) ->
  verify_mnemonic(Mnemonic),
  {ok, BinSeed} = epbkdf2:pbkdf2(sha512,
                                 Mnemonic,
                                 iolist_to_binary(["mnemonic", PassPhrase]),
                                 2048),
  BinSeed.

generate_mnemonic(Size) ->
  case Size rem 32 of
    0 -> gen_mnemonic(Size);
    _ -> error({bad_mnemonic_size, Size, not_a_multiple_of_32})
  end.

gen_mnemonic(Size) ->
  gen_mnemonic(Size, crypto:strong_rand_bytes(Size div 8)).

gen_mnemonic(Size, Seed) ->
  CSize = Size div 32,
  <<CS:(CSize), _/bitstring>> = crypto:hash(sha256, Seed),
  Table  = ix_table(),
  Words = [ maps:get(G, Table) || <<G:11>> <= <<Seed/bytes, CS:(CSize)>> ],
  iolist_to_binary(lists:join(<<" ">>, Words)).

verify_mnemonic(Mnemonic) ->
  Table = word_table(),
  Ixs   = [ maps:get(W, Table) || W <- string:lexemes(Mnemonic, " ") ],
  Size  = length(Ixs) * 11,
  CSize = Size rem 32,
  SSize = Size - CSize,
  <<Seed:(SSize div 8)/bytes, CS:(CSize)>> = << <<Ix:11>> || Ix <- Ixs >>,
  case crypto:hash(sha256, Seed) of
    <<CS:(CSize), _/bitstring>> -> ok;
    _                           -> error({bad_mnemonic_string, checksum_error})
  end.

word_table() ->
  Words = read_wordlist(),
  maps:from_list(lists:zip(Words, lists:seq(0, 2047))).

ix_table() ->
  Words = read_wordlist(),
  maps:from_list(lists:zip(lists:seq(0, 2047), Words)).

read_wordlist() ->
  File = filename:join(code:priv_dir(ebip39), ?WORDLIST),
  {ok, BinData} = file:read_file(File),
  Words = string:lexemes(BinData, "\n"),
  2048 = length(Words),
  Words.

