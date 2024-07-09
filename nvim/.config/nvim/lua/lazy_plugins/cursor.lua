--[[ autodoc
	====================================================================================================
	Multi-cursor info (Plugin)[info]                                          *plugin-multi-cursor-info*

	Information abut the statusline can be found here: |vm-infoline|

	====================================================================================================
	Multi-cursor mappings (Plugin)[maps]                                      *plugin-multi-cursor-maps*

	Any mode~

	`<Tab>`             Switch between cursor (like vim normal) and extend mode (like vim visual mode).
	`Q`                 Remove current region.
	`{[,]}`             Previous or next region.
	`<leader><space>`   Toggle (enable or disable) the mappings.
	`s{motion}`         Select a motion.
	`<leader>{n,N}`     add a number at the cursor. The expression is described in |vm-numbering|.
	`<leader>gS`        Re-select last selections

	Cursor mode~

	`<C-{Down,Up}}>`   Add multi cursor above or below the current cursor.
	`<VM_leader>\`     Add a multi cursor in the current vim cursor.
	`|`                set cursors column
	`&`                repeat the substitution
	`<leader><CR>`     Toggle the single cursor mode. Switch between cursors with <Tab> and <S-Tab>.

	Extend mode~

	`<S-{Left,Right}>`     Expand the selection in extend mode.
	`<leader>t`            Swap the content of the selections. Between them.
	`<leader>C`            Case conversion (also supports cammelCase, snake_case, PascalCase, etc.).
	`<M-S-{left,right}>`   Move the selections left and right.

	Some commands allow to start with 'gc' instead of 'c'. This will enable the |vm-smart-case-change|

	Find and replace:~

	`<leader>/`   Use a regex to define the current selection pattern.
	`<C-n>`       Selects words under the cursor and go to extend mode. You can move through them with |vm-find-next|.
	`{n,N}`       Find next or previous pattern.
	`<leader>A`   Selects all the selection patterns and go to extend mode. If there are no match, uses the word under the cursor.
	`R`           Replace a patter in all selections (interactively).
	`<leader>s`   Unselect patter in all regions. Splits if needed.
	`<leader>f`   Unselect all regions that dos not match a regex.

	More power full transformation: |vm-transform|.

	Commands~

	`<leader>x`  run a command at all cursors.
	`<leader>z`  run a :normal command at all cursors.
	`<leader>@`  run a macro at all cursors.
	`<leader>v`  run a command at all visual selections.

	See |vm-run-at-cursors| and |vm-commands|

	Menus~

	*<leader>`*  Some menus. E.g, show lines in quickfix.
	`<leader>"`  Show VM registers

	Other information~

	General mappings: |vm-mappings-qr|
	quick reference with some maps: |vm-quick-reference|
	cursor mode with some maps: |vm-cursor-mode|
	extend mode with some maps: |vm-extend-mode|
	Mouse maps: |vm-mouse-support|

	====================================================================================================
	Multi-cursor commands (Plugin)[cmd]                                   *plugin-multi-cursor-commands*

	`VMSearch`      Selects all matches the range as in extend mode.
	`VMRegisters`   Show the registers and its contents.
]]


return {
	{
		'mg979/vim-visual-multi',

		init = function()
			MYPLUGFUNC.set_keymap_name('\\\\', 'Multi cursor mappings')
			vim.g.VM_leader = '\\\\'  -- Double '\'
			vim.g.VM_mouse_mappings = 1
		end
	}
}
