#!/bin/bash
echo "Install script."
temp_dir=`pwd` 		# default directory is current directory
home=`eval echo "~$USER"`	# need user home directory to watch acd_cli log
read -p "Please enter directory inw_acd_cli is installed [$temp_dir] " install_dir_cfg
if [ -z $install_dir_cfg ]; then
	install_dir_cfg=$temp_dir
fi
mkdir $install_dir_cfg
watch_dir=""
while [ -z $watch_dir ];
do
	read -p "Please enter directory to watch for uploads. " watch_dir
done
read -p "Please enter directory to link executable into. [/usr/local/bin] " ln_dir
if [ -z $ln_dir ]; then
	ln_dir="/usr/local/bin"
fi
echo "The following prompt for root permissions is to link the script into $ln_dir"
sudo ln -s "$install_dir_cfg/inw_acd_cli.sh" "$ln_dir"
echo "Depending on the size of the watched directory, you may need to increase max_user_watches."
muw_old=`cat /proc/sys/fs/inotify/max_user_watches`
read -p "Enter new value for max_user_watches. [$muw_old] " m_u_w
if [ ! -z $m_u_w ]; then
	echo "need root permissions again, to set this."
	sudo echo "fs.inotify.max_user_watches=$m_u_w" >> /etc/sysctl.conf
	echo "need root one last time, make it take effect now."
	sudo sysctl -p /etc/sysctl.conf
fi
echo "Setting config files for $install_dir_cfg. Running the script will"
echo "watch $watch_dir. Please put any files or directories to be excluded into"
echo "$install_dir_cfg/inw_acd_cli.watch prefixed by a \@"
echo "The main log file to watch once the script is up and running is:"
echo "$install_dir_cfg/log/inw_acd_cli.log"
{
	echo "install_dir=$install_dir_cfg"
	echo "log_dir=\$install_dir/log"
	echo "lock_dir=\$install_dir/.lock"
	echo "base_name=$watch_dir"
	echo "acd_ul_lock=\$lock_dir/acd_ul.lock"
	echo "watch_file=$install_dir_cfg/inw_acd_cli.watch"
	echo "home_dir=$home"
} > $install_dir_cfg/inw_acd_cli.cfg
mkdir $install_dir_cfg/log
mkdir $install_dir_cfg/.lock
{
	echo "$watch_dir"
	echo "@$install_dir_cfg/.lock"
	echo "@$install_dir_cfg/.log"
	echo "@/data/torrents/incomplete" 		#PRB ONLY
	echo "@/data/torrents/incompletepieces" 	#PRB ONLY
	echo "@/data/prb/monolith/inw_acd_cli/.lock"	#PRB ONLY
	echo "@/data/prb/monolith/inw_acd_cli/log"	#PRB ONLY
} > $install_dir_cfg/inw_acd_cli.watch
# gotta jump through hoops to get the config file sourced. inside & outside {}
{
	echo "#!/bin/bash"
	echo "source $install_dir_cfg/inw_acd_cli.cfg"
	echo "{"
	echo "source $install_dir_cfg/inw_acd_cli.cfg"
} > inw_acd_cli.temp.sh
cat inw_acd_cli.orig >> inw_acd_cli.temp.sh
mv inw_acd_cli.temp.sh inw_acd_cli.sh
chmod 744 inw_acd_cli.sh
{
	echo "#!/bin/bash"
	echo "source $install_dir_cfg/inw_acd_cli.cfg"
	echo "{"
	echo "source $install_dir_cfg/inw_acd_cli.cfg"
} > inw_acd_cli_ul.temp.sh
cat inw_acd_cli_ul.orig >> inw_acd_cli_ul.temp.sh
mv inw_acd_cli_ul.temp.sh inw_acd_cli_ul.sh
chmod 744 inw_acd_cli_ul.sh
