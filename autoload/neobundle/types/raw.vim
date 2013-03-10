"=============================================================================
" FILE: raw.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 10 Mar 2013.
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================

let s:save_cpo = &cpo
set cpo&vim

" Global options definition. "{{{
call neobundle#util#set_default(
      \ 'g:neobundle#types#raw#calc_hash_command',
      \ executable('sha1sum') ? 'sha1sum' :
      \ executable('md5sum') ? 'md5sum' : '')
"}}}

function! neobundle#types#raw#define() "{{{
  return s:type
endfunction"}}}

let s:type = {
      \ 'name' : 'raw',
      \ }

function! s:type.detect(path, opts) "{{{
  " No auto detect.
  let type = ''

  if a:path =~# '^https\?:.*\.vim$'
    " HTTP/HTTPS

    let name = split(a:path, '/')[-1]

    let type = 'raw'
  endif

  return type == '' ?  {} :
        \ { 'name': name, 'uri' : a:path, 'type' : type }
endfunction"}}}
function! s:type.get_sync_command(bundle) "{{{
  if a:bundle.script_type == ''
    return 'E: script_type is not found.'
  endif

  if !executable('curl') && !executable('wget')
    return 'E: curl or wget command is not available!'
  endif

  let path = a:bundle.path

  if !isdirectory(path)
    " Create script type directory.
    call mkdir(path, 'p')
  endif

  let filename = path . '/' . fnamemodify(a:bundle.uri, ':t')
  let a:bundle.type__filename = filename
  if executable('curl')
    let cmd = 'curl --fail -s -o "' . filename . '" '. a:bundle.uri
  elseif executable('wget')
    let cmd = 'wget -q -O "' . filename . '" ' . a:bundle.uri
  endif

  return cmd
endfunction"}}}
function! s:type.get_revision_number_command(bundle) "{{{
  if g:neobundle#types#raw#calc_hash_command == ''
    return ''
  endif

  let filename = a:bundle.path . '/' . fnamemodify(a:bundle.uri, ':t')
  if !filereadable(filename)
    " Not Installed.
    return ''
  endif

  " Calc hash.
  return g:neobundle#types#raw#calc_hash_command . ' ' . a:bundle.type__filename
endfunction"}}}
function! s:type.get_revision_lock_command(bundle) "{{{
  let new_rev = matchstr(a:bundle.new_rev, '^\S\+')
  if a:bundle.rev != '' && new_rev != '' &&
        \ new_rev !=# a:bundle.rev
    " Revision check.
    return printf('E: revision digest is not matched : "%s"(got) and "%s"(rev).',
          \ new_rev, a:bundle.rev)
  endif

  " Not supported.
  return ''
endfunction"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker
