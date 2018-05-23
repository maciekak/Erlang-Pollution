%%%-------------------------------------------------------------------
%%% @author Maciek
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 25. Apr 2018 21:27
%%%-------------------------------------------------------------------
-module(pollution_server).
-author("Maciek").

-export([init/0, start/0, stop/0, addStation/2, addValue/4, removeValue/3,
  getOneValue/3, getStationMean/2, getAreaMean/3, crash/0, start_link/0]).


start() ->
  register (pollutionServer, spawn(pollution_server, init, [])).

start_link() ->
  register (pollutionServer, spawn_link(pollution_server, init, [])).


init() ->
  process_flag(trap_exit, true),
  Monitor = pollution:createMonitor(),
  loop(Monitor).

loop(Monitor) ->
  receive
    {request, Pid, Function, Arguments} when Function == getOneValue
        orelse Function == getStationMean
        orelse Function == getAreaMean ->
      Args = lists:append(Arguments, [Monitor]),
      P = apply(pollution, Function, Args),
      io:format(P),
      case P of
        {error, Message} -> Pid!{reply, {error, Message}};
        _                -> Pid!{reply, P}
      end,
      loop(Monitor);

    {request, Pid, crash, _} ->
      pollution:crash(),
      Pid !  {reply, ok};

    {request, Pid, stop, _} ->
      Pid!{reply, ok};

    {request, Pid, Function, Arguments} when Function == createMonitor
      orelse Function == addStation
      orelse Function == addValue
      orelse Function == removeValue ->

      Args = lists:append(Arguments, [Monitor]),
      M = apply(pollution, Function, Args),
      case M of
        {error, Message} ->
          Pid!{reply,{error,Message}},
          loop(Monitor);
        _ ->
          Pid!{reply, ok},
          loop(M)
      end
  end.


call(Function, Arguments) ->
  erlang:display(Function),
  pollutionServer ! {request, self(), Function, Arguments},
  receive
    {reply, Reply} ->
      case Reply of
        {error, Message} -> Message;
        _                -> Reply
      end;
    {'EXIT', _, _} ->
      io:format("Here")
  after 1000 -> error
  end.

addStation(Name, {Width, Height}) -> call(addStation,[Name,{Width, Height}]).
addValue(Station, Datetime, Type, Value) -> call(addValue, [Station, Datetime, Type, Value]).
removeValue(Station, Datetime, Type) -> call(removeValue, [Station, Datetime, Type]).
getOneValue(Station, Datetime, Type) -> call(getOneValue,[Station, Datetime, Type]).
getStationMean(Station, Type) -> call(getStationMean, [Station, Type]).
getAreaMean(Station, Radius, Type) -> call(getAreaMean, [Station, Radius, Type]).
crash() -> call(crash, []).
stop() -> call(stop,[]).