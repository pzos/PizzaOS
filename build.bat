@echo off

echo This batchfile is used for archiving every build of PizzaOS. This batchfile ("build.bat" SPECIFICALLY) is public domain. You can use it for your own projects, so modify it and enjoy! :D

for /f "delims=" %%a in ('wmic OS Get localdatetime ^| find "."') do set DateTime=%%a

set Yr=%DateTime:~0,4%
set Mon=%DateTime:~4,2%
set Day=%DateTime:~6,2%
set Hr=%DateTime:~8,2%
set Min=%DateTime:~10,2%
set Sec=%DateTime:~12,2%

set ArchiveName=PizzaOS__%Yr%_%Mon%_%Day%__%Hr%_%Min%_%Sec%

cd /D "D:\PizzaOS\repo\src"
nasm "D:\PizzaOS\repo\src\pzos.asm"
qemu-system-x86_64 -drive format=raw,file=pzos

mkdir "D:\PizzaOS\repo\build\%ArchiveName%"
mkdir "D:\PizzaOS\repo\build\%ArchiveName%\src"
copy "D:\PizzaOS\repo\src\*" "D:\PizzaOS\repo\build\%ArchiveName%\src"
cd "D:\PizzaOS\repo\build\"

7z a %ArchiveName%.7z %ArchiveName% -mx=9

del "D:\PizzaOS\repo\build\%ArchiveName%" /S /Q
rmdir "D:\PizzaOS\repo\build\%ArchiveName%" /S /Q