"command! -nargs=1 Xplr lua require'xplr'.load_command(<f-args>)
command! -bar -nargs=? -complete=dir Xplr lua require'xplr'.load_command(<f-args>)

function! health#xplr#check()
  lua require 'xplr/health'.check_health()
endfunction
