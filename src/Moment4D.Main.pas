unit Moment4D.Main;

interface

type
  IWithDuration = interface;
  IDateTime = interface;

  TMoment = class
    class function fromDelphiDT(dt: TDateTime): IDateTime;
    class function fromArray (units: array of Word): IDateTime;
    class function fromIsoDate(const s:string): IDateTime;
    class function fromIsoWeekDate (const s:string): IDateTime;
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

uses Moment4D.DateTime, Winapi.Windows, System.SysUtils;

{ TMoment }

class function TMoment.fromArray(units: array of Word): IDateTime;
var
  i: Integer;
  j:Integer;
  units2: array[0..6] of word;
  dt1: TDateTime;
  yy, mm, dd: Word;
  hh, nn, ss, msec: Word;
  dt2: TDateTime;
begin
  i := Length(units);
  for j := 0 to i-1 do
    units2[j] := units[j];
  dt1 := Now();
  DecodeDate(dt1, yy, mm, dd);
  DecodeTime(dt1, hh, nn, ss, msec);
  for j := i to 6 do
    case j of
      0: units2[0] := yy;
      1: units2[1] := mm;
      2: units2[2] := dd;
      3: units2[3] := hh;
      4: units2[4] := nn;
      5: units2[5] := ss;
      6: units2[6] := msec;
      else ;
    end;
  dt2 := EncodeDate(units2[0], units2[1], units2[2])
    + EncodeTime(units2[3], units2[4], units2[5], units2[6]);
  Result := Moment4D.DateTime.TMomentDateTime.CreateFromDelphi(dt2);
end;

class function TMoment.fromDelphiDT(dt: TDateTime): IDateTime;
begin
  Result := Moment4D.DateTime.TMomentDateTime.CreateFromDelphi(dt);
end;

class function TMoment.fromIsoDate(const s: string): IDateTime;
begin
  { TODO : Do zakodowania }
  // Specyfikacja: https://en.wikipedia.org/wiki/ISO_8601
  Result := fromDelphiDT(0);
end;

class function TMoment.fromIsoWeekDate(const s: string): IDateTime;
begin
  { TODO : Do zakodowania }
  // Specyfikacja: https://en.wikipedia.org/wiki/ISO_week_date
  Result := fromDelphiDT(0);
end;


end.
