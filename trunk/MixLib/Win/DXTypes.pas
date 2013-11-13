{******************************************************************************}
{*                                                                            *}
{*  Copyright (C) Microsoft Corporation.  All Rights Reserved.                *}
{*                                                                            *}
{*  Files:      dxsdkver.h, extracts from various DirectX SDK include files   *}
{*  Content:    DirectX 9.0 headers common types                              *}
{*                                                                            *}
{*  DirectX 9.0 Delphi / FreePascal adaptation by Alexey Barkovoy             *}
{*  E-Mail: directx@clootie.ru                                                *}
{*                                                                            *}
{*  Latest version can be downloaded from:                                    *}
{*    http://www.clootie.ru                                                   *}
{*    http://sourceforge.net/projects/delphi-dx9sdk                           *}
{*                                                                            *}
{*----------------------------------------------------------------------------*}
{*  $Id: DXTypes.pas,v 1.23 2007/04/14 20:57:43 clootie Exp $  }
{******************************************************************************}

{$I Defines.inc}
{ I DirectX.inc}

{$WEAKPACKAGEUNIT}
{$ALIGN ON}
{$MINENUMSIZE 4}

unit DXTypes;

interface

{$DEFINE TYPE_IDENTITY}

uses Windows;

(*==========================================================================;
 *
 *  File:   dxsdkver.h
 *  Content:    DirectX SDK Version Include File
 *
 ****************************************************************************)
const
  _DXSDK_PRODUCT_MAJOR  = 9;
  {$EXTERNALSYM _DXSDK_PRODUCT_MAJOR}
  _DXSDK_PRODUCT_MINOR  = 18;
  {$EXTERNALSYM _DXSDK_PRODUCT_MINOR}
  _DXSDK_BUILD_MAJOR    = 944;
  {$EXTERNALSYM _DXSDK_BUILD_MAJOR}
  _DXSDK_BUILD_MINOR    = 0000;
  {$EXTERNALSYM _DXSDK_BUILD_MINOR}


(****************************************************************************
 *  Other files
 ****************************************************************************)

type
  // TD3DValue is the fundamental Direct3D fractional data type
  D3DVALUE = Single;
  {$EXTERNALSYM D3DVALUE}
  TD3DValue = D3DVALUE;
  {$NODEFINE TD3DValue}
  PD3DValue = ^TD3DValue;
  {$NODEFINE PD3DValue}

  D3DCOLOR = type DWord;
  {$EXTERNALSYM D3DCOLOR}
  TD3DColor = D3DCOLOR;
  {$NODEFINE TD3DColor}
  PD3DColor = ^TD3DColor;
  {$EXTERNALSYM PD3DColor}

  _D3DVECTOR = record
    x: Single;
    y: Single;
    z: Single;
//  class function Create(const X, Y, Z: Single): _D3DVECTOR; static; inline;
//  class operator Equal(const Left, Right: _D3DVECTOR): Boolean;
//  class function Zero: _D3DVECTOR; static; inline;
  end {_D3DVECTOR};
  {$EXTERNALSYM _D3DVECTOR}
  D3DVECTOR = _D3DVECTOR;
  {$EXTERNALSYM D3DVECTOR}
  TD3DVector = _D3DVECTOR;
  {$NODEFINE TD3DVector}
  PD3DVector = ^TD3DVector;
  {$NODEFINE PD3DVector}

  REFERENCE_TIME = LONGLONG;
  {$EXTERNALSYM REFERENCE_TIME}
  TReferenceTime = REFERENCE_TIME;
  {$NODEFINE TReferenceTime}
  PReferenceTime = ^TReferenceTime;
  {$NODEFINE PReferenceTime}

  PD3DColorValue = ^TD3DColorValue;
  {$EXTERNALSYM PD3DColorValue}
  _D3DCOLORVALUE = record
    r: Single;
    g: Single;
    b: Single;
    a: Single;
//  class function Create(const R, G, B, A: Single): _D3DCOLORVALUE; static; inline;
//  class operator Implicit(const Value: DWORD): _D3DCOLORVALUE; inline;
//  class operator Implicit(const Value: _D3DCOLORVALUE): DWORD; inline;
//  class operator Equal(const Left, Right: _D3DCOLORVALUE): Boolean; inline;
  end {_D3DCOLORVALUE};
  {$EXTERNALSYM _D3DCOLORVALUE}
  D3DCOLORVALUE = _D3DCOLORVALUE;
  {$EXTERNALSYM D3DCOLORVALUE}
  TD3DColorValue = _D3DCOLORVALUE;
  {$EXTERNALSYM TD3DColorValue}

  PD3DRect = ^TD3DRect;
  {$EXTERNALSYM PD3DRect}
  _D3DRECT = record
    x1: LongInt;
    y1: LongInt;
    x2: LongInt;
    y2: LongInt;
  end {_D3DRECT};
  {$EXTERNALSYM _D3DRECT}
  D3DRECT = _D3DRECT;
  {$EXTERNALSYM D3DRECT}
  TD3DRect = _D3DRECT;
  {$EXTERNALSYM TD3DRect}

  PD3DMatrix = ^TD3DMatrix;
  {$EXTERNALSYM PD3DMatrix}
  _D3DMATRIX = record
//  class function Create(
//  _m00, _m01, _m02, _m03,
//  _m10, _m11, _m12, _m13,
//  _m20, _m21, _m22, _m23,
//  _m30, _m31, _m32, _m33: Single): _D3DMATRIX; static; inline;
//  class operator Add(const M1, M2: _D3DMATRIX): _D3DMATRIX; inline;
//  class operator Subtract(const M1, M2: _D3DMATRIX): _D3DMATRIX; inline;
//  class operator Multiply(const M: _D3DMATRIX; const S: Single): _D3DMATRIX; inline;
//  class operator Equal(const M1, M2: _D3DMATRIX): Boolean; inline;
//public
    case integer of
      0 : (_11, _12, _13, _14: Single;
           _21, _22, _23, _24: Single;
           _31, _32, _33, _34: Single;
           _41, _42, _43, _44: Single);
      1 : (m : array [0..3, 0..3] of Single);
  end {_D3DMATRIX};
  {$EXTERNALSYM _D3DMATRIX}
  D3DMATRIX = _D3DMATRIX;
  {$EXTERNALSYM D3DMATRIX}
  TD3DMatrix = _D3DMATRIX;
  {$EXTERNALSYM TD3DMatrix}

implementation

//uses System.SysUtils;

{ _D3DVECTOR }

(*
class function _D3DVECTOR.Create(const X, Y, Z: Single): _D3DVECTOR;
begin
  Result.x := X;
  Result.y := Y;
  Result.z := Z;
end;

class operator _D3DVECTOR.Equal(const Left, Right: _D3DVECTOR): Boolean;
begin
  Result:= (Left.x = Right.x) and (Left.y = Right.y) and (Left.z = Right.z);
end;

class function _D3DVECTOR.Zero: _D3DVECTOR;
begin
  Result.x := 0.0;
  Result.y := 0.0;
  Result.z := 0.0;
end;
*)

{ _D3DMATRIX }

(*
class operator _D3DMATRIX.Add(const M1, M2: _D3DMATRIX): _D3DMATRIX;
var
  pOut, p1, p2: PSingle;
  I: Integer;
begin
  pOut:= @Result._11; p1:= @M1._11; p2:= @M2._11;
  for I := 0 to 15 do
  begin
    pOut^:= p1^ + p2^;
    Inc(pOut);
    Inc(p1);
    Inc(p2);
  end;
end;

class function _D3DMATRIX.Create(_m00, _m01, _m02, _m03, _m10, _m11, _m12, _m13, _m20, _m21, _m22, _m23, _m30, _m31,
  _m32, _m33: Single): _D3DMATRIX;
begin
  with Result do
  begin
    m[0,0]:= _m00; m[0,1]:= _m01; m[0,2]:= _m02; m[0,3]:= _m03;
    m[1,0]:= _m10; m[1,1]:= _m11; m[1,2]:= _m12; m[1,3]:= _m13;
    m[2,0]:= _m20; m[2,1]:= _m21; m[2,2]:= _m22; m[2,3]:= _m23;
    m[3,0]:= _m30; m[3,1]:= _m31; m[3,2]:= _m32; m[3,3]:= _m33;
  end;
end;

class operator _D3DMATRIX.Equal(const M1, M2: _D3DMATRIX): Boolean;
begin
  Result:= CompareMem(@m1, @m2, SizeOf(_D3DMATRIX));
end;

class operator _D3DMATRIX.Multiply(const M: _D3DMATRIX; const S: Single): _D3DMATRIX;
var
  pOut, p: PSingle;
  I: Integer;
begin
  pOut:= @Result._11; p:= @M._11;
  for I := 0 to 15 do
  begin
    pOut^:= p^ * S;
    Inc(pOut);
    Inc(p);
  end;
end;

class operator _D3DMATRIX.Subtract(const M1, M2: _D3DMATRIX): _D3DMATRIX;
var
  pOut, p1, p2: PSingle;
  I: Integer;
begin
  pOut:= @Result._11; p1:= @M1._11; p2:= @M2._11;
  for I := 0 to 15 do
  begin
    pOut^:= p1^ - p2^;
    Inc(pOut);
    Inc(p1);
    Inc(p2);
  end;
end;

{ _D3DCOLORVALUE }

class function _D3DCOLORVALUE.Create(const R, G, B, A: Single): _D3DCOLORVALUE;
begin
  Result.r := R;
  Result.g := G;
  Result.b := B;
  Result.a := A;
end;

class operator _D3DCOLORVALUE.Equal(const Left, Right: _D3DCOLORVALUE): Boolean;
begin
  Result:= (Left.r = Right.r) and (Left.g = Right.g) and (Left.b = Right.b) and (Left.a = Right.a);
end;

class operator _D3DCOLORVALUE.Implicit(const Value: DWORD): _D3DCOLORVALUE;
const
  f = 1/255;
begin
  with Result do
  begin
    r:= f * Byte(Value shr 16);
    g:= f * Byte(Value shr  8);
    b:= f * Byte(Value{shr 0});
    a:= f * Byte(Value shr 24);
  end;
end;

class operator _D3DCOLORVALUE.Implicit(const Value: _D3DCOLORVALUE): DWORD;
var
  dwR, dwG, dwB, dwA: DWORD;
begin
  if Value.r > 1.0 then dwR:= 255 else if Value.r < 0 then dwR:= 0 else dwR:= DWORD(Trunc(Value.r * 255.0 + 0.5));
  if Value.g > 1.0 then dwG:= 255 else if Value.g < 0 then dwG:= 0 else dwG:= DWORD(Trunc(Value.g * 255.0 + 0.5));
  if Value.b > 1.0 then dwB:= 255 else if Value.b < 0 then dwB:= 0 else dwB:= DWORD(Trunc(Value.b * 255.0 + 0.5));
  if Value.a > 1.0 then dwA:= 255 else if Value.a < 0 then dwA:= 0 else dwA:= DWORD(Trunc(Value.a * 255.0 + 0.5));

  Result := (dwA shl 24) or (dwR shl 16) or (dwG shl 8) or dwB;
end;
*)

end.

