# Bash 4.4+. Source from an interactive shell. No DEBUG trap or PS1 changes.
[[ $- == *i* && -z ${TMUX:-}${STY:-} ]] || return 0
[[ ${_SHELL_IME_OWNER:-} != "$BASHPID" ]] || return 0
_SHELL_IME_OWNER=$BASHPID
_SHELL_IME_ENGLISH=1
_SHELL_IME_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
export SHELL_IME_STATE_DIR="${SHELL_IME_STATE_DIR:-${XDG_RUNTIME_DIR:-$HOME/.cache}/shell-ime}"
_shell_ime_emit() {
 local shell_ime_status=$?
 if [[ ${SHELL_IME_BACKEND:-} == vscode ]]; then printf '\e]777;shell-ime;%s\a' "$1"; fi
 if [[ -x $_SHELL_IME_ROOT/build/shell-ime-state ]]; then "$_SHELL_IME_ROOT/build/shell-ime-state" "$BASHPID" "$1" >/dev/null 2>&1; fi
 return "$shell_ime_status"
}
_shell_ime_prompt() {
 local shell_ime_status=$?
 _shell_ime_emit "$_SHELL_IME_ENGLISH"
 return "$shell_ime_status"
}
ime() {
 case "${1:-toggle}" in
 status) if (( _SHELL_IME_ENGLISH )); then printf 'english\n'; else printf 'system\n'; fi; return;;
 english) _SHELL_IME_ENGLISH=1;; system) _SHELL_IME_ENGLISH=0;;
 toggle) _SHELL_IME_ENGLISH=$((1-_SHELL_IME_ENGLISH));;
 *) printf 'Usage: ime [status|english|system]\n' >&2;return 2;;
 esac
 _shell_ime_emit "$_SHELL_IME_ENGLISH"
}
if declare -p PROMPT_COMMAND 2>/dev/null | command grep -q '^declare -a'; then
 PROMPT_COMMAND+=(_shell_ime_prompt)
else
 PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }_shell_ime_prompt"
fi
# PS0 expands before builtins, read, exec and external commands. Command
# substitution emits only OSC; the parent prompt and exit status are preserved.
PS0='$( _shell_ime_emit 0 )'"${PS0:-}"
