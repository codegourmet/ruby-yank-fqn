" configuration example:
" nmap yf :call YankFQN()<CR>

if exists('g:loaded_YFQN')
	finish
endif
let g:loaded_YFQN = 1

if ! exists("g:yankfqn_register")
	let g:yankfqn_register = '"'
end
if ! exists("g:yankfqn_verbose")
	let g:yankfqn_verbose = 0
end

function! YFQN_IsEndStatement(line_nr)
	let line = getline(a:line_nr)
	return match(line, '^\s*\(end\)\(\s|#\)*.*$') > -1
endfunction

function! YFQN_SearchPosPrevClassDef()
	return searchpos('^\s*\(module\|class\)\s', 'bW')
endfunction

function! YFQN_GetClassName(line_nr)
	let line = getline(a:line_nr)
	let m = matchlist(line, '^\s*\(module\|class\)\s\(\S\+\)')

	let result = ''
	if len(m) > 2
		let result = m[2]
	endif

	return result
endfunction

function! YFQN_MoveToPrevNonBlank(line_nr)
	let line_nr = prevnonblank(a:line_nr)
	call setpos('.', [0, line_nr, 0, 0])
	return line_nr
endfunction

function! YankFQN()
	let saved_cursor = getpos('.')
	let line_nr = saved_cursor[1]

	" move to first indented line before current pos
	let line_nr = YFQN_MoveToPrevNonBlank(saved_cursor[1])
	let current_indent = indent(line_nr)

	" if we are on an end statement, increase indent to account for
	" the possibility of this being a relevant classdef end statement
	" NOTE but don't do this if we moved here from a blank (outer) line
	if line_nr == saved_cursor[1] && YFQN_IsEndStatement(line_nr)
		let current_indent = indent(line_nr) + 1
	endif

	" special case: cursor on class statement
	let result = YFQN_GetClassName(line_nr)

	while line_nr > 0
		let found_indent = current_indent " guarantee first while loop execution

		" find prev module/class definition with lower indent, this is the wrapping namespace
		" skip module/class defs on same level as current
		while found_indent >= current_indent " will also exit with -1 if at top of buffer
			let [line_nr,column_nr] = YFQN_SearchPosPrevClassDef()
			let found_indent = indent(line_nr)
		endwhile
		let current_indent = found_indent

		" if not reached top, extract class/module name
		if line_nr > 0
			let class_name = YFQN_GetClassName(line_nr)

			if ! empty(class_name)
				if ! empty(result)
					let result = '::' . result
				end
				let result = class_name .  result
			endif
		endif
	endwhile

	execute 'let @' . g:yankfqn_register . ' = "' . result . '"'
	call setpos('.', saved_cursor)

	if g:yankfqn_verbose == 1
		echo('yanking: ' . result)
	end
endfunction
