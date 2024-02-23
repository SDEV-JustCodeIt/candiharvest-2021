#!/bin/bash

main() {
  printf "\n\n  _____                _ _ _                               _   \n"
  printf "  / ____|              | (_) |                             | |  \n"
  printf " | |     __ _ _ __   __| |_| |__   __ _ _ ____   _____  ___| |_ \n"
  printf " | |    / _\` | '_ \ / _\` | | '_ \ / _\` | '__\ \ / / _ \/ __| __|\n"
  printf " | |___| (_| | | | | (_| | | | | | (_| | |   \ V /  __/\__ \ |_ \n"
  printf "  \_____\__,_|_| |_|\__,_|_|_| |_|\__,_|_|    \_/ \___||___/\__|\n"
  printf "                                                 by INFOMANIHACK\n\n"

  printf " Level        : 1 \n"
  printf " Participant  : XXX \n"
  printf " Submission date : DD MMMM. 2021 \n"

  printf "\n--------------------------------------------------------------------------------------------------------------------\n\n"



###################  ANSWERS TO THE CANDIHARVEST'S QUESTIONS -  LEVEL 1 ########################

##  Company domain name
DN=infomaniak.com

# [ 1 ] What is the list of ips present in Infomaniak SPF ?  

## The procedure to generate a list of IP ranges related to SPF records : 
## 1st step : recover all domains indexed by SPF records
get_spf_dn ${DN}
# 2nd  step : Extract all IPs linked to the domains SPF records extracted in the first step
get_spf_ips
# print answer
print_answer_1

# [ 2 ] Where can you usually find DNS information on a Linux system ?
print_answer_2

# [ 3 ] What is the abuse address of the 185.181.161.0/24 range ?
print_answer_3

# [ 4 ] Do you prefer using Vim or Emacs ?
print_answer_4

## [ 5 ] Script 
print_info_script
}


#################################################################################################
#
# Script Requirements  : dig, whois, sipcalc, nmap
#
# to execute : #bash ./answers.sh
#
# /!\  It is a small script to answer the first Level of CandiHarvest
#      error/exception handling and testing on various environments are not verified
#
#################################################################################################


declare -a spf_dn_array  # SPF domain name array
declare -a spf_ips_array # arrayof IP addresses authorized by the SPF
declare -a rangeipv4arr # IPv4 ranges array
declare -a rangeipv6arr # IPv6 ranges array
declare -a ipv4arr #IPv4 array
declare -a ipv6arr #IPv4 array

# Function to populate the array of domain names related to SPF records
# in   : Domain name
# out : spf_dn_array 
get_spf_dn(){
  SPF_DN=$(dig TXT $1 | grep -oP '(?<=include:|redirect=).[^ |"]*')
  if [ ! -z "${SPF_DN}" ]; then SPFarr0=("${SPF_DN}"); length=${#SPFarr0[@]};
    for (( i=0; i<${length}; i++ )); do IFS=' ' read -r -a SPFarr1 <<< $(echo ${SPFarr0[$i]}); count=${#SPFarr1[@]};
      for (( j=0; j<${count}; j++ )); do
       if [[ ! "${spf_dn_array[*]}" =~ "${SPFarr1[$j]}" ]]; then spf_dn_array+=("${SPFarr1[$j]}"); fi
       if [[ $i == 0 ]] && [[ $j == 0 ]] && [[ ! -z ${SPFarr1[$j+1]} ]]; then spf_dn_array+=("${SPFarr1[$j+1]}"); fi 
       get_spf_dn "${SPFarr1[$j]}"
      done
    done
  fi
}

# Function listing all  ip addresses/ranges authorized by the SPF
# in   : spf_dn_array (array of domain names extracted by get_spf_dn() )
# out : spf_ips_array (array of IPs or subnets allowed to send emails)
get_spf_ips(){
   length=${#spf_dn_array[@]}
   for (( i=0; i<${length}; i++ ))
   do
     IPS=$(dig TXT "${spf_dn_array[$i]}" | grep -oP '(?<=ip4:|ip6:).[^ |"]*')
     IFS=' ' read -r -a IParr <<< $(echo ${IPS}) 
     count=${#IParr[@]}
     for (( j=0; j<${count}; j++ )); do
      if [[ ! "${spf_ips_array[*]}" =~ "${IParr[$j]}" ]]
      then
        if [[ "${IParr[$j]}" =~ .*"/".* ]]
	then
	  if [[ "${IParr[$j]}" =~ .*".".* ]]; then rangeipv4arr+=("${IParr[$j]}"); fi
          if [[ "${IParr[$j]}" =~ .*":".* ]]; then rangeipv6arr+=("${IParr[$j]}"); fi
        else
          if [[ "${IParr[$j]}" =~ .*".".* ]]; then ipv4arr+=("${IParr[$j]}"); fi
          if [[ "${IParr[$j]}" =~ .*":".* ]]; then ipv6arr+=("${IParr[$j]}"); fi
	  fi
        spf_ips_array+=("${IParr[$j]}")
      fi
     done
   done
}
# just for a nice display
print_range_ip(){
  if [[ ! "$1" =~ .*"/".* ]]; then echo '  → IP : '$1;
  else
    IP_INFO=$(sipcalc $1)
    echo '  → CIDR : '$1
    echo '    ↳ Network range : '$(echo ${IP_INFO} | grep -oP '(?<=Network.range.-.).[^U]*' | rev | cut -c 2- | rev)
    if [[ ! "$1" =~ .*":".* ]]; then
    echo "    ↳ Network mask : "$(echo ${IP_INFO} | grep -oP '(?<=Network.mask.-.).[^ ]*')" ("$(echo ${IP_INFO} | grep -oP '(?<=Addresses.in.network.-.).[^N]*')"hosts)"
    else echo "   ↳ Subnet prefix : "$(echo ${IP_INFO} | grep -oP '(?<=Subnet.prefix..masked..-.).[^A]*'); fi
  fi
}

print_answer_1(){
  printf "◉ Answer 1 : Authorized IP's related to SPF records (*) \n"
  cnt1=${#ipv4arr[@]}; cnt2=${#rangeipv4arr[@]}; cnt3=${#ipv6arr[@]}; cnt4=${#rangeipv6arr[@]}
  if [ $((cnt1+cnt2)) > 0 ]; then echo "  ⭗ Allowed IPv4 addresses ("$((cnt1+cnt2))" records) : "; fi
  if [ ${cnt1} -gt 0 ]; then for (( i=0; i<${cnt1}; i++ )); do print_range_ip "${ipv4arr[$i]}"; done; fi
  if [ ${cnt2} -gt 0 ]; then for (( i=0; i<${cnt2}; i++ )); do print_range_ip "${rangeipv4arr[$i]}"; done; fi
  if [ $((cnt3+cnt4)) > 0 ]; then echo "  ⭗ Allowed IPv6 addresses ("$((cnt3+cnt4))" records) : "; fi
  if [ ${cnt3} -gt 0 ]; then for (( i=0; i<${cnt3}; i++ )); do print_range_ip "${ipv6arr[$i]}"; done; fi
  if [ ${cnt4} -gt 0 ]; then for (( i=0; i<${cnt4}; i++ )); do print_range_ip "${rangeipv6arr[$i]}"; done; fi
  printf "\n[!] To generate a listing of all IP addresses of some range, we can use 'namp'\n"
  printf "     ex. #nmap -sL -n 45.157.188.8/29 | awk '/Nmap scan report/{print $NF}' \n"
  printf "     + '-6' like option for  IPv6 ranges\n\n"
  printf "(*)the procedure to generate this list of IPs related to SPF records is explained on './answer.sh' \n" 
  printf "\n--------------------------------------------------------------------------------------------------------------------\n\n"
}

print_answer_2(){
  printf "◉ Answer 2 : Usual location of DNS information on a Linux system : \n"
  printf "   ' #/etc/resolv.conf '  \n"
  printf "   ↳ resolver manual  : https://man7.org/linux/man-pages/man5/resolv.conf.5.html \n\n"
  printf "/!\ But in some configurations, if no resolv.conf file exists, the resolver routines continue \n    to search their direct path, which may include searching through /etc/hosts file or the NIS host map. \n"
  printf "    ↳ ex.  - https://www.ibm.com/docs/en/aix/7.1?topic=formats-resolvconf-file-format-tcpip \n"
  printf "\n--------------------------------------------------------------------------------------------------------------------\n\n"
}

print_answer_3(){
  route_ip=185.181.161.0 #/24
  abuse_mailbox=$(whois ${route_ip} | grep -o -P '(?<=abuse-mailbox:..).*[[:alnum:]+\.\_\-]*@[[:alnum:]+\.\_\-]*')
  printf "◉ Answer 3 : Abuse mailbox of 185.181.161.0/24 range (*):  "${abuse_mailbox}"  \n\n"  
  printf "(*) the email is extracted directly from the RIPE Database by the whois command #whois "${route_ip}"\n" 
  printf "     and filtered by # | grep -o -P '(?<=abuse-mailbox:..  ' -details at #./scripts/answers.sh \n"   
  printf "\n--------------------------------------------------------------------------------------------------------------------\n\n"
}

print_answer_4(){
  printf "◉ Answer 4 :  Favorite code editor(s): \n"
  printf "   ' >  terminal : nano for small scripts and Vim for the rest  \n" 
  printf "   ' >   w/ GUI  : VS code or Sublime Text  \n"  
  printf "\n--------------------------------------------------------------------------------------------------------------------\n\n"
}

print_info_script(){
  printf "◉ A small script that solves the first part : \n"
  printf "   ' >  the script is included inside #./scripts folder, use the language (bash, python, pearl, php) that suits you.  \n\n" 
  printf "  /!\ it is a small script to answer the first Level of CandiHarvest, \n      error/exception handling and testing on various environments are not verified.\n"
  printf "      *Dev. environment :  \n       - Debian Bullseye \n       - bash v. 4.4-5 \n       - python3 v. 3.9.1 \n       - perl5 v. 5.32 \n       - PHP8, v. 8.0.7\n"
  printf "\n--------------------------------------------------------------------------------------------------------------------\n\n"
}

main "$@"; exit