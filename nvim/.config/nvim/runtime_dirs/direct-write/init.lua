-- If the `vim.o.backupcopy` option is `no`, the backup is made by rename the file and writing to a new one. Software that tracks changes to
-- files may have issues when the file is renamed or moved. Changing this option to 'yes' makes Neovim writes directly to the file when
-- saving it, avoiding this issue

vim.o.backupcopy = 'yes'
