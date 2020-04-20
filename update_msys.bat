@echo off
SETLOCAL EnableDelayedExpansion

for %%f in (.bashrc, .bash_profile, .inputrc, _vimrc, _gvimrc) do (
    copy !USERPROFILE!\%%f .\msys2\
)
copy !USERPROFILE!\bash\* .\msys2\bash\
del .\msys2\bash\ualias
