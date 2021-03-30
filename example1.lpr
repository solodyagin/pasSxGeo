program example1;

{$mode objfpc}{$H+}
{$APPTYPE CONSOLE}

uses
 {$IFDEF UNIX}
  {$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}
 {$ENDIF}
 {$IFDEF WINDOWS}
  Windows,
 {$ENDIF}
  Classes, SysUtils, DateUtils, usxgeo;

var
  //cp: LongWord;
  sxgeo: TSxGeo;
  ip: String;
  //blocklist: TStringList;
  //i: Integer;
begin
  //{$IFDEF WINDOWS}
  //  cp := GetConsoleOutputCP;
  //  SetConsoleOutputCP(CP_UTF8);
  //{$ENDIF}

  ip := '31.193.1.105';

  sxgeo := TSxGeo.Create;
  try
    if sxgeo.Open('SxGeo.dat') then
    begin
      //WriteLn('Время создания: ', DateTimeToStr(UnixToDateTime(sxgeo.Time)));
      WriteLn(ip, '=', sxgeo.GetCountry(ip));
      //blocklist := TStringList.Create;
      //try
      //  blocklist.LoadFromFile('blocklist.txt');
      //  for i := 0 to blocklist.Count - 1 do
      //  begin
      //    ip := blocklist[i];
      //    WriteLn(ip, '=', sxgeo.GetCountry(ip));
      //  end;
      //finally
      //  blocklist.Free;
      //end;
    end;
  finally
    sxgeo.Free;
  end;

  //ReadLn;

  //{$IFDEF WINDOWS}
  //  SetConsoleOutputCP(cp);
  //{$ENDIF}
end.
