@ECHO off
SET CurrentDirectory=%~dp0
SET ConvertScript=%CurrentDirectory%pl\ImageToMovie.pl

IF EXIST %ConvertScript% (
    perl %ConvertScript%
) ELSE (
    ECHO %ConvertScript% is not exists!
)

PAUSE
