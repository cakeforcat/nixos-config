{
  config,
  pkgs,
  ...
}: {
  # shell config
  programs = {
    fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting
        starship init fish | source
      '';
      shellAliases = {
        econf = "nvim ~/nixos-config/configuration.nix";
        ehwconf = "nvim ~/nixos-config/hardware-configuration.nix";
        nixit = "source ~/nixos-config/holy-mother-of-scripts.fish";
        nix-fish = "nix-shell --command fish";
      };
    };
    starship = {
      enable = true;
      settings = {
        format = "[](#9A348E)$username[](bg:#DA627D fg:#9A348E)$directory[](fg:#DA627D bg:#FCA17D)$git_branch$git_status[](fg:#FCA17D bg:#86BBD8)$c$elixir$elm$golang$gradle$haskell$java$julia$nodejs$nim$rust$scala[](fg:#86BBD8 bg:#06969A)$docker_context[](fg:#06969A bg:#33658A)$time[ ](fg:#33658A)$nix_shell";
        username = {
          show_always = true;
          style_user = "bg:#9A348E";
          style_root = "bg:#9A348E";
          format = "[$user ]($style)";
          disabled = false;
        };
        directory = {
          style = "bg:#DA627D";
          format = "[ $path ]($style)";
          truncation_length = 4;
          truncation_symbol = "…/";
        };
        directory.substitutions = {
          "Documents" = "󰈙 ";
          "Downloads" = " ";
          "Music" = " ";
          "Pictures" = " ";
        };
        c = {
          symbol = " ";
          style = "bg:#86BBD8";
          format = "[ $symbol ($version) ]($style)";
        };
        cpp = {
          symbol = " ";
          style = "bg:#86BBD8";
          format = "[ $symbol ($version) ]($style)";
        };
        docker_context = {
          symbol = " ";
          style = "bg:#06969A";
          format = "[ $symbol $context ]($style)";
        };
        elixir = {
          symbol = " ";
          style = "bg:#86BBD8";
          format = "[ $symbol ($version) ]($style)";
        };
        elm = {
          symbol = " ";
          style = "bg:#86BBD8";
          format = "[ $symbol ($version) ]($style)";
        };
        git_branch = {
          symbol = "";
          style = "bg:#FCA17D";
          format = "[ $symbol $branch ]($style)";
        };
        git_status = {
          style = "bg:#FCA17D";
          format = "[$all_status$ahead_behind ]($style)";
        };
        golang = {
          symbol = " ";
          style = "bg:#86BBD8";
          format = "[ $symbol ($version) ]($style)";
        };
        gradle = {
          style = "bg:#86BBD8";
          format = "[ $symbol ($version) ]($style)";
        };
        haskell = {
          symbol = " ";
          style = "bg:#86BBD8";
          format = "[ $symbol ($version) ]($style)";
        };
        java = {
          symbol = " ";
          style = "bg:#86BBD8";
          format = "[ $symbol ($version) ]($style)";
        };
        julia = {
          symbol = " ";
          style = "bg:#86BBD8";
          format = "[ $symbol ($version) ]($style)";
        };
        nodejs = {
          symbol = "";
          style = "bg:#86BBD8";
          format = "[ $symbol ($version) ]($style)";
        };
        nim = {
          symbol = "󰆥 ";
          style = "bg:#86BBD8";
          format = "[ $symbol ($version) ]($style)";
        };
        rust = {
          symbol = "";
          style = "bg:#86BBD8";
          format = "[ $symbol ($version) ]($style)";
        };
        scala = {
          symbol = " ";
          style = "bg:#86BBD8";
          format = "[ $symbol ($version) ]($style)";
        };
        time = {
          disabled = false;
          time_format = "%R"; # Hour:Minute Format
          style = "bg:#33658A";
          format = "[ ♥ $time ]($style)";
        };
        nix_shell = {
          disabled = false;
          symbol = " ";
          style = "bg:#33658A";
          format = "[](fg:#33658A)[$symbol]($style)[ ](fg:#33658A)";
        };
      };
    };
  };
}
