unit PingThread;

interface

uses Windows, Classes, PingSend, IPUtils, SysUtils, WinSock;

type
     PPingResult = ^TPingResult;
     TPingResult = Record
                     IPAdress:String;
                     MacAdress:String;
                     Exists:Boolean;
                   end;


type
  TPingThread = class(TThread)
  private
    { Private declarations }
  protected
    procedure Execute; override;
  public
    PingResult:TPingResult;
    Ready:Boolean;
    constructor Create(Ping:TPingResult);
  end;

function SendARP(DestIp: DWORD; srcIP: DWORD; pMacAddr: pointer; PhyAddrLen: Pointer): DWORD;stdcall; external 'iphlpapi.dll';

implementation

function MySendARP(const IPAddress: String): String;
var
  DestIP: ULONG;
  MacAddr: Array [0..5] of Byte;
  MacAddrLen: ULONG;
  SendArpResult: Cardinal;
begin
  DestIP := inet_addr(PAnsiChar(AnsiString(IPAddress)));
  MacAddrLen := Length(MacAddr);
  SendArpResult := SendARP(DestIP, 0, @MacAddr, @MacAddrLen);

  if SendArpResult = NO_ERROR then
    Result := Format('%2.2X:%2.2X:%2.2X:%2.2X:%2.2X:%2.2X',
                     [MacAddr[0], MacAddr[1], MacAddr[2],
                      MacAddr[3], MacAddr[4], MacAddr[5]])
  else
    Result := '';
end;

{ TPingThread }

constructor TPingThread.Create(Ping:TPingResult);
begin
  PingResult.IPAdress := Ping.IPAdress;
  inherited Create(False);
end;

procedure TPingThread.Execute;
var Ping:TPingSend;
begin
  Ready := False;
  Ping  := TPingSend.Create;
  Ping.Timeout := 500;
  PingResult.Exists := Ping.Ping(PingResult.IPAdress);
  if PingResult.Exists then
    PingResult.MacAdress := MySendARP(PingResult.IPAdress);
  Ping.Free;
  Ready := true;
end;

end.
