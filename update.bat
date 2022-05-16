@echo off
SETLOCAL EnableDelayedExpansion

for %%f in (.bashrc, .bash_profile, .inputrc, _vimrc, _gvimrc) do (
    copy !USERPROFILE!\%%f .\src\
)
copy !USERPROFILE!\bash\* .\src\bash\
del .\src\bash\ualias >nul 2>&1
del .\src\bash\ufunc >nul 2>&1
del .\src\bash\upath >nul 2>&1
