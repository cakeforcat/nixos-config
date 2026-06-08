#!/usr/bin/env fish
# A rebuild script that commits on a successful build
# the approach for tracking the nixos configuration files I used to use was symlinks.
# one of the sources below shows how. since then I decided to mercilessly kill nix-channels
# and use npins to pin my nixpkgs version. I now explicitly pass the nixos-config to the rebuild script.
# see below for more on that, npins and more. Especially relevant is my comment on nixos forum (last link at the bottom)
# sources:
# https://gist.github.com/0atman/1a5133b842f929ba4c1e195ee67599d5
# https://nixos-and-flakes.thiscute.world/nixos-with-flakes/other-useful-tips#managing-the-configuration-with-git
# https://github.com/JustCoderdev/dotfiles/blob/nixos-compliant/nixos/modules/system/bin/rebuild-system/rebuild-system.sh
# https://stackoverflow.com/questions/11023929/using-the-alternate-screen-in-a-bash-script
# dependencies:
# - fish
# - git
# - jq (for parsing JSON)
# - nixfmt
# - notify-send (for notifications)
# - ripgrep (for checking rebuild log)
#
# hello npins!
# https://github.com/andir/npins
# https://jade.fyi/blog/pinning-nixos-with-npins/
# https://piegames.de/dumps/pinning-nixos-with-npins-revisited/
# https://discourse.nixos.org/t/pinning-nixos-with-npins/63721/10
#
# https://cakeforcat.dev/blog/npins.html

# some script arguments
set -l options (fish_opt -s h -l help)
set options $options (fish_opt -o -s e -l edit)
set options $options (fish_opt -s b -l boot)
set options $options (fish_opt -s u -l update)
set options $options (fish_opt -s p -l push)
set options $options (fish_opt -s f -l force)
set options $options (fish_opt -s c -l clean)
set options $options (fish_opt -s s -l system)

argparse --exclusive "boot,push" $options -- $argv

set -g absolute_nixos_config_path "/home/$USER/nixos-config"

if set -q _flag_boot
    set -g rebuild_type "boot"
else
    set -g rebuild_type "switch"
end

function exit_with_notification -a message
    if test "$PWD" = "$absolute_nixos_config_path"
        popd
    end
    notify-send --transient --icon=software-update-urgent --app-name=NIXIT "NIXIT Failed: $message"
    echo $message
    exit 1
end

function push_to_remote
    echo "Pushing changes to remote repository..."
    if not git push -u origin main
        exit_with_notification "Failed to push changes to remote repository."
    else
        echo "Changes pushed successfully."
    end
end

function update_npins
    echo "Updating npins"
    npins update
end

function edit_config
    if set -q _flag_edit[1]
        if not test -f $_flag_edit
            exit_with_notification "File $_flag_edit does not exist."
        end
        $EDITOR $_flag_edit
    else
        $EDITOR configuration.nix
    end
end

function autoformat
    if not nixfmt -q *.nix # noooo dont touch my submodules
        exit_with_notification "Nixfmt formatting failed"
    end
end

function show_diff
    git diff -U0
end

function fancy_rebuild -a type metatask
    echo $metatask

    # grab the latest nixpkgs path
    set -l nixpkgs_path (nix-instantiate --json --eval npins/default.nix -A nixpkgs.outPath | jq -r .)

    # move to alt terminal buffer
    tput smcup
    clear
    echo $metatask

    # REBUILD
    sudo nixos-rebuild $type -I nixos-config=$absolute_nixos_config_path/configuration.nix -I nixpkgs=$nixpkgs_path --show-trace 2>&1 | tee rebuild.log

    # exit slowly
    echo "Rebuild completed"
    echo "Exit in 3..."
    sleep 1
    echo "Exit in 2..."
    sleep 1
    echo "Exit in 1..."
    sleep 1
    tput rmcup
end

function check_rebuild
    # check if the rebuild was successful
    if not rg --quiet "Done. The new configuration is " rebuild.log
        echo "Rebuild failed, exiting."
        return 1
        # exit_with_notification "Check rebuild.log for details."
    end
    if rg --quiet "SIGKILL" rebuild.log
        echo "Rebuild was killed (probably out of memory), exiting."
        return 1
        # exit_with_notification "Check rebuild.log for details."
    end
end

function commit_build
    echo "Rebuild successful, committing changes..."
    set -l curr_json (nixos-rebuild list-generations --json | jq -r '.[] | select (.current == true)')
    set -l curr_generation (echo $curr_json | jq -r '"\(.generation)"')
    # set -l curr_date (echo $curr_json | jq -r '"\(.date)"')
    set -l curr_nixos (echo $curr_json | jq -r '"\(.nixosVersion)"')
    set -l curr_nixos_major (echo $curr_nixos | string split -f "1,2" . | string join .)
    set -l curr_kernel (echo $curr_json | jq -r '"\(.kernelVersion)"')
    git add npins/*
    git add *.nix
    git commit -m "Gen: $curr_generation NixOS: $curr_nixos_major Kernel: $curr_kernel"
    echo "Changes committed successfully."
end

function print_system
    nixos-rebuild list-generations --json | jq -r '.[] | select (.current == true)'
end

function collect_garbage
    echo "Collecting garbage..."
    tput smcup
    clear
    echo "Collecting garbage..."
    sudo nix-collect-garbage -d 2>&1 | tee gc.log
    echo "Garbage collection completed."
    tput rmcup
    tail -n 2 gc.log
end

function refresh_boot_entries
    fancy_rebuild boot "refreshing boot entries..."
end

function print_help
    echo "Usage: holy-mother-of-scripts.sh [OPTIONS]"
    echo "A script to rebuild NixOS configuration and commit changes."
    echo ""
    echo "Options:"
    echo "  -h,       --help          Show this help message"
    echo "  -e[FILE], --edit[=FILE]   Edit a configuration file (configuration.nix by default)"
    echo "  -b,       --boot          Rebuild and switch at next boot"
    echo "  -u,       --update        Update (n)pins"
    echo "  -p,       --push          Push changes to remote repository (if successful)"
    echo "  -f,       --force         Force rebuild even if no changes detected"
    echo "  -c,       --clean         collect garbage after rebuild, and run rebuild boot to refresh boot entries"
    echo "  -s,       --system        print current generation info"
    echo ""
    echo "for safety boot and push are mutually exclusive"
    echo "If you want to push changes, use the --push flag after a successful reboot."
    exit 0
end

# function exit_handler --on-signal SIGINT
#     if test "$PWD" = "$absolute_nixos_config_path"
#         popd
#     end
#     echo "interrupted!"
# end



# -------------------------------------------------------------------------
# ---------------------------Entry Point-----------------------------------
#--------------------------------------------------------------------------



# handle help flag
if set -q _flag_help
    print_help
end

# go to config root
pushd ~/nixos-config/

# handle update flag
if set -q _flag_update
    update_npins
end

# handle edit flag
if set -q _flag_edit
    edit_config
end

# core rebuild logic
if not git diff --quiet '*.nix'; or not git diff --quiet 'npins/sources.json'; or set -q _flag_force
    echo "Proceeding with rebuild."
    autoformat
    git diff -U0
    fancy_rebuild "$rebuild_type" "Rebuilding NixOS configuration..."
    if not check_rebuild
        # revert npins
        git restore 'npins/sources.json'
        # fail if bad rebuild
        exit_with_notification "Check rebuild.log for details."
    else
        commit_build
    end
else
    echo "Skipping Rebuild"
end

# handle push flag
if set -q _flag_push
    push_to_remote
end

# handle clean flag
if set -q _flag_clean
    collect_garbage
    refresh_boot_entries
end

# handle system flag
if set -q _flag_system
    echo "Current system:"
    print_system
end

# finish successfully
popd
echo "NIXIT completed successfully."
notify-send --transient --icon=software-update-available --app-name=NIXIT "NIXIT Successful" 
return 0
