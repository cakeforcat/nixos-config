#!/usr/bin/env fish
# A rebuild script that commits on a successful build
# the approach for tracking the nixos configuration files I use is symlinking
# sources:
# https://gist.github.com/0atman/1a5133b842f929ba4c1e195ee67599d5
# https://nixos-and-flakes.thiscute.world/nixos-with-flakes/other-useful-tips#managing-the-configuration-with-git
# https://github.com/JustCoderdev/dotfiles/blob/nixos-compliant/nixos/modules/system/bin/rebuild-system/rebuild-system.sh
# https://stackoverflow.com/questions/11023929/using-the-alternate-screen-in-a-bash-script
# dependencies:
# - fish
# - git
# - jq (for parsing JSON)
# - alejandra (for nix autoformatting)
# - notify-send (for notifications)
# - ripgrep (for checking rebuild log)

# some script arguments
set -l options (fish_opt -s h -l help)
set options $options (fish_opt -o -s e -l edit)
set options $options (fish_opt -s b -l boot)
set options $options (fish_opt -s u -l update)
set options $options (fish_opt -s p -l push)


argparse --exclusive "boot,push" $options -- $argv

function exit_with_notification
    set -l message $argv[1]
    notify-send -e "Rebuild Failed: $message" --icon=software-update-urgent
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

# handle help flag
if set -q _flag_help
    echo "Usage: holy-mother-of-scripts.sh [OPTIONS]"
    echo "A script to rebuild NixOS configuration and commit changes."
    echo ""
    echo "Options:"
    echo "  -h,       --help          Show this help message"
    echo "  -e[FILE], --edit[=FILE]   Edit a configuration file (configuration.nix by default)"
    echo "  -b,       --boot          Rebuild and switch at next boot"
    echo "  -u,       --update        Update NixOS channels before rebuilding"
    echo "  -p,       --push          Push changes to remote repository (if successful)"
    echo ""
    echo "for safety boot and push are mutually exclusive"
    echo "If you want to push changes, use the --push flag after a successful reboot."
    return 0
end

# handle update flag
if set -q _flag_update
    echo "Updating NixOS channels..."
    sudo nix-channel --update
end

# go to config root
pushd ~/nixos-config/

# handle edit flag
if set -q _flag_edit
    if set -q _flag_edit[1]
        if not test -f $_flag_edit
            exit_with_notification "File $_flag_edit does not exist."
        end
        $EDITOR $_flag_edit
    else
        $EDITOR configuration.nix
    end
end

# Early return if no changes were detected (thanks @singiamtel!)
if not git diff --quiet '*.nix'
    echo "Changes detected, proceeding with rebuild."
else if set -q _flag_update
    echo "No changes detected, but channels updated, proceeding with rebuild."
else if set -q _flag_push 
    echo "No changes detected, no channels updated, but push requested"
    push_to_remote
    popd
    return 0
else
    echo "No changes detected, exiting."
    popd
    return 0
end

# autoformat nix files
if not alejandra -q .
    popd
    exit_with_notification "Alejandra formatting failed, exiting."
end

# show the diff
git diff -U0 '*.nix'

# start the rebuild
echo "Rebuilding NixOS configuration..."
tput smcup
clear
echo "Rebuilding NixOS configuration..."
if set -q _flag_boot
    sudo nixos-rebuild boot 2>&1 | tee rebuild.log
else
    sudo nixos-rebuild switch 2>&1 | tee rebuild.log
end

echo "Rebuild completed"
echo "Exit in 3..."
sleep 1
echo "Exit in 2..."
sleep 1
echo "Exit in 1..."
sleep 1
tput rmcup

# check if the rebuild was successful
if rg --quiet error rebuild.log
    echo "Rebuild failed, exiting."
    popd
    exit_with_notification "Rebuild failed, check rebuild.log for details."
end

echo "Rebuild successful, committing changes..."
set -l curr_json (nixos-rebuild list-generations --json | jq -r '.[] | select (.current == true)')
set -l curr_generation (echo $curr_json | jq -r '"\(.generation)"')
set -l curr_date (echo $curr_json | jq -r '"\(.date)"')
set -l curr_nixos (echo $curr_json | jq -r '"\(.nixosVersion)"')
set -l curr_nixos_major (echo $curr_nixos | string split -f "1" -m 2 -r .)
set -l curr_kernel (echo $curr_json | jq -r '"\(.kernelVersion)"')
git add *.nix
git commit -m "Gen: $curr_generation NixOS: $curr_nixos_major Kernel: $curr_kernel"
echo "Changes committed successfully."

# handle push flag
if set -q _flag_push
    push_to_remote
end

# finish successfully
popd
echo "NixOS configuration rebuild and commit completed successfully."
notify-send -e "Rebuild Successful" --icon=software-update-available
return 0
