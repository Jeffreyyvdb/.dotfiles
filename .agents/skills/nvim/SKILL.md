---
name: nvim
description: "Answer questions about Neovim keymaps, shortcuts, and workflows in a LazyVim + Omarchy setup. Use when the user asks about nvim keybindings, how to do something in neovim, vim shortcuts, navigation, git in nvim, or IDE features. Triggers on: nvim shortcut, neovim keymap, how to in nvim, vim keybinding, lazyvim shortcut."
---

# Neovim (LazyVim + Omarchy) Keymap & Workflow Reference

This skill knows the user's Neovim configuration and can answer questions about keymaps, shortcuts, and IDE workflows.

---

## User's Configuration

- **Base**: LazyVim starter (lazy.nvim plugin manager)
- **Omarchy layer**: Theme hot-reload system, transparency, 14 pre-loaded colorschemes
- **Leader key**: `<Space>`
- **Custom overrides**: Absolute line numbers (relative disabled), no custom keymaps
- **LazyVim extras enabled**: `editor.neo-tree`, `lang.dotnet`
- **Picker**: Snacks.nvim picker (default in LazyVim, NOT Telescope/fzf-lua)
- **Key plugins**: which-key, neo-tree, gitsigns, flash, trouble, snacks, bufferline, lualine, conform, nvim-lint, mason, blink.cmp, noice, grug-far, persistence, todo-comments

---

## How to Discover Keys

| Action | Key |
|---|---|
| Show all keymaps for current mode | `<leader>` then wait (which-key popup) |
| Search all keymaps | `<leader>sk` |
| Open Lazy plugin manager | `<leader>l` |

---

## Complete Keymap Reference

### File Navigation & Finding

| Action | Key | Notes |
|---|---|---|
| Find files (root dir) | `<leader>ff` | Snacks picker |
| Find files (cwd) | `<leader>fF` | |
| Recent files | `<leader>fr` | |
| Recent files (cwd) | `<leader>fR` | |
| New file | `<leader>fn` | |
| File explorer (neo-tree) | `<leader>fe` | Toggle sidebar |
| File explorer (root) | `<leader>fE` | |
| File explorer (focus) | `<leader>e` | Short alias |
| Switch to other buffer | `<leader>bb` or `` <leader>` `` | Alternate file |
| Next buffer | `<S-l>` or `]b` | |
| Previous buffer | `<S-h>` or `[b` | |
| Delete buffer | `<leader>bd` | Snacks bufdelete |
| Delete other buffers | `<leader>bo` | |
| Delete buffer + window | `<leader>bD` | |
| Buffer picker | `<leader>,` | Pick from open buffers |

### Window Management

| Action | Key |
|---|---|
| Go to left window | `<C-h>` |
| Go to lower window | `<C-j>` |
| Go to upper window | `<C-k>` |
| Go to right window | `<C-l>` |
| Increase window height | `<C-Up>` |
| Decrease window height | `<C-Down>` |
| Decrease window width | `<C-Left>` |
| Increase window width | `<C-Right>` |
| Split window below | `<leader>-` |
| Split window right | `<leader>\|` |
| Window management menu | `<leader>w` |

### Tabs

| Action | Key |
|---|---|
| Tab group menu | `<leader><tab>` |
| New tab | `<leader><tab>n` |
| Close tab | `<leader><tab>d` |
| Next tab | `<leader><tab>]` |
| Previous tab | `<leader><tab>[` |
| First tab | `<leader><tab>f` |
| Last tab | `<leader><tab>l` |

### Search & Grep

| Action | Key | Notes |
|---|---|---|
| Live grep (root dir) | `<leader>sg` | Snacks picker |
| Live grep (cwd) | `<leader>sG` | |
| Grep word under cursor (root) | `<leader>sw` | |
| Grep word under cursor (cwd) | `<leader>sW` | |
| Grep visual selection | `<leader>sw` | Visual mode |
| Search in current buffer | `<leader>sb` | |
| Search help pages | `<leader>sh` | |
| Search keymaps | `<leader>sk` | |
| Search registers | `<leader>s"` | |
| Search marks | `<leader>sm` | |
| Search jumplist | `<leader>sj` | |
| Search command history | `<leader>sc` | |
| Search commands | `<leader>sC` | |
| Search diagnostics (document) | `<leader>sd` | |
| Search diagnostics (workspace) | `<leader>sD` | |
| Search highlight groups | `<leader>sH` | |
| Search man pages | `<leader>sM` | |
| Resume last search | `<leader>sR` | |
| Search quickfix list | `<leader>sq` | |
| Search location list | `<leader>sl` | |
| Search auto commands | `<leader>sa` | |

### Find & Replace (grug-far)

| Action | Key |
|---|---|
| Open find & replace | `<leader>sr` |

### LSP / Code Intelligence

| Action | Key | Notes |
|---|---|---|
| Go to definition | `gd` | Snacks picker |
| Go to references | `gr` | |
| Go to implementation | `gI` | |
| Go to type definition | `gy` | |
| LSP symbols (document) | `<leader>ss` | |
| LSP symbols (workspace) | `<leader>sS` | |
| Hover documentation | `K` | |
| Signature help | `<C-k>` | Insert mode |
| Code action | `<leader>ca` | |
| Rename symbol | `<leader>cr` | |
| Format document/selection | `<leader>cf` | conform.nvim |
| Source action | `<leader>cA` | |
| Next diagnostic | `]d` | |
| Previous diagnostic | `[d` | |
| Line diagnostics | `<leader>cd` | |
| Keywordprg | `<leader>K` | |
| Open with system app | `gx` | Opens URLs, files |

### Git

| Action | Key | Notes |
|---|---|---|
| **Lazygit (root dir)** | `<leader>gg` | Full git TUI |
| Lazygit (cwd) | `<leader>gG` | |
| Git log (cwd) | `<leader>gL` | Snacks picker |
| Git log (root) | `<leader>gl` | |
| Git blame line | `<leader>gb` | Snacks picker |
| Git file history | `<leader>gf` | |
| Git browse (open in browser) | `<leader>gB` | Opens GitHub/remote |
| Git browse (copy URL) | `<leader>gY` | |
| **Gitsigns (hunks)** | `<leader>gh` | Hunk submenu |
| Next hunk | `]h` | |
| Previous hunk | `[h` | |
| Last hunk | `]H` | |
| First hunk | `[H` | |
| Stage hunk | `<leader>ghs` | Normal + visual |
| Reset hunk | `<leader>ghr` | Normal + visual |
| Stage entire buffer | `<leader>ghS` | |
| Undo stage hunk | `<leader>ghu` | |
| Reset entire buffer | `<leader>ghR` | |
| Preview hunk inline | `<leader>ghp` | |
| Blame line (full) | `<leader>ghb` | |
| Blame buffer | `<leader>ghB` | |
| Diff this | `<leader>ghd` | |
| Diff this ~ | `<leader>ghD` | Against previous commit |
| Select hunk (text object) | `ih` | Operator/visual mode |

### Diagnostics & Quickfix (Trouble)

| Action | Key |
|---|---|
| Diagnostics/quickfix menu | `<leader>x` |
| Document diagnostics (Trouble) | `<leader>xx` |
| Workspace diagnostics | `<leader>xX` |
| Location list (Trouble) | `<leader>xL` |
| Quickfix list (Trouble) | `<leader>xQ` |
| Next trouble item | `]q` |
| Previous trouble item | `[q` |

### Flash (Motion / Jump)

| Action | Key | Mode |
|---|---|---|
| Flash jump | `s` | Normal, visual, operator |
| Flash treesitter | `S` | Normal, visual, operator |
| Flash remote | `r` | Operator |
| Flash treesitter search | `<C-s>` | Command mode |
| Toggle flash search | `<C-s>` | Normal |

### Editing

| Action | Key | Mode |
|---|---|---|
| Move line down | `<A-j>` | Normal, insert, visual |
| Move line up | `<A-k>` | Normal, insert, visual |
| Better indent (keep selection) | `<` / `>` | Visual |
| Add comment below | `gco` | Normal |
| Add comment above | `gcO` | Normal |
| Toggle comment (line) | `gcc` | Normal |
| Toggle comment (selection) | `gc` | Visual |
| Save file | `<C-s>` | All modes |
| Escape + clear search | `<Esc>` | All modes |

### Surround (mini.surround via `gs` prefix)

| Action | Key | Mode |
|---|---|---|
| Add surround | `gsa` | Normal, visual |
| Delete surround | `gsd` | Normal |
| Replace surround | `gsr` | Normal |
| Find surround (right) | `gsf` | Normal |
| Find surround (left) | `gsF` | Normal |
| Highlight surround | `gsh` | Normal |
| Update surround n_lines | `gsn` | Normal |

### UI & Utilities

| Action | Key |
|---|---|
| Redraw / clear hlsearch | `<leader>ur` |
| Toggle UI options menu | `<leader>u` |
| Open Lazy plugin manager | `<leader>l` |
| Quit all | `<leader>qq` |
| Restore session | `<leader>qs` |
| Restore last session | `<leader>ql` |
| Don't save current session | `<leader>qd` |

### TODO Comments

| Action | Key |
|---|---|
| Next TODO comment | `]t` |
| Previous TODO comment | `[t` |
| Search all TODOs | `<leader>st` |
| TODOs in Trouble | `<leader>xt` |

### Prev / Next Navigation Summary

| What | Previous | Next |
|---|---|---|
| Buffer | `[b` / `<S-h>` | `]b` / `<S-l>` |
| Git hunk | `[h` | `]h` |
| Diagnostic | `[d` | `]d` |
| TODO comment | `[t` | `]t` |
| Trouble item | `[q` | `]q` |
| Search result | `N` | `n` |

---

## Answering User Questions

When the user asks "how do I...":

1. Look up the relevant keymap from the tables above
2. If the action involves multiple steps, describe the workflow
3. Mention which-key (`<leader>` then wait) for discovering related keys
4. If asking about something not in the config (e.g., DAP debugging), note that the extra isn't enabled and explain how to add it via `lazyvim.json`
5. The user's config uses Snacks picker (not Telescope or fzf-lua) -- use the correct keys
6. The user does NOT have any custom keymaps -- everything is LazyVim defaults
7. For git workflows, recommend `<leader>gg` (lazygit) as the primary tool -- it handles staging, committing, branching, rebasing, etc. in a full TUI
