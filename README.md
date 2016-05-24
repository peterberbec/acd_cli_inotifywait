# inw_acd_cli
OK! So you've gone through the trouble of setting up the most amazing acd_cli (http://github.com/yadayada/acd_cli). You've got your authorization, you've done the BIG F***ING UPLOAD (it took me three months).

Now what? Do you sit there and manually upload every new file? Set up a cron job? Set up a fuse mount and do periodic acd_cli overwrite s?

I have an alternative: these little scripts.

We set up an inotifywait watch over our directory (it's /data for me)
When we detect a file moved into, created in, or modified in this watch directory, we spawn an instance of acd_cli and upload it. I have a queueing system in place, unzip a file and 500,000 processes don't spawn, the go one at a time.

Download the files here into a directory (I use ~/inw_acd_cli). Make the setup.sh file executable (<code> chmod 744 setup.sh</code>). Run setup.sh Answer the prompts, give the script root permissions*. Run inw_acd_cli.sh

To watch activity, <code>tail -f ~/inw_acd_cli/log/inw_acd_cli.log</code>

*: Root is needed for the following:
  1. to place a symbolic link with the script into the user defined directory (it defaults to /usr/local/bin)
    the command run is: <code>sudo ln -s "$install_dir_cfg/inw_acd_cli.sh" "$ln_dir"
  2. if requested, to update the fs.inotify.max_user_watches setting in /etc/sysctl.conf</code>
    I needed to update it to 4194304
    the command run is: <code>sudo echo "fs.inotify.max_user_watches=$m_u_w" >> /etc/sysctl.conf</code>
  3. if requested, to implement the sysctl.conf update immediately.
    the command run is: <code>sudo sysctl -p /etc/sysctl.conf</code>
