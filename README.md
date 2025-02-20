# codegate.nvim

CodeGate.nvim is a Neovim plugin that interfaces with CodeGate—a secure local gateway for AI code generation that ensures best practices and protects your code and privacy.

## Overview

This plugin allows you to:
- **List Workspaces:** Display available workspaces from your CodeGate API.
- **Activate Workspaces:** Set an active workspace.
- **Telescope Integration:** Use a fuzzy finder to select workspaces (if [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) is installed).

## Installation

Using **lazy.nvim**, you can use the following code snippet to install and configure **codegate.nvim**:

```lua
{
  "stacklok/codegate.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  lazy = false,
  config = function()
    require("codegate").setup({
      base_url = "http://127.0.0.1:8989",
    })
  end,
}
```

## Usage

- **List Workspaces**: Run `:CodeGateListWorkspaces` to display available workspaces.
- **Activate a Workspace**: Run `:CodeGateSetWorkspace <workspace>` to activate a specific workspace.
- **Telescope Picker**: If **telescope.nvim** is installed, run `:CodeGateTelescopeWorkspaces` to open a fuzzy search picker.

## Creating keymaps

To work with CodeGate workspaces more efficiently, you can set up your own keymaps to
switch between workspaces. Here are a few ideas that can help you get started!

**Use a fuzzy finder to switch between workspaces**

```lua
vim.api.nvim_set_keymap('n', '<leader>cgg', ':CodeGateTelescopeWorkspaces<CR>', { noremap = true, silent = true })
```

**Switch to a specific workspace with a fixed shortcut**

```lua
vim.api.nvim_set_keymap('n', '<leader>cga', ':CodeGateSetWorkspace default<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>cgs', ':CodeGateSetWorkspace integration-testing<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>cgd', ':CodeGateSetWorkspace react-implementation<CR>', { noremap = true, silent = true })
```

**Switch to a specific workspace by typing the workspace name**

```lua
vim.api.nvim_set_keymap('n', '<leader>cgq', ':CodeGateSetWorkspace ', { noremap = true, silent = false }) -- notice `silent = false`
```

