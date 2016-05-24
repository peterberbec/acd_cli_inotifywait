OK. Here is what all goes on.
There are three scripts: setup.sh, inw_acd_cli.sh and inw_acd_cli_ul.sh
setup.sh creates inw_acd_cli.sh and inw_acd_cli_ul.sh from the .orig files. I had to do it this way to make the <code>source $install_dir/inw_acd_cli.cfg</code> line know where to find the config file. Setup creates inw_acd_cli.cfg with the values pointing to where to place log files, lock files, directory to watch etc. It also updates the inotify.max_user_watches if needed. If you run the script, and after <code>2016/05/24 12:15:00 - 01418: inw_acd_cli.sh started</code> you get an error like:
<code>Failed to watch /data/not_porn.mp4; upper limit on inotify watches reached!
Please increase the amount of inotify watches allowed per user via '/proc/sys/fs/inotify/max_user_watches'.</code>
You need to up your limit. 
inw_acd_cli.sh is the main script containing the inotifywait loop. I create a lockfile to keep from two scripts running at once. we then start inotifywait. the line of code is:
<code>inotifywait --exclude '(/\..+|~$|.tmp$|.log$|.lock$)' --format "%w%f" -qrme close_write,moved_to --fromfile $watch_file | while read file; do</code>
The excludes are to ignore: files that start with a ., files that end with a ~, files that end in tmp, files that end in log and files that end in lock. Things get ugly if you remove some of these. God forbid you watch your home directory and browse the web: thousands of files in your web browser's cache will get uploaded! 
Format only outputs the path and filename, we don't care about the other items available.
-qrme close_write,moved_to is four options in one:
-q = quiet, don't output much
-r = recursive, watch all subdirectories
-m = monitor, keep watching even after the first event
-ee close_write,moved_to = watch files that were closed & writen to, and files that were moved to the watched directory.
The watch_file is created by setup parsing the user's input. The output of inotifywait is piped into a while loop reading every line of output. Every line contains the path and filename of a file to be uploaded. We queue up if another file is being uploaded. Once it's our turn, we spawn inw_acd_cli_ul.sh
Once in inw_acd_cli_ul.sh, we do some sanity checks (lock files, correct variables etc) and parse the file into source path & file and destination path. if the file is /data/downloads/totally_not_porn.m4v, we upload it to /downloads/totally_not_porn.m4v. Next we check the last time acd_cli synced. If under 10 minutes, we skip it. 
I then create the directory the file exists in, and all parent directories. It takes just as much time for a failed directory creation as to test if we need to create the directories, so I just do it even if it throws an error. File /data/taxes/2015/Quickbooks/no_way_this_is_porn.fax.mkv makes us create /taxes, /taxes/2015, /taxes/2015 and /taxes/2015/Quickbooks. Anyone who knows a better way to do this, please let me know!
Once we are sure the file to be uploaded has a directory to land in, we upload the file and parse the output of acd_cli for our log file.
I've tried to trap errors, kill command etc, but the spawning of a child process is tough. Tips and updates are 100% appreciated!
