unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls;

type
  TfrmMain = class(TForm)
    tblTop: TPanel;
    tblClient: TPanel;
    btnSearch: TButton;
    lwListe: TListView;
    edtFromIp: TEdit;
    edtToIp: TEdit;
    Label1: TLabel;
    edtMAC: TLabeledEdit;
    procedure btnSearchClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

uses IPUtils, PingThread;

{$R *.dfm}

procedure TfrmMain.btnSearchClick(Sender: TObject);
var
  i,j: Cardinal;
  Ping: Array of TPingResult;
  PingCount,Cardinal1,Cardinal2: Cardinal;
  ThreadArray: Array of TPingThread;
  ThreadsComplete: Boolean;
  MAC, IP: string;
begin
  Screen.Cursor := crHourGlass;
  lwListe.Items.Clear;
  try
    if (not IsIPAdress(edtFromIp.Text)) or (not IsIPAdress(edtToIp.Text)) then
    begin
      ShowMessage('Hatalý IP Adresi');
      Exit;
    end;

    Cardinal1 := IPToCardinal(StrToIP(edtFromIp.Text));
    Cardinal2 := IPToCardinal(StrToIP(edtToIp.Text));
    PingCount := (Cardinal2 - Cardinal1) + 1;
    if PingCount < 1 then Exit;

    SetLength(Ping,PingCount);
    SetLength(ThreadArray,PingCount);
    j := 0;
    for i := Cardinal1 to Cardinal2 do
    begin
      Ping[j].IPAdress  := IPToStr(CardinalToIP(i));
      Ping[j].Exists    := false;
      Inc(j);
    end;

    for i := 0 to PingCount-1 do
      ThreadArray[i] := TPingThread.Create(Ping[i]);

    repeat
      ThreadsComplete := True;
      Sleep(1000);
      for i := 0 to PingCount-1 do
        if not ThreadArray[i].Ready then
        begin
          ThreadsComplete := False;
          Break;
        end;
    until ThreadsComplete;

	lwListe.Items.BeginUpdate;
    try      
      for i := 0 to PingCount-1 do
      begin
        if ThreadArray[i].PingResult.Exists then
        begin
          IP := ThreadArray[i].PingResult.IPAdress;
          MAC := ThreadArray[i].PingResult.MacAdress;
          if edtMAC.Text <> '' then
          begin
            if Pos(edtMAC.Text, MAC) > 0 then
            begin
              with lwListe.Items.Add do
              begin
                Caption := IP;
                SubItems.Add(MAC);
              end;
            end;
          end else
            with lwListe.Items.Add do
            begin
              Caption := IP;
              SubItems.Add(MAC);
            end;
        end;
      end;
    finally
      lwListe.Items.EndUpdate;
    end;

    for i := 0 to PingCount-1 do
      ThreadArray[i].Free;

  finally
    Screen.Cursor := crDefault;
  end;

end;

end.
