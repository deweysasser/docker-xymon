#!/bin/bash

# Purpose:  turn xymon ghost hosts (hosts we don't know about) into displayable records

xymon=/usr/lib/xymon/server/bin/xymon
list=/etc/xymon/ghostlist.cfg
tmp=/tmp/ghostlist.$$

trap 'rm $tmp' 0

cp $list $tmp
(
    $xymon localhost ghostlist | awk -F\| '{print $2 " " $1 " # noconn"}'
    cat $tmp
) | sort -u > $list


