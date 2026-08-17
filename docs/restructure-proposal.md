# Ristrutturazione degli script di build

Obiettivo: eliminare la dipendenza da **rechunker** e ottenere layer di dimensione
contenuta (target **50–100 MB** per layer) suddividendo i `RUN` del `Containerfile`.

> ✅ **Stato: implementato.** Questo documento descrive la struttura finale e le
> motivazioni alla base della suddivisione.

---

## 1. Struttura finale

Il `Containerfile` esegue un `RUN` per ogni **sottocartella numerata**, tramite
`runner.sh`. Ogni `RUN` produce un layer separato.

```
build_scripts/
├── standard/
│   ├── 1/  packages-core.sh
│   ├── 2/  packages-heavy.sh
│   ├── 3/  rpmfusion.sh
│   ├── 4/  kde-apps.sh
│   ├── 5/  cockpit.sh, tigervnc.sh
│   ├── 6/  protonmail-bridge.sh
│   └── 7/  tailscale.sh, terra.sh, ksystemstats-scripts.sh, kwin-minimize2tray.sh
├── virttools/
│   ├── 1/  virt-core.sh
│   └── 2/  virt-tools.sh
├── devtools/
│   ├── 1/  git.sh
│   └── 2/  vscode.sh
├── experimental/
│   └── .gitkeep          ← segnaposto nascosto (non eseguito da runner.sh)
├── disabled/
│   ├── gimp.sh           ← ex extended
│   ├── libreoffice.sh    ← ex extended
│   └── ... (altri script disattivati)
├── common.sh
├── runner.sh
└── ...
```

### RUN del `Containerfile`

| # | RUN | Flag |
| --- | ----- | ------ |
| 1 | `runner.sh ENABLE_STANDARD /ctx/standard/1` | `ENABLE_STANDARD` |
| 2 | `runner.sh ENABLE_STANDARD /ctx/standard/2` | `ENABLE_STANDARD` |
| 3 | `runner.sh ENABLE_STANDARD /ctx/standard/3` | `ENABLE_STANDARD` |
| 4 | `runner.sh ENABLE_STANDARD /ctx/standard/4` | `ENABLE_STANDARD` |
| 5 | `runner.sh ENABLE_STANDARD /ctx/standard/5` | `ENABLE_STANDARD` |
| 6 | `runner.sh ENABLE_STANDARD /ctx/standard/6` | `ENABLE_STANDARD` |
| 7 | `runner.sh ENABLE_STANDARD /ctx/standard/7` | `ENABLE_STANDARD` |
| 8 | `runner.sh ENABLE_VIRTTOOLS /ctx/virttools/1` | `ENABLE_VIRTTOOLS` |
| 9 | `runner.sh ENABLE_VIRTTOOLS /ctx/virttools/2` | `ENABLE_VIRTTOOLS` |
| 10 | `runner.sh ENABLE_DEVTOOLS /ctx/devtools/1` | `ENABLE_DEVTOOLS` |
| 11 | `runner.sh ENABLE_DEVTOOLS /ctx/devtools/2` | `ENABLE_DEVTOOLS` |
| 12 | `runner.sh ENABLE_EXPERIMENTAL /ctx/experimental` | `ENABLE_EXPERIMENTAL` |
| 13 | `runner.sh ENABLE_COMMON /ctx/common.sh` | `ENABLE_COMMON` |

> `runner.sh` itera con il glob `"$SCRIPT_TO_RUN"/*`, che **non** include i file
> nascosti: per questo `experimental/.gitkeep` mantiene la cartella tracciata da git
> senza essere mai eseguito.

---

## 2. Dimensioni rilevate dal log di build

I valori sotto sono le **dimensioni di download** (compresse) riportate da dnf nel log
`job-logs.txt`. La dimensione **installata** (uncompressed, quella che finisce nel layer)
è tipicamente 2–3× maggiore.

### 2.1 Gruppo `standard`

| Script | Download | Installato (stima) | Note |
| -------- | ---------- | -------------------- | ------ |
| `packages-core.sh` | ~90 MiB | ~250–300 MiB | parte leggera di `1.packages.sh` |
| `packages-heavy.sh` | ~65 MiB | ~150–200 MiB | rclone 108.9, cascadia-fonts ~65, syncthing 25, yt-dlp 20.8, vlc |
| `rpmfusion.sh` | **50.5 MiB** (28 pkg) | ~163 MiB | intel-media-driver 39.6, mesa-va-freeworld 52.1, ffmpeg-libs 23.3, x265 16.7 |
| `kde-apps.sh` | **75.0 MiB** (53 pkg) | ~200+ MiB | kate 17.7, krusader 15, kate-plugins 13.4, okular-part 11.1 |
| `cockpit.sh` | **30.6 MiB** (46 pkg) | ~80–100 MiB | appstream-data 14.9, PackageKit 3.6 |
| `tigervnc.sh` | 3.0 MiB (8 pkg) | ~8 MiB | |
| `protonmail-bridge.sh` | **200.7 MiB** (1 pkg) | ~206 MiB | singolo RPM enorme |
| `tailscale.sh` | **72.5 MiB** (1 pkg) | ~72 MiB | singolo RPM |
| `terra.sh` | 5.0 MiB (20 pkg) | ~12 MiB | font |
| `ksystemstats-scripts.sh` | ~0.05 MiB | ~1 MiB | copr |
| `kwin-minimize2tray.sh` | ~0.05 MiB | ~1 MiB | copr |

### 2.2 Gruppo `virttools`

| Script | Download | Installato (stima) | Note |
|--------|----------|--------------------|------|
| `virt-core.sh` | ~60 MiB | ~150 MB | qemu, edk2-ovmf, libvirt core |
| `virt-tools.sh` | ~20 MiB | ~100 MB | cockpit-machines, virt-manager, distrobox, podman-compose |

### 2.3 Gruppo `devtools`

| Script | Download | Installato (stima) | Note |
|--------|----------|--------------------|------|
| `git.sh` | 11.8 MiB | ~40 MiB | gh 40 MiB |
| `vscode.sh` | **330.4 MiB** (1 pkg) | **~1 GiB** | code 1.0 GiB |

### 2.4 Gruppo `common`

| Script | Download | Installato (stima) | Note |
|--------|----------|--------------------|------|
| `common.sh` | temi + dracut | initramfs ~95 MiB | rigenerazione initramfs, temi, sys_files |

---

## 3. Riepilogo RUN e target

| RUN | Contenuto | Dimensione (stima) | Nel target 50–100 MB? |
| ----- | ----------- | -------------------- | ---------------------- |
| S1 | `packages-core.sh` | ~250–300 MB | ❌ (grande) |
| S2 | `packages-heavy.sh` | ~150–200 MB | ❌ (grande) |
| S3 | `rpmfusion.sh` | ~163 MB | ❌ (grande) |
| S4 | `kde-apps.sh` | ~200 MB | ❌ (grande) |
| S5 | `cockpit.sh` + `tigervnc.sh` | ~90–110 MB | ✅ |
| S6 | `protonmail-bridge.sh` | ~206 MB | ❌ (grande) |
| S7 | `tailscale.sh` + `terra.sh` + `ksystemstats-scripts.sh` + `kwin-minimize2tray.sh` | ~85 MB | ✅ |
| V1 | `virt-core.sh` | ~150 MB | ❌ (grande) |
| V2 | `virt-tools.sh` | ~100 MB | ✅ |
| D1 | `git.sh` | ~40 MB | ✅ |
| D2 | `vscode.sh` | ~1 GB | ❌ (enorme) |
| C1 | `common.sh` | ~95 MB | ✅ |

---

## 4. Considerazioni

1. **Limite intrinseco**: alcuni pacchetti sono singoli RPM enormi (vscode ~1 GiB,
   protonmail ~206 MB, tailscale ~72 MB). Non è possibile ridurre il layer sotto la
   dimensione del singolo RPM. Per questi il target 50–100 MB è **irraggiungibile**;
   l'unica opzione è accettare il layer grande o spostare il pacchetto in un gruppo
   opzionale disattivato di default.

2. **Splitting applicato**: `1.packages.sh` è stato diviso in `packages-core.sh` e
   `packages-heavy.sh`; `virt.sh` in `virt-core.sh` e `virt-tools.sh`.

3. **Ordine di esecuzione**: `common.sh` resta **ultimo** (rigenera initramfs, copia
   `sys_files`, abilita servizi). Gli altri gruppi sono indipendenti tra loro.

4. **Cache dnf**: i `RUN` usano `--mount=type=cache,dst=/var/cache`. Splittare in più
   `RUN` non perde la cache dei pacchetti già scaricati, quindi il tempo di build non
   aumenta in modo significativo.

5. **`ENABLE_EXPERIMENTAL`**: la cartella `experimental/` contiene solo `.gitkeep`
   (file nascosto, non eseguito da `runner.sh`). Il `RUN` è quindi inerte finché non
   verranno aggiunti script reali.

6. **`extended` rimosso**: il gruppo `extended` è stato spostato in `disabled/`
   (`gimp.sh`, `libreoffice.sh`) e rimosso da `Containerfile` e workflow GitHub.

7. **Vantaggi senza rechunker**: layer più piccoli → pull più efficiente, aggiornamenti
   incrementali più leggeri, e niente dipendenza dal tool esterno `legacy-rechunk`.

---

## 5. Azioni rimanenti (opzionali)

- [ ] Rimuovere lo step `Run Rechunker` dal workflow `build.yml` (se non più usato).
- [ ] Valutare se spostare `vscode.sh` in un gruppo opzionale.
- [ ] (Opzionale) Splittare `libreoffice.sh` se si vorrà riabilitarlo in futuro.
