#!/usr/bin/env bash
# clean-caches.sh - free disk space by clearing well-known, re-creatable caches.
#
# Default = DRY RUN (shows what would be removed and how big it is).
#
#   ./clean-caches.sh                 # dry run, user-level caches
#   ./clean-caches.sh --yes           # actually delete
#   ./clean-caches.sh --yes --system  # also system caches (journal, portage, apt...) via sudo
#   ./clean-caches.sh --yes --aggressive
#                                     # also: Go modcache, ~/.m2, gradle, browser caches,
#                                     #       trash, Rust target/ dirs, docker dangling/build cache,
#                                     #       mise prune (unused tool versions)
#   --node-modules
#                                     # also delete node_modules/ of projects untouched for --days days
#   --days N   age (days) for the ~/.cache sweep and --node-modules (default 30)
#   --exclude PATH   never touch PATH (repeatable, comma-separated lists OK).
#                    Relative = under ~/.cache, else absolute or ~/...
#                    e.g. --exclude huggingface --exclude ~/.cargo/registry,mozilla

set -u

DRY_RUN=1
AGGRESSIVE=0
SYSTEM=0
NODE_MODULES=0
CACHE_DAYS=30
PRIV=""
EXCLUDES=()

# Register an exclusion. Accepts: absolute path, ~/path, or a path relative to ~/.cache.
# Comma-separated lists are allowed: --exclude huggingface,mozilla
add_exclude() {
  local item e IFS=','
  for item in $1; do
    [ -n "$item" ] || continue
    case "$item" in
      "~/"*) e="$HOME/${item#\~/}" ;;
      /*)    e="$item" ;;
      *)     e="$HOME/.cache/$item" ;;
    esac
    e="${e%/}"
    EXCLUDES+=("$e")
  done
}

# True if path $1 is an excluded path, lies inside one, or contains one.
path_is_protected() {
  local p="${1%/}" e
  for e in ${EXCLUDES[@]+"${EXCLUDES[@]}"}; do
    case "$p" in "$e"|"$e"/*) return 0 ;; esac
    case "$e" in "$p"/*) return 0 ;; esac
  done
  return 1
}

while [ $# -gt 0 ]; do
  case "$1" in
    --yes|-y)     DRY_RUN=0 ;;
    --aggressive) AGGRESSIVE=1 ;;
    --system)     SYSTEM=1 ;;
    --node-modules) NODE_MODULES=1 ;;
    --days)       shift; CACHE_DAYS="${1:-30}" ;;
    --exclude|-x) shift; add_exclude "${1:-}" ;;
    -h|--help)    sed -n '2,22p' "$0"; exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
  shift
done

have()  { command -v "$1" >/dev/null 2>&1; }
log()   { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
human() { numfmt --to=iec --suffix=B $(( $1 * 1024 )) 2>/dev/null || echo "${1}K"; }

# Remove the CONTENTS of each given path (the directory itself is kept).
clean_path() {
  local p kb
  for p in "$@"; do
    [ -e "$p" ] || continue
    if path_is_protected "$p"; then
      printf '  %-65s skipped (excluded)\n' "$p"; continue
    fi
    kb=$($PRIV du -sk "$p" 2>/dev/null | cut -f1)
    [ "${kb:-0}" -gt 0 ] || continue
    printf '  %-65s %s\n' "$p" "$(human "$kb")"
    [ "$DRY_RUN" -eq 0 ] && $PRIV find "$p" -mindepth 1 -delete 2>/dev/null
  done
  return 0
}

# Run a command (only if the binary exists); just print it in dry-run mode.
run() {
  have "$1" || return 0
  printf '  $ %s\n' "$*"
  [ "$DRY_RUN" -eq 0 ] && "$@" 2>&1 | sed 's/^/    /'
  return 0
}

H="$HOME"
BEFORE=$(df -k --output=avail / | tail -1)

[ "$DRY_RUN" -eq 1 ] && echo "DRY RUN: nothing will be deleted. Re-run with --yes to apply."

# ---------------------------------------------------------------- Rust
log "Rust: cargo / rustup"
clean_path "$H/.cargo/registry/cache" "$H/.cargo/registry/src" \
           "$H/.cargo/git/db" "$H/.cargo/git/checkouts" \
           "$H/.rustup/downloads" "$H/.rustup/tmp"
have sccache && run sccache --stop-server

if [ "$AGGRESSIVE" -eq 1 ]; then
  log "Rust: build artifacts (target/ dirs next to a Cargo.toml)"
  while IFS= read -r t; do
    clean_path "$t"
    [ "$DRY_RUN" -eq 0 ] && rmdir "$t" 2>/dev/null
  done < <(find "$H" -maxdepth 6 -type d -name target \
             -not -path "$H/.cargo/*" -not -path "$H/.rustup/*" \
             -exec test -f '{}/../Cargo.toml' \; -print 2>/dev/null)
fi

# ---------------------------------------------------------------- Python
log "Python: pip / pipx / uv / poetry / conda"
run pip cache purge
run pip3 cache purge
clean_path "$H/.cache/pip" "$H/.cache/pipx" "$H/.cache/pypoetry" \
           "$H/.cache/pre-commit" "$H/.cache/pip-tools"
have uv && run uv cache clean
have conda && run conda clean -afy

# ---------------------------------------------------------------- mise
log "mise"
run mise cache clear
clean_path "$H/.cache/mise" "$H/.local/share/mise/downloads"
[ "$AGGRESSIVE" -eq 1 ] && run mise prune --yes

# ---------------------------------------------------------------- JS
log "JavaScript: npm / yarn / pnpm / bun / deno"
run npm cache clean --force
clean_path "$H/.npm/_cacache" "$H/.npm/_logs"
have yarn && run yarn cache clean
clean_path "$H/.cache/yarn" "$H/.yarn/cache"
have pnpm && run pnpm store prune
clean_path "$H/.bun/install/cache" "$H/.cache/deno" "$H/.cache/node" \
           "$H/.cache/typescript" "$H/.cache/node-gyp" "$H/.node-gyp"
clean_path "$H/.cache/ms-playwright" "$H/.cache/puppeteer" "$H/.cache/Cypress"

# ---------------------------------------------------------------- Go
log "Go"
run go clean -cache
[ "$AGGRESSIVE" -eq 1 ] && run go clean -modcache

# ---------------------------------------------------------------- JVM / others
log "Java / PHP / Ruby / misc build caches"
clean_path "$H/.cache/composer" "$H/.composer/cache" "$H/.cache/ccache" \
           "$H/.ccache" "$H/.cache/bazel" "$H/.cache/cmake" "$H/.cache/vcpkg" \
           "$H/.cache/zig" "$H/.cache/gem" "$H/.cache/bundler"
have ccache && run ccache -C
if [ "$AGGRESSIVE" -eq 1 ]; then
  clean_path "$H/.gradle/caches" "$H/.gradle/wrapper/dists" "$H/.m2/repository"
fi

# ---------------------------------------------------------------- Desktop
log "Desktop: thumbnails, app caches"
clean_path "$H/.cache/thumbnails" "$H/.thumbnails" \
           "$H/.cache/fontconfig" "$H/.cache/mesa_shader_cache" \
           "$H/.cache/nvidia" "$H/.nv/ComputeCache" "$H/.cache/gstreamer-1.0" \
           "$H/.cache/pocl" "$H/.cache/spotify" "$H/.cache/vscode-cpptools" \
           "$H/.config/Code/CachedData" "$H/.config/Code/Cache" \
           "$H/.config/Code/CachedExtensionVSIXs"
if [ "$AGGRESSIVE" -eq 1 ]; then
  clean_path "$H/.cache/mozilla" "$H/.cache/google-chrome" "$H/.cache/chromium" \
             "$H/.cache/BraveSoftware" "$H/.local/share/Trash"
fi

# ---------------------------------------------------------------- Docker
if [ "$AGGRESSIVE" -eq 1 ] && have docker; then
  log "Docker: dangling images + build cache (volumes and tagged images are NOT touched)"
  run docker image prune -f
  run docker builder prune -f
fi

# ---------------------------------------------------------------- More Python tooling
log "Python extras: ruff / mypy / pdm / hatch / pipenv / tox / jupyter"
clean_path "$H/.cache/ruff" "$H/.cache/mypy" "$H/.cache/pdm" "$H/.cache/hatch" \
           "$H/.cache/pipenv" "$H/.cache/tox" "$H/.cache/black" "$H/.cache/pytest" \
           "$H/.cache/pypa" "$H/.cache/virtualenv" "$H/.cache/matplotlib" \
           "$H/.cache/jedi" "$H/.cache/pylint" "$H/.cache/flake8"
have pdm   && run pdm cache clear
have poetry && run poetry cache clear --all . -n

# ---------------------------------------------------------------- Other languages
log "Other languages: Nix, opam, Haskell, .NET, Dart/Flutter, Scala, Elixir, Ruby, Lua"
clean_path "$H/.cache/nix" "$H/.cache/opam" "$H/.opam/download-cache" \
           "$H/.cabal/packages" "$H/.cache/cabal" "$H/.stack/indices" \
           "$H/.nuget/packages" "$H/.cache/NuGet" "$H/.dotnet/toolResolverCache" \
           "$H/.pub-cache" "$H/.cache/coursier" "$H/.ivy2/cache" "$H/.sbt/boot" \
           "$H/.hex/packages" "$H/.mix/archives" "$H/.cache/rebar3" \
           "$H/.cache/luarocks" "$H/.cache/julia" "$H/.julia/compiled" \
           "$H/.cache/R" "$H/.cache/cpan" "$H/.cpanm/work" "$H/.cache/cpm"
have nix-collect-garbage && run nix-collect-garbage -d
have dotnet && run dotnet nuget locals all --clear
have gem    && run gem cleanup
have brew   && run brew cleanup --prune=all -s

# ---------------------------------------------------------------- DevOps / Cloud
log "DevOps & cloud: terraform, helm, kubectl, aws, gcloud, ansible, vagrant, packer"
clean_path "$H/.terraform.d/plugin-cache" "$H/.cache/helm" "$H/.kube/cache" \
           "$H/.kube/http-cache" "$H/.aws/cli/cache" "$H/.azure/cliCache" \
           "$H/.config/gcloud/logs" "$H/.ansible/tmp" "$H/.ansible/cp" \
           "$H/.ansible/galaxy_cache" "$H/.cache/packer" "$H/.vagrant.d/tmp" \
           "$H/.cache/trivy" "$H/.cache/pulumi" "$H/.cache/skaffold" \
           "$H/.minikube/cache"

# ---------------------------------------------------------------- IDEs & Electron apps
log "IDEs & Electron apps"
clean_path "$H/.cache/JetBrains" "$H/.cache/Google/AndroidStudio"* \
           "$H/.cache/Microsoft" "$H/.cache/Code" "$H/.cache/vscode-ripgrep" \
           "$H/.config/discord/Cache" "$H/.config/discord/Code Cache" \
           "$H/.config/discord/GPUCache" "$H/.config/Slack/Cache" \
           "$H/.config/Slack/Code Cache" "$H/.config/Slack/GPUCache" \
           "$H/.config/Signal/Cache" "$H/.config/Signal/Code Cache" \
           "$H/.config/Element/Cache" "$H/.config/obsidian/Cache" \
           "$H/.config/Postman/Cache" "$H/.config/Cursor/Cache" \
           "$H/.config/Cursor/CachedData" "$H/.config/Cursor/Code Cache" \
           "$H/.config/Code/Code Cache" "$H/.config/Code/GPUCache" \
           "$H/.android/cache" "$H/.android/build-cache" \
           "$H/.config/libreoffice/4/cache" "$H/.cache/libreoffice"

# ---------------------------------------------------------------- Games / Wine
log "Games & Wine (shader caches, installers)"
clean_path "$H/.cache/winetricks" "$H/.cache/wine" "$H/.cache/lutris" \
           "$H/.cache/mesa_shader_cache_db" "$H/.cache/radv_builtin_shaders" \
           "$H/.local/share/Steam/steamapps/shadercache" \
           "$H/.local/share/Steam/logs" "$H/.local/share/Steam/appcache/httpcache"

# ---------------------------------------------------------------- AI / ML model caches
if [ "$AGGRESSIVE" -eq 1 ]; then
  log "AI/ML model caches (can be many GB; models re-download on demand)"
  clean_path "$H/.cache/huggingface" "$H/.cache/torch" "$H/.cache/whisper" \
             "$H/.cache/pip/wheels" "$H/.keras" "$H/.cache/tensorflow" \
             "$H/.cache/lm-studio" "$H/.cache/gpt4all" "$H/.cache/clip" \
             "$H/.cache/selenium" "$H/.cache/wdm" "$H/.cache/spacy" \
             "$H/.cache/nltk_data" "$H/nltk_data" "$H/.cache/chroma" \
             "$H/.cache/sentence_transformers" "$H/.cache/instructlab"
fi

# ---------------------------------------------------------------- Project-level junk
if [ "$AGGRESSIVE" -eq 1 ]; then
  log "Project junk under ~: __pycache__, .pytest_cache, .mypy_cache, .ruff_cache, .tox, .gradle, .next, .nuxt, .parcel-cache, .turbo"
  for name in __pycache__ .pytest_cache .mypy_cache .ruff_cache .tox .parcel-cache \
              .turbo .next/cache .nuxt .svelte-kit .angular/cache .eslintcache; do
    while IFS= read -r d; do
      clean_path "$d"
      [ "$DRY_RUN" -eq 0 ] && rmdir "$d" 2>/dev/null
    done < <(find "$H" -maxdepth 7 -path "$H/.cache" -prune -o -path "$H/.cargo" -prune \
               -o -path "$H/.rustup" -prune -o -path '*/node_modules' -prune \
               -o -path "*/$name" -print 2>/dev/null | head -200)
  done
fi

# ---------------------------------------------------------------- node_modules (opt-in only)
if [ "$NODE_MODULES" -eq 1 ]; then
  log "node_modules not modified for ${CACHE_DAYS}+ days (restore with npm/pnpm/yarn install)"
  while IFS= read -r d; do
    clean_path "$d"
    [ "$DRY_RUN" -eq 0 ] && rmdir "$d" 2>/dev/null
  done < <(find "$H" -maxdepth 6 -type d -name node_modules -prune \
             -not -path '*/node_modules/*' -not -path "$H/.cache/*" \
             -mtime +"$CACHE_DAYS" -exec test -f '{}/../package.json' \; -print 2>/dev/null)
fi

# ---------------------------------------------------------------- Generic ~/.cache sweep
log "Generic sweep: files in ~/.cache not accessed for ${CACHE_DAYS}+ days"
# Build "-not -path" filters for every exclusion (-prune would be ignored by -delete).
NOT_ARGS=()
for e in ${EXCLUDES[@]+"${EXCLUDES[@]}"}; do
  esc=$(printf '%s' "$e" | sed 's/[][\\*?]/\\&/g')
  NOT_ARGS+=( -not -path "$esc" -not -path "$esc/*" )
  echo "  excluded: $e"
done
OLD_KB=$(find "$H/.cache" -type f ${NOT_ARGS[@]+"${NOT_ARGS[@]}"} -atime +"$CACHE_DAYS" -printf '%s\n' 2>/dev/null \
         | awk '{s+=$1} END {printf "%d", s/1024}')
printf '  %-65s %s\n' "$H/.cache (old files)" "$(human "${OLD_KB:-0}")"
if [ "$DRY_RUN" -eq 0 ]; then
  find "$H/.cache" -type f ${NOT_ARGS[@]+"${NOT_ARGS[@]}"} -atime +"$CACHE_DAYS" -delete 2>/dev/null
  find "$H/.cache" -mindepth 1 -type d -empty ${NOT_ARGS[@]+"${NOT_ARGS[@]}"} -delete 2>/dev/null
fi
echo "  Biggest remaining entries in ~/.cache:"
du -sk "$H"/.cache/* 2>/dev/null | sort -rn | head -10 \
  | while read -r kb path; do printf '    %-60s %s\n' "$path" "$(human "$kb")"; done

# ---------------------------------------------------------------- System
if [ "$SYSTEM" -eq 1 ]; then
  [ "$(id -u)" -ne 0 ] && PRIV="sudo"
  log "System caches (via ${PRIV:-root})"

  have journalctl && run $PRIV journalctl --vacuum-size=200M
  clean_path /var/lib/systemd/coredump /var/tmp/portage /var/cache/ldconfig/aux-cache 2>/dev/null

  # Gentoo (portage)
  if have eclean-dist; then
    run $PRIV eclean-dist --deep
    run $PRIV eclean-pkg --deep
  else
    clean_path /var/cache/distfiles /var/cache/binpkgs /usr/portage/distfiles
  fi

  # Other distros
  have apt-get && run $PRIV apt-get clean
  have dnf     && run $PRIV dnf clean all
  have pacman  && run $PRIV pacman -Sc --noconfirm
  have flatpak && run $PRIV flatpak uninstall --unused -y
  have snap    && echo "  (snap: remove old revisions manually: snap list --all)"
fi

# ---------------------------------------------------------------- Summary
AFTER=$(df -k --output=avail / | tail -1)
log "Summary"
if [ "$DRY_RUN" -eq 1 ]; then
  echo "  Dry run only. Free space on /: $(human "$AFTER")"
  echo "  Re-run with --yes to apply (add --aggressive / --system for more)."
else
  echo "  Free space on /: $(human "$BEFORE") -> $(human "$AFTER")  (freed $(human $((AFTER - BEFORE))))"
fi
