%% Copyright (c) 2020-2021 Nicolas Martyanoff <khaelin@gmail.com>.
%%
%% Permission to use, copy, modify, and/or distribute this software for any
%% purpose with or without fee is hereby granted, provided that the above
%% copyright notice and this permission notice appear in all copies.
%%
%% THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
%% WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
%% MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
%% SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
%% WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
%% ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR
%% IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

-module(uuid_test).

-include_lib("eunit/include/eunit.hrl").

nil_test() ->
  ?assertEqual(<<0:128>>, uuid:nil()).

uuid_test() ->
  ?assertEqual(<<128,67,215,26,230,84,74,42,173,74,77,96,75,234,90,90>>,
               uuid:uuid(<<"8043d71a-e654-4a2a-ad4a-4d604bea5a5a">>)),
  ?assertError(invalid_format, uuid:uuid(<<"foo">>)),
  ?assertError({invalid_hex_digit, $x},
               uuid:uuid(<<"8043d71a-e654-4a2a-ad4a-4d604bea5a5x">>)).

generate_v4_test() ->
  UUIDs = [uuid:generate_v4() || _ <- lists:seq(1, 1000)],
  [?assertEqual(4, uuid:version(U)) || U <- UUIDs].

version_test() ->
  ?assertEqual(1, uuid:version(
                    uuid:uuid(<<"e1a5bc48-b3bf-11ea-a9c7-503eaa1231c5">>))),
  ?assertEqual(3, uuid:version(
                    uuid:uuid(<<"9073926b-929f-31c2-abc9-fad77ae3e8eb">>))),
  ?assertEqual(4, uuid:version(
                    uuid:uuid(<<"eb83ded1-ab17-4349-928a-7d7d2756d2ce">>))),
  ?assertEqual(5, uuid:version(
                    uuid:uuid(<<"cfbff0d1-9375-5685-968c-48ce8b15ae17">>))).

parse_test() ->
  ?assertEqual({ok, <<128,67,215,26,230,84,74,42,173,74,77,96,75,234,90,90>>},
               uuid:parse(<<"8043d71a-e654-4a2a-ad4a-4d604bea5a5a">>)),
  ?assertEqual({ok, <<128,67,215,26,230,84,74,42,173,74,77,96,75,234,90,90>>},
               uuid:parse("8043d71a-e654-4a2a-ad4a-4d604bea5a5a")),
  ?assertEqual({ok, <<128,67,215,26,230,84,74,42,173,74,77,96,75,234,90,90>>},
               uuid:parse("8043D71A-E654-4A2A-AD4A-4D604BEA5A5A")),
  ?assertEqual({error, invalid_format},
               uuid:parse(<<>>)),
  ?assertEqual({error, invalid_format},
               uuid:parse([])),
  ?assertEqual({error, invalid_format},
               uuid:parse(<<"8043d71a-e654-4a2a-ad4a">>)),
  ?assertEqual({error, invalid_format},
               uuid:parse(<<"8043d71ae6544a2aad4a4d604bea5a5a">>)),
  ?assertEqual({error, invalid_format},
               uuid:parse(<<"8043d71a-e654-4a2a-ad4a-4d604bea5a5a-1234">>)),
  ?assertEqual({error, {invalid_hex_digit, $x}},
               uuid:parse(<<"8043d71a-e654-4a2a-ad4a-4d604bea5a5x">>)),
  ?assertEqual({error, {invalid_hex_digit, $X}},
               uuid:parse(<<"8043D71A-E654-4A2A-AD4A-4D604BEA5A5X">>)).

format_test() ->
  ?assertEqual(<<"8043d71a-e654-4a2a-ad4a-4d604bea5a5a">>,
               uuid:format(<<128,67,215,26,230,84,74,42,173,74,77,96,75,234,90,
                             90>>)).
