#!/bin/sh
#=============================================================================
#
# Program:   CMake - Cross-Platform Makefile Generator
# Module:    $RCSfile$
# Language:  C++
# Date:      $Date$
# Version:   $Revision$
#
# Copyright (c) 2002 Kitware, Inc., Insight Consortium.  All rights reserved.
# See Copyright.txt or http://www.cmake.org/HTML/Copyright.html for details.
#
#    This software is distributed WITHOUT ANY WARRANTY; without even 
#    the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR 
#    PURPOSE.  See the above copyright notices for more information.
#
#=============================================================================

#
# CMake UNIX Release Script.
#

[ -z "$REMOTE" ] && SELF="$0"
CVSROOT=":pserver:anonymous@www.cmake.org:/cvsroot/CMake"
CVSROOT_GREP=":pserver:anonymous@www.cmake.org:[0-9]*/cvsroot/CMake"
TAG="Release-1-6"
VERSION="1.6.beta2"
RELEASE="1"
PREVIOUS_VERSION="1.4.7"
PREVIOUS_RELEASE="1"
RELEASE_ROOT_NAME="CMakeReleaseRoot"
RELEASE_ROOT="${HOME}/${RELEASE_ROOT_NAME}"
CC=""
CXX=""
CFLAGS=""
CXXFLAGS=""
PREFIX="/usr/local"
INSTALL_SUBDIRS="bin share doc"
DOC_DIR="/doc/cmake"

#-----------------------------------------------------------------------------
usage()
{
    echo "Usage!!"
}

#-----------------------------------------------------------------------------
error_log()
{
    echo "An error has been logged to $1:" &&
    cat "$1" &&
    return 1
}

#-----------------------------------------------------------------------------
check_host()
{
    HOST="$1"
    if [ -z "$HOST" ]; then
        echo "Must specify host."
        return 1
    fi
}

#-----------------------------------------------------------------------------
remote()
{
    check_host "$1" || return 1
    shift
    REMOTE_TASK="$@"
    RESULT=0
    echo "------- Running remote task on $HOST. -------" &&
    (echo "REMOTE=\"1\"" &&
     echo "TASK=\"${REMOTE_TASK}\"" &&
     cat $SELF) | ssh "$HOST" /bin/sh 2>/dev/null || RESULT=1
    echo "-------- Remote task on $HOST done.  --------" &&
    return $RESULT
}

#-----------------------------------------------------------------------------
remote_copy()
{
    check_host "$1" || return 1
    EXPR="$2"
    [ ! -z "$EXPR" ] || EXPR="*"
    echo "------- Copying tarballs from $HOST. -------" &&
    scp "$HOST:${RELEASE_ROOT_NAME}/Tarballs/${EXPR}" . &&
    echo "---- Done copying tarballs from $HOST. -----"
}

#-----------------------------------------------------------------------------
remote_copy_source()
{
    check_host "$1" || return 1
    remote_copy "$HOST" "cmake-${VERSION}.tar*"
}

#-----------------------------------------------------------------------------
remote_copy_binary()
{
    check_host "$1" || return 1
    remote_copy "$HOST" "cmake-${VERSION}-*"
}

#-----------------------------------------------------------------------------
remote_source()
{
    check_host "$1" || return 1
    remote "$HOST" source_tarball &&
    remote_copy_source "$HOST"
}

#-----------------------------------------------------------------------------
remote_binary()
{
    check_host "$1" || return 1
    remote "$HOST" binary_tarball &&
    remote_copy_binary "$HOST"
}

#-----------------------------------------------------------------------------
upload()
{
    echo "------- Copying tarballs to www.cmake.org. -------"
    scp cmake-${VERSION}*tar.* www.cmake.org:/projects/FTP/pub/cmake
    echo "---- Done copying tarballs to www.cmake.org. -----"
}

#-----------------------------------------------------------------------------
setup()
{
    [ -z "${DONE_setup}" ] || return 0 ; DONE_setup="yes"
    mkdir -p ${RELEASE_ROOT}/Logs &&
    echo "Entering ${RELEASE_ROOT}" &&
    cd ${RELEASE_ROOT}
}

#-----------------------------------------------------------------------------
clean()
{
    cd "${HOME}" &&
    echo "Cleaning up ${RELEASE_ROOT}" &&
    rm -rf "${RELEASE_ROOT_NAME}"
}

#-----------------------------------------------------------------------------
cvs_login()
{
    [ -z "${DONE_cvs_login}" ] || return 0 ; DONE_cvs_login="yes"
    setup || return 1
    (
        if [ -f "${HOME}/.cvspass" ]; then
            CVSPASS="${HOME}/.cvspass"
        else
            CVSPASS=""
        fi
        if [ -z "`grep \"$CVSROOT_GREP\" ${CVSPASS} /dev/null`" ]; then
            echo "cmake" | cvs -q -z3 -d $CVSROOT login
        else
            echo "Already logged in."
        fi
    ) >Logs/cvs_login.log 2>&1 || error_log Logs/cvs_login.log
}

#-----------------------------------------------------------------------------
utilities()
{
    [ -z "${DONE_utilities}" ] || return 0 ; DONE_utilities="yes"
    cvs_login || return 1
    (
        if [ -d "ReleaseUtilities/CVS" ]; then
            cd ReleaseUtilities && cvs -z3 -q update -dAP
        else
            rm -rf CheckoutTemp &&
            mkdir CheckoutTemp &&
            cd CheckoutTemp &&
            cvs -q -z3 -d $CVSROOT co CMake/Utilities/Release &&
            mv CMake/Utilities/Release ../ReleaseUtilities &&
            cd .. &&
            rm -rf CheckoutTemp
        fi
    ) >Logs/utilities.log 2>&1 || error_log Logs/utilities.log
}

#-----------------------------------------------------------------------------
config()
{
    [ -z "${DONE_config}" ] || return 0 ; DONE_config="yes"
    utilities || return 1
    CONFIG_FILE="config_`uname`"
    echo "Loading ${CONFIG_FILE} ..."
    . ${RELEASE_ROOT}/ReleaseUtilities/${CONFIG_FILE} >Logs/config.log 2>&1 || error_log Logs/config.log
    if [ -z "${CC}" ] || [ -z "${CXX}" ] || [ -z "${PLATFORM}" ]; then
        echo "${CONFIG_FILE} should specify CC, CXX, and PLATFORM." &&
        return 1
    fi
    export CC CXX CFLAGS CXXFLAGS PATH LD_LIBRARY_PATH
}

#-----------------------------------------------------------------------------
checkout()
{
    [ -z "${DONE_checkout}" ] || return 0 ; DONE_checkout="yes"
    config || return 1
    echo "Exporting cmake from cvs ..." &&
    (
        rm -rf cmake-${VERSION} &&
        rm -rf CheckoutTemp &&
        mkdir CheckoutTemp &&
        cd CheckoutTemp &&
        cvs -q -z3 -d $CVSROOT export -r ${TAG} CMake &&
        mv CMake ../cmake-${VERSION} &&
        cd .. &&
        rm -rf CheckoutTemp
    ) >Logs/checkout.log 2>&1 || error_log Logs/checkout.log
}

#-----------------------------------------------------------------------------
source_tarball()
{
    [ -z "${DONE_source_tarball}" ] || return 0 ; DONE_source_tarball="yes"
    config || return 1
    [ -d "cmake-${VERSION}" ] || checkout || return 1
    echo "Creating source tarballs ..." &&
    (
        mkdir -p Tarballs &&
        rm -rf Tarballs/cmake-${VERSION}.tar* &&
        tar cvf Tarballs/cmake-${VERSION}.tar cmake-${VERSION} &&
        gzip -c Tarballs/cmake-${VERSION}.tar >Tarballs/cmake-${VERSION}.tar.gz &&
        compress Tarballs/cmake-${VERSION}.tar
    ) >Logs/source_tarball.log 2>&1 || error_log Logs/source_tarball.log
}

#-----------------------------------------------------------------------------
write_cache()
{
    cat > CMakeCache.txt <<EOF
BUILD_TESTING:BOOL=OFF
EOF
}

#-----------------------------------------------------------------------------
cache()
{
    [ -z "${DONE_cache}" ] || return 0 ; DONE_cache="yes"
    config || return 1
    echo "Writing CMakeCache.txt ..." &&
    (
        rm -rf "cmake-${VERSION}-${PLATFORM}" &&
        mkdir -p "cmake-${VERSION}-${PLATFORM}" &&
        cd "cmake-${VERSION}-${PLATFORM}" &&
        write_cache
    ) >Logs/cache.log 2>&1 || error_log Logs/cache.log
}

#-----------------------------------------------------------------------------
configure()
{
    [ -z "${DONE_configure}" ] || return 0 ; DONE_configure="yes"
    config || return 1
    [ -d "cmake-${VERSION}" ] || checkout || return 1
    cache || return 1
    echo "Running configure ..." &&
    (
        cd "cmake-${VERSION}-${PLATFORM}" &&
        ../cmake-${VERSION}/configure --prefix=${PREFIX}
    ) >Logs/configure.log 2>&1 || error_log Logs/configure.log
}

#-----------------------------------------------------------------------------
build()
{
    [ -z "${DONE_build}" ] || return 0 ; DONE_build="yes"
    config || return 1
    if [ ! -d "cmake-${VERSION}-${PLATFORM}/Bootstrap" ]; then
        configure || return 1
    fi
    echo "Running make ..." &&
    (
        cd "cmake-${VERSION}-${PLATFORM}" &&
        make
    ) >Logs/build.log 2>&1 || error_log Logs/build.log
}

#-----------------------------------------------------------------------------
install()
{
    [ -z "${DONE_install}" ] || return 0 ; DONE_install="yes"
    config || return 1
    [ -f "cmake-${VERSION}-${PLATFORM}/Source/ccmake" ] || build || return 1
    echo "Running make install ..." &&
    (
        rm -rf Install &&
        cd "cmake-${VERSION}-${PLATFORM}" &&
        make install DESTDIR="${RELEASE_ROOT}/Install"
    ) >Logs/install.log 2>&1 || error_log Logs/install.log
}

#-----------------------------------------------------------------------------
strip()
{
    [ -z "${DONE_strip}" ] || return 0 ; DONE_strip="yes"
    config || return 1
    [ -f "Install/usr/local/bin/ccmake" ] || install || return 1
    echo "Stripping executables ..." &&
    (
        strip Install${PREFIX}/bin/*
    ) >Logs/strip.log 2>&1 || error_log Logs/strip.log
}

#-----------------------------------------------------------------------------
manifest()
{
    [ -z "${DONE_manifest}" ] || return 0 ; DONE_manifest="yes"
    config || return 1
    [ -f "Install/usr/local/bin/ccmake" ] || install || return 1
    echo "Writing MANIFEST ..." &&
    (
        mkdir -p Install${PREFIX}${DOC_DIR} &&
        rm -rf Install${PREFIX}${DOC_DIR}/MANIFEST &&
        touch Install${PREFIX}${DOC_DIR}/MANIFEST &&
        cd Install${PREFIX} &&
        FILES=`find ${INSTALL_SUBDIRS} -type f |sed 's/^\.\///'` &&
        cd ${RELEASE_ROOT} &&
        (cat >> Install${PREFIX}${DOC_DIR}/MANIFEST <<EOF
${FILES}
EOF
        ) &&
        rm -rf Install/README &&
        (cat > Install/README <<EOF
CMake $VERSION binary for $PLATFORM

Extract the file "cmake-${VERSION}-${PLATFORM}-files.tar" into your
destination directory (typically /usr/local).  The following files will
be extracted:

${FILES}

EOF
        )
    ) >Logs/manifest.log 2>&1 || error_log Logs/manifest.log
}

#-----------------------------------------------------------------------------
binary_tarball()
{
    [ -z "${DONE_binary_tarball}" ] || return 0 ; DONE_binary_tarball="yes"
    config || return 1
    strip || return 1
    manifest || return 1
    echo "Creating binary tarballs ..." &&
    (
        mkdir -p Tarballs &&
        rm -rf Install/cmake-${VERSION}-${PLATFORM}-files.tar &&
        (
            cd Install${PREFIX} &&
            tar cvf ${RELEASE_ROOT}/Install/cmake-${VERSION}-${PLATFORM}-files.tar ${INSTALL_SUBDIRS}
        ) &&
        rm -rf Tarballs/cmake-${VERSION}-${PLATFORM}.tar* &&
        (
            cd Install &&
            tar cvf ${RELEASE_ROOT}/Tarballs/cmake-${VERSION}-${PLATFORM}.tar cmake-${VERSION}-${PLATFORM}-files.tar README
        ) &&
        (
            cd Tarballs &&
            gzip -c cmake-${VERSION}-${PLATFORM}.tar >cmake-${VERSION}-${PLATFORM}.tar.gz &&
            compress cmake-${VERSION}-${PLATFORM}.tar
        )
    ) >Logs/binary_tarball.log 2>&1 || error_log Logs/binary_tarball.log
}

#-----------------------------------------------------------------------------
cygwin_source_tarball()
{
    [ -z "${DONE_cygwin_source_tarball}" ] || return 0 ; DONE_cygwin_source_tarball="yes"
    config || return 1
    [ -d "cmake-${VERSION}" ] || checkout || return 1
    echo "Creating cygwin source tarball ..." &&
    (
        rm -rf cmake-${VERSION}.tar.bz2 &&
        tar cvjf cmake-${VERSION}.tar.bz2 cmake-${VERSION}
    ) >Logs/cygwin_source_tarball.log 2>&1 || error_log Logs/cygwin_source_tarball.log
}

#-----------------------------------------------------------------------------
cygwin_source_patch()
{
    [ -z "${DONE_cygwin_source_patch}" ] || return 0 ; DONE_cygwin_source_patch="yes"
    config || return 1
    [ -d "cmake-${VERSION}" ] || checkout || return 1
    echo "Creating source patch for cygwin ..." &&
    (
        rm -rf Patched &&
        mkdir -p Patched &&
        (tar c cmake-${VERSION} | (cd Patched; tar x)) &&
        cd Patched &&
        mkdir -p cmake-${VERSION}/CYGWIN-PATCHES &&
        (
            CYGVERSION=`uname -r`
            cat > cmake-${VERSION}/CYGWIN-PATCHES/cmake.README <<EOF
cmake
--------------------------------------
Runtime requirements:
  cygwin-${CYGVERSION} or newer

Build requirements
  cygwin-${CYGVERSION} or newer
  make

Canonical homepage:
  http://www.cmake.org

Canonical download:
  ftp://www.cmake.org/pub/cmake/

------------------------------------

Build instructions:
  unpack cmake-${VERSION}-${RELEASE}-src.tar.bz2
    if you use setup to install this src package, it will be
	 unpacked under /usr/src automatically
  cd /usr/src
  ./cmake-${VERSION}-${RELEASE}.sh all

This will create:
  /usr/src/cmake-${VERSION}-${RELEASE}.tar.bz2
  /usr/src/cmake-${VERSION}-${RELEASE}-src.tar.bz2

-------------------------------------------

Port Notes:

<none>

------------------

Cygwin port maintained by: CMake Developers <cmake@www.cmake.org>

EOF
        ) &&
        (
            cat > cmake-${VERSION}/CYGWIN-PATCHES/setup.hint <<EOF
# CMake setup.hint file for cygwin setup.exe program
category: Devel 
requires: libncurses6 cygwin 
sdesc: "A cross platform build manger" 
ldesc: "CMake is a cross platform build manager. It allows you to specify build parameters for C and C++ programs in a cross platform manner. For cygwin Makefiles will be generated. CMake is also capable of generating microsoft project files, nmake, and borland makefiles. CMake can also perform system inspection operations like finding installed libraries and header files." 
prev: ${PREVIOUS_VERSION}-${PREVIOUS_RELEASE}
curr: ${VERSION}-${RELEASE}
EOF
        ) &&
        dos2unix cmake-${VERSION}/CYGWIN-PATCHES/setup.hint &&
        cp cmake-${VERSION}/CYGWIN-PATCHES/setup.hint ../setup.hint &&
        (diff -urN "../cmake-${VERSION}" "cmake-${VERSION}" > "../cmake-${VERSION}-${RELEASE}.patch"; [ "$?" = "1" ])
    ) >Logs/cygwin_source_patch.log 2>&1 || error_log Logs/cygwin_source_patch.log
}

#-----------------------------------------------------------------------------
cygwin_package_script()
{
    [ -z "${DONE_cygwin_package_script}" ] || return 0 ; DONE_cygwin_package_script="yes"
    utilities || return 1
    echo "Creating cygwin packaging script ..." &&
    (
        cp ReleaseUtilities/cmake-cygwin-package.sh cmake-${VERSION}-${RELEASE}.sh &&
        chmod u+x cmake-${VERSION}-${RELEASE}.sh
    ) >Logs/cygwin_package_script.log 2>&1 || error_log Logs/cygwin_package_script.log
}

#-----------------------------------------------------------------------------
cygwin_package()
{
    [ -z "${DONE_cygwin_package}" ] || return 0 ; DONE_cygwin_package="yes"
    config || return 1
    [ -f "cmake-${VERSION}.tar.bz2" ] || cygwin_source_tarball || return 1
    [ -f "cmake-${VERSION}-${RELEASE}.patch" ] || cygwin_source_patch || return 1
    [ -f "cmake-${VERSION}-${RELEASE}.sh" ] || cygwin_package_script || return 1
    echo "Running cygwin packaging script ..." &&
    (
        rm -rf Package &&
        mkdir -p Package &&
        cd Package &&
        cp ../setup.hint . &&
        cp ../cmake-${VERSION}.tar.bz2 . &&
        cp ../cmake-${VERSION}-${RELEASE}.patch . &&
        cp ../cmake-${VERSION}-${RELEASE}.sh . &&
        ./cmake-${VERSION}-${RELEASE}.sh all
    ) >Logs/cygwin_package.log 2>&1 || error_log Logs/cygwin_package.log
}

if [ -z "$TASK" ]; then
    [ -z "$REMOTE" ] && TASK="$@"
fi

if [ -z "$TASK" ]; then
    TASK="usage"
fi

eval $TASK
