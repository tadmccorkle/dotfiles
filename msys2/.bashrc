# ~/.bashrc

# prevent multiple source
([[ -z ${TILDE_BASHRC} ]] && TILDE_BASHRC="1") || return

source ~/bash/ps1
source ~/bash/alias
source ~/bash/path
source ~/bash/editor
source ~/bash/gitcompletion
