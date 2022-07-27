set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc



" ## Telescope ##

nnoremap <leader>ff <cmd>lua require('telescope.builtin').find_files({ hidden = true })<cr>
nnoremap <leader>ft :Telescope<CR>
nnoremap <leader>fg <cmd>lua require('telescope.builtin').live_grep()<cr>
nnoremap <leader>fb <cmd>lua require('telescope.builtin').buffers()<cr>
nnoremap <leader>fh <cmd>lua require('telescope.builtin').help_tags()<cr>

nnoremap <leader>fvc <cmd>lua require('telescope.builtin').commands()<cr>

" - `<cr>`: checks out the currently selected branch
" - `<C-t>`: tracks currently selected branch
" - `<C-r>`: rebases currently selected branch
" - `<C-a>`: creates a new branch, with confirmation prompt before creation
" - `<C-d>`: deletes the currently selected branch, with confirmation prompt before deletion
nnoremap <leader>gb <cmd>lua require('telescope.builtin').git_branches()<cr>
" - `<Tab>`: stages or unstages the currently selected file
" - `<cr>`: opens the currently selected file
nnoremap <leader>gs <cmd>lua require('telescope.builtin').git_status()<cr>

lua << EOF
local actions = require('telescope.actions')
require('telescope').setup {
    defaults = {
        file_sorter = require('telescope.sorters').get_fzy_sorter,
        file_ignore_patterns = {"node_modules", ".git"},
        color_devicons = true,
        mappings = {
            i = {
                ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
                ["<C-Q>"] = actions.add_to_qflist + actions.open_qflist,
                ["<M-Q>"] = actions.add_selected_to_qflist + actions.open_qflist,
            },
        }
    },
pickers = {
    buffers = {
        show_all_buffers = true,
        sort_lastused = true,
        theme = "dropdown",
        previewer = false,
        mappings = {
            i = {
                ["<c-d>"] = require("telescope.actions").delete_buffer,
                },
            n = {
                ["<c-d>"] = require("telescope.actions").delete_buffer,
                }
            }
        }
    },
    extensions = {
        fzy_native = {
            override_generic_sorter = false,
            override_file_sorter = true,
        }
    }
}

require('telescope').load_extension('fzy_native')
EOF



" ## LSP ##

lua << EOF
local lspconfig = require('lspconfig')
local ts_utils = require("nvim-lsp-ts-utils")


local lsp_opts = { noremap=true, silent=true }

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  --Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', lsp_opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', lsp_opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', lsp_opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', lsp_opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', lsp_opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>lwa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', lsp_opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>lwr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', lsp_opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>lwl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', lsp_opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', lsp_opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>lrn', '<cmd>lua vim.lsp.buf.rename()<CR>', lsp_opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>lca', '<cmd>lua vim.lsp.buf.code_action()<CR>', lsp_opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', lsp_opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', lsp_opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', lsp_opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', lsp_opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>lq', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', lsp_opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>lf", "<cmd>lua vim.lsp.buf.formatting()<CR>", lsp_opts)
end

local ts_utils_settings = {
    -- debug = true,
    enable_import_on_completion = true,
    import_all_scan_buffers = 100,
    eslint_bin = "eslint_d",
    eslint_enable_diagnostics = true,
    enable_formatting = true,
    formatter = "eslint_d",
    update_imports_on_move = true,
}

local flags = { debounce_text_changes = 150, }

-- sudo npm install -g typescript typescript-language-server diagnostic-languageserver eslint_d
lspconfig.tsserver.setup({
    -- cmd = { "typescript-language-server", "--stdio", "--tsserver-path", "/usr/local/bin/tsserver-wrapper" },
    flags,
    on_attach = function(client, bufnr)
        client.resolved_capabilities.document_formatting = false
        on_attach(client, bufnr)

        ts_utils.setup(ts_utils_settings)
        ts_utils.setup_client(client)

        -- Mappings.
        local opts = { noremap=true, silent=true }
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>lgs', ':TSLspOrganize<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>lgI', ':TSLspRenameFile<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>lgo', ':TSLspImportAll<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>qq', ':TSLspFixCurrent<CR>', opts)
    end,
})

-- npm install -g pyright
lspconfig.pyright.setup({
settings = {
    python = {
        analysis = {
            autoSearchPaths = true,
            useLibraryCodeForTypes = true,
            diagnosticMode = 'openFilesOnly',
        },
        venvPath = vim.env.VIRTUAL_ENV
    }
    },
    flags,
    on_attach = function(client, bufnr)
        on_attach(client, bufnr)
    end,
})

-- Don't have a binary for this yet
lspconfig.sumneko_lua.setup {
    -- cmd = {sumneko_binary, "-E", sumneko_root_path .. "/main.lua"};
    on_attach = function(client, bufnr)
        on_attach(client, bufnr)
    end,
    settings = {
        Lua = {
            runtime = {
                -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                version = 'LuaJIT',
                -- Setup your lua path
                path = vim.split(package.path, ';'),
            },
            diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = {'vim'},
            },
            workspace = {
                -- Make the server aware of Neovim runtime files
                library = {
                    [vim.fn.expand('$VIMRUNTIME/lua')] = true,
                    [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
                },
            },
        },
    },
}
EOF


" Disable diagnostics:
" :lua vim.diagnostic.config({virtual_text = false})


" ## Treesitter ##

lua << EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = { "javascript", "bash", "php", "java", "clojure", "elixir", "erlang", "json", "lua", "make", "php", "python", "typescript", "vim", "yaml" }, -- one of "all", "maintained" (parsers with maintainers), or a list of languages
  -- ignore_install = { "javascript" }, -- List of parsers to ignore installing
  highlight = {
    enable = true,              -- false will disable the whole extension
    -- disable = { "c", "rust" },  -- list of language that will be disabled
    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    -- additional_vim_regex_highlighting = false,
  },
  indent = { enable = true },
}
EOF
