# tcsh integration does not replace existing user precmd/postcmd aliases.
if ($?prompt && ! $?TMUX && ! $?STY) then
set _shell_ime_conflict = `alias precmd`
set _shell_ime_postconflict = `alias postcmd`
if ("$_shell_ime_conflict" != "" || "$_shell_ime_postconflict" != "") then
 echo 'shell-ime: existing precmd/postcmd aliases; automatic integration skipped.'
else
 set shell_ime_english = 1
 alias precmd 'if ($?SHELL_IME_BACKEND) printf "\033]777;shell-ime;%s\007" $shell_ime_english'
 alias postcmd 'if ($?SHELL_IME_BACKEND) printf "\033]777;shell-ime;0\007"'
 alias ime 'source ~/.install/shell-ime/shell/tcsh-ime.csh \!*'
endif
endif
