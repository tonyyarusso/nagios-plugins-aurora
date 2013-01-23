#!/bin/sh
# ======================================================================================================================
# Nagios auroral activity level check
#
# Copyright:        2010, Tony Yarusso
# Author:           Tony Yarusso <tonyyarusso@gmail.com>
# License:          BSD <http://www.opensource.org/licenses/bsd-license.php>
# Homepage:         http://tonyyarusso.com/
# Description:      Checks for auroral activity based on satellite data.
#                     Instruments on board the NOAA Polar-orbiting Operational Environmental Satellite (POES)
#                     continually monitor the power flux carried by the protons and electrons that produce aurora in
#                     the atmosphere. SWPC has developed a technique that uses the power flux observations obtained
#                     during a single pass of the satellite over a polar region (which takes about 25 minutes) to
#                     estimate the total power deposited in an entire polar region by these auroral particles. The
#                     power input estimate is converted to an auroral activity index that ranges from 1 to 10.
#
# Usage: ./check_aurora -w <level> -c <level>
#        e.g. ./check_aurora -w 5 -c 9
#
# ----------------------------------------------------------------------------------------------------------------------
#
# Full license text:
#
# Copyright (c) 2010, Tony Yarusso
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the
# following conditions are met:
#
#    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following
#      disclaimer.
#    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the
#      following disclaimer in the documentation and/or other materials provided with the distribution.
#    * Neither the name of Nagios nor the names of its contributors may be used to endorse or promote products derived
#      from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# ======================================================================================================================

VERSION="0.1"
WARN_LEVEL=7
CRIT_LEVEL=9

usage() {
	echo "Check plugin for Auroral activity"
	echo "Copyright:  2010, Tony Yarusso"
	echo "Author:     Tony Yarusso <tonyyarusso@gmail.com>"
	echo "License:    BSD <http://www.opensource.org/licenses/bsd-license.php>"
	echo ""
	echo "Options:"
	echo "    -h | --help"
	echo "           Display this help text"
	echo "    -v | --version"
	echo "           Display the version of this script"
	echo "    -w | --warning <level>"
	echo "           The activity level to trigger a warning state [1-10, Default=7]"
	echo "    -c | --critical <level>"
	echo "           The activity level to trigger a critical state [1-10, Default=9]"
	echo ""
}

# Parse parameters
while [ $# -gt 0 ]; do
	case "$1" in
		-h | --help)
			usage
			exit 0
			;;
		-v | --version)
			echo "Script version $VERSION"
			exit 0
			;;
		-w | --warning)
			shift
			WARN_LEVEL="$1"
			;;
		-c | --critical)
			shift
			CRIT_LEVEL="$1"
			;;
		*)  echo "Unknown argument: $1"
			usage
			exit 1
			;;
	esac
shift
done

if [ $WARN_LEVEL -gt $CRIT_LEVEL ]; then
	WARN_LEVEL=$CRIT_LEVEL
fi

LEVEL=$(wget -q -O - http://www.swpc.noaa.gov/pmap/passTime.js | grep actLevel | sed 's/.*\([0-9][0-9]*\).*/\1/')

if [ $LEVEL -ge $WARN_LEVEL ] && [ $LEVEL -lt $CRIT_LEVEL ]; then
	echo "Aurora Warning: Activity level is $LEVEL|'auroral_activity'=$LEVEL;$WARN_LEVEL;$CRIT_LEVEL;1;10"
	exit 1
elif [ $LEVEL -ge $CRIT_LEVEL ]; then
	echo "Aurora Critical: Activity level is $LEVEL|'auroral_activity'=$LEVEL;$WARN_LEVEL;$CRIT_LEVEL;1;10"
	exit 2
else
	echo "Aurora OK: Activity level is $LEVEL|'auroral_activity'=$LEVEL;$WARN_LEVEL;$CRIT_LEVEL;1;10"
	exit 0
fi
