%%%-------------------------------------------------------------------
%%% @author Maciek
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 07. Jun 2018 11:39
%%%-------------------------------------------------------------------
-module(pollution_server_otp_sup).
-author("Maciek").

-behaviour(supervisor).

%% API
-export([start_link/1]).

%% Supervisor callbacks
-export([init/1]).

start_link(InitialValue) ->
  supervisor:start_link({local, pollution_server_suppervisor}, ?MODULE, InitialValue).

init(InitialValue) ->
  {ok, {
    {one_for_all, 2, 2000},
    [ {pollution_server_gen,
      {pollution_server_gen, start_link, [dict:new()]},
      permanent,
      brutal_kill,
      worker,
      [pollution_server_gen]}]
  }}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
