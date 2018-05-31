unit Playground.TimeZone;

interface

uses
  DUnitX.TestFramework;

type

  [TestFixture]
  TTZDB = class(TObject)
  public
    [Test]
    [TestCase('Test 1949','1949,1949-04-10 03:00')]
    // 1950 - 1956 - nie by³o zmiany czasu
    [TestCase('Test 1957','1957,1957-06-02 02:00')]
    [TestCase('Test 1958','1958,1958-03-30 02:00')]
    [TestCase('Test 1964','1964,1964-05-31 02:00')]
    [TestCase('Test 1980','1980,1980-04-06 03:00')]
    [TestCase('Test 1990','1990,1990-03-25 03:00')]
    [TestCase('Test 1996','1996,1996-03-31 03:00')]
    [TestCase('Test 2000','2000,2000-03-26 03:00')]
    [TestCase('Test 2010','2010,2010-03-28 03:00')]
    procedure DaylightStart (AYear:word; sExpectedDate: string);
  published
    procedure GetTimeZoneInformation_Win;
    procedure KnownTimeZones;
    procedure Time_EuropeParis;
    procedure Time_AmericaNewYork;
    procedure DaylightEnd2017;
    procedure DaylightDuration2017_TZDB;
    procedure DaylightDuration2017_Win;
  end;

implementation

uses Winapi.Windows, System.SysUtils, System.DateUtils, System.Types,
  System.Classes, TZDB, Utils.Time;

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

procedure TTZDB.GetTimeZoneInformation_Win;
var
  ZoneInfo: TTimeZoneInformation;
  sInfo: string;
  sExpected: string;
begin
  GetTimeZoneInformation(ZoneInfo);
  sInfo := TimeZoneInfoToString(ZoneInfo);
  sExpected := 'Bias: -60; StandardName:Europa Œrodkowa (czas stand.); ' +
    'StandardDate: 05 paŸ  03:00; StandardBias: 0;' +
    ' DaylightName: Europa Œrodkowa (czas letni); DaylightBias: -60';
  Assert.AreEqual(sExpected, sInfo);
end;

procedure TTZDB.KnownTimeZones;
var
  timeZoneInfo: TArray<string>;
begin
  timeZoneInfo := TBundledTimeZone.KnownTimeZones();
  Assert.AreEqual(387, Length(timeZoneInfo), 'Rozmiar timeZoneInfo');
  Assert.AreEqual('Africa/Abidjan', timeZoneInfo[0], 'timeZoneInfo[0]');
  Assert.AreEqual('America/Menominee', timeZoneInfo[100], 'timeZoneInfo[110]');
  Assert.AreEqual('Europe/Warsaw', timeZoneInfo[334], 'timeZoneInfo[110]');
end;

procedure TTZDB.DaylightDuration2017_TZDB;
var
  AYear: Integer;
  tz: TBundledTimeZone;
  sDuration: string;
begin
  AYear := 2017;
  tz := TBundledTimeZone.Create('Europe/Warsaw');
  sDuration := FormatDateTime('yyyy-mm-dd', tz.DaylightTimeStart(AYear)) + ' .. '
    + FormatDateTime('yyyy-mm-dd', tz.DaylightTimeEnd(AYear));
  Assert.AreEqual('2017-03-26 .. 2017-10-29', sDuration);
end;

procedure TTZDB.DaylightDuration2017_Win;
var
  AYear: Integer;
  LTZ: TIME_ZONE_INFORMATION;
  dt1: TDateTime;
  dt2: TDateTime;
  sDuration: string;
begin
  AYear := 2017;
  GetTimeZoneInformationForYear(AYear, nil, LTZ);
  dt1 := GetDateFromDaylightRule(AYear, LTZ.DaylightDate);
  dt2 := GetDateFromDaylightRule(AYear, LTZ.StandardDate);
  sDuration := FormatDateTime('yyyy-mm-dd', dt1) + ' .. ' +
    FormatDateTime('yyyy-mm-dd', dt2);
  Assert.AreEqual( '2017-03-26 .. 2017-10-29', sDuration);
end;

procedure TTZDB.DaylightEnd2017;
var
  tz: TBundledTimeZone;
  dt1: TDateTime;
  dt2: TDateTime;
  h: Integer;
begin
  tz := TBundledTimeZone.Create('Europe/Warsaw');
  dt1 := tz.ToUniversalTime(EncodeDate(2017, 10, 29) + EncodeTime(0, 0, 0, 0));
  dt2 := tz.ToUniversalTime(EncodeDate(2017, 10, 29) + EncodeTime(5, 0, 0, 0));
  h := hoursBetween(dt1, dt2);
  Assert.AreEqual(6, h, 'Godzin pomiêdzy');
end;

procedure TTZDB.DaylightStart (AYear:word; sExpectedDate: string);
var
  LTZ: TIME_ZONE_INFORMATION;
  dt: TDateTime;
  tz: TBundledTimeZone;
begin
  GetTimeZoneInformationForYear(AYear, nil, LTZ);
  dt := GetDateFromDaylightRule(AYear, LTZ.DaylightDate);
  // tz := TBundledTimeZone.Create('Europe/Warsaw');
  // dt := tz.DaylightTimeStart(AYear);
  // ---
  if dt=0 then
    Assert.Fail('Nie ma danych o zmianie czasu');
  Assert.AreEqual( sExpectedDate, FormatDateTime('yyyy-mm-dd hh:nn', dt));
end;

procedure TTZDB.Time_AmericaNewYork;
var
  tz: TBundledTimeZone;
  s: string;
begin
  tz := TBundledTimeZone.Create('America/New_York');
  s := tz.ToISO8601Str(EncodeDate(2018, 01, 01) + EncodeTime(21, 0, 0, 0));
  Assert.AreEqual('2018-01-01 16:00:00.0-05:00', s);
end;

procedure TTZDB.Time_EuropeParis;
var
  tz: TBundledTimeZone;
  s: string;
begin
  tz := TBundledTimeZone.Create('Europe/Paris');
  s := tz.ToISO8601Str(EncodeDate(2018, 01, 01) + EncodeTime(21, 0, 0, 0));
  Assert.AreEqual('2018-01-01 22:00:00.0+01:00', s);
end;

initialization

TDUnitX.RegisterTestFixture(TTZDB);

end.
