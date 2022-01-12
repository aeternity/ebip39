ebip39
=====

Erlang implementation of [BIP-0039
Mnemonics](https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki).

The BIP-0039 standard describes the implementation of a mnemonic code or
mnemonic sentence -- a group of easy to remember words -- for the generation of
deterministic wallets. It consists of two parts: generating the mnemonic and
converting it into a binary seed. This seed can be later used to generate
deterministic wallets using BIP-0032 or similar methods.

Usage
-----

`ebip39:generate_mnemonic(Size)` will generate a mnemonic corresponding to a
secret with `Size` bits. Note: `Size` should divisible by 32.

`ebip39:mnemonic_to_seed(Mnemonic, PassPhrase)` will turn the mnemonic and the
pass phrase into a 64 byte binary `Seed`.

Test
----

    $ rebar3 eunit

Build
-----

    $ rebar3 compile
