# rpms

RPMs installed from the build context instead of being downloaded at build
time; the Containerfile copies this directory into the `ctx` stage, so the
scripts under `build_scripts/` reach them as `/ctx/rpms/<dir>/`. Each
directory is named after the script in `build_scripts/standard/` that
installs it.

## ksystemstats-scripts

Release `v1.0` of [itotm/ksystemstats_scripts](https://github.com/itotm/ksystemstats_scripts).

## kwin-close2tray

Release `v0.2.1` of [itotm/kwin-close2tray](https://github.com/itotm/kwin-close2tray).

## sticky

Release `v1.33-2` of [itotm/sticky](https://github.com/itotm/sticky), Linux
Mint's Sticky with a KDE-style look.
