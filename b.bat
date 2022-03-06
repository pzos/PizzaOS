@echo off

echo This batchfile is used for building/archiving every build of PizzaOS. This batchfile is public domain. You can use it for your own projects, so modify it and enjoy! :)

for /f "delims=" %%a in ('wmic OS Get localdatetime ^| find "."') do set DateTime=%%a

set Yr=%DateTime:~0,4%
set Mon=%DateTime:~4,2%
set Day=%DateTime:~6,2%
set Hr=%DateTime:~8,2%
set Min=%DateTime:~10,2%
set Sec=%DateTime:~12,2%

set ArchiveName=PizzaOS__%Yr%_%Mon%_%Day%__%Hr%_%Min%_%Sec%

cd /D "D:\PizzaOS\repo\src"
nasm "D:\PizzaOS\repo\src\pzos.asm" -o pz.os
move /Y "D:\PizzaOS\repo\src\pz.os" "D:\PizzaOS\repo\build\"

mkdir "D:\PizzaOS\repo\archive\%ArchiveName%"
mkdir "D:\PizzaOS\repo\archive\%ArchiveName%\src"
xcopy "D:\PizzaOS\repo\src\" "D:\PizzaOS\repo\archive\%ArchiveName%\src" /e
mkdir "D:\PizzaOS\repo\archive\%ArchiveName%\bin"
xcopy "D:\PizzaOS\repo\build\pz.os" "D:\PizzaOS\repo\archive\%ArchiveName%\bin" /e
cd "D:\PizzaOS\repo\archive\"

7z a %ArchiveName%.7z %ArchiveName% -mx=9

del "D:\PizzaOS\repo\archive\%ArchiveName%" /S /Q
rmdir "D:\PizzaOS\repo\archive\%ArchiveName%" /S /Q

cd ../