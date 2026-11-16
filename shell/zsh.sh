# zsh hooks preserve existing precmd/preexec functions and prompt.
[[ -o interactive && -z ${TMUX:-}${STY:-} ]] || return 0
[[ ${_SHELL_IME_OWNER:-} != $$ ]] || return 0
typeset -g _SHELL_IME_OWNER=$$ _SHELL_IME_ENGLISH=1
typeset -g _SHELL_IME_ROOT=${${(%):-%N}:A:h:h}
export SHELL_IME_STATE_DIR=${SHELL_IME_STATE_DIR:-${XDG_RUNTIME_DIR:-$HOME/.cache}/shell-ime}
_shell_ime_emit(){
 local shell_ime_status=$?
 [[ ${SHELL_IME_BACKEND:-} != vscode ]] || printf '\e]777;shell-ime;%s\a' "$1"
 [[ ! -x $_SHELL_IME_ROOT/build/shell-ime-state ]] || "$_SHELL_IME_ROOT/build/shell-ime-state" $$ "$1" >/dev/null 2>&1
 return $shell_ime_status
}
_shell_ime_precmd(){ local shell_ime_status=$?;_shell_ime_emit $_SHELL_IME_ENGLISH;return $shell_ime_status; }
_shell_ime_preexec(){ _shell_ime_emit 0; }
ime(){
 case ${1:-toggle} in
 status) if (( _SHELL_IME_ENGLISH ));then print english;else print system;fi;return;;
 english) _SHELL_IME_ENGLISH=1;;system) _SHELL_IME_ENGLISH=0;;toggle) (( _SHELL_IME_ENGLISH=1-_SHELL_IME_ENGLISH ));;
 *) print -u2 'Usage: ime [status|english|system]';return 2;;
 esac
 _shell_ime_emit $_SHELL_IME_ENGLISH
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _shell_ime_precmd
add-zsh-hook preexec _shell_ime_preexec
