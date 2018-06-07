defmodule PollutionData do
  def importLinesFromCsv() do
    File.read!("pollution.csv") |> String.split()
  end
  def convertStringToMap(str) do
    [data,godzina,dlugosc,szerokosc,wartosc] = (str |> String.split(","))
    %{:datetime => {dateToTuple(data),timeToTuple(godzina)}, :location => {elem(Float.parse(dlugosc), 0),elem(Float.parse(szerokosc), 0)}, :pollutionLevel => elem(Integer.parse(wartosc),0)}
  end
  def dateToTuple(date) do
    [dzien, miesiac, rok] = (date |> String.split("-"))
    {elem(Integer.parse(rok), 0), elem(Integer.parse(miesiac), 0), elem(Integer.parse(dzien), 0)}
  end
  def timeToTuple(time) do
    [godzina, minuta] = (time |> String.split(":"))
    {elem(Integer.parse(godzina), 0), elem(Integer.parse(minuta), 0)}
  end
  def linesToList(lines) do
    for line <- lines do convertStringToMap(line) end
  end
  def getData() do
    linesToList(importLinesFromCsv())
  end
  def identifyStation() do
    results = getData()
    Enum.uniq_by(results, fn a -> a[:location] end)
  end
  def addManyStations(stations) do
    Enum.reduce(stations, 0, fn curr, :pollution_server_gen.addStation("Station #{acc}", curr[:location]), acc -> acc+1 end)

  end
end
