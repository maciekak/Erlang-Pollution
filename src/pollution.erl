%%%-------------------------------------------------------------------
%%% @author Maciek
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. Apr 2018 1:19
%%%-------------------------------------------------------------------
-module(pollution).
-author("Maciek").

%% API
-export([createMonitor/0, addStation/3, addValue/5, removeValue/4,
  getOneValue/4, getStationMean/3, getAreaMean/4]).

-record(station, {name, place}).
-record(measurement, {datetime, type, value}).


createMonitor() -> dict:new().

getKey(Station,Monitor) when is_tuple(Station) ->
  Keys = dict:fetch_keys(Monitor),
  Key = [S || S <- Keys, S#station.place == Station],
  case Key of
    [] -> not_found;
    _ -> [K] = Key,
      K
  end;
getKey(Station,Monitor)->
  Keys = dict:fetch_keys(Monitor),
  Key = [S || S <- Keys, string:equal(S#station.name, Station)],
  case Key of
    [] -> not_found;
    _ -> [K] = Key,
      K
  end.

getKeysInRadius(Station, Radius, Monitor) ->
  Keys = dict:fetch_keys(Monitor),
  CenterStation = getKey(Station, Monitor),
  {Xc, Yc} = CenterStation#station.place,
  lists:filter(fun (Elem) -> {X, Y} = Elem#station.place, ((X-Xc)*(X-Xc)+(Y-Yc)*(Y-Yc)-Radius*Radius) =< 0 end, Keys).

addStation(Name, {XCord, YCord}, Monitor) ->
  K1 = getKey(Name, Monitor),
  case K1 of
    not_found ->
      K2 = getKey({XCord, YCord}, Monitor),
      case K2 of
        not_found -> dict:append_list(#station{name=Name, place={XCord, YCord}},[],Monitor);
        _ -> {error, "There is already station with that cordinates."}
      end;
    _ -> {error, "There is already station with that name."}
  end.

addValue(Station, Datetime, Type, Value, Monitor) ->
  K  = getKey(Station,Monitor),
  case K of
    not_found -> {error, "Station you've choose doesnt exist."};
    _         ->
      Measurements = dict:fetch(K, Monitor),
      Eq = fun (M) -> (M#measurement.datetime == Datetime) and string:equal(M#measurement.type, Type) end,
      case lists:any(Eq, Measurements) of
        false -> dict:append(K,#measurement{datetime=Datetime, type=Type, value=Value},Monitor);
        true  -> {error, "Measurment has already exists"}
      end
  end.

removeValue(Station, Datetime, Type, Monitor) ->
  Key = getKey(Station,Monitor),
  case Key of
    not_found -> {error, "Station you've choose doesnt exist."};
    _         ->
      Measurements = dict:fetch(Key, Monitor),
      Eq = fun (M) -> (M#measurement.datetime == Datetime) and string:equal(M#measurement.type, Type) end,
      case lists:any(Eq,Measurements) of
        false -> {error, "Not found passed measurment"};
        true  -> dict:update(Key, fun (M) -> [ X || X <- M, Eq(M) == false]end, Monitor)
      end
  end.

getOneValue(Station, Datetime, Type, Monitor)->
  Key = getKey(Station, Monitor),
  case Key of
    not_found -> {error, "Station you've choose doesnt exist."};
    _        ->
      Val = [V || V <- dict:fetch(Key,Monitor),
        (V#measurement.datetime == Datetime) and string:equal(V#measurement.type, Type) ],
      case Val of
        [] -> {error, "Measurement you've choose do not exists"};
        _  -> [V] = Val,
          V#measurement.value
      end
  end.


avg(Measurement,{Sum, Num}) ->
  lists:foldl(fun (M,{S,N}) -> {S + M#measurement.value, N+1} end, {Sum,Num}, Measurement).

getStationMean(Station, Type, Monitor) ->
  Key = getKey(Station, Monitor),
  case Key of
    not_found -> {error, "Station you've choose doesnt exist."};
    _      ->
      Measurements = [V || V <- dict:fetch(Key,Monitor), V#measurement.type == Type],
      {Sum, Num} = avg(Measurements,{0,0}),
      case Num of
        0 -> {error, "There are no measurements from choosen station"};
        _ -> Sum / Num
      end
  end.


getAreaMean(Station, Radius, Type, Monitor) ->
  Keys = getKeysInRadius(Station, Radius, Monitor),
  case Keys of
    [] -> {error, "Not found station."};
    _  ->
      Measurements = [V || K <- Keys, V <- dict:fetch(K, Monitor), V#measurement.type == Type],
      {Sum, Num} = avg(Measurements,{0,0}),
      case Num of
      0 -> {error, "There are no measurements on choosen radius"};
      _ -> Sum / Num
      end
  end.