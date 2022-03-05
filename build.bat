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

cd /D "D:\PizzaOS\src"
nasm "D:\PizzaOS\src\boot.asm"
qemu-system-x86_64 -drive format=raw,file=boot

mkdir "D:\PizzaOS\build\%ArchiveName%"
copy "D:\PizzaOS\src\*" "D:\PizzaOS\build\%ArchiveName%"
cd "D:\PizzaOS\build\"

7z a %ArchiveName%.7z %ArchiveName% -mx=9

del "D:\PizzaOS\build\%ArchiveName%" /Q
rmdir "D:\PizzaOS\build\%ArchiveName%" /Q