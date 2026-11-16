if ($#argv == 0) then
 @ shell_ime_english = 1 - $shell_ime_english
else if ("$argv[1]" == "status") then
 if ($shell_ime_english) then
  echo english
 else
  echo system
 endif
else if ("$argv[1]" == "english") then
 set shell_ime_english = 1
else if ("$argv[1]" == "system") then
 set shell_ime_english = 0
else
 echo 'Usage: ime [status|english|system]'
endif
