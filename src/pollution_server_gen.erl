%%%-------------------------------------------------------------------
%%% @author Maciek
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 26. Apr 2018 13:49
%%%-------------------------------------------------------------------
-module(pollution_server_gen).
-author("Maciek").

-behaviour(gen_server).

-export([start_link/1, init/1, handle_call/3]).

%% gen_server callbacks
-export([addStation/2
  ,addValue/4
  ,removeValue/3
  ,getOneValue/3
  ,getStationMean/2
  ,getAreaMean/3
  ,terminate/0]).


start_link(InitValue) ->
  gen_server:start_link(
    {local,pollution_server_gen}
    ,pollution_server_gen
    ,InitValue,[]).

init(_) ->
  M = pollution:createMonitor(),
  {ok, M}.

addStation(Name, {Height, Width}) ->
  gen_server:call(pollution_server_gen,{addStation, {Name, {Height, Width}}}).

addValue(Station, Datetime, Type, Value) ->
  gen_server:call(pollution_server_gen,{addValue, {Station, Datetime, Type, Value}}).

removeValue(Station, Datetime, Type) ->
  gen_server:call(pollution_server_gen,{removeValue, {Station, Datetime, Type}}).

getOneValue(Station, Datetime, Type)->
  gen_server:call(pollution_server_gen, {getOneValue, {Station, Datetime, Type}}).

getStationMean(Station, Type) ->
  gen_server:call(pollution_server_gen, {getStationMean, {Station, Type}}).

getAreaMean(Station, Radius, Type) ->
  gen_server:call(pollution_server_gen, {getAreaMean, {Station, Radius, Type}}).


handle_call({addStation, Args},_From,LoopData) ->
  {Name, Coordinates} = Args,
  Res = pollution:addStation(Name,Coordinates,LoopData),
  case Res of
    {error, _} -> {reply, Res, LoopData};
    _                -> {reply, ok, Res}
  end;

handle_call({addValue, Args},_From,LoopData) ->
  {Station, Datetime, Type, Value} = Args,
  Res = pollution:addValue(Station, Datetime, Type, Value,LoopData),
  case Res of
    {error, _} -> {reply, Res, LoopData};
    _                -> {reply, ok, Res}
  end;

handle_call({removeValue, Args},_From,LoopData) ->
  {Station, Datetime, Type} = Args,
  Res = pollution:removeValue(Station, Datetime, Type, LoopData),
  case Res of
    {error, _} -> {reply, Res, LoopData};
    _                -> {reply, ok, Res}
  end;

handle_call({getOneValue, Args},_From,LoopData) ->
  {Station, Datetime, Type} = Args,
  Res = pollution:getOneValue(Station, Datetime, Type, LoopData),
  {reply, Res, LoopData};


handle_call({getStationMean, Args},_From,LoopData) ->
  {Station, Type} = Args,
  Res = pollution:getStationMean(Station, Type, LoopData),
  {reply, Res, LoopData};

handle_call({getAreaMean, Args},_From,LoopData) ->
  {Station, Radius, Type} = Args,
  Res = pollution:getAreaMean(Station, Radius, Type),
  {reply, Res, LoopData}.

terminate() -> gen_server:stop(pollution_server_gen).