::@echo off

for /f "delims=" %%a in ('wmic OS Get localdatetime ^| find "."') do set DateTime=%%a

set Yr=%DateTime:~0,4%
set Mon=%DateTime:~4,2%
set Day=%DateTime:~6,2%
set Hr=%DateTime:~8,2%
set Min=%DateTime:~10,2%
set Sec=%DateTime:~12,2%

set LogName=PizzaOS__%Yr%_%Mon%_%Day%__%Hr%_%Min%_%Sec%

cd D:\PizzaOS\repo\build
qemu-system-x86_64 -drive format=raw,file=pzos.img -D "D:\PizzaOS\repo\logs\%LogName%.log" -monitor stdio
cd ../