unit Moment4D.Main;

interface

type
  IWithDuration = interface;
  IDateTime = interface;

  TMoment = class
    class function fromDelphiDT(dt: TDateTime): IDateTime;
  end;

  IDateTime = interface
    function add: IWithDuration;
    procedure delphiDT(dt: TDateTime);
    function asDelphiDT: TDateTime;
    function clone: IDateTime;
  end;

  IWithDuration = interface
    function days(num: integer): IDateTime;
    function minutes(num: integer): IDateTime;
  end;

implementation

uses Moment4D.DateTime,
  Winapi.Windows, System.SysUtils;

{ TMoment }

class function TMoment.fromDelphiDT(dt: TDateTime): IDateTime;
begin
  Result := Moment4D.DateTime.TMomentDateTime.CreateFromDelphi(dt);
end;

end.
