unit Playground.TimeZone;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TTimeZone = class(TObject)
  published
    procedure Test_Win_GetTimeZoneInformation;
    procedure Test_KnownTimeZones;
    procedure Test_EuropeParis;
    procedure Test_AmericaNewYork;
  end;

implementation

uses Winapi.Windows, System.SysUtils, TZDB, System.Types, System.Classes;

{ TStringClassHelper }

type
  TStringClassHelper = record helper for
    String
    function add(s: string): string;
    overload;
    function add(s: string; const Args: array of const): string; overload;
  end;

function TStringClassHelper.add(s: string): string;
begin
  if self = '' then
    Result := s
  else
    Result := self + '; ' + s;
  self := Result;
end;

function TStringClassHelper.add(s: string; const Args: array of const): string;
begin
  if self = '' then
    Result := Format(s, Args)
  else
    Result := self + '; ' + Format(s, Args);
  self := Result;
end;

// ---------------------------------------------

function TimeZoneInfoToString(ZoneInfo: TTimeZoneInformation): string;
var
  s: string;
  sStandardDate: string;
begin
  ZoneInfo.StandardDate.wYear := 1900;
  sStandardDate := FormatDateTime('dd mmm  hh:nn',
    SystemTimeToDateTime(ZoneInfo.StandardDate));
  Result := s.add('Bias: %d', [ZoneInfo.Bias]) // ---
    .add('StandardName:' + ZoneInfo.StandardName) // ---
    .add('StandardDate: %s', [sStandardDate]) // ---
    .add('StandardBias: %d', [ZoneInfo.StandardBias]) // ---
    .add('DaylightName: ' + ZoneInfo.DaylightName) // ---
    .add('DaylightBias: %d', [ZoneInfo.DaylightBias]); // --
  ZoneInfo.StandardDate.wYear := 0;
end;

procedure TTimeZone.Test_Win_GetTimeZoneInformation;
var
  ZoneInfo: TTimeZoneInformation;
  sInfo: string;
  sExpected: string;
begin
  GetTimeZoneInformation(ZoneInfo);
  sInfo := TimeZoneInfoToString(ZoneInfo);
  sExpected := 'Bias: -60; StandardName:Europa årodkowa (czas stand.); ' +
    'StandardDate: 05 paü  03:00; StandardBias: 0;' +
    ' DaylightName: Europa årodkowa (czas letni); DaylightBias: -60';
  Assert.AreEqual(sExpected, sInfo);
end;

procedure TTimeZone.Test_KnownTimeZones;
var
  timeZoneInfo: TArray<string>;
begin
  timeZoneInfo := TBundledTimeZone.KnownTimeZones();
  Assert.AreEqual(387, Length(timeZoneInfo), 'Rozmiar timeZoneInfo');
  Assert.AreEqual('Africa/Abidjan', timeZoneInfo[0], 'timeZoneInfo[0]');
  Assert.AreEqual('America/Menominee', timeZoneInfo[100], 'timeZoneInfo[110]');
  Assert.AreEqual('Europe/Warsaw', timeZoneInfo[334], 'timeZoneInfo[110]');
end;

procedure TTimeZone.Test_AmericaNewYork;
var
  tz: TBundledTimeZone;
  s: string;
begin
  tz := TBundledTimeZone.Create('America/New_York');
  s := tz.ToISO8601Str(EncodeDate(2018, 01, 01) + EncodeTime(21, 0, 0, 0));
  Assert.AreEqual('2018-01-01 16:00:00.0-05:00', s);
end;

procedure TTimeZone.Test_EuropeParis;
var
  tz: TBundledTimeZone;
  s: string;
begin
  tz := TBundledTimeZone.Create('Europe/Paris');
  s := tz.ToISO8601Str(EncodeDate(2018, 01, 01) + EncodeTime(21, 0, 0, 0));
  Assert.AreEqual('2018-01-01 22:00:00.0+01:00', s);
end;

initialization

TDUnitX.RegisterTestFixture(TTimeZone);

end.
