if exists("g:loaded_codegate")
  finish
endif
let g:loaded_codegate = 1

" Load the Lua module
lua require('codegate')

" Register the command to list workspaces.
command! CodeGateListWorkspaces lua require('codegate').list_workspaces()

" Register the command to set (activate) a workspace. Accepts one argument.
command! -nargs=1 CodeGateSetWorkspace lua require('codegate').set_workspace(<f-args>)
