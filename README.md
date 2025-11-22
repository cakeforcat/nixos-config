# Hello!
This is my current collection of NixOS configuration files and a support script for building.

## Input locking with npins
Npins is used for input locking (noe need for channels or flakes!), have a look at the links inside holy-mother-of-scripts.fish. Depending on when you are reading this the blog post decribing it might be up on my page [here](https://cakeforcat.dev/blog.html)

## nixos-hardware
I maintain a fork of nixos-hardware and keep it here as a submodule for version pinning. This is mostly so I can watch out for updates to the legion module and make updates explicitly manual (more stable).

## holy-mother-of-scripts.fish
This is the fun part you might want to look at. Install the dependencies in their recommended manners (either through packages or `programs.<package>.enable = true;`). Check the script itself or using `source holy-mother-of-scripts.fish -h` (intentionally long so you alias it to something funnier)