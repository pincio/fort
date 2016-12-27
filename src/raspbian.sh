. "src/path.sh"

# This script is based on Havard Blok's "chroot to ARM" blog post
# <https://hblok.net/blog/posts/2014/02/06/chroot-to-arm/>.

# Public: Mount the Raspbian image's root filesystem.
#
# $1 - The absolute path of the Raspbian image.
# $2 - The aboslute path of the mount point.
#
# Returns 128 if the path of the Raspbian image isn't absolute.
# Returns 129 if the path of the mount point isn't absolute.
# Returns 130 if the mount point already exists.
# Returns 131 if the mount point can't be created.
raspbian_mount_image() {
  local image_path=$1
  local mp_path=$2
  local device_name
  local device_path

  path_is_absolute "$image_path" || return 128
  path_is_absolute "$mp_path" || return 129

  if [[ -e "$mp_path" ]]; then
    return 130
  fi

  # `kpartx -asv` will output one line per mapped partition to stdout in the
  # following form:
  #
  # ```
  # add map $device_name ...
  # ```
  #
  # NOTE: The exit status `kpartx -a` isn't reliable: 1 if an error occured
  # **and** 1 if it successfully mapped 1 partition from the device.
  device_name=$(kpartx -asv "$image_path" | tail -n 1 | cut -d " " -f 3)
  device_path="/dev/mapper/$device_name"

  mkdir -p "$mp_path" || return 131

  mount "$device_path" "$mp_path"
}

# Public: Unmount the Raspbian image's root filesystem.
#
# $1 - The absolute path of the Raspbian image.
# $2 - The aboslute path of the mount point.
#
# Returns 128 if the path of the Raspbian image isn't absolute.
# Returns 129 if the path of the mount point isn't absolute.
# Returns 130 if the mount point doesn't exist.
# Returns 131 if the mount point can't be removed.
raspbian_unmount_image() {
  local image_path=$1
  local mp_path=$2
  local result

  path_is_absolute "$image_path" || return 128
  path_is_absolute "$mp_path" || return 129

  if [[ ! -e "$mp_path" ]]; then
    return 130
  fi

  umount "$mp_path"
  result="$?"

  if [[ "$result" != 0 ]]; then
    return "$result"
  fi

  rm -r "$mp_path" || return 131

  # `kpartx -d` will output one line per mapped partition deleted.
  kpartx -d "$image_path" >/dev/null

  return 0
}
