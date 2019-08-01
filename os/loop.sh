#!/bin/bash
# loop.sh
# Created Thu Aug  1 12:45:17 AKDT 2019
# Copyright (C) 2019 by Raymond E. Marcil <marcilr@gmail.com>
#
# Generate html file, displayed to common output, with
# disk usage of all sytems listed in ~/.credentials file.
#

#
# Configuration
#
CREDENTIALS=/home/remarcil/.credentials.txt

# ========
# Binaries
# ========
CAT=/bin/cat
GREP=/bin/grep
SED=/bin/sed
SSH=/usr/bin/ssh
SSHPASS=/usr/bin/sshpass
TR=/usr/bin/tr

# Source credentails
source ${CREDENTIALS}

#echo "TOMPROD: ${TOMPROD}"
#echo "WEBPROD: ${WEBPROD}"


#
# Loop over ~./credentials file, excluding commnets,
# for list of systems to inspect disk usage.
#
# NOTE: Had to use the curly braces and /dev/null input
#       wrapping to avoid have the loop with ssh about
#       after one run:
#
#   ${CAT} ... | while read LINE; do {
#   ...
#   } < /dev/null; done
#
# Links
# =====
# SSH causes while loop to stop
# UNIX & Linux
# https://unix.stackexchange.com/questions/66154/ssh-causes-while-loop-to-stop
#
echo "<!DOCTYPE html>"
echo "<html>"
echo "<head>"
echo "<title>System Disk Usage</title>"
echo "</head>"
echo "<body>"
echo "<h1>System Disk Usage</h1>"

#
# Create table to organize disk usage output
#
echo "<table>"
echo "<tr>"
echo "</tr>"

${CAT} ${CREDENTIALS} | ${GREP} -v "#" | while read LINE; do {
#  echo ${LINE}

#  echo "<p>"
  # Get system name in upper case
  SYSTEM=`echo ${LINE} | ${SED} 's/=.*//g'`
#  echo "SYSTEM: ${SYSTEM}<br>"

  # Get upper case system name and convert to lower case.
  SYSTEMLOWER=`echo ${LINE} | ${SED} 's/=.*//g' | ${TR} '[:upper:]' '[:lower:]'`
#  echo "SYSTEMLOWER: ${SYSTEMLOWER}<br>"

  # Get system's credential
  CREDENTIAL=`echo ${LINE} | ${SED} 's/.*=//g'`
#  echo "CREDENTIAL: ${CREDENTIAL}<br>"

#  echo "</p>"

  # Test remote ssh command
#  TIME=`${SSHPASS} -p "${CREDENTIAL}" ${SSH} root@${SYSTEMLOWER} uptime`
#  echo "TIME: ${TIME}"

  # loop of 'df -h' results omitting  /mnt and /home
#  echo "<p>"
  ${SSHPASS} -p "${CREDENTIAL}" ${SSH} root@${SYSTEMLOWER} 'df -h' | ${GREP} -v '/mnt\|/home' | while read DFLINE; do
    echo "<tr>"
    if [[ $DFLINE == *"Filesystem"* ]]; then
      echo "<td>System</td>"
      #echo "System ${DFLINE}<br>"

      #
      # Wrap each space separated value in td tag.
      #
      # How to loop through space separated values?
      # Shell Programming and Scripting
      # https://www.unix.com/shell-programming-and-scripting/173276-how-loop-through-space-separated-values.html
      #
      for VALUE in $DFLINE; do
        echo "<td>${VALUE}</td>"
#        echo "VALUE=${VALUE}"
      done
    else
      echo "<td>${SYSTEMLOWER}</td>"
      for VALUE in $DFLINE; do
        echo "<td>${VALUE}</td>"
#        echo ${DFLINE}<br>"
      done
    fi
    echo "</tr>"
  done
#  echo "End inner loop"
#  echo "</p>"

} < /dev/null; done

echo "</table>"
echo "</body>"
echo "</html>"
