@echo off

cd D:\PizzaOS\repo\build
qemu-system-x86_64 -drive format=raw,file=pz.os
cd ../