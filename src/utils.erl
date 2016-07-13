-module(utils).
-export([normalize/1, parse_args/1, flat/1]).

-spec normalize(string()) -> string().
normalize(Str)->
    normalizeStrWith(80, ".", Str).

-spec normalizeStrWith(non_neg_integer(), string(), string()) -> string().
normalizeStrWith(Length, Fill, Str) when length(Str) > Length ->
    Mid = Length div 2,
    A = lists:sublist(Str, Mid - 2),
    B = lists:sublist(lists:reverse(Str), Mid - 2),
    normalizeStrWith(Mid, Fill, A) ++ lists:reverse(normalizeStrWith(Mid, Fill, B));
normalizeStrWith(Length, _Fill, Str) ->
    Str ++ lists:flatten(lists:duplicate(Length - length(Str),["."])).

-spec parse_args(string()) -> list().
-spec parse_args(string(), list()) -> list().
parse_args(Args) when length(Args) rem 2 == 0 ->
    parse_args(Args, dict:new());
parse_args(_) ->
    erlang:error("Arguments count are odd.").
parse_args([], Acc) -> Acc;
parse_args([["-" | Key], Val | Tail], Acc)->
    parse_args(Tail, dict:append(Key, Val, Acc)).

-spec flat([string()]) ->string().
flat(List)->
    lists:flatten(lists:join(" ", List)).
