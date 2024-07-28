vim.opt.spell = true
vim.opt.spelllang = 'en_us'
vim.opt.spellfile = MYPATHS.config .. 'spell_adds/main.UTF-8.add'
vim.opt.complete:append('k')

-- Local dictionaries and thesaurus
vim.opt.dictionary:append('.vim/local_dictionary')
vim.opt.dictionary:append('.local_dictionary')
vim.opt.thesaurus:append('.vim/local_thesaurus')
vim.opt.thesaurus:append('.local_thesaurus')
