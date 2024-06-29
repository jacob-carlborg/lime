download() {
  curl --retry 3 -fsS "$1"
}

d_compiler() {
  case "${LIME_COMPILER}" in
    'dmd-latest') echo 'dmd' ;;
    'ldc-latest') echo 'ldc' ;;
    'dmd-master') echo 'dmd-nightly' ;;
    'ldc-master') echo 'ldc-latest-ci' ;;
    *) echo "${LIME_COMPILER}" ;;
  esac
}

install_compiler() {
  download https://dlang.org/d-keyring.gpg | gpg --import /dev/stdin
  source $(download https://dlang.org/install.sh | bash -s "$(d_compiler)" -a)
  # export DMD="$([ "$DC" = 'ldc2' ] && echo 'ldmd2' || echo 'dmd')"
}

print_d_compiler_version() {
  "${DMD}" --version
}
