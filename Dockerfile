FROM alpine:3.8

RUN apk add --no-cache tftp-hpa

# Help setting up the basic pxelinux environment
RUN apk add --no-cache --virtual syslinux_with_deps syslinux && \
    mkdir -p /tftpboot && \
    cp -r /usr/share/syslinux /tftpboot && \
    find /tftpboot -type f -exec chmod 444 {} \;  && \
    find /tftpboot -type d -exec chmod 555 {} \;  && \
    ln -s ../boot /tftpboot/syslinux/boot && \
    apk del syslinux_with_deps
COPY pxelinux.cfg /tftpboot/syslinux/pxelinux.cfg

EXPOSE 1069/udp
# User-provided boot items, e.g. kernels
VOLUME /tftpboot/boot

# The daemon doesn't seem to work if container is not run as root, but it still drops the root
# privileges with the -u option.
# Note that the main process still runs as root, but files are being served as non-root.
ENTRYPOINT ["in.tftpd"]
CMD ["-L", "-vvv", "-u", "ftp", "--secure", "--address", "0.0.0.0:1069", "/tftpboot"]
