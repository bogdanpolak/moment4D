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
    procedure FromUnitsYear2016_04_22;
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

procedure TDateTimeCreate.FromUnitsYear2016_04_22;
var
  s: string;
begin
  s := FormatDateTime('yyyy-mm-dd',TMoment.fromArray([2016, 04, 22]).asDelphiDT);
  Assert.AreEqual('2016-04-22', s);
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
