#!/bin/bash
# MIT License
# Copyright (c) 2019 Turtle Bot NYUAD

# bash script to install all **simulation** tools needed for ROS Melodic + Ubuntu 18.04 LTS

echo ""
echo "[NOTE] This bash script assumes Ubuntu 18.04 + ROS Melodic install and assumes a fresh install"

sudo apt-get update
sudo apt-get upgrade

##########THE FOLLOWING BASH SCRIPT IS ADAPTED FROM ROBOTIS CO. LTD###################

# Apache License 2.0
# Copyright (c) 2018, ROBOTIS CO., LTD.

echo ""
echo "[Note] Target OS version  >>> Ubuntu 18.04.x (Bionic Beaver) or Linux Mint 19.x"
echo "[Note] Target ROS version >>> ROS Melodic Morenia"
echo "[Note] Catkin workspace   >>> $HOME/catkin_ws"
echo ""
echo "PRESS [ENTER] TO CONTINUE THE INSTALLATION"
echo "IF YOU WANT TO CANCEL, PRESS [CTRL] + [C]"
read

echo "[Set the target OS, ROS version, name of catkin workspace, and turtlebot3 model]"
name_os_version=${name_os_version:="bionic"}
name_ros_version=${name_ros_version:="melodic"}
name_catkin_workspace=${name_catkin_workspace:="catkin_ws"}
TB3_MODEL=${TB3_MODEL:="waffle"}


echo "[Update the package lists and upgrade them]"
sudo apt update -y
sudo apt upgrade -y

echo "[Install build environment, the chrony, ntpdate and set the ntpdate]"
sudo apt install -y chrony ntpdate build-essential
sudo ntpdate ntp.ubuntu.com

echo "[Add the ROS repository]"
if [ ! -e /etc/apt/sources.list.d/ros-latest.list ]; then
  sudo sh -c "echo \"deb http://packages.ros.org/ros/ubuntu ${name_os_version} main\" > /etc/apt/sources.list.d/ros-latest.list"
fi

echo "[Download the ROS keys]"
roskey=`apt-key list | grep "Open Robotics"`
if [ -z "$roskey" ]; then
  sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
fi

echo "[Check the ROS keys]"
roskey=`apt-key list | grep "Open Robotics"`
if [ -n "$roskey" ]; then
  echo "[ROS key exists in the list]"
else
  echo "[Failed to receive the ROS key, aborts the installation]"
  exit 0
fi

echo "[Update the package lists and upgrade them]"
sudo apt update -y
sudo apt upgrade -y

echo "[Install the ros-desktop-full and all rqt plugins]"
sudo apt install -y ros-$name_ros_version-desktop-full ros-$name_ros_version-rqt-*

echo "[Initialize rosdep]"
sudo sh -c "rosdep init"
rosdep update

echo "[Environment setup and getting rosinstall]"
source /opt/ros/$name_ros_version/setup.sh
sudo apt install -y python-rosinstall python-rosinstall-generator python-wstool

echo "[Make the catkin workspace and test the catkin_make]"
mkdir -p $HOME/$name_catkin_workspace/src
cd $HOME/$name_catkin_workspace/src
catkin_init_workspace
cd $HOME/$name_catkin_workspace
catkin_make

echo "[Set the ROS evironment]"
sh -c "echo \"alias eb='nano ~/.bashrc'\" >> ~/.bashrc"
sh -c "echo \"alias sb='source ~/.bashrc'\" >> ~/.bashrc"
sh -c "echo \"alias gs='git status'\" >> ~/.bashrc"
sh -c "echo \"alias gp='git pull'\" >> ~/.bashrc"
sh -c "echo \"alias cw='cd ~/$name_catkin_workspace'\" >> ~/.bashrc"
sh -c "echo \"alias cs='cd ~/$name_catkin_workspace/src'\" >> ~/.bashrc"
sh -c "echo \"alias cm='cd ~/$name_catkin_workspace && catkin_make'\" >> ~/.bashrc"

sh -c "echo \"source /opt/ros/$name_ros_version/setup.bash\" >> ~/.bashrc"
sh -c "echo \"source ~/$name_catkin_workspace/devel/setup.bash\" >> ~/.bashrc"

sh -c "echo \"export ROS_MASTER_URI=http://localhost:11311\" >> ~/.bashrc"
sh -c "echo \"export ROS_HOSTNAME=localhost\" >> ~/.bashrc"

source $HOME/.bashrc

##################################################################################

echo "[Install the turtlebot3 simulation package dependencies]"
cd ~/${name_catkin_workspace}/src/
git clone https://github.com/ROBOTIS-GIT/turtlebot3.git
git clone https://github.com/ROBOTIS-GIT/turtlebot3_msgs.git
git clone https://github.com/ROBOTIS-GIT/turtlebot3_simulations.git
cd ~/${name_catkin_workspace} && catkin_make

export TURTLEBOT3_MODEL=${TB3_MODEL}

echo "[Install Gazebo standalone]"
curl -sSL http://get.gazebosim.org | sh

sudo apt-get install ros-melodic-gazebo-ros-pkgs ros-melodic-gazebo-ros-control

# echo "[Install the turtlebot3 simulation package]"
# cd ~/${name_catkin_workspace}/src/
# git clone https://github.com/ROBOTIS-GIT/turtlebot3_simulations.git
# cd ~/catkin_ws && catkin_make
