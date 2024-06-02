# Empty Neovim plugin repository

This folder acts as a real Neovim plugin repository, but does not load any files.
Its is useful for creating a fake plugin repository to execute some functions and commands as if it were real Neovim plugins.

Example for Lazy.nvim:

```lua
return {
    {
        {
            name = 'my-plugin-without-repository',
            lazy = false,

            -- If *dir* is provided, the plugin will be load from a local directory instead from the internet (with git).
            -- To this plugin, the *dir* is pointing to a folder without a plugin installed. This makes creates a plugin that
            -- does not load any files, but act as an real plugin and executes the *init* function.
            dir = '~/.config/nvim/empty_plugin/',

            init = function()
                -- Function executed when the plugin is initialized.
            end
        },
    }
}
```
