# Copyright (c) 2018 kalaksi@users.noreply.github.com.
# This work is licensed under the terms of the MIT license. For a copy, see <https://opensource.org/licenses/MIT>.

FROM alpine:3.11.3

RUN apk add --no-cache tftp-hpa

# Help setting up the basic pxelinux environment
RUN apk add --no-cache --virtual syslinux_with_deps syslinux && \
    mkdir -p /tftpboot && \
    cp -r /usr/share/syslinux /tftpboot && \
    find /tftpboot -type f -exec chmod 444 {} \;  && \
    find /tftpboot -type d -exec chmod 555 {} \;  && \
    # Not all systems use pxelinux for PXE (e.g. u-boot). Therefore, the actual directories are 
    # placed in the tftp root and symlinks are provided for the syslinux environment.
    ln -s ../boot /tftpboot/syslinux/boot && \
    ln -s ../pxelinux.cfg /tftpboot/syslinux/pxelinux.cfg && \
    apk del syslinux_with_deps

COPY pxelinux.cfg /tftpboot/pxelinux.cfg

EXPOSE 1069/udp
# User-provided boot items, e.g. kernels
VOLUME /tftpboot/boot

# The daemon doesn't seem to work if container is not run as root, but it still drops the root
# privileges with the -u option.
# Note that the main process still runs as root, but files are being served as non-root.
ENTRYPOINT ["in.tftpd"]
CMD ["-L", "-vvv", "-u", "ftp", "--secure", "--address", "0.0.0.0:1069", "/tftpboot"]
