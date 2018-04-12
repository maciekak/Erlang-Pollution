%%%-------------------------------------------------------------------
%%% @author Maciek
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. Apr 2018 9:12
%%%-------------------------------------------------------------------
-module(pollution_tests).
-author("Maciek").

%% API
-export([]).

-include_lib("eunit/include/eunit.hrl").

-import(pollution, [createMonitor/0, addStation/3, addValue/5, getAreaMean/4]).

simple_test() ->
  ?assert(true).

addValue_doublyAddedByName_test() ->
  P = createMonitor(),
  P1 = addStation("Station 1", {10, 10}, P),
  P2 = addValue("Station 1", {2017,5,4}, "PM10", 100.0, P1),
  P3 = addValue("Station 1", {2017,5,4}, "PM10", 100.0, P2),
  {E,_} = P3,
  ?assertEqual(error, E).

addValue_doublyAddedByCoordinates_test() ->
  P = createMonitor(),
  P1 = addStation("Station 1", {10, 10}, P),
  P2 = addValue({10, 10}, {2017,5,4}, "PM10", 100.0, P1),
  P3 = addValue({10, 10}, {2017,5,4}, "PM10", 100.0, P2),
  {E,_} = P3,
  ?assertEqual(error, E).

addValue_doublyAddedByNameAndByCoordinates_test() ->
  P = createMonitor(),
  P1 = addStation("Station 1", {10, 10}, P),
  P2 = addValue("Station 1", {2017,5,4}, "PM10", 100.0, P1),
  P3 = addValue({10, 10}, {2017,5,4}, "PM10", 100.0, P2),
  {E,_} = P3,
  ?assertEqual(error, E).

addValue_measurementsDiffValue_test() ->
  P = createMonitor(),
  P1 = addStation("Station 1", {10, 10}, P),
  P2 = addValue("Station 1", {2017,5,4}, "PM10", 100.0, P1),
  P3 = addValue("Station 1", {2017,5,4}, "PM10", 120.0, P2),
  {E,_} = P3,
  ?assertEqual(error, E).

addValue_notExistingStation_test() ->
  P = createMonitor(),
  P1 = addValue("Station 1", {2017,5,4}, "PM10", 100.0, P),
  {E,_} = P1,
  ?assertEqual(error, E).

getAreaMean_test() ->
  P = createMonitor(),
  P1 = addStation("Station 1", {10, 10}, P),
  P2 = addStation("Station 2", {40, 10}, P1),
  P3 = addValue("Station 1", {2017,5,6}, "PM10", 100.0, P2),
  P4 = addValue("Station 1", {2017,5,4}, "PM10", 120.0, P3),
  P5 = addValue("Station 2", {2017,5,6}, "PM10", 180.0, P4),
  P6 = addValue("Station 2", {2017,5,4}, "PM10", 200.0, P5),
  ?assertEqual(110.0, pollution:getAreaMean("Station 1", 10, "PM10", P6)).

getAreaMean_longRadius_test() ->
  P = createMonitor(),
  P1 = addStation("Station 1", {10, 10}, P),
  P2 = addStation("Station 2", {40, 10}, P1),
  P3 = addValue("Station 1", {2017,5,6}, "PM10", 100.0, P2),
  P4 = addValue("Station 1", {2017,5,4}, "PM10", 120.0, P3),
  P5 = addValue("Station 2", {2017,5,6}, "PM10", 180.0, P4),
  P6 = addValue("Station 2", {2017,5,4}, "PM10", 200.0, P5),
  ?assertEqual(150.0, pollution:getAreaMean("Station 1", 4000, "PM10", P6)).

