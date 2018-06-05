unit Tests.DateTime.Construct;

interface

uses
  DUnitX.TestFramework;

type

  [TestFixture]
  [IgnoreMemoryLeaks(True)]
  TDateTimeCreate = class(TObject)
  private
  public
    [Test]
    procedure FromDelphi;
    [Test]
    procedure FromUnitsYear2016;
    [Test]
    procedure FromUnits2016_04_22;
    [Test]
    procedure FromUnits2016_04_22_T_19_50;
    [Test]
    procedure FromISODate;
    [Test]
    procedure FromISOWeekDays;
    [Test]
    procedure TestAddDays;
  end;

implementation

uses Moment4D.Main, System.SysUtils, System.DateUtils;

procedure TDateTimeCreate.FromDelphi;
var
  dt: Extended;
  mdt: IDateTime;
begin
  dt := Now();
  mdt := TMoment.fromDelphiDT(dt);
  Assert.AreEqual(dt, mdt.asDelphiDT, 0.000000001);
end;

procedure TDateTimeCreate.FromUnitsYear2016;
var
  m: IDateTime;
begin
  m := TMoment.fromArray([2016]);
  Assert.AreEqual('2016', YearOf(m.asDelphiDT).ToString);
end;

procedure TDateTimeCreate.FromUnits2016_04_22;
var
  s: string;
begin
  s := FormatDateTime('yyyy-mm-dd',TMoment.fromArray([2016, 04, 22]).asDelphiDT);
  Assert.AreEqual('2016-04-22', s);
end;

procedure TDateTimeCreate.FromUnits2016_04_22_T_19_50;
var
  dt: TDateTime;
  s: string;
begin
  dt := TMoment.fromArray([2016, 04, 22, 19, 50]).asDelphiDT;
  s := FormatDateTime('yyyy-mm-dd hh:nn',dt);
  Assert.AreEqual('2016-04-22 19:50', s);
end;

procedure TDateTimeCreate.FromISODate;
var
  dt: TDateTime;
  s: string;
begin
  dt := TMoment.fromIsoDate('2016-04-22T19:50:00+05:00').asDelphiDT;
  s := FormatDateTime('yyyy-mm-dd hh:nn',dt);
  // Assert.AreEqual('2016-04-22T00:00:00.000+02:00',s);
  Assert.NotImplemented;
end;

procedure TDateTimeCreate.FromISOWeekDays;
var
  dt: TDateTime;
  s: string;
begin
  dt := TMoment.fromIsoWeekDate('2016-W50-2').asDelphiDT;
  s := FormatDateTime('yyyy-mm-dd',dt);
  // Assert.AreEqual('2016-12-13',s);
  Assert.NotImplemented;
end;

procedure TDateTimeCreate.TestAddDays;
var
  dt: TDateTime;
  mdt1: IDateTime;
  mdt2: IDateTime;
  s: string;
begin
  dt := EncodeDate(2018, 05, 20);
  mdt1 := TMoment.fromDelphiDT(dt);
  mdt2 := mdt1.add.days(5);
  s := DateToISO8601(mdt2.asDelphiDT);
  Assert.AreEqual('2018-05-25T00:00:00.000Z', s);
end;

initialization

TDUnitX.RegisterTestFixture(TDateTimeCreate);

end.
