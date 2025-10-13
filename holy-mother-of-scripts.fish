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
# - alejandra (for nix autoformatting)
# - notify-send (for notifications)
# - ripgrep (for checking rebuild log)
#
# hello npins!
# https://github.com/andir/npins
# https://jade.fyi/blog/pinning-nixos-with-npins/
# https://piegames.de/dumps/pinning-nixos-with-npins-revisited/
# https://discourse.nixos.org/t/pinning-nixos-with-npins/63721/10

# some script arguments
set -l options (fish_opt -s h -l help)
set options $options (fish_opt -o -s e -l edit)
set options $options (fish_opt -s b -l boot)
set options $options (fish_opt -s u -l update)
set options $options (fish_opt -s p -l push)
set options $options (fish_opt -s f -l force)
set options $options (fish_opt -s l -l limited)
set options $options (fish_opt -s c -l clean)



argparse --exclusive "boot,push" $options -- $argv

function exit_with_notification
    set -l message $argv[1]
    notify-send --transient --icon=software-update-urgent --app-name=NIXIT "Rebuild Failed: $message"
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
    echo "  -u,       --update        Update (n)pins"
    echo "  -p,       --push          Push changes to remote repository (if successful)"
    echo "  -f,       --force         Force rebuild even if no changes detected"
    echo "  -l,       --limited       Resource limited rebuild"
    echo "  -c,       --clean         collect garbage after rebuild, and run rebuild boot to refresh boot entries"
    echo ""
    echo "for safety boot and push are mutually exclusive"
    echo "If you want to push changes, use the --push flag after a successful reboot."
    return 0
end

# go to config root
pushd ~/nixos-config/

# handle update flag
if set -q _flag_update
    echo "Updating npins"
    npins update
end


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

# Early return if no changes were detected
if not git diff --quiet '*.nix'
    echo "Changes detected, proceeding with rebuild."
else if not git diff --quiet 'npins/sources.json'
    echo "No changes detected, but pins updated, proceeding with rebuild."
else if set -q _flag_force
    echo "No changes detected, but force rebuild requested."
else if set -q _flag_push 
    echo "No changes detected, no pins updated, but push requested"
    push_to_remote
    popd
    return 0
else
    echo "No changes detected, exiting."
    popd
    return 0
end

# autoformat nix files
if not nixfmt -q *.nix # noooo dont touch my submodules
    popd
    exit_with_notification "Nixfmt formatting failed"
end

# show the diff
git diff -U0

# start the rebuild
echo "Rebuilding NixOS configuration..."
tput smcup
clear
# grab the latest nixpkgs path
set -l nixpkgs_path (nix-instantiate --json --eval npins/default.nix -A nixpkgs.outPath | jq -r .)
# limit jobs options
set -l limited_opts ""
if set -q _flag_limited
    set limited_opts "--cores=4"
    echo "Resource limited rebuild enabled"
end
echo "Rebuilding NixOS configuration..."
if set -q _flag_boot
    sudo nixos-rebuild boot -I nixos-config=/home/julia/nixos-config/configuration.nix -I nixpkgs=$nixpkgs_path 2>&1 | tee rebuild.log
else
    sudo nixos-rebuild switch -I nixos-config=/home/julia/nixos-config/configuration.nix -I nixpkgs=$nixpkgs_path 2>&1 | tee rebuild.log
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
if rg --quiet "error:" rebuild.log
    echo "Rebuild failed, exiting."
    popd
    exit_with_notification "Check rebuild.log for details."
end

if rg --quiet "SIGKILL" rebuild.log
    echo "Rebuild was killed (probably out of memory), exiting."
    popd
    exit_with_notification "Check rebuild.log for details."
end

echo "Rebuild successful, committing changes..."
set -l curr_json (nixos-rebuild list-generations --json | jq -r '.[] | select (.current == true)')
set -l curr_generation (echo $curr_json | jq -r '"\(.generation)"')
# set -l curr_date (echo $curr_json | jq -r '"\(.date)"')
set -l curr_nixos (echo $curr_json | jq -r '"\(.nixosVersion)"')
set -l curr_nixos_major (echo $curr_nixos | string split -f "1,2" . | string join .)
set -l curr_kernel (echo $curr_json | jq -r '"\(.kernelVersion)"')
git add npins/sources.json
git add *.nix
git commit -m "Gen: $curr_generation NixOS: $curr_nixos_major Kernel: $curr_kernel"
echo "Changes committed successfully."

# handle push flag
if set -q _flag_push
    push_to_remote
end

# handle clean flag
if set -q _flag_clean

    echo "Collecting garbage..."
    tput smcup
    clear
    echo "Collecting garbage..."
    sudo nix-collect-garbage -d 2>&1 | tee gc.log
    echo "Garbage collection completed."
    tput rmcup

    echo "refreshing boot entries..."
    tput smcup
    clear
    echo "refreshing boot entries..."
    sudo nixos-rebuild boot -I nixos-config=/home/julia/nixos-config/configuration.nix -I nixpkgs=$nixpkgs_path 2>&1 | tee refresh-boot.log
    echo "Boot entries refreshed."
    tput rmcup

end

# finish successfully
popd
echo "NixOS configuration rebuild and commit completed successfully."
notify-send --transient --icon=software-update-available --app-name=NIXIT "Rebuild Successful" 
return 0
