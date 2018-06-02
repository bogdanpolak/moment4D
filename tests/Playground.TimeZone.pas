unit Playground.TimeZone;

interface

uses
  DUnitX.TestFramework;

type

  [TestFixture]
  TPlayground = class(TObject)
  private
  public
    { *
      * źródło: https://pl.wikipedia.org/wiki/Czas_letni
      *
      * 1917	16 kwietnia	17 września
      * 1918	15 kwietnia	16 września
      * 1949	10 kwietnia	2 października
      * 1957	2 czerwca	29 września
      * 1958	30 marca	28 września
      * 1964	31 maja	27 września
      * 1980	6 kwietnia	28 września
      * 1990	25 marca	30 września
      * 1996	31 marca	27 października
      * 2010	28 marca	31 października
      *
      * Godziny:
      * 1947	2:00 → 3:00
      * 1948–1949	2:00 → 3:00
      * 1957–1964	1:00 → 2:00
      * 1977–1987	1:00 → 2:00
      * 1988–2021	2:00 → 3:00
      * }
    [Test]
    [TestCase('Test 1949', '1949,1949-04-10 03:00')]
    // 1950 - 1956 - nie było zmiany czasu
    [TestCase('Test 1955', '1955,-')]
    { TODO: przypadek testowy dla roku 1957 nie działa a powinien }
    // [TestCase('Test 1957','1957,1957-06-02 02:00')]
    [TestCase('Test 1958', '1958,1958-03-30 02:00')]
    [TestCase('Test 1964', '1964,1964-05-31 02:00')]
    // 1965 - 1976 -  nie było zmiany czasu
    [TestCase('Test 1980', '1980,1980-04-06 03:00')]
    [TestCase('Test 1990', '1990,1990-03-25 03:00')]
    [TestCase('Test 1996', '1996,1996-03-31 03:00')]
    [TestCase('Test 2000', '2000,2000-03-26 03:00')]
    [TestCase('Test 2010', '2010,2010-03-28 03:00')]
    procedure DaylightStart_TZDB(AYear: word; sExpectedDate: string);
    [Test]
    [TestCase('Test 1949', '1949,1949-03-27 02:00')]
    [TestCase('Test 1955', '1955,1955-03-27 02:00')]
    [TestCase('Test 1957', '1957,1957-03-31 02:00')]
    [TestCase('Test 1958', '1958,1958-03-30 02:00')]
    [TestCase('Test 1964', '1964,1964-03-29 02:00')]
    [TestCase('Test 1980', '1980,1980-03-30 02:00')]
    [TestCase('Test 1990', '1990,1990-03-25 02:00')]
    [TestCase('Test 1996', '1996,1996-03-31 02:00')]
    [TestCase('Test 2000', '2000,2000-03-26 02:00')]
    [TestCase('Test 2010', '2010,2010-03-28 02:00')]
    [TestCase('Test 2017', '2017,2017-03-26 02:00')]
    procedure DaylightStart_Win(AYear: word; sExpectedDate: string);
    [Test]
    [TestCase('1990', '1990,03,25,02')]
    [TestCase('2010', '2010,03,28,02')]
    [TestCase('2017', '2017,03,26,02')]
    procedure TestDaylightAddHour(year, month, day, hour: word);
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
  sStandardName: String;
  sDaylightName: String;
begin
  ZoneInfo.StandardDate.wYear := 1900;
  sStandardDate := FormatDateTime('dd mmm  hh:nn',
    SystemTimeToDateTime(ZoneInfo.StandardDate));
  sStandardName := ZoneInfo.StandardName;
  sDaylightName := ZoneInfo.DaylightName;
  Result := s.add('Bias: %d', [ZoneInfo.Bias]) // ---
    .add('StandardName:' + sStandardName) // ---
    .add('StandardDate: %s', [sStandardDate]) // ---
    .add('StandardBias: %d', [ZoneInfo.StandardBias]) // ---
    .add('DaylightName: ' + sDaylightName) // ---
    .add('DaylightBias: %d', [ZoneInfo.DaylightBias]); // --
  ZoneInfo.StandardDate.wYear := 0;
end;

procedure TPlayground.GetTimeZoneInformation_Win;
var
  ZoneInfo: TTimeZoneInformation;
  sInfo: string;
  sExpected: string;
begin
  GetTimeZoneInformation(ZoneInfo);
  sInfo := TimeZoneInfoToString(ZoneInfo);
  sExpected := 'Bias: -60; StandardName:Europa Środkowa (czas stand.); ' +
    'StandardDate: 05 paź  03:00; StandardBias: 0;' +
    ' DaylightName: Europa Środkowa (czas letni); DaylightBias: -60';
  Assert.AreEqual(sExpected, sInfo);
end;

procedure TPlayground.KnownTimeZones;
var
  timeZoneInfo: TArray<string>;
begin
  timeZoneInfo := TBundledTimeZone.KnownTimeZones();
  Assert.AreEqual(387, Length(timeZoneInfo), 'Rozmiar timeZoneInfo');
  Assert.AreEqual('Africa/Abidjan', timeZoneInfo[0], 'timeZoneInfo[0]');
  Assert.AreEqual('America/Menominee', timeZoneInfo[100], 'timeZoneInfo[110]');
  Assert.AreEqual('Europe/Warsaw', timeZoneInfo[334], 'timeZoneInfo[110]');
end;

procedure TPlayground.DaylightDuration2017_TZDB;
var
  AYear: Integer;
  tz: TBundledTimeZone;
  sDuration: string;
begin
  AYear := 2017;
  tz := TBundledTimeZone.Create('Europe/Warsaw');
  sDuration := FormatDateTime('yyyy-mm-dd', tz.DaylightTimeStart(AYear)) +
    ' .. ' + FormatDateTime('yyyy-mm-dd', tz.DaylightTimeEnd(AYear));
  Assert.AreEqual('2017-03-26 .. 2017-10-29', sDuration);
end;

procedure TPlayground.DaylightDuration2017_Win;
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
  Assert.AreEqual('2017-03-26 .. 2017-10-29', sDuration);
end;

procedure TPlayground.DaylightEnd2017;
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
  Assert.AreEqual(6, h, 'Godzin pomiędzy');
end;

procedure TPlayground.DaylightStart_TZDB(AYear: word; sExpectedDate: string);
var
  tz: TBundledTimeZone;
  dt: TDateTime;
begin
  tz := TBundledTimeZone.Create('Europe/Warsaw');
  dt := tz.DaylightTimeStart(AYear);
  if dt = 0 then
  begin
    if sExpectedDate = '-' then
      Assert.Pass()
    else
      Assert.Fail('Nie ma danych o zmianie czasu');
  end;
  Assert.AreEqual(sExpectedDate, FormatDateTime('yyyy-mm-dd hh:nn', dt));
end;

procedure TPlayground.DaylightStart_Win(AYear: word; sExpectedDate: string);
var
  LTZ: TIME_ZONE_INFORMATION;
  dt: TDateTime;
  tz: TBundledTimeZone;
begin
  GetTimeZoneInformationForYear(AYear, nil, LTZ);
  dt := GetDateFromDaylightRule(AYear, LTZ.DaylightDate);
  if dt = 0 then
    Assert.Fail('Nie ma danych o zmianie czasu');
  Assert.AreEqual(sExpectedDate, FormatDateTime('yyyy-mm-dd hh:nn', dt));
end;

procedure TPlayground.TestDaylightAddHour(year, month, day, hour: word);
var
  tz: TTimeZone;
  dt1: TDateTime;
  dt2: TDateTime;
  s1: string;
  s2: string;
begin
  tz := TTimeZone.Local;
  dt1 := EncodeDateTime(year, month, day, hour-1, 0, 0, 0);
  dt2 := EncodeDateTime(year, month, day, hour+1, 0, 0, 0);
  s1 := tz.GetAbbreviation(dt1)+' '+tz.GetAbbreviation(dt2);
  Assert.AreEqual('GMT+01 GMT+02', s1);
  s1 := DateToISO8601(dt1,false);
  s2 := DateToISO8601(dt2,false);
  Assert.AreEqual(Format('%d-%.2d-%.2dT%.2d:00:00.000+01:00',
    [year,month,day,hour-1]), s1);
  Assert.AreEqual(Format('%d-%.2d-%.2dT%.2d:00:00.000+02:00',
    [year,month,day,hour+1]), s2);
end;

procedure TPlayground.Time_AmericaNewYork;
var
  tz: TBundledTimeZone;
  s: string;
begin
  tz := TBundledTimeZone.Create('America/New_York');
  s := tz.ToISO8601Str(EncodeDate(2018, 01, 01) + EncodeTime(21, 0, 0, 0));
  Assert.AreEqual('2018-01-01 16:00:00.0-05:00', s);
end;

procedure TPlayground.Time_EuropeParis;
var
  tz: TBundledTimeZone;
  s: string;
begin
  tz := TBundledTimeZone.Create('Europe/Paris');
  s := tz.ToISO8601Str(EncodeDate(2018, 01, 01) + EncodeTime(21, 0, 0, 0));
  Assert.AreEqual('2018-01-01 22:00:00.0+01:00', s);
end;

initialization

TDUnitX.RegisterTestFixture(TPlayground);

end.
