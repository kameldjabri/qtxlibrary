unit qtxutils;

interface

uses 
  W3System;

(* Helper functions *)
function  w3_FindElementRootAncestor(const aElement:THandle):THandle;
function  W3_ElementInDOM(const aElement:THandle):Boolean;
procedure w3_ExecuteOnElementReady(const aElement:THandle;
          Const aFunc:TProcedureRef);


implementation

function w3_FindElementRootAncestor(const aElement:THandle):THandle;
var
  mAncestor:  THandle;
Begin
  if (aElement) then
  Begin
    mAncestor:=aElement;
    while (mAncestor.parentNode) do
    mAncestor:=mAncestor.parentNode;
    result:=mAncestor;
  end;
end;

function W3_ElementInDOM(const aElement:THandle):Boolean;
var
  mRef: THandle;
begin
  if (aElement) then
  Begin
    (* Check that top-level ancestor is window->document->body *)
    mRef:=w3_FindElementRootAncestor(aElement);
    result:=(mRef.body);
  end;
end;

procedure w3_ExecuteOnElementReady(const aElement:THandle;
          Const aFunc:TProcedureRef);
Begin
  if (aElement) then
  begin
    if assigned(aFunc) then
    Begin
      if W3_ElementInDOM(aElement) then
      aFunc() else
      w3_callback(
        procedure ()
        begin
          w3_ExecuteOnElementReady(aElement,aFunc);
        end,
        100);
    end;
  end;
end;



end.
