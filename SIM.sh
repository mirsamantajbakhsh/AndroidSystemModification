#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

command=$1
APFile=$2

current_dir=$(pwd)
workdir="$current_dir/workdir"
outputDir="$current_dir/output"
tmpdir="$workdir/tmp"
mountPoint="$tmpdir/mnt"
systemAppLocation="$mountPoint/system/priv-app/";
signatureFile="$outputDir/keystore.ks"
ksPassword="secret_password"

printHeader()
{
  echo "MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMmyoosmMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM"
  echo "MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMh+////+mMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM"
  echo "MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMd+/////+mMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM"
  echo "MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMm+//////dMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM"
  echo "MMMMMMMMMMMMMMMMMMMMMMMMMMMMMNdhdNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNo/////:hMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM"
  echo "MMMMMMMMMMMMMMMMMMMMMMMMMMMMh+///+ymMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNs+////:sMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM"
  echo "MMMMMMMMMMMMMMMMMMMMMMMMMMMMs+++///+smMMMMMMMMMMMMMMNmdhyysoo+///////////+syhdmNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM"
  echo "MMMMMMMMMMMMMMMMMMMMMMMMMMMMmy+++++///sdMMMMMMNmhys++/////::--...--::://////////+oyhmNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM"
  echo "MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMmy++//++//odNdyo++///////////::::::::::::::::::::::::://oydNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM"
  echo "MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMmy++++++++++/////////////////::::::::::::::::::::::::::::/+ymMMMMMMMMMMMMMMMMMMMMMMMMMMMMM"
  echo "MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNyo+//////////////////:::::::::::::::::::::::::::::::::---:+ymMMMMMMMMMMMMMMMMMMMMMMMMMM"
  echo "MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMmy+///////////////::::::::::::::::::::::::::::::::::::::::----:+ymMMMMMMMMMMMMMMMMMMMMMMM"
  echo "MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMdo/::////////////:::::::::::::::::::::::::::::::::::::::::::::---.-:odMMMMMMMMMMMMMMMMMMMMM"
  echo "MMMMMMMMMMMMMMMMMMMMMMMMMMMMNh+:::://////////:::::::::::::::::::::::::::::::::::::::::::::::::::--..-+dMMMMMMMMMMMMMMMMMMM"
  echo "MMMMMMMMMMMMMMMMMMMMMMMMMMNh+:::://///////:::::::::::::::::::::::::::::::::::::::::::::::::::::::--...-+dMMMMMMMMMMMMMMMMM"
  echo "MMMMMMMMMMMMMMMMMMMMMMMMMdo:-:::////////:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::--...-omMMMMMMMMMMMMMMM"
  echo "MMMMMMMMMMMMMMMMMMMMMMMNs/:-::////////:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::-....:yNMMMMMMMMMMMMM"
  echo "MMMMMMMMMMMMMMMMMMMMMMd+:-:::////////:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::--...-+dMMMMMMMMMMMM"
  echo "MMMMMMMMMMMMMMMMMMMMNy/:-:::///////:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::-....:yNMMMMMMMMMM"
  echo "MMMMMMMMMMMMMMMMMMMmo::-::////////:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::--...-oNMMMMMMMMM"
  echo "MMMMMMMMMMMMMMMMMMd+:-::://+//////::::::::::::::::::::::::::::::::::::::::::::::/++:--:::::::::::::::::::::-...-+mMMMMMMMM"
  echo "MMMMMMMMMMMMMMMMMd+::::://++/////:::::::::::::::::::::::::::::::::::::::::::::+hhs:\`  \`-/:::::::::::::::::::-...-/dMMMMMMM"
  echo "MMMMMMMMMMMMMMMMd+::::://++//////::::::::::::::::::::::::::::::::::::::::::::sdhhs:\`   \`/o-::::::::::::::::::-...-/dMMMMMM"
  echo "MMMMMMMMMMMMMMMd+::::::/++//////:::::::::::::::::::::::::::::::::::::::::::::dhhyyys+--/sh::::::::::::::::::::-...-/mMMMMM"
  echo "MMMMMMMMMMMMMMmo::::::/+++//////:::::::::::::::::::::::::::::::::::::::::::::hhyyyyyyyyydh:::::::::::::::::::::-...-+NMMMM"
  echo "MMMMMMMMMMMMMNs/::::://+++//////:::::::::/+/:-:::::::::::::::::::::::::::::::+hhyyyyyyhhh/::::::::::::::::::::::--..-oMMMM"
  echo "MMMMMMMMMMMMMy/::::://++++//////:::::::+yhs-   \`:+:::::::::::::::::::::::::::::oyhhhhhyo:::::::::::::::::::::::::--.--yMMM"
  echo "MMMMMMMMMMMMm+::::::/+++++//////:::::-+dhhs:\`   \`+y:::::::::::::::::::::::::::::::///:::::::::::::::::::::::::::::----/mMM"
  echo "MMMMMMMMMMMNs/::::://+++++/////:::::::hhhyyys+::/yd/:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::----sMM"
  echo "MMMMMMMMMMMd+::::://++++++/////:::::::yhyyyyyyyyydd:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::---:mM"
  echo "MMMMMMMMMMMs/::::://++++++//////:::::::yhyyyyyyyhd+-:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::--:sM"
  echo "MMMMMMMMMMmo::::://+++++++//////::::::::+shhhhhyo:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::/N"
  echo "MMMMMMMMMMh+:::::/++++++++//////:::::::::::::::::::::::::::::::::::::::::::::::::::::::////+++++++++++ooooooooooo++++///:h"
  echo "MMMMMMMMMMs/:::://++++++++//////:::::::::::::::::::::::::::::::::::::::::::::://++oooooooooooooooooooooooooooooooooooooood"
  echo "MMMMMMMMMNo///////+++++++///////:::::::::::::::::::::::::::::::::::::::::/+osssssssssssssssssssssssssssoooooooooooooooosmM"
  echo "MMMMMMMMMmo//////++++++++///////::::::::::::::::::::::::::::::::::::/+ossyyyyyssssssssssssssssssssssssssssssooooooooosdMMM"
  echo "MMMMMMMMMmo/////+++++++++//////::::::::::::::::::::/::::::::::::---------------:::::://////+++++ooosssssssssssooooshmMMMMM"
  echo "MMMMMMMMMdo+++/+++++++++///////::::::::////////::::::----------...............-------:::::::::::::::::://+++oosydmMMMMMMMM"
  echo "MMMMMMMMMdo+++++++++++++//////////////:::::::::////////////////::::--........------:::::://:::::::::::::::::::::+shmMMMMMM"
  echo "MMMMMMMMMNhhyyssssoo+++++++/////::::::::////////:::::::::::::::::::::/:::----:::::/::::::::::::::///:::::::::::::---/odNMM"
  echo "MMMMMMMMMMMMMMMMMMMNmhso+////////////+++++/////::::::::::::::::::::::::::///::::::::::::::::::::----://::::::::::::---:/hM"
  echo "MMMMMMMMMMMMMMMMNdso//::::::::::::://++oooo++////::::::::::::::::::::::::::://::::::::::::::::::::::---:/::::::::::::--::y"
  echo "MMMMMMMMMMMMMMds+/////:::::::::::::::::://+ooooo+///:::::::::::::::::::::::::://::::::::::::::::::::::---:/:::::::::::--:o"
  echo "MMMMMMMMMMMMNho+++//////:::::::::::::::::::://+ooooo+//::::::::::::::::::::::::://::::::::::::::::::::::--:/::::::::::-::o"
  echo "MMMMMMMMMNdyoooo++++//////::::::::::::::::::::://+ooooo+/:::::::::::::::::::::::://::::::::::::::::::::::--:/:::::::::-::o"
  echo "MMMMMMMmyo++oooo++++++/////:::::::::::::::::::::::/++oooo+/:--::::::::::::::////+++:::::::::::::::::::::::--:/::::::::-::o"
  echo "MMMMMms++++oooooo++++++/////:::::::::::::::::::::::://++ooo+/---::::////+++++++//::::::::::::::::::::::::::--/::::::::-::o"
  echo "MMMNy+//++oooooooo+++++++/////:::::::::::::::::::::::://+++o++//++++ooo++++//::::::::::::::::::::::::::::::--:/:::::::-::o"
  echo "MMms+//+ooooooooooo++++++++/////:::::::::::::::::::::::://++oooo+++++////:::::::::::::::::::::::::::::::::::-:+:::::::-::o"
  echo "Mms///+oooooooooooss+++++++++////:::::::::::::::::::::::::///+/////:::::::::::::::::::::::::::::::::::::::::-:+:::::::-::o"
  echo "Ms////oooooooooooooss+++++++++/////:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::-//:::::::-::o"
  echo "d+///+ooooooooooooooss+/++++++++/////::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::-:+::::::::-::o"
  echo "h+///ooooooooooooooosss+/+++++++++////::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::--//::::::::-::o"
  echo "h+///+ooooooooooooooossso/++++++++++////:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::-://::::::::::::o"
  echo "do///+ooooooooooooooossyyo+++o+++++++/////::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::://::::::::::::::o"
  echo "Ns+//++ooooooooooooooossyyso++oo+++++++////::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::///:::::::::::::::o"
  echo "Mho+//+oooooooooooooooossyyyo++oooo+++++/////::::::::::::::::::::::::::::::::::///////////////:::::////::::::::::::::::::o"
  echo "MMho+//++ooooooooooooooossyyyso++oooo+++++////:::::::::::::::::::::::://////////////////////////////:::::::::::::::::::::o"
  echo "MMMds++/++oooooooooooooosssyyyysoooooooo+++////::::::::::::::////////////++++++++++/////////+++//::::::::::::::::::/:::::o"
  echo "MMMMmhso+++++ooosssssssssssyyyyyysoo+oooooo++//:::///////////////+++++++++++++++++///+++oo+++//::::::::::::::::::::/:::::o"
  echo "MMMMMMmhysoooooooosssssssssssssyyyysoo+oooooo+++//+++++++++++++++ooooooo+++++++++ooooooo+++//::::::::::::::::::::::/:::::o"
  echo "MMMMMMMMNmdhsssssssssssssssssyyyyyyyyssoooooooooooooooooooooooooooo++++++oooossssssooo++////:::::::::::::::::::::::/:::::o"
  echo "MMMMMMMMMMMNysssysssssyyyyyyyyyyyyyyyyyyssooooooooooooooooooooooooooosssssssssssooo+++///::::::::::::::::::::::::::/:::::o"
  echo "MMMMMMMMMMMNsossssssssssyyyyysssssyyyyyyyyysssooooooooooooooossssssyyysssssssooo+++////::::::::::::::::::::::::::::/:::::o"
  echo "MMMMMMMMMMMNsooossssssssssssssssssssyyyyyyyyyyysssssssssssyyyyyyyyyysssssoooo++++////:::::::::::::::::::::::::::::///::::o"
  echo "MMMMMMMMMMMNo++ooooooooooooooooooossssyyyyyyyyyyyyyyyyyyyyyyyyyysssssoooo+++++//////::::::::::::::::::::::::::::::///::::o"
  echo "MMMMMMMMMMMNo+++oooooooooooooooooooossssssyyyyyyyyyyyyyyyyyssssssoooo++++++//////////:::::::::::::::::::::::::::::///::::o"
  echo "MMMMMMMMMMMNo+/+oooooooooooooooooooooosssssssssssssssssssssoooooo+++++++//////////////::::::::::::::::::::::::::::///::::o"
  echo "MMMMMMMMMMMNo+/+ooooooooooooooooooooooooooosssssssssoooooooooo++++++++/////////////////:::::::::::::::::::::::::::///::::o"
  echo "MMMMMMMMMMMNs+/+ooooooooooooooooooooooooooooooooooooooooooooo++++++++/////////////////////::::::::::::::::::::::::///::::o"
  echo "MMMMMMMMMMMNs+++ossoooooooooooooooooooooooooooooooooooooooooo+++++++++/////////////////////:::::::::::::::::::::::///::::o"
  echo "MMMMMMMMMMMNs+++ossssssssssssoooooooooooooooooooooooooooooooooo++++++++/////////////////////:::::::::::::::::::::////::::o"
  echo "MMMMMMMMMMMNs+++osssssssssssssssooooooooooooooooooooooooooooooooo++++++++/////////////////////::::::::::::::::::://///:::o"
  echo "MMMMMMMMMMMNs+++ossssssssssssssssoooooooooooooooooooooooooooooooooo+++++++////////////////////::::::::::::::::::://///:::o"
  echo "MMMMMMMMMMMNs+++ossssssssssssssssssooooooooooooooooooooooooooooooooo+++++++////////////////////::::::::::::::::://////:::o"
  echo "MMMMMMMMMMMNs++oossssssssssssssssssssosooooooooooooooooooooooooooooooo++++++/////////////////////::::::::::::::://////:::o"
  echo "MMMMMMMMMMMNs++oossssssssssssssssssssssssoooooooooooooooooooooooooooooo+++++++//////////////////////////:::://////////:::s"
  echo "MMMMMMMMMMMNs++osssssssssssssssssssssssssssoooooooooooooooooooooooooooooo++++++///////////////////////////////////////::/s"
  echo "MMMMMMMMMMMNo++oossssssssssssssssssssssssssssssssooooooooooooooooooooooooo+++++++///////+++++++++++//////////////////////s"
  echo "MMMMMMMMMMMNo+++ossssssssssssssssssssssssssssssssssssssooooooooooooooooooooo+++++++++++++++++++++++++++++++++++++////////s"
  echo "MMMMMMMMMMMNo+++oossssssssssssssssssssssssssssssssssssssssssoooooooooooooooooooooooooooooooooooooooo++++++++++++++++////+s"
  echo "MMMMMMMMMMMNs++++oosssssssssssssssssssssssssssssssssssssssssssssooooooooooooooooooooooooooooooooooooo+++++++++++++++///+oh"
  echo "MMMMMMMMMMMMdo+++++osssssssssssssssssssssssssssssssssssssssssssssssooooooooooooooooooooooooosssoooooooooooooo++++////++oyN"
  echo "MMMMMMMMMMMMMdsoo+++oossssssssssssssssssssssssssssssssssssssssssssssssssssssssssooooooossssssoooooooooo+++++++/++o++++oyNM"
  echo "MMMMMMMMMMMMMMNhsooo+oooossssssssssssssssssssssssssssssssssssssssssssssssssssssooooosooooooooooo+++++++++++///////+ossdNMM"
  echo "MMMMMMMMMMMMMMMMNdysoooooooosssssssssssssssssssssssssssssssssssssssssssssssssooosssooooooo+++++++//////////////////+smMMMM"
  echo "MMMMMMMMMMMMMMMMMMNdysssoooooooosssssssssssssssssssssssssssssssssssssssssssssssoooooooo++++/////////////////////////oNMMMM"
  echo "MMMMMMMMMMMMMMMMMMMMhyyyysssoooooooossssssssssssssssssssssssssssssssssssssssssoosooooo+++/////////:::::::::::///////+mMMMM"
  echo "MMMMMMMMMMMMMMMMMMMMmyyyyyyyyyssssoooooossssssssssssssssssssssssssssssssssssoosssoooo+++///////::::::::::::::///////+dMMMM"
  echo "MMMMMMMMMMMMMMMMMMMMMhyyyyyyyyyyyyyyssssooooooosssssssssssssssssssssssssossoossssoooo+++////////:::::::::::::////////hMMMM"
  echo "MMMMMMMMMMMMMMMMMMMMMmysyyyyyyyyyyyyyyyyyyysssssoooooossssssssssssssssoossooossssoooo++++////////::::::::::::////////yMMMM"
  echo "MMMMMMMMMMMMMMMMMMMMMMhysyyyyyyyyyyyyyyyyyyyyyyyyyyysssssssssssssssssssossooosssssoooo+++++////////::::::::::////////sMMMM"
  echo "MMMMMMMMMMMMMMMMMMMMMMNyssyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyhmmmmNNNhoooosssssoooo+++++///////:::::::::://///://oMMMM"
  echo "MMMMMMMMMMMMMMMMMMMMMMMhyssyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyMMMMMMMNsooossssssoooo+++++////////:::::::://///://oNMMM"
  echo "MMMMMMMMMMMMMMMMMMMMMMMNysssyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyNMMMMMMMhsooosssssssooo+++++/////////::::://////://+mMMM"
  echo "MMMMMMMMMMMMMMMMMMMMMMMMdysssyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyssyNMMMMMMMNysooosssssssooo+++++///////////////////::/+dMMM"
  echo "MMMMMMMMMMMMMMMMMMMMMMMMNysssyyyyyyyyyyyyyyyyysyyyyyyyyyyyyyyyyssymMMMMMMMMdsoooosssssssooo+++++//////////////////:://hMMM"
  echo "MMMMMMMMMMMMMMMMMMMMMMMMMdysssyyyyyyyyyyyyysssssssssssssssssysssssmMMMMMMMMNysoooosssssssooo+++++/////////////////////sMMM"
  echo "MMMMMMMMMMMMMMMMMMMMMMMMMNyssssyyyyyyyyyyyyyssssssssssssssssssssssdMMMMMMMMMdssoooossssssoooo+++++////////////////////sMMM"
  echo "MMMMMMMMMMMMMMMMMMMMMMMMMMdssssyyyyyyyyyyyyysssssssssssssssssssssshMMMMMMMMMNysoooosssssssoooo+++++///////////////////oMMM"
  echo "MMMMMMMMMMMMMMMMMMMMMMMMMMMyssssyyyyyyyyyyyyyyssssssssssssssssssssyMMMMMMMMMMmssoooosssssssoooo+++++//////////////////oNMM"
  echo "MMMMMMMMMMMMMMMMMMMMMMMMMMMmyssssyyyyyyyyyyyyyyyssssssssssssssssssyNMMMMMMMMMMysooooosssssssoooo+++++/////////////////+mMM"
  echo "MMMMMMMMMMMMMMMMMMMMMMMMMMMMhysssssssyyyyyyyyyyyyyysysssssssssssssyNMMMMMMMMMMmssooooosssssssoooo+++++////////////////+dMM"
  echo "MMMMMMMMMMMMMMMMMMMMMMMMMMMMNmhyysssssssssssssssssssssssssssyyyyhdNMMMMMMMMMMMMhsoooooosssssssoooo++++++//////////////+hMM"
  echo "MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNmddhyyyyyyyyyyyyyyyyyyyyyhddmmNMMMMMMMMMMMMMMMNysooooooossssssooooo+++++///////++////+yMM"
  echo "MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNNNNNNNNNNNNNNNMMMMMMMMMMMMMMMMMMMMMMMMMhssooooooooooooooooo+++++/////////////+sNM"
  echo "MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNyssooooooooooooooo+++++//////////////+sNM"
  echo "MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMdyssssoooooooo++++++++/////////////++oyNM"
  echo "MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNmdyyssoooooooo++++++++////////++oshmMMM"
  echo "MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNNmmdhhyyyssssssooosssyyhddmNMMMMMMM"

  echo ""
  echo " ______     __  __     ______     ______   ______     __    __        __     __    __     ______     ______     ______    ";
  echo "/\  ___\   /\ \_\ \   /\  ___\   /\__  _\ /\  ___\   /\ \-./  \      /\ \   /\ \-./  \   /\  __ \   /\  ___\   /\  ___\   ";
  echo "\ \___  \  \ \____ \  \ \___  \  \/_/\ \/ \ \  __\   \ \ \-./\ \     \ \ \  \ \ \-./\ \  \ \  __ \  \ \ \__ \  \ \  __\   ";
  echo " \/\_____\  \/\_____\  \/\_____\    \ \_\  \ \_____\  \ \_\ \ \_\     \ \_\  \ \_\ \ \_\  \ \_\ \_\  \ \_____\  \ \_____\ ";
  echo "  \/_____/   \/_____/   \/_____/     \/_/   \/_____/   \/_/  \/_/      \/_/   \/_/  \/_/   \/_/\/_/   \/_____/   \/_____/ ";
  echo "                                                                                                                          ";
  echo " __    __     ______     _____     __     ______   __     ______     ______     ______   __     ______     __   __        ";
  echo "/\ \"-./  \   /\  __ \   /\  __-.  /\ \   /\  ___\ /\ \   /\  ___\   /\  __ \   /\__  _\ /\ \   /\  __ \  /\ \-.\ \       ";
  echo "\ \ \-./\ \  \ \ \/\ \  \ \ \/\ \ \ \ \  \ \  __\ \ \ \  \ \ \____  \ \  __ \  \/_/\ \/ \ \ \  \ \ \/\ \  \ \ \-.  \      ";
  echo " \ \_\ \ \_\  \ \_____\  \ \____-  \ \_\  \ \_\    \ \_\  \ \_____\  \ \_\ \_\    \ \_\  \ \_\  \ \_____\  \ \_\ \_ \     ";
  echo "  \/_/  \/_/   \/_____/   \/____/   \/_/   \/_/     \/_/   \/_____/   \/_/\/_/     \/_/   \/_/   \/_____/   \/_/ \/_/     ";
  echo "                                                                                                                          ";
  echo " By: Mir Saman Tajbakhsh                                                                                                  ";
  echo " https://mstajbakhsh.ir                                                                                                   ";
  echo " Join my YouTube Channel: https://www.youtube.com/channel/UCxBpft2wcGKkPbf6h_NabPQ                                        ";
  echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~";
  echo "This application works in three modes:"
  printf "\tinit:\tFor initializing the environment and manually modify and build the system image\n"
  printf "\tmodify:\tWill call initialization first, then will add APKs as system application and rebuild the system image\n"
  printf "\tresign:\tSame as modify but will resign the whole system image and will make your applications as\n"
  printf "\t\tplatform app with the most abilities that an app can have\n"
  echo ""
}

# Thanks to https://stackoverflow.com/users/65706/yordan-georgiev
#------------------------------------------------------------------------------
# echo pass params and print them to a log file and terminal
# with timestamp and $host_name and $0 PID
# usage:
# doLog "INFO some info message"
# doLog "DEBUG some debug message"
# doLog "WARN some warning message"
# doLog "ERROR some really ERROR message"
# doLog "FATAL some really fatal message"
#------------------------------------------------------------------------------
doLog(){
  type_of_msg=$(echo $*|cut -d" " -f1)
  msg=$(echo "$*"|cut -d" " -f2-)
  [[ $type_of_msg == DEBUG ]] && type_of_msg="DEBUG"
  [[ $type_of_msg == INFO ]] && type_of_msg="INFO" # one space for aligning
  [[ $type_of_msg == WARN ]] && type_of_msg="WARN" # as well

  # print to the terminal if we have one
  test -t 1 && echo " [$type_of_msg] $(date "+%Y.%m.%d-%H:%M:%S %Z") ""$msg"
}

init()
{

  doLog "INFO initializing the environment"

  rm -r "$workdir" &>/dev/null
  mkdir "$workdir" &>/dev/null

  toolsDir="$workdir/tools"
  mkdir "$toolsDir" &>/dev/null

  rm -r "$tmpdir" &> /dev/null
  mkdir "$tmpdir" &>/dev/null

  rm -r "$outputDir" &> /dev/null
  mkdir "$outputDir" &> /dev/null

  rm -r "$mountPoint" &>/dev/null
  mkdir "$mountPoint" &>/dev/null

  rm -r "$tmpdir/AP/" &>/dev/null
  mkdir "$tmpdir/AP/" &>/dev/null

  doLog "INFO Getting Needed tools"
  # Useful tools
  apt-get install lz4 zlib1g-dev python-is-python3 attr apksigner zipalign xmlstarlet openssl xxd -y -qq &>/dev/null

  # Android simg2img
  cd "$toolsDir" && git clone https://github.com/anestisb/android-simg2img.git  &>/dev/null
  cd "$toolsDir/android-simg2img" && make &>/dev/null

  # compare apk signature
  cd "$toolsDir" && git clone https://github.com/warren-bank/print-apk-signature.git  &>/dev/null
  cd "$toolsDir/print-apk-signature/bin" && chmod +x compare-apk-signatures && chmod +x print-apk-signature
  cd "$toolsDir/print-apk-signature/bin" && sed -i "s_print-apk-signature_$toolsDir/print-apk-signature/bin/print-apk-signature_gI" compare-apk-signatures

  # AVB
  cd "$toolsDir" && git clone https://android.googlesource.com/platform/external/avb  &>/dev/null
  python "$toolsDir"/avb/avbtool.py make_vbmeta_image --flags 2 --padding_size 4096 --output "$tmpdir/vbmeta.img" &>/dev/null
  lz4 -B6 --content-size "$tmpdir/vbmeta.img" "$tmpdir/vbmeta.img.lz4" &>/dev/null

  doLog "INFO Uncompressing [$APFile]"
  cd "$current_dir" && tar -C "$tmpdir/AP/" -xvf "$APFile" &>/dev/null

  # remove the cache
  rm -r "$tmpdir/AP/meta-data/"

  # Replace vbmeta.img.lz4
  cp "$tmpdir/vbmeta.img.lz4" "$tmpdir/AP/"

  doLog "INFO Uncompressing system.img"
  unlz4 "$tmpdir/AP/system.img.lz4" "$tmpdir/AP/system.img" &>/dev/null
  doLog "INFO Converting system.img"
  "$toolsDir"/android-simg2img/simg2img "$tmpdir/AP/system.img" "$tmpdir/AP/system.img.raw" &>/dev/null
  rm "$tmpdir/AP/system.img.lz4"
  rm "$tmpdir/AP/system.img"

  doLog "INFO Mounting [$tmpdir/AP/system.img.raw]"
  mount -t ext4 -o loop "${tmpdir}/AP/system.img.raw" "$mountPoint" &>/dev/null

  doLog "INFO System.img mounted successfully at [$mountPoint]"
}

modify()
{
  shouldResign=$1
  doLog "INFO Modification phase started"
  echo "[!] In this phase, enter the path of a folder which contains folders of apps you want to make them as system app. It is strictly recommended that the name of the folder and the name of the APK be the same."
  read -p "Please enter the full path: " -r APKsDir

  doLog "INFO System applications are located in: $mountPoint"

  # Pick an APK file from systemAppLocation to get the attributes (The first APK)
  apkFile=$( find "$systemAppLocation" -type f -name "*.apk" -exec grep -lis apk {} + 2>/dev/null | grep priv-app | head  -n 1 )
  doLog "DEBUG $apkFile"
  filePermission=$( getfattr --absolute-names --only-values -n security.selinux "$apkFile" | tr -d '\0' )
  folderPermission=$( getfattr --absolute-names --only-values -n security.selinux "$( dirname "$apkFile" )" | tr -d '\0' )

  # Copy the APKs directory to systemAppLocation
  cp -r "$APKsDir/"* "$systemAppLocation"

  if [ "$shouldResign" = "true" ]; then
      doResign
  fi

  # Apply file SELinux permission on all files
  find "$systemAppLocation" ! -path "$systemAppLocation" -type f -exec setfattr -n security.selinux -v "$filePermission" {} \;
  find "$systemAppLocation" ! -path "$systemAppLocation" -type d -exec setfattr -n security.selinux -v "$folderPermission" {} \;

  doLog "INFO Building the new AP ..."
  buildNewSystem
  doLog "INFO New AP file created successfully [$outputDir/AP_Modified.tar]"
}

doResign()
{
  # Generate a certificate
  keytool -genkey -v -keystore "$signatureFile" -storepass "$ksPassword" -keypass "$ksPassword" -alias SystemImageModification -keyalg RSA -keysize 4096 -validity 10000 -noprompt -dname "CN=SystemImageModification, C=IR" &>/dev/null
  echo "KeyStore: $signatureFile" > "$outputDir/KeyStoreInformation.txt"
  echo "Password: $ksPassword" >> "$outputDir/KeyStoreInformation.txt"
  keytool -importkeystore -srckeystore "$signatureFile" -srcstorepass "$ksPassword" -deststorepass "$ksPassword" -destkeystore "$outputDir/keystore.p12" -srcstoretype jks -deststoretype pkcs12
  openssl pkcs12 -in "$outputDir/keystore.p12" -out "$outputDir/keystore.pem" -password pass:"$ksPassword" -passout pass:"$ksPassword"
  openssl x509 -outform pem -in "$outputDir/keystore.pem" -out "$outputDir/keystore.crt"
  doLog "INFO Key for new signature generated successfully."

  # Remove all cached files
  removeCaches

  # Check if the application has same signature as the framework-res.apk
  # Process System APKs
  doLog "INFO Resigning the system (APKs) ..."
  compareAPKSignature="$workdir/tools/print-apk-signature/bin/compare-apk-signatures"
  framework_res="$mountPoint/system/framework/framework-res.apk"

  declare -i count=0
  declare -i total=0
  total=$(find "$mountPoint" ! -path "$mountPoint" -type f -name "*.jar" | wc -l)
  doLog "INFO There are total of ${total} number of JARs in ${mountPoint}"

  # Processing JAR
  doLog "INFO Resigning the system (JARs) ..."
  for i in $( find "$mountPoint" ! -path "$mountPoint" -type f -name "*.jar" 2>/dev/null ); do
    result=$( bash "$compareAPKSignature" "$framework_res" "$i" 2>/dev/null )

    count=$((count + 1))
    printf "\r\033[KResigning JAR: [%d / %d]" "$count" "$total"

    if [ "$result" = "EQUAL" ] || [ "$result" = "" ] ; then
      resign "$i"
    fi
  done

  echo ""
  doLog "INFO Resigning of system apps (JARs) finished successfully."

  declare -i count=0
  declare -i total=0
  total=$(find "$mountPoint" ! -path "$mountPoint" -type f -name "*.apk" ! -name "framework-res.apk" | wc -l)
  doLog "INFO There are total of ${total} number of APKs in ${mountPoint}"

  # Processing APK
  for i in $( find "$mountPoint" ! -path "$mountPoint" -type f -name "*.apk" ! -name "framework-res.apk" 2>/dev/null ); do # do not resign framework-res.apk. It should be resigned at the end
    result=$( bash "$compareAPKSignature" "$framework_res" "$i" 2>/dev/null)

    count=$((count + 1))
    printf "\r\033[KResigning ${i}: [%d / %d]" "$count" "$total"

    if [ "$result" = "EQUAL" ] || [ "$result" = "" ]; then
      resign "$i"
    fi
  done
  echo ""
  doLog "INFO Resigning of system apps (APKs) finished successfully."

  # finally resign framework-res.apk itself
  doLog "INFO Resigning framework-res.apk ..."
  resign "$framework_res"
  doLog "INFO Resigning framework-res.apk finished successfully."

  # Add new signature to macPermission.xml
  doLog "INFO Generating and adding new signature to the system ..."
  updateSignature
  doLog "INFO Generating and adding new signature to the system finished successfully."
}

removeCaches()
{
  find "$mountPoint" ! -path "$mountPoint" -type f -name "*.odex" -exec rm -r {} \;
  find "$mountPoint" ! -path "$mountPoint" -type f -name "*.oat" -exec rm -r {} \;
  find "$mountPoint" ! -path "$mountPoint" -type f -name "*.vdex" -exec rm -r {} \;
  find "$mountPoint" ! -path "$mountPoint" -type f -name "*.prof" -exec rm -r {} \;
}

resign()
{
  fileForResign=$1
  # Remove old signature
  zip -d "$fileForResign" "META-INF/*" &>/dev/null
  if [[ "$fileForResign" == *.apk ]]
  then
    resignAPK "$fileForResign"
  elif [[ "$fileForResign" == *.jar ]]
  then
    resignJAR "$fileForResign"
  fi
}

resignAPK()
{
  fileForResign=$1
  rm -r "$(dirname "$fileForResign")/oat" 2>/dev/null

  # Zipalign before signature
  zipalign -p 4 "$fileForResign" "$fileForResign.aligned"
  rm "$fileForResign"
  mv "$fileForResign.aligned" "$fileForResign"


  echo "$ksPassword" | apksigner sign --ks "$signatureFile" "$fileForResign" > /dev/null 2>&1
}

resignJAR()
{
  fileForResign=$1
  jarsigner -keystore "$signatureFile" -storepass "$ksPassword" "$fileForResign" "SystemImageModification" > /dev/null 2>&1 # "SystemImageModification" is The alias
}

updateSignature()
{
  xmlFile="$mountPoint/system/etc/selinux/mac_permissions.xml"

  if [ -e "$xmlFile" ]
  then
      # File exists
      echo "File Exists" > /dev/null
  else
      xmlFile="$mountPoint/system/etc/selinux/plat_mac_permissions.xml" # This file is the next candidate
  fi

  xmlPermission=$( getfattr --absolute-names --only-values -n security.selinux "$xmlFile" | tr -d '\0' )

  # MAKE DER FORMAT OF THE CERTIFICATE
  openssl x509 -in "$outputDir/keystore.pem" -inform PEM -outform DER -out "$outputDir/keystore.der"
  newSignature=$( xxd -p "$outputDir/keystore.der" | tr -d '\r\n' | tr -d '\r' | tr -d '\n' )

  newXML=$( xmlstarlet ed -O -u "//*[@value='platform']/../@signature" -v "$newSignature" "$xmlFile" )
  echo "$newXML" > "$xmlFile"

  # Update SELinux Permission
  setfattr -n security.selinux -v "$xmlPermission" "$xmlFile"
}

buildNewSystem()
{
  umount "$mountPoint"
  doLog "INFO Creating modified system image ..."
  "$toolsDir"/android-simg2img/img2simg "$tmpdir/AP/system.img.raw" "$tmpdir/AP/system.img"
  rm "$tmpdir/AP/system.img.raw"

  doLog "INFO Compressing modifies system image .."
  lz4 -B6 --content-size "$tmpdir/AP/system.img" "$tmpdir/AP/system.img.lz4"
  #rm "$tmpdir/AP/system.img"

  doLog "INFO Generating new AP_Modified.tar"
  cd "$tmpdir/AP/" && tar -cf "$outputDir/AP_Modified.tar" *.lz4
}

cleanUp()
{
  doLog "INFO Clearing the environment"
  # TODO Do the job
  doLog "INFO Everything finished!"
}
printHeader
init # Will call in all cases

case $command in
#  "init")
#	  init
#  ;;
  "modify")
#    init
	  modify false
  ;;
  "resign")
#    init
	  modify true
  ;;
esac
