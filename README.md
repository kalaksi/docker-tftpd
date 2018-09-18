
### Repositories
- [Docker Hub repository](https://registry.hub.docker.com/u/kalaksi/tftpd/)
- [GitHub repository](https://github.com/kalaksi/docker-tftpd)

### What is this container for?
This container runs a TFTP server with a prepopulated ```/tftpboot``` directory with necessary files and configuration for PXE booting.

### Why use this container?
**Simply put, this container has been written with simplicity and security in mind.**

Surprisingly, _many_ community containers run unnecessarily with root privileges by default and don't provide help for dropping unneeded CAPabilities either.
Additionally, overly complex shell scripts and unofficial base images make it harder to verify the source and keep images up-to-date.  

To remedy the situation, these images have been written with security and simplicity in mind. See [Design Goals](#design-goals) further down.

### Running this container
See the example ```docker-compose.yml``` in the source repository.

#### Supported tags
See the ```Tags``` tab on Docker Hub for specifics. Basically you have:
- The default ```latest``` tag that always has the latest changes.
- Minor versioned tags (follow Semantic Versioning), e.g. ```1.1``` which would follow branch ```1.1.x``` on GitHub.

#### Configuration
The user should populate ```/tftpboot/boot``` with bootable images and usually replace the ```/tftpboot/syslinux/pxelinux.cfg``` directory with one having the appropriate configuration. 

Here's an overview of the directory structure with an example boot image for LibreELEC.
```
/tftpboot
 ├── boot                <- Place your boot images here.
 │   └── libreelec
 │       └── KERNEL
 └── syslinux            <- Contains files and configuration directory necessary for PXE booting.
     ├── pxelinux.cfg    <- Configuration directory. Mount your own directory over this to customize.
     │   └── default     <- Example configuration that only contains the "Boot from local disk" option.
     └── ...
 
```
  
And this could be the contents for custom ```pxelinux.cfg/default```:
```
DEFAULT menu.c32
PROMPT 0
TIMEOUT 100
ONTIMEOUT local

MENU TITLE Main Menu
LABEL libreelec
    MENU LABEL LibreELEC
    kernel boot/libreelec/KERNEL
    append <INSERT YOUR BOOT PARAMETERS HERE>

LABEL local
    MENU LABEL Boot from local disk
    LOCALBOOT 0
```

### Development
#### Design Goals
- Never run as root unless necessary.
- No static default passwords. That would make the container insecure by default.
- Use only official base images.
- Provide an example ```docker-compose.yml``` that also shows what CAPabilities can be dropped.
- Offer versioned tags for stability.
- Try to keep everything in the Dockerfile (if reasonable, considering line count and readability).
- Don't restrict configuration possibilities: provide a way to use native config files for the containerized application.
- Handle signals properly.

#### Contributing
See the repository on <https://github.com/kalaksi/docker-tftpd>.
All kinds of contributions are welcome!

### License
View [license information](https://github.com/kalaksi/docker-tftpd/blob/master/LICENSE) for the software contained in this image.  
As with all Docker images, these likely also contain other software which may be under other licenses (such as Bash, etc from the base distribution, along with any direct or indirect dependencies of the primary software being contained).  
  
As for any pre-built image usage, it is the image user's responsibility to ensure that any use of this image complies with any relevant licenses for all software contained within.
