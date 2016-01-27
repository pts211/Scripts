#!/bin/sh
# grip_install_script.sh
# Paul Sites 2016.01.27
# This is a script to setup GRIP. A computer vision project for FRC that helps make tracking goals a little more user-friendly. 

# -------------------- VARIABLES --------------------
dir=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
wdir="$dir/wrkdir"

# -------------------- FUNCTIONS --------------------
CleanDirectories() {
  echo -n "Cleaning... "
  #Clean up previous run
  rm -rf wrkdir

  echo "DONE"
}

Install() {
  #GRIP Install
  echo "-------------------- GRIP Install --------------------"
    
  echo -n "Installing prereq's... "
  
  apt-add-repository ppa:webupd8team/java
  apt-add-repository ppa:wpilib/toolchain
  
  apt update
  
  apt-get -qq install build-essential -y
  apt-get -qq install git -y
  apt-get -qq install oracle-java8-set-default -y
  apt-get -qq install frc-toolchain -y
  apt-get -qq install libc6-dev-i386 -y
  apt-get -qq install gcc-4.8-multilib g++-4.8-multilib -y
  
  echo "DONE"

  cd $wdir

  echo -n "Pulling NetworkTables... https://github.com/PeterJohnson/ntcore/"
  # https://github.com/PeterJohnson/ntcore/
  git clone https://github.com/PeterJohnson/ntcore.git -q
  echo "DONE"
  
  cd $wdir/ntcore
  
  echo -n "Building NetworkTables... "
  ./gradlew -q build
  echo "DONE"
  
  echo -n "Publishing NetworkTables... "
  ./gradlew -q publish
  echo "DONE"
  
  echo -n "Pulling GRIP... https://github.com/PeterJohnson/ntcore/"
  # https://github.com/PeterJohnson/ntcore/
  git clone https://github.com/WPIRoboticsProjects/GRIP.git
  echo "DONE"
  
  cd $wdir/GRIP
  
  echo -n "Building GRIP... "
  ./gradlew -q :ui:run
  echo "DONE"
  
}

# -------------------- Input Parameters --------------------
for var in "$@"
do
    echo "$var"
    case "$var" in
        "--" ) break 2;;
        "--clean" )
           CleanDirectories;;
        "--install" )
           Install;;
        *) echo >&2 "Invalid option: $@"; exit 1;;
   esac    
done

mkdir -p wrkdir

cd $wdir

Install

echo "-------------------- GRIP Install Completed  --------------------"

echo "Script Completed."
