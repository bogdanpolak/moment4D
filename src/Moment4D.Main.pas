unit Moment4D.Main;

interface

type
  IDTDurationOperation = interface;
  IDateTime = interface;

  TMoment = class
    class function fromDelphiDT (dt: TDateTime): IDateTime;
  end;

  IDateTime = interface
    function add: IDTDurationOperation;
    function asDelphiDT: TDateTime;
  end;

  IDTDurationOperation = interface
    function days (num: integer): IDateTime;
    function minutes (num: integer): IDateTime;
  end;

implementation

uses Moment4D.DateTime;

{ TMoment }

class function TMoment.fromDelphiDT(dt: TDateTime): IDateTime;
begin
  Result := Moment4D.DateTime.TMomentDateTime.CreateFromDelphi(dt);
end;

end.
