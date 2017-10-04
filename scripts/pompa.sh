#!/bin/bash

# I got a big issue
# create a big issue, 
# read fortune, format with figlet, color with lolcat
# calculate hxv center
# mash and convert to issue.

# tty1 dimensions: 170x48
TERMH=48 # number of lines
TERMW=170  # number of collumns

# TERMH=63 # number of lines
# TERMW=226  # number of collumns


MAX_LINES=4 # Maximum number of lines to display
WRAP=17     # On which Collumn to wrap fortune
FONT="3d.flf" # figlet font to use
# FONT=rustofat.tlf
LOLCAT_OPTIONS='-p 10'
TOILET_OPTIONS=(-w ${TERMW} -f "${FONT}")
FORTUNE_OPTIONS=()

# todo, check if font exist, if not set default font..
# /usr/share/figlet

OFS=${IFS} # save original Field Separor
LFS=$'\n'  # Separate on lines

# extract colorscheme from xrdb and translate it for issue
getcolors(){
  IFS=${OFS}
  xrdb=( $(xrdb -query | grep -P "color[0-9]*:" | sort | cut -f 2-) )
  for c in ${!xrdb[@]}; do
    case $c in
       19) echo -en "\e]PC${xrdb[$c]:1}" ;;
       30) echo -en "\e]P8${xrdb[$c]:1}" ;;
       0)  echo -en "\e]P0${xrdb[$c]:1}" ;;
       7)  echo -en "\e]P1${xrdb[$c]:1}" ;;
       15) echo -en "\e]P9${xrdb[$c]:1}" ;;
       8)  echo -en "\e]P2${xrdb[$c]:1}" ;;
       1)  echo -en "\e]PA${xrdb[$c]:1}" ;;
       9)  echo -en "\e]P3${xrdb[$c]:1}" ;;
       2)  echo -en "\e]PB${xrdb[$c]:1}" ;; 
       10) echo -en "\e]P4${xrdb[$c]:1}" ;;
       11) echo -en "\e]P5${xrdb[$c]:1}" ;;
       4)  echo -en "\e]PD${xrdb[$c]:1}" ;;
       12) echo -en "\e]P6${xrdb[$c]:1}" ;;
       5)  echo -en "\e]PE${xrdb[$c]:1}" ;;
       13) echo -en "\e]P7${xrdb[$c]:1}" ;;
       6)  echo -en "\e]PF${xrdb[$c]:1}" ;;
    esac
  done
  echo -en "\e[2J"
}

# get a random fortune, fold it and check if it doesn't exceed maximum lines
getfortune(){
  IFS=${LFS}

  fh=0 # fontheight
  fw=0 # fontwidth
  lchk=$((MAX_LINES+1)) # fortune lines

  while [[ $lchk -gt $MAX_LINES ]]; do
    # -s flag makes sure fold wraps on spaces
    # sed removes leading whitespace
    # todo: translate multiple spaces and tabs to single space..
    frt=($(fortune ${FORTUNE_OPTIONS[@]} | sed -e 's/^[[:space:]]*//' | fold -s -w${WRAP}))
    lchk=${#frt[@]}
  done

  # format fortune
  for l in ${frt[@]}; do
    toi=$(echo "${l}" | toilet ${TOILET_OPTIONS[@]} )
    # dimensions of formated text

    tlh=$(printf "${toi}" | wc -l)
    [[ $tlh -gt $fh ]] && fh=$tlh

    tlw=$(printf "${toi}" | wc -L)
    [[ $tlw -gt $fw ]] && fw=$tlw
    # IFS=$OIFS
    text2+=("${toi}")
  done

  # centerfortune
  vpad=$(((TERMH-(fh*lchk))/2)) # vertical padding 
  hpad=$(((TERMW-fw)/2))        # horizontal padding
  for (( i = 2; i < ${vpad}; i++ )); do
    echo
  done
  for l in ${text2[@]}; do
    printf "%${hpad}s"
    printf "${l}\n" 
  done
  echo
}

if [[ $1 = test ]]; then
  clear
  getfortune
else
  rm -f /tmp/issue
  getcolors > /tmp/issue
  # getfortune >> /tmp/issue
  getfortune | lolcat -f ${LOLCAT_OPTIONS} >> /tmp/issue
  sudo mv -f /tmp/issue /etc/issue
fi

