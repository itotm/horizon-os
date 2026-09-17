# rpms

RPMs installed from the build context instead of being downloaded at build
time; the Containerfile copies this directory into the `ctx` stage, so the
scripts under `build_scripts/` reach them as `/ctx/rpms/<dir>/`. Each
directory is named after the script in `build_scripts/standard/` that
installs it.

## epson-v200

Image Scan! for Linux for the Epson Perfection V200 Photo (GT-F670), taken as
is from Epson's `iscan-gt-f670-bundle-2.30.4.x64.rpm.tar.gz`
(sha256 `664360a1517a74b4e22ae8227ac58e8031450dc8b56dea2d2d1a6dd157043547`):

| file | origin in the bundle | license |
| --- | --- | --- |
| `iscan-data-1.39.2-1.noarch.rpm` | `data/` | GPL-2.0+ |
| `iscan-2.30.4-2.x86_64.rpm` | `core/` | GPL-2.0+ with Epson exception |
| `iscan-plugin-gt-f670-2.1.3-1.x86_64.rpm` | `plugins/` | Epson EULA (non-free) |

## ksystemstats-scripts

Release `v1.0` of [itotm/ksystemstats_scripts](https://github.com/itotm/ksystemstats_scripts).

## kwin-minimize2tray

Release `20260510` of [itotm/kwin-minimize2tray](https://github.com/itotm/kwin-minimize2tray).
