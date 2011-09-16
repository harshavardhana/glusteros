#!/usr/bin/python                                                              

import os, string, sys, getopt
from Gluster.GFrontEnd import dialog
from Gluster.GTmp import Dir
from Gluster import gmap

dlg = dialog.Dialog ()

def Partitioning (disk):
    
    dlg.infobox ("Partitioning ... %s" % disk)
    os.system ("sleep 2")
    if os.system ("parted -s -- %s mklabel msdos" % disk):
        return "1"
    if os.system ("parted -s -- %s mkpart primary ext3 0M 1024M" % disk):
        return "1"
    if os.system ("parted -s -- %s mkpart linux-swap 1024M 5120M" % disk):
        return "1"
    if os.system ("parted -s -- %s mkpart primary ext3 5120M -1M" % disk):
        return "1"
        
    dlg.infobox ("Done")
    
    return None

def Formatting (disk):

    dlg.infobox ("Formatting ...")
    os.system ("sleep 2")
    if os.system ("mkfs.ext3 %s1" % disk):
        return "1"
    if os.system ("tune2fs -j -L '/' %s1" % disk):
        return "1"
    dlg.infobox ("Activating swap ...")
    if os.system ("mkswap %s2" % disk):
        return "1"
    if os.system ("swapon %s2" % disk):
        return "1"

    dlg.infobox ("Done")
    return None

def Installing (disk,image):

    dlg.infobox ("Installing GlusterSOS on '/' ...")
    os.system ("sleep 2")
    if os.system ("mkdir -p /tmp/installdir/"):
        return "1"
    if os.system ("mount %s1 /tmp/installdir/" % disk):
        return "1"
    if os.system ("tar -xvf %s -C /tmp/installdir/" % image):
        return "1"
        
    dlg.infobox ("Done")
    return None


def usage ():
    print """Usage: install [OPTION]...
    An installer utility invoked from GDesktop (frontend for
    GlusterSOS) for auto installation. 
    
    -d --disk         Specify the disk to install GlusterSOS
    -i --image        Specify the image to install GlusterSOS
    """
    return


def main():


    image_fd = ""
    disk_fd = ""
    
    try:
        (opt, args) = getopt.getopt (sys.argv[1:], "d:i:",
                                     ["disk=",
                                      "image="])
    except getopt.GetoptError, (msg, opt):
        print msg
        usage ()
        sys.exit (1)
        
    for (o, val) in opt:
        if o == '-d' or o == '--disk':
            try:
                disk_fd = val
            except:
                sys.exit (1)
        if o == '-i' or o == '--image':
            try:
                image_fd = val
            except:
                sys.exit (1)

    
    disk = disk_fd.strip()
    image = image_fd.strip()
    
    if Partitioning(disk):
        dlg.msgbox ("Problems during Partitioning\nExiting\n",
                    title="[ Error ]")
        sys.exit(1)
    if Formatting(disk):
        dlg.msgbox ("Problems during Formatting\nExiting\n",
                    title="[ Error ]")
        sys.exit(1)
    if Installing(disk,image):
        dlg.msgbox ("Problems during OS installation\nExiting\n",
                    title="[ Error ]")
        sys.exit(1)

    dlg.infobox ("GlusterSOS installation finished ... Rebooting in 3 secs")
    os.system ("sleep 3")
    os.system ("shutdown -t3 -r now")

main ()
