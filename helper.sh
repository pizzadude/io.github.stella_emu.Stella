#!/bin/sh

set -e

trap "retval=\$? ; [ 0 -eq \${retval} ] || { echo 'An error occured, code '\${retval}'... stopping!'; exit \${retval}; }" EXIT

readonly BUILD_DIR="build"
readonly UPSTREAM_TARBALL="https://github.com/stella-emu/stella/releases/download/%VERSION%/stella-%VERSION%-src.tar.xz"
readonly FLATPAK_XML="io.github.stella_emu.Stella.metainfo.xml"
readonly FLATPAK_YML="io.github.stella_emu.Stella.yaml"
readonly FLATPAK_ID="$(grep app-id: "${FLATPAK_YML}" | cut -f2 -d\ )"
readonly FLATPAK_DESKTOP="build/files/share/applications/io.github.stella_emu.Stella.desktop"
readonly SDK_VERSION="$(grep runtime-version: "${FLATPAK_YML}" | cut -f2 -d\')"

setup()
{
   local answer show
   show=0

   echo "the following commands will be run using sudo for SDK_VERSION=${SDK_VERSION}:"
   echo
   while read line ;do
      case "${line}" in
      *\<\<END_OF_SETUP) show=1;;
      END_OF_SETUP) show=0;;
      *) [ ${show} -ne 0 ] && echo "${line}";;
      esac
   done <$0

   echo
   echo -n "press enter to continue "

   read answer

   sudo -i <<END_OF_SETUP
apt-get install flatpak-builder
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install flathub org.freedesktop.Sdk//${SDK_VERSION} org.freedesktop.Platform//${SDK_VERSION} -y
END_OF_SETUP
   exit ${?}
}

build()
{
   exec flatpak-builder --force-clean "${BUILD_DIR}" "${FLATPAK_YML}"
}

run()
{
   shift # first parameter is "run"
   exec flatpak-builder --run "${BUILD_DIR}" "${FLATPAK_YML}" stella "${@}"
}

inst()
{
   exec flatpak-builder --user --install --force-clean "${BUILD_DIR}" "${FLATPAK_YML}"
}

check()
{
   echo "checking ${FLATPAK_XML}..."
   flatpak run org.freedesktop.appstream-glib validate ${FLATPAK_XML}

   echo "checking ${FLATPAK_DESKTOP}..."
   if [ ! -f "${FLATPAK_DESKTOP}" ]; then
      echo "desktop file '${FLATPAK_DESKTOP}' not found (not built?), skipping check"
   else
      desktop-file-validate "${FLATPAK_DESKTOP}"
   fi
false
}

update()
{
   shift # first parameter is "update"
   local pattern version download_url sha256 date
   version="${1}"
   date="$(date +%Y-%m-%d)"
   pattern="$(echo "${UPSTREAM_TARBALL}" | sed "s,%VERSION%,\[\.0-9\]\*,g")"
   download_url="$(echo "${UPSTREAM_TARBALL}" | sed "s,%VERSION%,${version},g")"
   echo "calculating sha256 of upstream tarball:"
   echo "${download_url}"
   sha256="$(wget -q -O - "${download_url}" | sha256sum - | sed 's, .*$,,')"
   sed -e "s,${pattern},${download_url},g" \
       -e "s,sha256: .*$,sha256: ${sha256}," \
       -i "${FLATPAK_YML}"
   if grep -q "<release version=\"${version}\"" "${FLATPAK_XML}"; then
      sed -e "s,<release version=\"${version}\".*/>,<release version=\"${version}\" date=\"${date}\"/>,g" \
          -i "${FLATPAK_XML}"
   else
      sed -e "/  <releases>/a \    <release version=\"${version}\" date=\"${date}\"/>" \
          -i "${FLATPAK_XML}"
   fi
   echo "${FLATPAK_YML} updated:"
   grep -e "${pattern}" -e "sha256" "${FLATPAK_YML}" | sed 's/^  */  /'
}

case "${1}" in
setup)  setup  "${@}";; #: install flatpak-builder and SDK (will run sudo)
build)  build  "${@}";; #: download and build Stella release
check)  check  "${@}";; #: check config files
run)    run    "${@}";; #: test run Stella from current build
inst)   inst   "${@}";; #: install as user
update) update "${@}";; #: update upstream version (add version number as argument)
*) grep '^.*) .*#:.*' "${0}" | grep -v '^\*' | sed 's,\(.*\)) .*;; #: \(.*\)$,\1:\t\2,';;
esac
