# Copyright (c) 2018 kalaksi@users.noreply.github.com.
# This work is licensed under the terms of the MIT license. For a copy, see <https://opensource.org/licenses/MIT>.

FROM alpine:3.11.5

RUN apk add --no-cache tftp-hpa

# Help setting up the basic pxelinux environment
RUN apk add --no-cache --virtual syslinux_with_deps syslinux && \
    mkdir -p -m 0755 /tftpboot && \
    cp -r /usr/share/syslinux /tftpboot && \
    find /tftpboot -type f -exec chmod 444 {} \;  && \
    find /tftpboot -mindepth 1 -type d -exec chmod 555 {} \;  && \
    # Not all systems use pxelinux for PXE (e.g. u-boot). Therefore, the actual directories are 
    # placed in the tftp root and symlinks are provided for the syslinux environment.
    ln -s ../boot /tftpboot/syslinux/boot && \
    ln -s ../pxelinux.cfg /tftpboot/syslinux/pxelinux.cfg && \
    apk del syslinux_with_deps

# Default configuration that can be overridden
COPY pxelinux.cfg /tftpboot/pxelinux.cfg

EXPOSE 1069/udp
# User-provided boot items, e.g. kernels
VOLUME /tftpboot/boot

# The daemon doesn't seem to work if container is not run as root, but it still drops the root
# privileges with the -u option.
# Note that the main process still runs as root, but files are being served as non-root.
CMD set -eu ;\
    # Some devices such as the Raspberry Pi 4 expect files to be available directly in the TFTP root, so
    # use a boot directory with the special name "root" to have it's contents copied to the TFTP root directory.
    [ -d /tftpboot/boot/root ] && cp -a  /tftpboot/boot/root/* /tftpboot ;\
    exec in.tftpd -L -vvv -u ftp --secure --address 0.0.0.0:1069 /tftpboot
