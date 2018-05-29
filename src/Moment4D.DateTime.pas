unit Moment4D.DateTime;

interface

uses Moment4D.Main;

type
  TMomentDateTime = class (TInterfacedObject, IDateTime)
    FDelphiDT: TDateTime;
    function add: IWithDuration;
    procedure delphiDT (dt: TDateTime);
    function asDelphiDT: TDateTime;
    function clone: IDateTime;
    constructor CreateFromDelphi(dt: TDateTime);
  end;

implementation

{ TMomentDateTime }

uses Moment4D.WithDuration;

function TMomentDateTime.add: IWithDuration;
begin
  Result := TOperationWithDuration.Create(self);
end;

function TMomentDateTime.asDelphiDT: TDateTime;
begin
  Result := FDelphiDT;
end;

function TMomentDateTime.clone: IDateTime;
var
  dt2: TMomentDateTime;
begin
  dt2 := TMomentDateTime.Create();
  dt2.FDelphiDT := FDelphiDT;
  Result := dt2;
end;

constructor TMomentDateTime.CreateFromDelphi(dt: TDateTime);
begin
  FDelphiDT := dt;
end;

procedure TMomentDateTime.delphiDT(dt: TDateTime);
begin
  FDelphiDT := dt;
end;

end.
