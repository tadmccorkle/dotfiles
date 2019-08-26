# ~/.bashrc

# prevent multiple source
([[ -z ${TILDE_BASHRC} ]] && TILDE_BASHRC="1") || return

source ~/bash/path
source ~/bash/editor
source ~/bash/alias
source ~/bash/gitcompletion
source ~/bash/ps1
