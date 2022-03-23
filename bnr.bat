::@echo off

echo This batchfile is used for building/archiving every build of PizzaOS. This batchfile is public domain. You can use it for your own projects, so modify it and enjoy! :)

for /f "delims=" %%a in ('wmic OS Get localdatetime ^| find "."') do set DateTime=%%a

set Yr=%DateTime:~0,4%
set Mon=%DateTime:~4,2%
set Day=%DateTime:~6,2%
set Hr=%DateTime:~8,2%
set Min=%DateTime:~10,2%
set Sec=%DateTime:~12,2%

set ArchiveName=PizzaOS__%Yr%_%Mon%_%Day%__%Hr%_%Min%_%Sec%

cd /D "D:\PizzaOS\repo\src\bootloader"
nasm "D:\PizzaOS\repo\src\bootloader\pzos.asm"
cd /D "D:\PizzaOS\repo\src\kernel"
make clean
make
mkdir "D:\PizzaOS\repo\build\obj"
move /Y "D:\PizzaOS\repo\src\bootloader\pzos" "D:\PizzaOS\repo\build\"
move /Y "D:\PizzaOS\repo\src\kernel\pzos_kernel" "D:\PizzaOS\repo\build\"
move /Y "D:\PizzaOS\repo\src\kernel\pzos_kernel.elf" "D:\PizzaOS\repo\build\"
move /Y "D:\PizzaOS\repo\src\kernel\krnl_entry.o" "D:\PizzaOS\repo\build\obj"
move /Y "D:\PizzaOS\repo\src\kernel\src\krnl.o" "D:\PizzaOS\repo\build\obj"
move /Y "D:\PizzaOS\repo\src\kernel\src\cpu\ports.o" "D:\PizzaOS\repo\build\obj"
move /Y "D:\PizzaOS\repo\src\kernel\src\driver\vga.o" "D:\PizzaOS\repo\build\obj"
cd "D:\PizzaOS\repo\build\"
cp pzos pz.os
cat pzos_kernel >> pz.os
cat pzos_kernel.elf >> pz.os

mkdir "D:\PizzaOS\repo\archive\%ArchiveName%"
mkdir "D:\PizzaOS\repo\archive\%ArchiveName%\src"
xcopy "D:\PizzaOS\repo\src\" "D:\PizzaOS\repo\archive\%ArchiveName%\src" /e /Y
mkdir "D:\PizzaOS\repo\archive\%ArchiveName%\bin"
xcopy "D:\PizzaOS\repo\build\pz.os" "D:\PizzaOS\repo\archive\%ArchiveName%\bin" /e /Y
xcopy "D:\PizzaOS\repo\build\pzos_kernel" "D:\PizzaOS\repo\archive\%ArchiveName%\bin" /e /Y
xcopy "D:\PizzaOS\repo\build\pzos_kernel.elf" "D:\PizzaOS\repo\archive\%ArchiveName%\bin" /e /Y
mkdir "D:\PizzaOS\repo\archive\%ArchiveName%\obj"
xcopy "D:\PizzaOS\repo\build\obj\" "D:\PizzaOS\repo\archive\%ArchiveName%\obj" /e /Y
xcopy "D:\PizzaOS\repo\build\" "D:\PizzaOS\repo\archive\%ArchiveName%\bin" /Y

rmdir "D:\PizzaOS\repo\archive\%ArchiveName%\bin\obj" /S /Q
cd "D:\PizzaOS\repo\archive"

7z a %ArchiveName%.7z %ArchiveName% -mx=9

del "D:\PizzaOS\repo\archive\%ArchiveName%" /S /Q
rmdir "D:\PizzaOS\repo\archive\%ArchiveName%" /S /Q

cd "D:\PizzaOS\repo\"

cd "D:\PizzaOS\repo\build"
qemu-system-x86_64 -drive format=raw,file=pz.os -D "D:\PizzaOS\repo\logs\%ArchiveName%.log" -monitor stdio
cd ../