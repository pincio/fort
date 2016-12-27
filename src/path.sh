# Internal: Get whether the path is absolute.
#
# $1 - The name of the variable that will be assigned the result.
# $2 - The path.
#
# Examples
#
#   path_is_absolute "../fortify.sh"
#   => 1
#
# Returns 1 if the path isn't absolute.
path_is_absolute () {
  if [[ ${1:0:1} == "/" ]]; then
    return 0
  fi

  return 1
}
