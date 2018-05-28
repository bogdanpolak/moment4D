unit Moment4D.DateTime;

interface

uses Moment4D.Main;

type
  TMomentDateTime = class (TInterfacedObject, IDateTime)
    DelphiDT: TDateTime;
    function add: IDTDurationOperation;
    function asDelphiDT: TDateTime;
    constructor CreateFromDelphi(dt: TDateTime);
  end;

implementation

{ TMomentDateTime }

function TMomentDateTime.add: IDTDurationOperation;
begin
  Result := nil;
end;

function TMomentDateTime.asDelphiDT: TDateTime;
begin
  Result := DelphiDT;
end;

constructor TMomentDateTime.CreateFromDelphi(dt: TDateTime);
begin
  DelphiDT := dt;
end;

end.
