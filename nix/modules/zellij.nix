{ config, pkgs, ... }:

{
  programs.zellij = {
    enable = true;
    
    settings = {
      theme = "cyber-blue";
      default_layout = "default";
      pane_frames = true;
      simplified_ui = false;
      mirror_session_to_terminal_title = true;

      keybinds = {
        unbind = [ "Ctrl b" "Ctrl h" ];
        
        normal = {
          "bind \"Ctrl g\"" = { SwitchToMode = "Locked"; };
        };
        locked = {
          "bind \"Ctrl g\"" = { SwitchToMode = "Normal"; };
        };

        tab = {
          unbind = [ "x" ];
          "bind \"Ctrl x\"" = {
            CloseTab = { };
            SwitchToMode = "Normal";
          };
        };

        shared_except = {
          _args = [ "locked" ];
          "bind \"Alt h\"" = { MoveFocusOrTab = "Left"; };
          "bind \"Alt l\"" = { MoveFocusOrTab = "Right"; };
          "bind \"Alt j\"" = { MoveFocus = "Down"; };
          "bind \"Alt k\"" = { MoveFocus = "Up"; };
          "bind \"Alt =\"" = { Resize = "Increase"; };
          "bind \"Alt -\"" = { Resize = "Decrease"; };
          "bind \"Alt n\"" = { NewPane = "Right"; };
          "bind \"Alt i\"" = { MoveTab = "Left"; };
          "bind \"Alt o\"" = { MoveTab = "Right"; };
        };
      };

      themes = {
        cyber-blue = {
          fg = [ 192 202 245 ];
          bg = [ 26 27 38 ];       # Calm navy/black background
          black = [ 21 22 30 ];
          red = [ 247 118 142 ];
          
          # Zellij uses 'green' as the normal mode border color.
          # Replaced original yellow/green with a cool blue cyber theme.
          green = [ 122 162 247 ]; 
          
          # Mapped shortcut bar elements (usually yellow/orange) 
          # to Cyan and Magenta to eliminate discordant yellows.
          yellow = [ 125 207 255 ];
          blue = [ 122 162 247 ];
          magenta = [ 187 154 247 ];
          cyan = [ 125 207 255 ];
          white = [ 169 177 214 ];
          orange = [ 187 154 247 ];
        };
      };

      mouse_mode = true;
      copy_on_select = true;
      copy_clipboard = "system";
      copy_command = ""; # 강제 복사 명령어를 비워두어야 SSH 환경에서 OSC 52 패스스루가 정상 작동함
    };
  };
}
