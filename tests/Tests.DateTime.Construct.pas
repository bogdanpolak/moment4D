unit Tests.DateTime.Construct;

interface
uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TDateTimeCreate = class(TObject)
  public
    [Test]
    procedure FromDelphi;
  end;

implementation

uses Moment4D.Main, System.SysUtils;

procedure TDateTimeCreate.FromDelphi;
var
  dt: Extended;
  mdt: IDateTime;
begin
  dt := Now();
  mdt := TMoment.fromDelphiDT(dt);
  Assert.AreEqual(dt, mdt.asDelphiDT, 0.000000001);
end;

initialization
  TDUnitX.RegisterTestFixture(TDateTimeCreate);
end.
