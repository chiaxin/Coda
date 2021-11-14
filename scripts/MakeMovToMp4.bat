@ECHO off
SET CurrentDirectory=%~dp0
SET ConvertScript=%CurrentDirectory%pl\MovToMp4.pl

IF EXIST %ConvertScript% (
    perl %ConvertScript%
) ELSE (
    ECHO %ConvertScript% is not exists!
)

PAUSE
