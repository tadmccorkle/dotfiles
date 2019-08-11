@echo off
copy .\msys2\* %USERPROFILE%
mkdir %USERPROFILE%\bash
copy .\msys2\bash\* %USERPROFILE%\bash
