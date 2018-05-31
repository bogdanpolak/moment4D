unit Utils.Time;

interface

uses
  WinApi.Windows;

function GetDateFromDaylightRule(const AYear: Word; st: TSystemTime): TDateTime;

implementation

uses
  System.SysUtils, System.DateUtils;

function GetDateFromDaylightRule(const AYear: Word; st: TSystemTime): TDateTime;
const
  CReDoW: array [0 .. 6] of Integer = (7, 1, 2, 3, 4, 5, 6);
var
  LExpDayOfWeek, LActualDayOfWeek: Word;
  AMonth, ADoW, ADoWIndex: Word;
  AToD: TTime;
begin
  AMonth := st.wMonth;
  ADoW := st.wDayOfWeek;
  ADoWIndex := st.wDay;
  AToD := EncodeTime(st.wHour,st.wMinute,st.wSecond,0);
  { No actual rule }
  if (AMonth = 0) and (ADoW = 0) and (ADoWIndex = 0) then
    Exit(0);
  { Transform into ISO 8601 day of week }
  LExpDayOfWeek := CReDoW[ADoW];
  { Generate a date in the form of: Year/Month/1st of month }
  Result := EncodeDate(AYear, AMonth, 1);
  { Get the day of week for this newly crafted date }
  LActualDayOfWeek := DayOfTheWeek(Result);
  { We're too far off now, let's decrease the number of days till we get to the desired one }
  if LActualDayOfWeek > LExpDayOfWeek then
    Result := IncDay(Result, DaysPerWeek - LActualDayOfWeek + LExpDayOfWeek)
  else if (LActualDayOfWeek < LExpDayOfWeek) Then
    Result := IncDay(Result, LExpDayOfWeek - LActualDayOfWeek);
  { Skip the required number of weeks }
  Result := IncDay(Result, DaysPerWeek * (ADoWIndex - 1));
  { If we've skipped the day in this moth, go back a few weeks until we get it right again }
  while (MonthOf(Result) > AMonth) do
    Result := IncDay(Result, -DaysPerWeek);
  { Add the time part }
  Result := Result + AToD;
end;

end.
