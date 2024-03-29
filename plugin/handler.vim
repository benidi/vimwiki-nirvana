" vim: fdm=marker ts=2 sts=2 sw=2 fdl=0

if g:twvim_debug | echom "-D- Sourcing " expand('<sfile>:p') | endif

function! TwHandler(link)  "{{{ do not use default handler like sdg-open, but specific one
  " define one schema per replacment
  " if replacement cannot be done, original link is returned and tested for existence
  " return: 2 (if invalid link: no fallback), 0 (fallback to default handler, 1 (success)

  let link = a:link

  let schema= TwExtractSchema(link)
  if schema == "" | return 0 | endif

  "if link =~? "^".schema."::.*"
    "call TwLog("VimwikiLinkHandler: Calling xxx Handler.")
  "endif

  let prefix = g:twvim_handlers[schema]['prefix']
  let replacement = g:twvim_handlers[schema]['replacement']
  let executable = ""

  if has_key(g:twvim_handlers[schema], 'executable')
    let executable = g:twvim_handlers[schema]['executable']
  endif

  call TwDebug(printf("TwHandler: schema: %s, prefix: %s, %s, exec: %s", schema, prefix, replacement, executable))
  call TwDebug(printf("TwHandler: link: %s", link))

  let toreplace = schema.'::'.prefix
  call TwDebug(printf("TwHandler: toreplace: %s", toreplace))

  " TODO: in case no replacment possible: better user feedback
  let nlink = fnamemodify(expand(substitute(link, toreplace, replacement, "")), ':p')
  call TwDebug(printf("TwHandler: nlink: %s", nlink))

  if !TwIsLinkValid(nlink)
    call TwWarn(printf("TwHandler: Invalid or non-existing link: %s", nlink))
    return 2
  endif

  if executable != ""
    if executable =~? 'vim'
      execute "tabnew" nlink
      return 1
    endif
    if executable =~? 'slides'
       "execute ("tabnew | term slides") 
       let filename = split(nlink, "/")[-1]
       let file = split(filename, '\.')[0]
       let windows = system("tmux list-windows | awk '{ print $2 }'")
       "call TwWarn(windows)
       "call TwWarn(windows =~ file)
       if windows =~ file 
         "call TwWarn('tmux select-window "' . file . '"')
         call system('tmux select-window -t "' . file . '"')
      else
          call system('tmux new-window -n ' . file)
          "sleep 1000m
          let strPath = 'tmux send-keys -t "'. file . '" "slides "' . nlink . " Enter"
          call system(strPath)
       endif
          return 1
    endif

    if executable =~? 'source'
       "execute ("tabnew | term slides") 
       let filename = split(nlink, "/")[-1]
       let file = join(split(filename, '\.')[0:-1],"-")
       "let file = split(filename, '\.')[0]
       let windows = system("tmux list-windows | awk '{ print $2 }'")
       "call TwWarn(windows)
       "call TwWarn(windows =~ file)
       if windows =~ file 
         "call TwWarn('tmux select-window "' . file . '"')
         call system('tmux select-window -t "' . file . '"')
      else
          call system('tmux new-window -n ' . file)
          "sleep 1000m
          let strPath = 'tmux send-keys -t "'. file . '" "vi "' . nlink . " Enter"
          let strPath = 'tmux send-keys -t "'. file . '" "cd "' . nlink . " Enter"
          call system(strPath)
          call system('tmux split-window -h -l 70  -c ' . nlink . ' bash')
          call system('tmux split-window -v  -c '. nlink . ' bash')
          let openCommand = 'tmux send-keys -t "'. file . '" "lazygit "' . " Enter"
          call system(openCommand)
          call system('tmux select-pane -t 0')
          let openVimCommand = 'tmux send-keys -t "'. file . '" "vi  ./"' . " Enter"
          call system(openVimCommand)
       endif
          return 1
    endif

    if executable =~? 'path'
       "execute ("tabnew | term slides") 
       let filename = split(nlink, "/")[-1]
       let windows = system("tmux list-windows | awk '{ print $2 }'")
       "call TwWarn(windows)
       "call TwWarn(windows =~ filename)
       if windows =~ filename 
         "call TwWarn('tmux select-window "' . filename . '"')
         call system('tmux select-window -t "' . filename . '"')
      else
         "call TwWarn('tmux new-window -n ' . filename . ' -c ' . nlink)
          call system('tmux new-window -n ' . filename . ' -c ' . nlink) "  . ' -c ' . nlink
          "let strPath = 'tmux send-keys -t "'. file . '" "slides "' . nlink . " Enter"
          "call system(strPath)
       endif
          return 1
    endif
  
    if executable =~? 'project'
       "execute ("tabnew | term slides") 
       let filename = split(nlink, "/")[-1]
       let windows = system("tmux list-windows | awk '{ print $2 }'")
       "call TwWarn(windows)
       "call TwWarn(windows =~ filename)
       if windows =~ filename 
         "call TwWarn('tmux select-window "' . filename . '"')
         call system('tmux select-window -t "' . filename . '"')
      else
         "call TwWarn('tmux new-window -n ' . filename . ' -c ' . nlink)
          call system('tmux new-window -n ' . filename . ' -c ' . nlink) "  . ' -c ' . nlink
          "sleep 1400m
          let strPath = 'tmux send-keys -t"' . filename . '" vi Enter'
          call system(strPath)
       endif
          return 1
    endif

    if executable =~? 'ssh'
       "execute ("tabnew | term slides") 
       let command = split(nlink, "/")[-1]
       let pathName = split(nlink, "@")[0]
       let filename = split(pathName, "/")[-1]
       let windows = system("tmux list-windows | awk '{ print $2 }'")
       "call TwWarn(windows)
       "call TwWarn(windows =~ filename)
       if windows =~ filename 
         "call TwWarn('tmux select-window "' . filename . '"')
         call system('tmux select-window -t "' . filename . '"')
      else
         "call TwWarn('tmux new-window -n ' . filename . ' -c ' . nlink)
          call system('tmux new-window -n ' . filename . ' -c ' . nlink) "  . ' -c ' . nlink
          "sleep 1400m
          let strPath = 'tmux send-keys -t "' . filename . '" ssh " " '. command .'  Enter'
          call system(strPath)
       endif
          return 1
    endif

    if executable =~? 'script'
       "execute ("tabnew | term slides") 
       let command = split(nlink, "/")[-1]
       let pathName = split(nlink, "@")[0]
       let filename = split(pathName, "/")[-1]
       let windows = system("tmux list-windows | awk '{ print $2 }'")
       let file = split(filename, '\.')[0]
       "call TwWarn(windows)
       "call TwWarn(windows =~ filename)
       if windows =~ file 
         "call TwWarn('tmux select-window "' . filename . '"')
         call system('tmux select-window -t "' . file . '"')
      else
         "call TwWarn('tmux new-window -n ' . filename . ' -c ' . nlink)
          call system('tmux new-window -n ' . file . ' -c ' . nlink) "  . ' -c ' . nlink
          "sleep 1400m
          let strPath = 'tmux send-keys -t "' . file . '" '. nlink .'  Enter'
          call system(strPath)
       endif
          return 1
    endif

      "let cmd = "!explorer.exe '" . substitute(nlink, "/", "\\\\", 'g') ."'"
      let cmd = printf("!%s %s", executable, nlink)
      call TwDebug(printf("TwHandler: %s", cmd))
      call TwWarn(printf("TwHandler: Must activate action."))
      "silent execute cmd
      return 1
    else
      call TwDebug(printf("TwHandler: calling default open, xdg-open, start: %s", nlink))
      let link_infos = vimwiki#base#resolve_link(nlink)  " no error when remote fs unmounted, resolves relative links
      if link_infos.filename == ''
        call TwWarn("TwHandler: Unable to resolve link ".nlink)
        return 0
      else
        call TwDebug(printf("TwHandler: link_infos: %s", link_infos))
        call TwDebug(printf("TwHandler: calling vimwiki#base#system_open_link('%s')", link_infos.filename))

        "must not use link_infos.filename because path is preceded with vimwiki sourcefile path (base.vim:186)
        "call vimwiki#base#system_open_link(link_infos.filename)
        call vimwiki#base#system_open_link(nlink)

        return 1
      endif
  endif
endfunction

"let s:link = "xxxxxx::smb://xxx/aaa/learnvimscriptthehardway.stevelosh.com/"
"command! TwHandler :call TwHandler(s:link)
"let s:link = "yyy::smb://yyy/tevelosh.com/"
"command! TwHandler :call TwHandler(s:link)
"}}}

function! TwExtractSchema(link) abort
  let link = a:link
  " echo matchstr('aebsd::asdfasdf:asdf/asdf', '\zs.*\ze::.*')
  let schema = matchstr(link, '\zs.*\ze::.*')
  call TwDebug(printf("TwExtractSchema: schema: %s", schema))
  if schema == "" | return "" | endif
  if index(keys(g:twvim_handlers), schema) == -1
    call TwWarn(printf("TwHandler: Undefined schema '%s', must b in [%s]", schema, join(keys(g:twvim_handlers), ',')))
    return ""
  endif
  return schema
endfunc
