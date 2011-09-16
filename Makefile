# Gluster Storage Platform 2009


SHELL = /bin/bash

# Configurable parameters
SRC            = /sources # inside MOUNT_PT
MOUNT_PT       = /mnt/lfs
INITRAMFS_PT   = /initramfs_build_dir # inside MOUNT_PT
REALROOT_PT    = /realroot_build_dir # inside MOUNT_PT
LUSER          = sac # build user
LGROUP         = sac # build group
LHOME          = /home # build user home
SCRIPT_ROOT    = glustersp # Git checkout

ARCH          ?= `uname -m`
KERNEL_ARCH    = `echo $(ARCH) | sed -e s/i.86/i386/ -e s/sun4u/sparc64/ -e s/arm.*/arm/ -e s/sa110/arm/ -e s/s390x/s390/ -e s/parisc64/parisc/`

BASEDIR        = $(MOUNT_PT)
SRCSDIR        = $(BASEDIR)/sources
CMDSDIR        = $(BASEDIR)/$(SCRIPT_ROOT)/glustersp-commands
LOGDIR         = $(BASEDIR)/$(SCRIPT_ROOT)/logs
TESTLOGDIR     = $(BASEDIR)/$(SCRIPT_ROOT)/test-logs

crCMDSDIR      = /$(SCRIPT_ROOT)/glustersp-commands
crLOGDIR       = /$(SCRIPT_ROOT)/logs
crTESTLOGDIR   = /$(SCRIPT_ROOT)/test-logs
crFILELOGDIR   = /$(SCRIPT_ROOT)/installed-files

SU_LUSER       = su - $(LUSER) -c
LUSER_HOME     = $(LHOME)/$(LUSER)
PRT_DU         = echo -e "\nKB: `du -skx --exclude=$(SCRIPT_ROOT) --exclude=lost+found`\n"
PRT_DU_CR      = echo -e "\nKB: `du -skx --exclude=$(SCRIPT_ROOT) --exclude=lost+found / `\n"
TIME_MARK      = `date +%s.%N`
BUILD_TIME     = perl -e "printf \"\nTotalseconds: %.3f\", ('$$end' - '$$start')"


export PATH := ${PATH}:/usr/sbin

include makefile-functions

CHROOT1= /usr/sbin/chroot $(MOUNT_PT) /tools/bin/env -i HOME=/root TERM="$$TERM" PS1='\u:\w\$$ ' INITRAMFS_PT=$(INITRAMFS_PT) REALROOT_PT=$(REALROOT_PT) ARCH=$(ARCH) PATH=/bin:/usr/bin:/sbin:/usr/sbin:/tools/bin /tools/bin/bash --login +h -c

CHROOT2= /usr/sbin/chroot $(MOUNT_PT) /usr/bin/env -i HOME=/root TERM="$$TERM" PS1='\u:\w\$$ ' PATH=/bin:/usr/bin:/sbin:/usr/sbin /bin/bash --login -c


all:	ck_UID mk_SETUP mk_LUSER mk_SUDO mk_CHROOT mk_BOOT 
	@sudo make do_housekeeping
	@echo "Gluster Storage Platform 2009 (Alpha)" > glustersp-release && \
	sudo mv glustersp-release $(MOUNT_PT)/etc

ck_UID:
	@if [ `id -u` = "0" ]; then \
	  echo "--------------------------------------------------"; \
	  echo "You cannot run this makefile from the root account"; \
	  echo "--------------------------------------------------"; \
	  exit 1; \
	fi

mk_SETUP:
	@$(call echo_SU_request)
	@sudo make BREAKPOINT=$(BREAKPOINT) SETUP
	@touch $@

mk_LUSER: mk_SETUP
	@$(call echo_SULUSER_request)
	@( sudo $(SU_LUSER) "source .bashrc && cd $(MOUNT_PT)/$(SCRIPT_ROOT) && make BREAKPOINT=$(BREAKPOINT) LUSER" )
	@sudo make restore-luser-env
	@touch $@

mk_SUDO: mk_LUSER
	@sudo make BREAKPOINT=$(BREAKPOINT) SUDO
	@touch $@

mk_CHROOT: mk_SUDO
	@$(call echo_CHROOT_request)
	@( sudo $(CHROOT1) "cd $(SCRIPT_ROOT) && make BREAKPOINT=$(BREAKPOINT) CHROOT")
	@touch $@
mk_INITRAMFS: mk_CHROOT
	@$(call echo_CHROOT_request)
	@( sudo $(CHROOT1) "cd $(SCRIPT_ROOT) && make BREAKPOINT=$(BREAKPOINT) INITRAMFS")
	@touch $@

mk_REALROOT: mk_INITRAMFS
	@$(call echo_CHROOT_request)
	@( sudo $(CHROOT1) "cd $(SCRIPT_ROOT) && make BREAKPOINT=$(BREAKPOINT) REALROOT")
	@touch $@

mk_BOOT: mk_REALROOT
	@$(call echo_CHROOT_request)
	@( sudo $(CHROOT2) "cd $(SCRIPT_ROOT) && make BREAKPOINT=$(BREAKPOINT) BOOT")
	@touch $@

SETUP:         020-creatingtoolsdir 021-addinguser 022-settingenvironment
LUSER:         029-binutils-pass1 030-gcc-pass1 031-linux-headers 032-glibc 033-adjusting 038-binutils-pass2 037-gcc-pass2 039-ncurses 040-bash 041-bzip2 042-coreutils 043-diffutils 044-e2fsprogs 045-findutils 046-gawk 047-gettext 048-grep 049-gzip 050-m4 051-make 052-patch 053-perl 054-sed 055-tar 056-texinfo 057-util-linux-ng 058-stripping
SUDO:           
CHROOT:       SHELL=/tools/bin/bash
CHROOT:       064-creatingdirs 065-createfiles 066-linux-headers 067-man-pages 068-glibc 069-readjusting 074-db 075-sed 076-e2fsprogs 077-coreutils 078-iana-etc 079-m4 080-bison 081-ncurses 082-procps 083-libtool 084-zlib 086-readline 089-bash 085-perl 087-autoconf 088-automake 090-bzip2 091-diffutils 092-file 093-gawk 094-findutils 095-flex 098-grep 099-groff 100-gzip 101-inetutils 102-iproute2 103-kbd 104-less 105-make 107-module-init-tools 108-patch 109-psmisc 110-shadow 111-sysklogd 112-sysvinit 113-tar 114-texinfo 115-udev 116-util-linux-ng 117-vim 136-kernel 138-apache 139-libxml 140-php 141-cpio 142-squashfs 119-strippingagain 
INITRAMFS:     SHELL=/tools/bin/bash
INITRAMFS:     200-setupinitramfs 201-klibc 202-udev 203-busybox 204-module-init-tools 205-cpioinitramfs
REALROOT:      SHELL=/tools/bin/bash
REALROOT:      300-setuprealroot 301-ncurses 302-readline 303-python 304-dialog 305-bzip2 306-gzip 307-kernel 308-xfsprogs 309-reiserfsprogs 310-parted 311-pciutils 312-zlib 313-bash 314-grep 316-udev 318-iproute2 319-module-init-tools 320-zile 321-procps 322-iputils 323-pcre 324-sysvinit 325-e2fsprogs 326-util-linux-ng 327-coreutils 328-sed 329-gawk 330-tar 331-squashfsrealroot
BOOT:          122-bootscripts 125-setclock 128-inputrc 129-profile 130-hostname 131-hosts 133-network 135-fstab 



restore-luser-env:
	@$(call echo_message, Building)
	@if [ -f $(LUSER_HOME)/.bashrc.XXX ]; then \
		mv -f $(LUSER_HOME)/.bashrc.XXX $(LUSER_HOME)/.bashrc; \
	fi;
	@if [ -f $(LUSER_HOME)/.bash_profile.XXX ]; then \
		mv $(LUSER_HOME)/.bash_profile.XXX $(LUSER_HOME)/.bash_profile; \
	fi;
	@chown $(LUSER):$(LGROUP) $(LUSER_HOME)/.bash*
	@$(call housekeeping)

do_housekeeping:
	@-umount $(MOUNT_PT)/sys
	@-umount $(MOUNT_PT)/proc
	@-umount $(MOUNT_PT)/dev/shm
	@-umount $(MOUNT_PT)/dev/pts
	@-umount $(MOUNT_PT)/dev
	@-if [ ! -f luser-exist ]; then \
	@-fi;


020-creatingtoolsdir:
	@$(call echo_message, Building)
	@mkdir $(MOUNT_PT)/tools && \
	rm -f /tools && \
	ln -s $(MOUNT_PT)/tools /
	@$(call housekeeping)

021-addinguser:  020-creatingtoolsdir
	@$(call echo_message, Building)
	@if [ ! -d $(LUSER_HOME) ]; then \
		groupadd $(LGROUP); \
		useradd -s /bin/bash -g $(LGROUP) -m -k /dev/null $(LUSER); \
	else \
		touch luser-exist; \
	fi;
	@chown $(LUSER) $(MOUNT_PT)/tools && \
	chmod -R a+wt $(MOUNT_PT)/$(SCRIPT_ROOT) && \
	chmod a+wt $(SRCSDIR)
	@$(call housekeeping)

022-settingenvironment:  021-addinguser
	@$(call echo_message, Building)
	@if [ -f $(LUSER_HOME)/.bashrc -a ! -f $(LUSER_HOME)/.bashrc.XXX ]; then \
		mv $(LUSER_HOME)/.bashrc $(LUSER_HOME)/.bashrc.XXX; \
	fi;
	@if [ -f $(LUSER_HOME)/.bash_profile  -a ! -f $(LUSER_HOME)/.bash_profile.XXX ]; then \
		mv $(LUSER_HOME)/.bash_profile $(LUSER_HOME)/.bash_profile.XXX; \
	fi;
	@echo "set +h" > $(LUSER_HOME)/.bashrc && \
	echo "umask 022" >> $(LUSER_HOME)/.bashrc && \
	echo "GLUSTERSP=$(MOUNT_PT)" >> $(LUSER_HOME)/.bashrc && \
	echo "LC_ALL=POSIX" >> $(LUSER_HOME)/.bashrc && \
	echo "PATH=/tools/bin:/bin:/usr/bin" >> $(LUSER_HOME)/.bashrc && \
	echo "export GLUSTERSP LC_ALL PATH" >> $(LUSER_HOME)/.bashrc && \
	echo "source /home/harsha/glusteros_build_dir/glusteros/envars" >> $(LUSER_HOME)/.bashrc && \
	chown $(LUSER):$(LGROUP) $(LUSER_HOME)/.bashrc && \
	touch envars && \
	chown $(LUSER) envars
	@$(call housekeeping)

029-binutils-pass1:  022-settingenvironment
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU) >>logs/$@
	@$(call remove_existing_dirs,binutils-2.18.tar.bz2)
	@$(call unpack,binutils-2.18.tar.bz2)
	@$(call get_pkg_root_LUSER)
	@start=$(TIME_MARK) && \
	source basic-envars && \
	$(CMDSDIR)/init/$@ >> logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU) >>logs/$@
	@$(call remove_build_dirs,binutils)
	@$(call housekeeping)

030-gcc-pass1:  029-binutils-pass1
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU) >>logs/$@
	@$(call remove_existing_dirs,gcc-4.3.2.tar.bz2)
	@$(call unpack,gcc-4.3.2.tar.bz2)
	@$(call get_pkg_root_LUSER)
	@start=$(TIME_MARK) && \
	source basic-envars && \
	$(CMDSDIR)/init/$@ >> logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU) >>logs/$@
	@$(call remove_build_dirs,gcc)
	@$(call housekeeping)

031-linux-headers:  030-gcc-pass1
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU) >>logs/$@
	@$(call remove_existing_dirs,linux-2.6.27.4.tar.bz2)
	@$(call unpack,linux-2.6.27.4.tar.bz2)
	@$(call get_pkg_root_LUSER)
	@start=$(TIME_MARK) && \
	source basic-envars && \
	$(CMDSDIR)/init/$@ >> logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU) >>logs/$@
	@$(call remove_build_dirs,linux-headers)
	@$(call housekeeping)

032-glibc:  031-linux-headers
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU) >>logs/$@
	@$(call remove_existing_dirs,glibc-2.8-20080929.tar.bz2)
	@$(call unpack,glibc-2.8-20080929.tar.bz2)
	@$(call get_pkg_root_LUSER)
	@start=$(TIME_MARK) && \
	source basic-envars && \
	$(CMDSDIR)/init/$@ >> logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU) >>logs/$@
	@$(call remove_build_dirs,glibc)
	@$(call housekeeping)

033-adjusting:  032-glibc
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU) >>logs/$@
	@start=$(TIME_MARK) && \
	source basic-envars && \
	$(CMDSDIR)/init/$@ >> logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU) >>logs/$@
	@$(call housekeeping)

038-binutils-pass2:  033-adjusting
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU) >>logs/$@
	@$(call remove_existing_dirs,binutils-2.18.tar.bz2)
	@$(call unpack,binutils-2.18.tar.bz2)
	@$(call get_pkg_root_LUSER)
	@start=$(TIME_MARK) && \
	source basic-envars && \
	$(CMDSDIR)/init/$@ >> logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU) >>logs/$@
	@$(call remove_build_dirs,binutils)
	@$(call housekeeping)

037-gcc-pass2:  038-binutils-pass2
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU) >>logs/$@
	@$(call remove_existing_dirs,gcc-4.3.2.tar.bz2)
	@$(call unpack,gcc-4.3.2.tar.bz2)
	@$(call get_pkg_root_LUSER)
	@start=$(TIME_MARK) && \
	source basic-envars && \
	$(CMDSDIR)/init/$@ >> logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU) >>logs/$@
	@$(call remove_build_dirs,gcc)
	@$(call housekeeping)

039-ncurses:  037-gcc-pass2
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU) >>logs/$@
	@$(call remove_existing_dirs,ncurses-5.6.tar.gz)
	@$(call unpack,ncurses-5.6.tar.gz)
	@$(call get_pkg_root_LUSER)
	@start=$(TIME_MARK) && \
	source basic-envars && \
	$(CMDSDIR)/init/$@ >> logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU) >>logs/$@
	@$(call remove_build_dirs,ncurses)
	@$(call housekeeping)

040-bash:  039-ncurses
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU) >>logs/$@
	@$(call remove_existing_dirs,bash-3.2.tar.gz)
	@$(call unpack,bash-3.2.tar.gz)
	@$(call get_pkg_root_LUSER)
	@start=$(TIME_MARK) && \
	source basic-envars && \
	$(CMDSDIR)/init/$@ >> logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU) >>logs/$@
	@$(call remove_build_dirs,bash)
	@$(call housekeeping)

041-bzip2:  040-bash
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU) >>logs/$@
	@$(call remove_existing_dirs,bzip2-1.0.5.tar.gz)
	@$(call unpack,bzip2-1.0.5.tar.gz)
	@$(call get_pkg_root_LUSER)
	@start=$(TIME_MARK) && \
	source basic-envars && \
	$(CMDSDIR)/init/$@ >> logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU) >>logs/$@
	@$(call remove_build_dirs,bzip2)
	@$(call housekeeping)

042-coreutils:  041-bzip2
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU) >>logs/$@
	@$(call remove_existing_dirs,coreutils-6.12.tar.gz)
	@$(call unpack,coreutils-6.12.tar.gz)
	@$(call get_pkg_root_LUSER)
	@start=$(TIME_MARK) && \
	source basic-envars && \
	$(CMDSDIR)/init/$@ >> logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU) >>logs/$@
	@$(call remove_build_dirs,coreutils)
	@$(call housekeeping)

043-diffutils:  042-coreutils
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU) >>logs/$@
	@$(call remove_existing_dirs,diffutils-2.8.1.tar.gz)
	@$(call unpack,diffutils-2.8.1.tar.gz)
	@$(call get_pkg_root_LUSER)
	@start=$(TIME_MARK) && \
	source basic-envars && \
	$(CMDSDIR)/init/$@ >> logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU) >>logs/$@
	@$(call remove_build_dirs,diffutils)
	@$(call housekeeping)

044-e2fsprogs:  043-diffutils
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU) >>logs/$@
	@$(call remove_existing_dirs,e2fsprogs-1.41.3.tar.gz)
	@$(call unpack,e2fsprogs-1.41.3.tar.gz)
	@$(call get_pkg_root_LUSER)
	@start=$(TIME_MARK) && \
	source basic-envars && \
	$(CMDSDIR)/init/$@ >> logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU) >>logs/$@
	@$(call remove_build_dirs,e2fsprogs)
	@$(call housekeeping)

045-findutils:  044-e2fsprogs
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU) >>logs/$@
	@$(call remove_existing_dirs,findutils-4.4.0.tar.gz)
	@$(call unpack,findutils-4.4.0.tar.gz)
	@$(call get_pkg_root_LUSER)
	@start=$(TIME_MARK) && \
	source basic-envars && \
	$(CMDSDIR)/init/$@ >> logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU) >>logs/$@
	@$(call remove_build_dirs,findutils)
	@$(call housekeeping)

046-gawk:  045-findutils
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU) >>logs/$@
	@$(call remove_existing_dirs,gawk-3.1.6.tar.bz2)
	@$(call unpack,gawk-3.1.6.tar.bz2)
	@$(call get_pkg_root_LUSER)
	@start=$(TIME_MARK) && \
	source basic-envars && \
	$(CMDSDIR)/init/$@ >> logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU) >>logs/$@
	@$(call remove_build_dirs,gawk)
	@$(call housekeeping)

047-gettext:  046-gawk
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU) >>logs/$@
	@$(call remove_existing_dirs,gettext-0.17.tar.gz)
	@$(call unpack,gettext-0.17.tar.gz)
	@$(call get_pkg_root_LUSER)
	@start=$(TIME_MARK) && \
	source basic-envars && \
	$(CMDSDIR)/init/$@ >> logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU) >>logs/$@
	@$(call remove_build_dirs,gettext)
	@$(call housekeeping)

048-grep:  047-gettext
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU) >>logs/$@
	@$(call remove_existing_dirs,grep-2.5.3.tar.bz2)
	@$(call unpack,grep-2.5.3.tar.bz2)
	@$(call get_pkg_root_LUSER)
	@start=$(TIME_MARK) && \
	source basic-envars && \
	$(CMDSDIR)/init/$@ >> logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU) >>logs/$@
	@$(call remove_build_dirs,grep)
	@$(call housekeeping)

049-gzip:  048-grep
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU) >>logs/$@
	@$(call remove_existing_dirs,gzip-1.3.12.tar.gz)
	@$(call unpack,gzip-1.3.12.tar.gz)
	@$(call get_pkg_root_LUSER)
	@start=$(TIME_MARK) && \
	source basic-envars && \
	$(CMDSDIR)/init/$@ >> logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU) >>logs/$@
	@$(call remove_build_dirs,gzip)
	@$(call housekeeping)

050-m4:  049-gzip
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU) >>logs/$@
	@$(call remove_existing_dirs,m4-1.4.12.tar.bz2)
	@$(call unpack,m4-1.4.12.tar.bz2)
	@$(call get_pkg_root_LUSER)
	@start=$(TIME_MARK) && \
	source basic-envars && \
	$(CMDSDIR)/init/$@ >> logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU) >>logs/$@
	@$(call remove_build_dirs,m4)
	@$(call housekeeping)

051-make:  050-m4
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU) >>logs/$@
	@$(call remove_existing_dirs,make-3.81.tar.bz2)
	@$(call unpack,make-3.81.tar.bz2)
	@$(call get_pkg_root_LUSER)
	@start=$(TIME_MARK) && \
	source basic-envars && \
	$(CMDSDIR)/init/$@ >> logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU) >>logs/$@
	@$(call remove_build_dirs,make)
	@$(call housekeeping)

052-patch:  051-make
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU) >>logs/$@
	@$(call remove_existing_dirs,patch-2.5.4.tar.gz)
	@$(call unpack,patch-2.5.4.tar.gz)
	@$(call get_pkg_root_LUSER)
	@start=$(TIME_MARK) && \
	source basic-envars && \
	$(CMDSDIR)/init/$@ >> logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU) >>logs/$@
	@$(call remove_build_dirs,patch)
	@$(call housekeeping)

053-perl:  052-patch
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU) >>logs/$@
	@$(call remove_existing_dirs,perl-5.10.0.tar.gz)
	@$(call unpack,perl-5.10.0.tar.gz)
	@$(call get_pkg_root_LUSER)
	@start=$(TIME_MARK) && \
	source basic-envars && \
	$(CMDSDIR)/init/$@ >> logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU) >>logs/$@
	@$(call remove_build_dirs,perl)
	@$(call housekeeping)

054-sed:  053-perl
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU) >>logs/$@
	@$(call remove_existing_dirs,sed-4.1.5.tar.gz)
	@$(call unpack,sed-4.1.5.tar.gz)
	@$(call get_pkg_root_LUSER)
	@start=$(TIME_MARK) && \
	source basic-envars && \
	$(CMDSDIR)/init/$@ >> logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU) >>logs/$@
	@$(call remove_build_dirs,sed)
	@$(call housekeeping)

055-tar:  054-sed
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU) >>logs/$@
	@$(call remove_existing_dirs,tar-1.20.tar.bz2)
	@$(call unpack,tar-1.20.tar.bz2)
	@$(call get_pkg_root_LUSER)
	@start=$(TIME_MARK) && \
	source basic-envars && \
	$(CMDSDIR)/init/$@ >> logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU) >>logs/$@
	@$(call remove_build_dirs,tar)
	@$(call housekeeping)

056-texinfo:  055-tar
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU) >>logs/$@
	@$(call remove_existing_dirs,texinfo-4.13a.tar.gz)
	@$(call unpack,texinfo-4.13a.tar.gz)
	@$(call get_pkg_root_LUSER)
	@start=$(TIME_MARK) && \
	source basic-envars && \
	$(CMDSDIR)/init/$@ >> logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU) >>logs/$@
	@$(call remove_build_dirs,texinfo)
	@$(call housekeeping)

057-util-linux-ng:  056-texinfo
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU) >>logs/$@
	@$(call remove_existing_dirs,util-linux-ng-2.14.1.tar.bz2)
	@$(call unpack,util-linux-ng-2.14.1.tar.bz2)
	@$(call get_pkg_root_LUSER)
	@start=$(TIME_MARK) && \
	source basic-envars && \
	$(CMDSDIR)/init/$@ >> logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU) >>logs/$@
	@$(call remove_build_dirs,util-linux-ng)
	@$(call housekeeping)

058-stripping:  057-util-linux-ng
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU) >>logs/$@
	@start=$(TIME_MARK) && \
	source basic-envars && \
	$(CMDSDIR)/init/$@ >> logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU) >>logs/$@
	@$(call housekeeping)

059-changingowner:  058-stripping
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU) >>logs/$@
	@start=$(TIME_MARK) && \
	export GLUSTERSP=$(MOUNT_PT) && \
	glustersp-commands/init/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU) >>logs/$@
	@$(call housekeeping)

061-kernfs:  059-changingowner
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU) >>logs/$@
	@start=$(TIME_MARK) && \
	export GLUSTERSP=$(MOUNT_PT) && \
	glustersp-commands/intermediate/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU) >>logs/$@
	@$(call housekeeping)

064-creatingdirs:  061-kernfs
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/intermediate/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call housekeeping)

065-createfiles:  064-creatingdirs
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/intermediate/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call housekeeping)

066-linux-headers:  065-createfiles
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,linux-2.6.27.4.tar.bz2)
	@$(call unpack2,linux-2.6.27.4.tar.bz2)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/intermediate/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,linux-headers)
	@$(call housekeeping)

067-man-pages:  066-linux-headers
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,man-pages-3.11.tar.bz2)
	@$(call unpack2,man-pages-3.11.tar.bz2)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/intermediate/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,man-pages)
	@$(call housekeeping)

068-glibc:  067-man-pages
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,glibc-2.8-20080929.tar.bz2)
	@$(call unpack2,glibc-2.8-20080929.tar.bz2)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/intermediate/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,glibc)
	@$(call housekeeping)

069-readjusting:  068-glibc
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/intermediate/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call housekeeping)

070-binutils:  069-readjusting
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,binutils-2.18.tar.bz2)
	@$(call unpack2,binutils-2.18.tar.bz2)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/intermediate/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,binutils)
	@$(call housekeeping)

071-gmp:  070-binutils
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,gmp-4.2.4.tar.bz2)
	@$(call unpack2,gmp-4.2.4.tar.bz2)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/intermediate/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,gmp)
	@$(call housekeeping)

072-mpfr:  071-gmp
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,mpfr-2.3.2.tar.bz2)
	@$(call unpack2,mpfr-2.3.2.tar.bz2)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/intermediate/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,mpfr)
	@$(call housekeeping)

073-gcc:  072-mpfr
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,gcc-4.3.2.tar.bz2)
	@$(call unpack2,gcc-4.3.2.tar.bz2)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/intermediate/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,gcc)
	@$(call housekeeping)

074-db:  069-readjusting
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,db-4.7.25.tar.gz)
	@$(call unpack2,db-4.7.25.tar.gz)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/intermediate/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,db)
	@$(call housekeeping)

075-sed:  074-db
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,sed-4.1.5.tar.gz)
	@$(call unpack2,sed-4.1.5.tar.gz)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/intermediate/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,sed)
	@$(call housekeeping)

076-e2fsprogs:  075-sed
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,e2fsprogs-1.41.3.tar.gz)
	@$(call unpack2,e2fsprogs-1.41.3.tar.gz)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/intermediate/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,e2fsprogs)
	@$(call housekeeping)

077-coreutils:  076-e2fsprogs
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,coreutils-6.12.tar.gz)
	@$(call unpack2,coreutils-6.12.tar.gz)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/intermediate/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,coreutils)
	@$(call housekeeping)

078-iana-etc:  077-coreutils
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,iana-etc-2.30.tar.bz2)
	@$(call unpack2,iana-etc-2.30.tar.bz2)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/intermediate/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,iana-etc)
	@$(call housekeeping)

079-m4:  078-iana-etc
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,m4-1.4.12.tar.bz2)
	@$(call unpack2,m4-1.4.12.tar.bz2)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/intermediate/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,m4)
	@$(call housekeeping)

080-bison:  079-m4
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,bison-2.3.tar.bz2)
	@$(call unpack2,bison-2.3.tar.bz2)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/intermediate/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,bison)
	@$(call housekeeping)

081-ncurses:  080-bison
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,ncurses-5.6.tar.gz)
	@$(call unpack2,ncurses-5.6.tar.gz)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/intermediate/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,ncurses)
	@$(call housekeeping)

082-procps:  081-ncurses
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,procps-3.2.7.tar.gz)
	@$(call unpack2,procps-3.2.7.tar.gz)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/intermediate/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,procps)
	@$(call housekeeping)

083-libtool:  082-procps
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,libtool-2.2.6a.tar.gz)
	@$(call unpack2,libtool-2.2.6a.tar.gz)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/intermediate/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,libtool)
	@$(call housekeeping)

084-zlib:  083-libtool
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,zlib-1.2.3.tar.bz2)
	@$(call unpack2,zlib-1.2.3.tar.bz2)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/intermediate/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,zlib)
	@$(call housekeeping)

085-perl: 084-zlib
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,perl-5.10.0.tar.gz)
	@$(call unpack2,perl-5.10.0.tar.gz)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/intermediate/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,perl)
	@$(call housekeeping)

086-readline:  085-perl
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,readline-5.2.tar.gz)
	@$(call unpack2,readline-5.2.tar.gz)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/intermediate/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,readline)
	@$(call housekeeping)

087-autoconf:  086-readline
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,autoconf-2.63.tar.bz2)
	@$(call unpack2,autoconf-2.63.tar.bz2)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/intermediate/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,autoconf)
	@$(call housekeeping)

088-automake:  087-autoconf
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,automake-1.10.1.tar.bz2)
	@$(call unpack2,automake-1.10.1.tar.bz2)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/intermediate/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,automake)
	@$(call housekeeping)

089-bash:  088-automake
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,bash-3.2.tar.gz)
	@$(call unpack2,bash-3.2.tar.gz)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/intermediate/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,bash)
	@$(call housekeeping)

090-bzip2:  089-bash
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,bzip2-1.0.5.tar.gz)
	@$(call unpack2,bzip2-1.0.5.tar.gz)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/intermediate/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,bzip2)
	@$(call housekeeping)

091-diffutils:  090-bzip2
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,diffutils-2.8.1.tar.gz)
	@$(call unpack2,diffutils-2.8.1.tar.gz)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/intermediate/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,diffutils)
	@$(call housekeeping)

092-file:  091-diffutils
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,file-4.26.tar.gz)
	@$(call unpack2,file-4.26.tar.gz)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/intermediate/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,file)
	@$(call housekeeping)

093-gawk:  092-file
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,gawk-3.1.6.tar.bz2)
	@$(call unpack2,gawk-3.1.6.tar.bz2)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/intermediate/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,gawk)
	@$(call housekeeping)

094-findutils:  093-gawk
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,findutils-4.4.0.tar.gz)
	@$(call unpack2,findutils-4.4.0.tar.gz)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/intermediate/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,findutils)
	@$(call housekeeping)

095-flex:  094-findutils
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,flex-2.5.35.tar.bz2)
	@$(call unpack2,flex-2.5.35.tar.bz2)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/intermediate/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,flex)
	@$(call housekeeping)

098-grep: 095-flex
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,grep-2.5.3.tar.bz2)
	@$(call unpack2,grep-2.5.3.tar.bz2)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/intermediate/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,grep)
	@$(call housekeeping)

099-groff:  098-grep
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,groff-1.18.1.4.tar.gz)
	@$(call unpack2,groff-1.18.1.4.tar.gz)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/intermediate/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,groff)
	@$(call housekeeping)

100-gzip:  099-groff
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,gzip-1.3.12.tar.gz)
	@$(call unpack2,gzip-1.3.12.tar.gz)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/intermediate/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,gzip)
	@$(call housekeeping)

101-inetutils:  100-gzip
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,inetutils-1.5.tar.gz)
	@$(call unpack2,inetutils-1.5.tar.gz)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/intermediate/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,inetutils)
	@$(call housekeeping)

102-iproute2:  101-inetutils
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,iproute2-2.6.26.tar.bz2)
	@$(call unpack2,iproute2-2.6.26.tar.bz2)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/intermediate/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,iproute2)
	@$(call housekeeping)

103-kbd:  102-iproute2
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,kbd-1.14.1.tar.gz)
	@$(call unpack2,kbd-1.14.1.tar.gz)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/intermediate/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,kbd)
	@$(call housekeeping)

104-less:  103-kbd
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,less-418.tar.gz)
	@$(call unpack2,less-418.tar.gz)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/intermediate/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,less)
	@$(call housekeeping)

105-make:  104-less
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,make-3.81.tar.bz2)
	@$(call unpack2,make-3.81.tar.bz2)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/intermediate/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,make)
	@$(call housekeeping)

106-man-db:  105-make
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,man-db-2.5.2.tar.gz)
	@$(call unpack2,man-db-2.5.2.tar.gz)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/intermediate/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,man-db)
	@$(call housekeeping)

107-module-init-tools:  105-make
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,module-init-tools-3.4.1.tar.bz2)
	@$(call unpack2,module-init-tools-3.4.1.tar.bz2)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/intermediate/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,module-init-tools)
	@$(call housekeeping)

108-patch:  107-module-init-tools
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,patch-2.5.4.tar.gz)
	@$(call unpack2,patch-2.5.4.tar.gz)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/intermediate/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,patch)
	@$(call housekeeping)

109-psmisc:  108-patch
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,psmisc-22.6.tar.gz)
	@$(call unpack2,psmisc-22.6.tar.gz)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/intermediate/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,psmisc)
	@$(call housekeeping)

110-shadow:  109-psmisc
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,shadow-4.1.2.1.tar.bz2)
	@$(call unpack2,shadow-4.1.2.1.tar.bz2)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/intermediate/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,shadow)
	@$(call housekeeping)

111-sysklogd:  110-shadow
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,sysklogd-1.5.tar.gz)
	@$(call unpack2,sysklogd-1.5.tar.gz)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/intermediate/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,sysklogd)
	@$(call housekeeping)

112-sysvinit:  111-sysklogd
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,sysvinit-2.86.tar.gz)
	@$(call unpack2,sysvinit-2.86.tar.gz)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/intermediate/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,sysvinit)
	@$(call housekeeping)

113-tar:  112-sysvinit
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,tar-1.20.tar.bz2)
	@$(call unpack2,tar-1.20.tar.bz2)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/intermediate/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,tar)
	@$(call housekeeping)

114-texinfo:  113-tar
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,texinfo-4.13a.tar.gz)
	@$(call unpack2,texinfo-4.13a.tar.gz)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/intermediate/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,texinfo)
	@$(call housekeeping)

115-udev:  114-texinfo
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,udev-130.tar.bz2)
	@$(call unpack2,udev-130.tar.bz2)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/intermediate/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,udev)
	@$(call housekeeping)

116-util-linux-ng:  115-udev
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,util-linux-ng-2.14.1.tar.bz2)
	@$(call unpack2,util-linux-ng-2.14.1.tar.bz2)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/intermediate/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,util-linux-ng)
	@$(call housekeeping)

117-vim:  116-util-linux-ng
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,vim-7.2.tar.bz2)
	@$(call unpack2,vim-7.2.tar.bz2)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/intermediate/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,vim)
	@$(call housekeeping)

119-strippingagain:  117-vim
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/intermediate/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call housekeeping)



122-bootscripts:  119-strippingagain
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,lfs-bootscripts-20081031.tar.bz2)
	@$(call unpack2,lfs-bootscripts-20081031.tar.bz2)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/final/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,dummy)
	@$(call housekeeping)

125-setclock:  122-bootscripts
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/final/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call housekeeping)

128-inputrc:  125-setclock
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/final/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call housekeeping)

129-profile:  128-inputrc
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/final/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call housekeeping)

130-hostname:  129-profile
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/final/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call housekeeping)

131-hosts:  130-hostname
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/final/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call housekeeping)

133-network:  131-hosts
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/final/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call housekeeping)

135-fstab:  133-network
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/additional/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call housekeeping)

136-kernel: 
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU) >>logs/$@
	@$(call remove_existing_dirs2,linux-2.6.27.4.tar.bz2)
	@$(call unpack2,linux-2.6.27.4.tar.bz2)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/additional/$@ >> logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU) >>logs/$@
	@$(call remove_build_dirs2,linux-headers)
	@$(call housekeeping)

138-apache:
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU) >>logs/$@
	@$(call remove_existing_dirs2,httpd-2.2.8.tar.bz2)
	@$(call unpack2,httpd-2.2.8.tar.bz2)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/additional/$@ >> logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU) >>logs/$@
	@$(call remove_build_dirs2,apache)
	@$(call housekeeping)

139-libxml: 138-apache
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU) >>logs/$@
	@$(call remove_existing_dirs2,libxml2-2.6.31.tar.gz)
	@$(call unpack2,libxml2-2.6.31.tar.gz)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/additional/$@ >> logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU) >>logs/$@
	@$(call remove_build_dirs2,libxml)
	@$(call housekeeping)

140-php: 139-libxml
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU) >>logs/$@
	@$(call remove_existing_dirs2,php-5.2.3.tar.gz)
	@$(call unpack2,php-5.2.3.tar.gz)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/additional/$@ >> logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU) >>logs/$@
	@$(call remove_build_dirs2,php)
	@$(call housekeeping)

141-cpio:
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU) >>logs/$@
	@$(call remove_existing_dirs2,cpio-2.9.tar.bz2)
	@$(call unpack2,cpio-2.9.tar.bz2)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/additional/$@ >> logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU) >>logs/$@
	@$(call remove_build_dirs2,cpio)
	@$(call housekeeping)

142-squashfs:
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU) >>logs/$@
	@$(call remove_existing_dirs2,squashfs3.4.tar.gz)
	@$(call unpack2,squashfs3.4.tar.gz)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/additional/$@ >> logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU) >>logs/$@
	@$(call remove_build_dirs2,squashfs)
	@$(call housekeeping)

## INITRAMFS Section ##

200-setupinitramfs:
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/initramfs/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call housekeeping)

201-klibc: 200-setupinitramfs
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU) >>logs/$@
	@$(call remove_existing_dirs2,klibc-1.5.tar.gz)
	@$(call unpack2,klibc-1.5.tar.gz)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/initramfs/$@ >> logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU) >>logs/$@
	@$(call remove_build_dirs2,klibc)
	@$(call housekeeping)

202-udev: 201-klibc
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,udev-130.tar.bz2)
	@$(call unpack2,udev-130.tar.bz2)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/initramfs/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,udev)
	@$(call housekeeping)

203-busybox: 202-udev
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,busybox-1.13.3.tar.gz)
	@$(call unpack2,busybox-1.13.3.tar.gz)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/initramfs/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,busybox)
	@$(call housekeeping)

204-module-init-tools: 203-busybox
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,module-init-tools-3.4.1.tar.bz2)
	@$(call unpack2,module-init-tools-3.4.1.tar.bz2)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/initramfs/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,module-init-tools)
	@$(call housekeeping)

205-cpioinitramfs: 204-module-init-tools
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/initramfs/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call housekeeping)

## REALROOT Section ##

300-setuprealroot:
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/realroot/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call housekeeping)

301-ncurses: 300-setuprealroot
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,ncurses-5.6.tar.gz)
	@$(call unpack2,ncurses-5.6.tar.gz)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/realroot/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,ncurses)
	@$(call housekeeping)

302-readline: 301-ncurses
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,readline-5.2.tar.gz)
	@$(call unpack2,readline-5.2.tar.gz)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/realroot/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,readline)
	@$(call housekeeping)

303-python: 302-readline
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,Python-2.5.2.tar.bz2)
	@$(call unpack2,Python-2.5.2.tar.bz2)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/realroot/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,Python)
	@$(call housekeeping)

304-dialog: 303-python
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,dialog-1.1-20080819.tar.gz)
	@$(call unpack2,dialog-1.1-20080819.tar.gz)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/realroot/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,dialog)
	@$(call housekeeping)

305-bzip2: 304-dialog
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,bzip2-1.0.5.tar.gz)
	@$(call unpack2,bzip2-1.0.5.tar.gz)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/realroot/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,bzip2)
	@$(call housekeeping)

306-gzip: 305-bzip2
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,gzip-1.3.12.tar.gz)
	@$(call unpack2,gzip-1.3.12.tar.gz)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/realroot/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,gzip)
	@$(call housekeeping)

307-kernel: 306-gzip
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/realroot/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call housekeeping)

308-xfsprogs: 307-kernel
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,xfsprogs-3.0.0.tar.gz)
	@$(call unpack2,xfsprogs-3.0.0.tar.gz)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/realroot/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,xfsprogs)
	@$(call housekeeping)

309-reiserfsprogs: 308-xfsprogs
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,reiserfsprogs-3.6.21.tar.gz)
	@$(call unpack2,reiserfsprogs-3.6.21.tar.gz)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/realroot/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,reiserfsprogs)
	@$(call housekeeping)

310-parted: 309-reiserfsprogs
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,parted-1.8.8.tar.bz2)
	@$(call unpack2,parted-1.8.8.tar.bz2)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/realroot/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,parted)
	@$(call housekeeping)

311-pciutils: 310-parted
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,pciutils-3.1.2.tar.gz)
	@$(call unpack2,pciutils-3.1.2.tar.gz)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/realroot/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,pciutils)
	@$(call housekeeping)

312-zlib:  311-pciutils
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,zlib-1.2.3.tar.bz2)
	@$(call unpack2,zlib-1.2.3.tar.bz2)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/realroot/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,zlib)
	@$(call housekeeping)

313-bash: 312-zlib 
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,bash-3.2.tar.gz)
	@$(call unpack2,bash-3.2.tar.gz)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/realroot/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,bash)
	@$(call housekeeping)

314-grep: 313-bash
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,grep-2.5.3.tar.bz2)
	@$(call unpack2,grep-2.5.3.tar.bz2)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/realroot/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,grep)
	@$(call housekeeping)

316-udev: 314-grep
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,udev-130.tar.bz2)
	@$(call unpack2,udev-130.tar.bz2)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/realroot/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,udev)
	@$(call housekeeping)

318-iproute2: 316-udev
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,iproute2-2.6.26.tar.bz2)
	@$(call unpack2,iproute2-2.6.26.tar.bz2)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/realroot/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,iproute2)
	@$(call housekeeping)

319-module-init-tools: 318-iproute2
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,module-init-tools-3.4.1.tar.bz2)
	@$(call unpack2,module-init-tools-3.4.1.tar.bz2)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/realroot/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,module-init-tools)
	@$(call housekeeping)

320-zile: 319-module-init-tools
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,zile-2.2.61.tar.gz)
	@$(call unpack2,zile-2.2.61.tar.gz)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/realroot/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,zile)
	@$(call housekeeping)

321-procps: 320-zile
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,procps-3.2.7.tar.gz)
	@$(call unpack2,procps-3.2.7.tar.gz)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/realroot/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,procps)
	@$(call housekeeping)

322-iputils: 321-procps
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,iputils-s20071127.tar.bz2)
	@$(call unpack2,iputils-s20071127.tar.bz2)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/realroot/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,iputils)
	@$(call housekeeping)

323-pcre: 322-iputils
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,pcre-7.8.tar.gz)
	@$(call unpack2,pcre-7.8.tar.gz)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/realroot/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,pcre)
	@$(call housekeeping)

324-sysvinit: 323-pcre
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,sysvinit-2.86.tar.gz)
	@$(call unpack2,sysvinit-2.86.tar.gz)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/realroot/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,sysvinit)
	@$(call housekeeping)

325-e2fsprogs: 324-sysvinit
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,e2fsprogs-1.41.3.tar.gz)
	@$(call unpack2,e2fsprogs-1.41.3.tar.gz)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/realroot/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,e2fsprogs)
	@$(call housekeeping)

326-util-linux-ng: 325-e2fsprogs
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,util-linux-ng-2.14.1.tar.bz2)
	@$(call unpack2,util-linux-ng-2.14.1.tar.bz2)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/realroot/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,util-linux-ng)
	@$(call housekeeping)

327-coreutils: 326-util-linux-ng
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,coreutils-6.12.tar.gz)
	@$(call unpack2,coreutils-6.12.tar.gz)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/realroot/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,coreutils)
	@$(call housekeeping)

328-sed: 327-coreutils
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,sed-4.1.5.tar.gz)
	@$(call unpack2,sed-4.1.5.tar.gz)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/realroot/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,sed)
	@$(call housekeeping)

329-gawk: 328-sed
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,gawk-3.1.6.tar.bz2)
	@$(call unpack2,gawk-3.1.6.tar.bz2)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/realroot/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,gawk)
	@$(call housekeeping)

330-tar: 329-gawk
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@$(call remove_existing_dirs2,tar-1.20.tar.bz2)
	@$(call unpack2,tar-1.20.tar.bz2)
	@$(call get_pkg_root2)
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/realroot/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call remove_build_dirs2,tar)
	@$(call housekeeping)

331-squashfsrealroot: 330-tar
	@$(call echo_message, Building)
	@export BASHBIN=$(SHELL) && $(SHELL) progress_bar.sh $@ $$PPID &
	@echo "$(nl_)`date`$(nl_)" >logs/$@
	@$(PRT_DU_CR) >>logs/$@
	@start=$(TIME_MARK) && \
	source envars && \
	$(crCMDSDIR)/realroot/$@ >>logs/$@ 2>&1 && \
	end=$(TIME_MARK) && $(BUILD_TIME) >>logs/$@ && \
	$(PRT_DU_CR) >>logs/$@
	@$(call housekeeping)