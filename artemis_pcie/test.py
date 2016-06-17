#! /usr/bin/env python

# Copyright (c) 2016 Dave McCoy (dave.mccoy@cospandesign.com)
#
# NAME is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# any later version.
#
# NAME is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with NAME; If not, see <http://www.gnu.org/licenses/>.


import sys
import os
import argparse

#sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), os.pardir)))

SYSFS_DRIVER_PATH = os.path.join(os.path.sep, "sys", "bus", "pci", "drivers", "nysa_pcie")
DEV_PATH = os.path.join(os.path.sep, "dev")

NAME = os.path.basename(os.path.realpath(__file__))

DESCRIPTION = "\n" \
              "\n" \
              "usage: %s [options]\n" % NAME

EPILOG = "\n" \
         "\n" \
         "Examples:\n" \
         "\tSomething\n" \
         "\n"

def main(argv):
    #Parse out the commandline arguments
    parser = argparse.ArgumentParser(
        formatter_class=argparse.RawDescriptionHelpFormatter,
        description=DESCRIPTION,
        epilog=EPILOG
    )

    parser.add_argument("-t", "--test",
                        nargs=1,
                        default=["something"])

    parser.add_argument("-d", "--debug",
                        action="store_true",
                        help="Enable Debug Messages")

    args = parser.parse_args()
    print "Running Script: %s" % NAME

    
    if os.path.exists(SYSFS_DRIVER_PATH):
        print "%s Exists!" % SYSFS_DRIVER_PATH


    if args.debug:
        print "Path: %s" % SYSFS_DRIVER_PATH
        print "test: %s" % str(args.test[0])

    for path, dirs, files in os.walk(SYSFS_DRIVER_PATH):
        dirs.remove("module")
        print "Dirs: %s" % str(dirs)

    for path, dirs, files in os.walk(DEV_PATH):
        for f in files:
            if f.startswith("nysa_pcie"):
                print "Found: %s" % f
        

if __name__ == "__main__":
    main(sys.argv)


