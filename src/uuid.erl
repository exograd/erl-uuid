%% Copyright (c) 2020 Nicolas Martyanoff <khaelin@gmail.com>.
%%
%% Permission to use, copy, modify, and/or distribute this software for any
%% purpose with or without fee is hereby granted, provided that the above
%% copyright notice and this permission notice appear in all copies.
%%
%% THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
%% REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
%% AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
%% INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
%% LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
%% OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
%% PERFORMANCE OF THIS SOFTWARE.

-module(uuid).

-export([nil/0, uuid/1, generate_v4/0, version/1, format/1, parse/1]).

-export_type([uuid/0, uuid_string/0]).

-type uuid() :: <<_:128>>.
-type uuid_string() :: <<_:288>>.

-type version() :: 1..5.

-spec nil() -> uuid().
nil() ->
  <<0:128>>.

-spec uuid(iodata()) -> uuid().
uuid(Data) ->
  case parse(Data) of
    {ok, U} ->
      U;
    {error, Reason} ->
      error(Reason)
  end.

-spec generate_v4() -> uuid().
generate_v4() ->
  Data = crypto:strong_rand_bytes(16),
  <<Data1:48, _:4, Data2:12, _:2, Data3:62>> = Data,
  <<Data1:48, 4:4, Data2:12, 2:2, Data3:62>>.

-spec version(uuid()) -> version().
version(U) ->
  <<_:48, Version:4, _:76>> = U,
  Version.

-spec format(uuid()) -> uuid_string().
format(U) ->
  Parts = [binary:part(U, {0, 4}),
           binary:part(U, {4, 2}),
           binary:part(U, {6, 2}),
           binary:part(U, {8, 2}),
           binary:part(U, {10, 6})],
  HexStrings = lists:map(fun binary_to_hex_string/1, Parts),
  Data = io_lib:format("~s-~s-~s-~s-~s", HexStrings),
  iolist_to_binary(Data).

-spec parse(iodata()) -> {ok, uuid()} | {error, term()}.
parse(Data) when is_list(Data) ->
  parse(iolist_to_binary(Data));
parse(Bin) ->
  case binary:split(Bin, <<"-">>, [global]) of
    [P1, P2, P3, P4, P5] when byte_size(P1) == 8,
                              byte_size(P2) == 4,
                              byte_size(P3) == 4,
                              byte_size(P4) == 4,
                              byte_size(P5) == 12 ->
      try
        D1 = hex_string_to_binary(P1),
        D2 = hex_string_to_binary(P2),
        D3 = hex_string_to_binary(P3),
        D4 = hex_string_to_binary(P4),
        D5 = hex_string_to_binary(P5),
        U = <<D1/binary, D2/binary, D3/binary, D4/binary, D5/binary>>,
        {ok, U}
      catch
        error:Reason ->
          {error, Reason}
      end;
    _ ->
      {error, invalid_format}
  end.

-spec binary_to_hex_string(binary()) -> string().
binary_to_hex_string(Bin) ->
  S = [io_lib:format("~2.16.0B", [Byte]) || <<Byte:8>> <= Bin],
  string:lowercase(S).

-spec hex_string_to_binary(binary()) -> binary().
hex_string_to_binary(Str) ->
  hex_string_to_binary(Str, <<>>).

-spec hex_string_to_binary(binary(), binary()) -> binary().
hex_string_to_binary(<<>>, Acc) ->
  Acc;
hex_string_to_binary(<<Digit1:8, Digit2:8, Rest/binary>>, Acc) ->
  Q1 = hex_digit_to_integer(Digit1),
  Q2 = hex_digit_to_integer(Digit2),
  hex_string_to_binary(Rest, <<Acc/binary, Q1:4, Q2:4>>).

-spec hex_digit_to_integer(char()) -> 0..15.
hex_digit_to_integer(C) when C >= $0, C =< $9 ->
  C - $0;
hex_digit_to_integer(C) when C >= $a, C =< $f ->
  10 + C - $a;
hex_digit_to_integer(C) when C >= $A, C =< $F ->
  10 + C - $A;
hex_digit_to_integer(C) ->
  error({invalid_hex_digit, C}).
