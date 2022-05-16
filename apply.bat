@echo off
copy .\src\* %USERPROFILE%
mkdir %USERPROFILE%\bash
copy .\src\bash\* %USERPROFILE%\bash
