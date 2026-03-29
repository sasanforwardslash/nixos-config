{ config, pkgs, ... }:
{
  home.username = "sasan";
  home.homeDirectory = "/home/sasan";
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;
  home.sessionVariables = {
    SOPS_AGE_KEY_FILE = "/home/sasan/.config/sops/age/keys.txt";
  };

  # --- Packages ---
  home.packages = with pkgs; [
    ripgrep
    fzf
    fd
    bat
    eza
    htop
    age
    ssh-to-age
    sops
  ];

  # --- Git ---
  programs.git = {
    enable = true;
		signing.format = null;
    settings = {
      user.name = "sasanforwardslash";
      user.email = "17885066+sasanforwardslash@users.noreply.github.com";
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
    };
  };

  # --- Zsh ---
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    history = {
      size = 10000;
      ignoreDups = true;
    };
    shellAliases = {
      ls = "eza";
      ll = "eza -la";
      cat = "bat";
      grep = "rg";
      rebuild = "sudo nixos-rebuild switch --flake ~/nixos-config#silco";
    };
  };

  # --- NeoVim ---
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    extraConfig = ''
      set number
      set relativenumber
      set tabstop=2
      set shiftwidth=2
      set expandtab
      set clipboard=unnamedplus
    '';
    plugins = with pkgs.vimPlugins; [
      editorconfig-nvim
    ];
  };
}

