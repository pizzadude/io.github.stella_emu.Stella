![Stella: a multi-platform Atari 2600 VCS emulator](https://stella-emu.github.io/title.gif)

[Stella](https://stella-emu.github.io/) is a multi-platform
[Atari 2600 VCS](https://en.wikipedia.org/wiki/Atari_2600) emulator. This
repository contains all information required to package Stella as
[flatpak](https://flatpak.org/) provided by [flathub](https://flathub.org/).

Install
=======

Using Flatpak
-------------
- [Stella on flathub](https://flathub.org/apps/details/io.github.stella_emu.Stella)
- Install from command line
```sh
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install --user io.github.stella_emu.Stella
```

Traditional Installation
------------------------
A list of installation files for a couple of systems, including Windows, is available
at the [official Stella download page](https://stella-emu.github.io/downloads.html).

Development Helper
==================
Also included is a script called `helper.sh`, which can be used to setup a
build environment, build the package and run it for testing purposes, as well
as prepare an update to a new version. (Just in case you don't want to read
the [build documentation](https://docs.flatpak.org/en/latest/building.html).)
Running it without any arguments will display all options.

Testbuild Of Flatpak
====================
Todo...

