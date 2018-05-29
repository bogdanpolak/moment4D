unit Moment4D.WithDuration;

interface

uses Moment4D.Main;

type
  TOperationWithDuration = class(TInterfacedObject, IWithDuration)
  private
    FDateTime: IDateTime;
  public
    constructor Create(dt: IDateTime);
    function days (num: integer): IDateTime;
    function minutes (num: integer): IDateTime;
  end;

implementation

uses
  System.DateUtils;


{ TOperationWithDuration }

constructor TOperationWithDuration.Create(dt: IDateTime);
begin
  FDateTime := dt.clone();
end;

function TOperationWithDuration.days(num: integer): IDateTime;
begin
  FDateTime.delphiDT( IncDay(FDateTime.asDelphiDT,num) );
  Result := FDateTime;
end;

function TOperationWithDuration.minutes(num: integer): IDateTime;
begin
  Result := FDateTime;
end;

end.
