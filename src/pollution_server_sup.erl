%%%-------------------------------------------------------------------
%%% @author Maciek
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 26. Apr 2018 13:12
%%%-------------------------------------------------------------------
-module(pollution_server_sup).
-author("Maciek").

%% API
-export([crash/0, start/0, some/0]).

start() ->
  pollution_server:start_link(),
  process_flag(trap_exit, true).

crash() ->
  pollution_server:crash(),
  receive
    { reply, A} -> erlang:display(A)
  end.

some() ->
  pollution_server:addStation(a, {10,20}).

