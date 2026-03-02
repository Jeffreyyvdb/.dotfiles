# Neovim as a Full IDE -- Workflow Guide

Your setup: **LazyVim + Omarchy** on Arch Linux.
Leader key: **Space**. All keymaps below use LazyVim defaults.

> Tip: Press `<Space>` and wait -- **which-key** will show you every available action grouped by category. This is the single most useful thing to remember.

---

## 1. Getting Oriented

### First thing to do in any session
Press `<Space>` and read the which-key popup. The groups are:
- `b` = buffer, `c` = code, `d` = debug, `f` = file/find, `g` = git
- `q` = quit/session, `s` = search, `u` = ui, `x` = diagnostics
- `w` = windows, `<tab>` = tabs, `l` = Lazy plugin manager

### Find any keymap
`<Space>sk` -- fuzzy search through all registered keymaps. Type what you're looking for (e.g., "rename", "blame", "format") and it'll show you the binding.

### Open plugin manager
`<Space>l` -- opens Lazy. Here you can see installed plugins, update them, check for issues, and profile startup time.

---

## 2. File Navigation

### Finding files
| What you want | Keys |
|---|---|
| Find file by name | `<Space>ff` |
| Find file by name (from cwd, not project root) | `<Space>fF` |
| Open a recent file | `<Space>fr` |
| Create a new empty file | `<Space>fn` |

The picker uses fuzzy matching. Type fragments of the path: `cont user` will match `src/controllers/userController.ts`.

### File explorer (Neo-tree)
| What you want | Keys |
|---|---|
| Toggle file tree sidebar | `<Space>e` or `<Space>fe` |
| Open file tree at project root | `<Space>fE` |

Inside Neo-tree:
- `a` = create new file/directory (add `/` suffix for directory)
- `d` = delete
- `r` = rename
- `c` = copy
- `m` = move
- `y` = copy filename
- `Y` = copy relative path
- `/` = filter/search
- `H` = toggle hidden files
- `Enter` or `o` = open file
- `s` = open in horizontal split
- `S` = open in vertical split
- `P` = preview (without leaving tree)
- `<` / `>` = navigate up/down in source (files, buffers, git)

### Switching between open files (buffers)
| What you want | Keys |
|---|---|
| Next buffer | `Shift+L` |
| Previous buffer | `Shift+H` |
| Pick from open buffers | `<Space>,` |
| Switch to last file (alternate) | `` <Space>` `` |
| Close current buffer | `<Space>bd` |
| Close all other buffers | `<Space>bo` |

The **bufferline** at the top shows all open buffers. `Shift+H/L` cycles through them like tabs.

---

## 3. Code Navigation (LSP)

Your config has `.NET/C#` language support enabled (OmniSharp). LSP keymaps work for any language with a configured server.

| What you want | Keys | Notes |
|---|---|---|
| **Go to definition** | `gd` | Jump to where a symbol is defined |
| **Go to references** | `gr` | See everywhere a symbol is used |
| Go to implementation | `gI` | Jump to interface implementation |
| Go to type definition | `gy` | Jump to the type of a variable |
| **Hover docs** | `K` | Show documentation popup |
| **Code actions** | `<Space>ca` | Quick fixes, refactors, imports |
| **Rename symbol** | `<Space>cr` | Rename across all files |
| Line diagnostics | `<Space>cd` | Show error/warning on current line |
| Document symbols | `<Space>ss` | Outline of current file |
| Workspace symbols | `<Space>sS` | Search symbols across project |

### Jumping back and forth
After using `gd` to jump to a definition, use `<C-o>` (Ctrl+O) to jump back. `<C-i>` (Ctrl+I) jumps forward. This is the standard Vim jumplist.

### Flash (fast motion)
Flash replaces the traditional `f`/`t` motions with a much more powerful system:
- Press `s` + type 1-2 characters = highlights all matches, press the label letter to jump
- Press `S` = treesitter-aware selection (expand selection by syntax node)

This is the fastest way to jump to any visible location.

---

## 4. Editing Efficiently

### Moving lines
Select lines in visual mode (`V` for linewise), then:
- `Alt+j` = move selection down
- `Alt+k` = move selection up

Works in normal mode too (moves current line).

### Commenting
| What you want | Keys |
|---|---|
| Comment/uncomment line | `gcc` |
| Comment/uncomment selection | `gc` (in visual mode) |
| Add comment line below | `gco` |
| Add comment line above | `gcO` |

### Indenting
In visual mode, `<` and `>` indent/dedent and **keep the selection** so you can press multiple times.

### Surround
| What you want | Keys | Example |
|---|---|---|
| Add surround | `gsa` + motion + char | `gsaiw"` surrounds word with `"` |
| Delete surround | `gsd` + char | `gsd"` removes surrounding `"` |
| Replace surround | `gsr` + old + new | `gsr"'` changes `"` to `'` |

### Completion (blink.cmp)
Completion appears automatically as you type. Use:
- `<Tab>` / `<S-Tab>` = navigate completion menu
- `<Enter>` = accept
- `<C-Space>` = trigger completion manually
- `<C-e>` = dismiss

### Undo
Vim has **undo trees**, not just linear undo. LazyVim also inserts undo break-points at `,` `.` `;` so undoing in insert mode is more granular.
- `u` = undo
- `<C-r>` = redo

---

## 5. Search & Replace

### Project-wide grep
| What you want | Keys |
|---|---|
| Live grep (type and see results) | `<Space>sg` |
| Grep word under cursor | `<Space>sw` |
| Grep visual selection | `<Space>sw` (visual mode) |
| Search in current buffer only | `<Space>sb` |

### Find and replace (grug-far)
`<Space>sr` opens **grug-far**, a powerful find-and-replace UI:
1. Type search pattern in the search field
2. Type replacement in the replace field
3. Results update live
4. You can include/exclude paths with globs
5. Apply replacements per-line or all at once

This is the equivalent of VS Code's "Search and Replace" in the sidebar.

### In-file search
- `/` = search forward (then `n`/`N` to navigate results)
- `?` = search backward
- `*` = search for word under cursor
- `<Esc>` clears search highlighting

---

## 6. Git Workflow

### Lazygit (the main git tool)
`<Space>gg` opens **lazygit** -- a full terminal git UI inside Neovim. This is your primary git tool. Inside lazygit:

- **Navigation**: `1-5` switches panels (Status, Files, Branches, Commits, Stash)
- **Staging**: `<Space>` to stage/unstage a file, `a` to stage all
- **Committing**: `c` to commit, `C` to commit with editor
- **Branching**: `n` for new branch, `<Space>` to checkout
- **Pushing/Pulling**: `P` to push, `p` to pull
- **Rebasing**: `r` on a commit for rebase options
- **Stashing**: `s` to stash, `g` to pop stash
- **Diffing**: navigate to file and press `Enter` to see diff
- **Log**: navigate to Commits panel to see git log
- `?` shows all keybindings within lazygit
- `q` or `<Esc>` to close

### Inline git (gitsigns)
Without leaving your code:

| What you want | Keys |
|---|---|
| See what changed (next hunk) | `]h` |
| See what changed (prev hunk) | `[h` |
| Stage this hunk | `<Space>ghs` |
| Undo staging this hunk | `<Space>ghu` |
| Reset hunk (discard changes) | `<Space>ghr` |
| Stage entire file | `<Space>ghS` |
| Preview hunk inline | `<Space>ghp` |
| Blame current line | `<Space>ghb` |
| Blame entire buffer | `<Space>ghB` |
| Diff this file | `<Space>ghd` |

### Git log & browse
| What you want | Keys |
|---|---|
| Git log (full project) | `<Space>gl` |
| Git log (cwd) | `<Space>gL` |
| Current file history | `<Space>gf` |
| Blame current line (picker) | `<Space>gb` |
| Open file on GitHub | `<Space>gB` |
| Copy GitHub URL | `<Space>gY` |

### Typical git workflow in Neovim
1. Edit files normally
2. `]h` / `[h` to review your changes hunk by hunk
3. `<Space>ghp` to preview each hunk inline
4. `<Space>gg` to open lazygit
5. Stage, commit, push -- all inside lazygit
6. `q` to close lazygit and continue coding

---

## 7. Diagnostics & Errors

### Quick navigation
- `]d` = jump to next error/warning
- `[d` = jump to previous error/warning
- `<Space>cd` = show diagnostic details for current line

### Trouble (diagnostics panel)
| What you want | Keys |
|---|---|
| Document diagnostics | `<Space>xx` |
| Workspace diagnostics | `<Space>xX` |
| Quickfix list | `<Space>xQ` |
| Location list | `<Space>xL` |
| All TODOs | `<Space>xt` |

Trouble provides a structured list of all errors, warnings, and TODOs. Navigate with `]q`/`[q` to jump between items.

### Fixing errors
1. `]d` to jump to the error
2. `K` to read the error message
3. `<Space>ca` to see if there's an auto-fix (code action)
4. If it's a formatting issue, `<Space>cf` to auto-format

---

## 8. Terminal

Snacks.nvim provides terminal integration:
- `<C-/>` = toggle floating terminal
- `<C-_>` = toggle floating terminal (alternate)

In terminal mode:
- `<Esc><Esc>` = exit terminal mode (back to normal mode)
- You can run any shell command, then close with `<C-/>` again

---

## 9. Windows & Splits

### Creating splits
| What you want | Keys |
|---|---|
| Horizontal split | `<Space>-` |
| Vertical split | `<Space>\|` |

### Navigating splits
`Ctrl+h/j/k/l` moves between windows (left/down/up/right). This is the fastest way.

### Resizing
`Ctrl+Arrow` keys resize the current window.

### All window operations
`<Space>w` opens the which-key window menu, which proxies all `Ctrl+W` commands. Some useful ones:
- `<Space>w=` = equalize window sizes
- `<Space>wo` = close all other windows
- `<Space>wq` = close window

---

## 10. Sessions

LazyVim includes **persistence.nvim** for session management. When you open Neovim in a project directory, it can restore your last session (open files, window layout, cursor positions).

| What you want | Keys |
|---|---|
| Restore session for current dir | `<Space>qs` |
| Restore last session | `<Space>ql` |
| Stop saving current session | `<Space>qd` |
| Quit all | `<Space>qq` |

---

## 11. Theme Switching (Omarchy)

Your config includes 14 colorschemes and the omarchy hot-reload system. To switch themes:

```bash
# From the terminal (outside Neovim)
omarchy-theme-set catppuccin
omarchy-theme-set tokyo-night
omarchy-theme-set nord
omarchy-theme-set gruvbox
omarchy-theme-set kanagawa
omarchy-theme-set rose-pine
omarchy-theme-set everforest
omarchy-theme-set hackerman
omarchy-theme-set ethereal
omarchy-theme-set matte-black
omarchy-theme-set flexoki-light
```

This changes the theme across your entire system (terminal, Hyprland, Neovim, VS Code, Waybar). Neovim picks up the change via the hot-reload plugin.

Inside Neovim, you can also:
- `:colorscheme catppuccin` to temporarily switch (resets on restart)
- `<Space>uC` to pick a colorscheme interactively

Transparency is forced by `plugin/after/transparency.lua` -- all backgrounds are transparent regardless of theme.

---

## 12. Formatting & Linting

| What you want | Keys |
|---|---|
| Format file/selection | `<Space>cf` |
| Format on save | Enabled by default via conform.nvim |

Formatting is handled by **conform.nvim**. Linting is handled by **nvim-lint**. Both are configured through Mason (`<Space>cm` to open Mason, or `:Mason`).

To install a formatter or linter:
1. `:Mason` to open the installer
2. Search for the tool (e.g., `stylua`, `prettier`, `eslint`)
3. Press `i` to install

---

## 13. Tips & Tricks

### Repeat last action
`.` repeats the last edit. This works with most operations including surround, commenting, and complex edits.

### Text objects
LazyVim enhances text objects with **mini.ai**:
- `va"` = select around quotes
- `vi(` = select inside parentheses
- `vaf` = select around function
- `vic` = select inside class
- `daf` = delete around function
- `cic` = change inside class

### Marks
- `ma` = set mark `a` at cursor
- `` `a `` = jump to mark `a`
- `<Space>sm` = search all marks

### Macros
- `qa` = start recording macro into register `a`
- `q` = stop recording
- `@a` = replay macro `a`
- `@@` = replay last macro

### Multi-file editing with quickfix
1. `<Space>sg` to grep across project
2. Select results you want to edit
3. Send to quickfix with `<C-q>` (in picker)
4. `:cdo s/old/new/g` to apply replacement across all quickfix files
5. `:wall` to save all

### Command mode
- `:w` = save
- `:q` = quit
- `:wq` or `ZZ` = save and quit
- `:qa` = quit all
- `:e filename` = open file
- `:vs filename` = open in vertical split
- `:sp filename` = open in horizontal split

---

## Quick Reference Card

The essentials to memorize first:

```
NAVIGATE          EDIT              CODE              GIT
<Space>ff  find   gcc    comment    gd   go to def    <Space>gg  lazygit
<Space>e   tree   gsa    surround   gr   references   ]h [h      hunks
<Space>,   bufs   <A-j>  move line  K    hover docs   <Space>ghs stage
Shift-H/L  prev/  <C-s>  save       <Space>ca action <Space>ghp preview
           next   u      undo       <Space>cr rename  <Space>ghb blame

SEARCH            WINDOWS           DIAGNOSTICS
<Space>sg  grep   <C-h/j/k/l> move  ]d [d     next/prev
<Space>sr  repl   <Space>-    hsplit <Space>xx trouble
<Space>sk  keys   <Space>|    vsplit <Space>ca fix

REMEMBER: Press <Space> and wait for which-key!
```
