{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true; 
    vimAlias = true;
    # wrapRc = true;  <-- 이 줄을 삭제하거나 주석 처리하세요.

    # Lua 라이브러리 추가 (jsregexp 등)
    extraLuaPackages = ps: [ ps.jsregexp ];

    # 1. 플러그인 목록
    plugins = with pkgs.vimPlugins; [
      tokyonight-nvim
      which-key-nvim 
      nvim-web-devicons
      lualine-nvim
      neo-tree-nvim
      nui-nvim 
      plenary-nvim
      telescope-nvim
      nvim-treesitter.withAllGrammars 
      gitsigns-nvim
      indent-blankline-nvim
      bufferline-nvim
      mini-nvim         # mini.icons 등
      oil-nvim          # 파일 관리
      comment-nvim      # 주석
      nvim-autopairs    # 괄호 자동완성
      trouble-nvim      # 에러 목록
      toggleterm-nvim   # 터미널 관리 (Ctrl+/)
      lazygit-nvim      # Lazygit 통합
      nvim-osc52        # SSH 클립보드 (OSC 52) 지원
      
      # LSP & Completion
      nvim-lspconfig
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      luasnip
      cmp_luasnip
      friendly-snippets # 사전 정의된 스니펫 모음
    ];

    # 2. Lua 설정
    extraConfig = "luafile ${./nvim/init.lua}";
  };
}
