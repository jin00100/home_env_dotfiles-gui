      -- 안전한 설정을 위한 헬퍼 함수
      local function safe_require(module, config_fn)
        local ok, mod = pcall(require, module)
        if ok then config_fn(mod) end
      end

      -- [기본 옵션]
      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.opt.tabstop = 4
      vim.opt.shiftwidth = 4
      vim.opt.expandtab = true
      vim.g.mapleader = " "         
      vim.opt.clipboard = "unnamedplus"
      vim.opt.termguicolors = true

      -- [OSC 52 클립보드 설정 (SSH 환경용)]
      safe_require("osc52", function(osc52)
        osc52.setup({
          max_length = 0,      -- 텍스트 길이 제한 없음
          silent = false,      -- 복사 시 메시지 표시 여부
          trim = false,        -- 텍스트 앞뒤 공백 제거 여부
          tmux_passthrough = true, -- Zellij/Tmux를 뚫고 Windows 터미널까지 복사 신호를 전달
        })
        
        -- yank 이벤트를 감지하여 OSC 52 신호 전송
        local function copy()
          if vim.v.event.operator == "y" and vim.v.event.regname == "" then
            osc52.copy_register("+")
          end
        end
        
        vim.api.nvim_create_autocmd('TextYankPost', {
          callback = copy,
        })
      end)

      vim.opt.laststatus = 3        -- 전역 상태줄 (Global Statusline)
      vim.opt.cmdheight = 1         -- 커맨드 라인 높이 유지

      -- [Navigation]
      vim.keymap.set('n', '<M-h>', '<C-w>h')
      vim.keymap.set('n', '<M-j>', '<C-w>j')
      vim.keymap.set('n', '<M-k>', '<C-w>k')
      vim.keymap.set('n', '<M-l>', '<C-w>l')

      -- [테마 설정]
      safe_require("tokyonight", function(tokyonight)
        tokyonight.setup({
          style = "moon", -- storm, night, moon, day
          transparent = true,
          styles = {
            sidebars = "transparent",
            floats = "transparent",
          },
        })
        vim.cmd.colorscheme "tokyonight"
      end)

      -- [Lualine 설정]
      safe_require("lualine", function(lualine)
        lualine.setup { options = { theme = 'tokyonight' } }
      end)

      -- [Bufferline 설정]
      safe_require("bufferline", function(bufferline)
        bufferline.setup{}
      end)

      -- [Gitsigns 설정]
      safe_require("gitsigns", function(gitsigns)
        gitsigns.setup()
      end)

      -- [Indent Blankline 설정]
      safe_require("ibl", function(ibl)
        ibl.setup()
      end)

      -- [Oil.nvim 설정]
      safe_require("oil", function(oil)
        oil.setup()
        vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
      end)

      -- [Comment.nvim 설정]
      safe_require("Comment", function(comment)
        comment.setup()
      end)

      -- [nvim-autopairs 설정]
      safe_require("nvim-autopairs", function(autopairs)
        autopairs.setup()
      end)

      -- [Trouble 설정]
      safe_require("trouble", function(trouble)
        vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>")
      end)

      -- [ToggleTerm 설정]
      safe_require("toggleterm", function(toggleterm)
        toggleterm.setup({
          open_mapping = [[<C-/>]], -- Ctrl+/ (일부 터미널에서는 <C-_>)
          direction = 'float',      -- float, horizontal, vertical 중 선택 가능
          float_opts = {
            border = 'curved',
          }
        })
        -- Ctrl+/ 와 Ctrl+_ 모두 매핑 (터미널 호환성)
        vim.keymap.set({'n', 't'}, '<C-/>', '<cmd>ToggleTerm<cr>', {desc = "Toggle terminal"})
        vim.keymap.set({'n', 't'}, '<C-_>', '<cmd>ToggleTerm<cr>', {desc = "Toggle terminal"})
        
        -- 터미널 모드 전용 키맵
        function _G.set_terminal_keymaps()
          -- 터미널 모드에서 Esc를 눌렀을 때 노멀 모드로 전환하고 싶다면 아래 주석을 해제하세요.
          -- 하지만 lazygit 등에서 Esc를 써야 할 경우가 많으므로 기본적으로는 매핑하지 않습니다.
          -- local opts = {buffer = 0}
          -- vim.keymap.set('t', '<Esc><Esc>', [[<C-\><C-n>]], opts)
        end
        vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')
      end)

      -- [Lazygit 설정]
      safe_require("lazygit", function(lazygit)
        vim.keymap.set("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "Open LazyGit" })
      end)

      -- [Neo-tree 설정]
      safe_require("neo-tree", function(neotree)
        neotree.setup({
          close_if_last_window = true,
          filesystem = {
            follow_current_file = {
              enabled = true,
            },
            use_libuv_file_watcher = true,
          },
          window = {
            width = 30,
            mappings = {
              ["<space>"] = "none",
            }
          }
        })
      end)

      -- [Mini.icons 설정]
      safe_require("mini.icons", function(icons)
        icons.setup()
        icons.mock_nvim_web_devicons()
      end)

      -- [Luasnip 경고 무시 및 jsregexp 설정]
      -- Nix에서 라이브러리를 직접 빌드하기 힘드므로 특정 기능에 대한 경고를 우회합니다.
      safe_require("luasnip", function(luasnip)
        luasnip.config.set_config({
          history = true,
          updateevents = "TextChanged,TextChangedI",
          delete_check_events = "TextChanged",
        })
        -- friendly-snippets (VSCode 포맷) 로드
        require("luasnip.loaders.from_vscode").lazy_load()
      end)

      -- [Neo-tree 키맵]
      vim.keymap.set('n', '<C-n>', ':Neotree toggle<CR>', { silent = true })

      -- [Telescope 키맵]
      safe_require("telescope.builtin", function(builtin)
        vim.keymap.set('n', '<leader>f', builtin.find_files, { desc = "Find files" })
        vim.keymap.set('n', '<leader>g', builtin.live_grep, { desc = "Live grep (text search)" })
        vim.keymap.set('n', '<leader>ss', builtin.spell_suggest, { desc = "Spell suggest" })
        
        -- [LSP 심볼/인덱싱 검색]
        vim.keymap.set('n', '<leader>s', builtin.lsp_document_symbols, { desc = "Current file symbols (Outline)" })
        vim.keymap.set('n', '<leader>S', builtin.lsp_dynamic_workspace_symbols, { desc = "Project-wide symbols" })
        vim.keymap.set('n', '<leader>d', builtin.lsp_definitions, { desc = "Go to definition" })
        vim.keymap.set('n', '<leader>r', builtin.lsp_references, { desc = "Find references" })
        vim.keymap.set('n', '<leader>i', builtin.lsp_implementations, { desc = "Go to implementation" })
      end)

      -- [Treesitter 설정]
      safe_require("nvim-treesitter.configs", function(configs)
        configs.setup {
          highlight = { enable = true },
          indent = { enable = true },
        }
      end)

      -- [진단(Diagnostics) 설정 UI 개선]
      vim.diagnostic.config({
        virtual_text = {
          prefix = '●', -- 오류 앞에 표시될 아이콘
          severity_sort = true,
        },
        signs = true,    -- 왼쪽 숫자 옆에 아이콘 표시
        underline = true, -- 오류 부분에 밑줄 표시
        update_in_insert = false,
        severity_sort = true,
        float = {
          border = 'rounded',
          source = 'always', -- 어느 LSP에서 보낸 에러인지 표시
        },
      })

      -- 진단 관련 아이콘 설정 (Sign Column)
      local signs = { Error = "󰅚 ", Warn = "󰀪 ", Hint = "󰌶 ", Info = "󱩎 " }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
      end

      -- 진단 상세 보기 단축키
      vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = "Show line diagnostics" })
      vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic" })
      vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = "Go to next diagnostic" })

      -- [LSP & Autocomplete 설정]
      local cmp_ok, cmp = pcall(require, "cmp")
      if cmp_ok then
        cmp.setup({
          snippet = { expand = function(args) require('luasnip').lsp_expand(args.body) end },
          mapping = cmp.mapping.preset.insert({
            ['<C-b>'] = cmp.mapping.scroll_docs(-4),
            ['<C-f>'] = cmp.mapping.scroll_docs(4),
            ['<C-Space>'] = cmp.mapping.complete(),
            ['<CR>'] = cmp.mapping.confirm({ select = true }),
          }),
          sources = cmp.config.sources({
            { name = 'nvim_lsp' },
            { name = 'luasnip' },
          }, {
            { name = 'buffer' },
            { name = 'path' },
          })
        })
      end

      -- [LSP & Autocomplete 설정 (Modern 0.11+)]
      local capabilities = {}
      local cmp_lsp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
      if cmp_lsp_ok then
        capabilities = cmp_nvim_lsp.default_capabilities()
      end

      -- 사용 중인 언어 서버들 목록 (packages.nix에 설치된 것들)
      local servers = { 'gopls', 'nil_ls', 'yamlls', 'bashls', 'dockerls' }

      -- Neovim 0.11+ 방식 (vim.lsp.config)
      if vim.lsp.config then
        for _, lsp in ipairs(servers) do
          vim.lsp.config(lsp, { capabilities = capabilities })
          vim.lsp.enable(lsp)
        end
        -- clangd 전용 안전 설정
        vim.lsp.config('clangd', {
          capabilities = capabilities,
          cmd = {
            "clangd",
            "--offset-encoding=utf-16",
          }
        })
        vim.lsp.enable('clangd')
      else
        -- Fallback: Neovim 0.10.x 이하 (nvim-lspconfig)
        local lsp_ok, lspconfig = pcall(require, "lspconfig")
        if lsp_ok then
          for _, lsp in ipairs(servers) do
            lspconfig[lsp].setup { capabilities = capabilities }
          end
        end
      end

      -- [YAML 전용 설정 (DevOps 추천)]
      vim.api.nvim_create_autocmd("FileType", {
        pattern = {"yaml", "yml"},
        callback = function()
          vim.opt_local.autoindent = true
          vim.opt_local.smartindent = true
          vim.opt_local.expandtab = true
          vim.opt_local.tabstop = 2
          vim.opt_local.shiftwidth = 2
          vim.opt_local.number = true
          -- filetype plugin indent on 은 Neovim에서 기본적으로 활성화되어 있으므로 생략 가능합니다.
        end,
      })