unit Test.Utils.MemoryLeaks;

interface
uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TMemory = class(TObject)
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure TestMemoryLeaks;
  end;

implementation

uses
  System.Classes;

procedure TMemory.Setup;
begin
end;

procedure TMemory.TearDown;
begin
end;

procedure TMemory.TestMemoryLeaks;
begin
  TStringList.Create;
  AllocMem( 1024 );
  Assert.Pass();
end;

initialization
  TDUnitX.RegisterTestFixture(TMemory);
end.
