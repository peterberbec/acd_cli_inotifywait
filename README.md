# inw_acd_cli
OK! So you've gone through the trouble of setting up the most amazing acd_cli (http://github.com/yadayada/acd_cli). You've got your authorization, you've done the BIG F***ING UPLOAD (it took me three months).

Now what? Do you sit there and manually upload every new file? Set up a cron job? Set up a fuse mount and do periodic acd_cli overwrite s?

I have an alternative: these little scripts.

We set up an inotifywait watch over our directory (it's /data for me). When we detect a file moved into, created in, or modified in this watch directory, we spawn an instance of acd_cli and upload it. I have a queueing system in place; if you unzip a file, 500,000 processes don't spawn: they go one at a time.
Before anything, get acd_cli setup and running. Check yadayada's page for this amazing tool. Got everything done? Well, come back in a few weeks once you have all your filed uploaded!
Now that you have everything backed up, make sure you have inotify-tools installed. For my system, I ran <code>sudo apt install inotify-tools</code> 
Now download the files here into a directory (I use ~/inw_acd_cli). Make the <code>setup.sh</code> file executable (<code>chmod 744 setup.sh</code>). Run <code>setup.sh</code> and answer the prompts, giving the script root permissions where requested*. Run <code>inw_acd_cli.sh</code>
To watch activity, <code>tail -f ~/inw_acd_cli/log/inw_acd_cli.log</code> The script &s itself into the background.

For a more detailed explination, see https://github.com/peterberbec/inw_acd_cli/blob/master/Details.md

*: I don't take root permissions lightly, but this is necissary. Here is a detailed explination of every <code>sudo</code> in the setup scripts.
  1. We place a symbolic link with the script into the user defined directory (it defaults to /usr/local/bin)
    the command run is: <code>sudo ln -s "$install_dir_cfg/inw_acd_cli.sh" "$ln_dir"</code>
    <code>$install_dir_cfg</code> is user-defined as the directory inw_acd_cli is installed to. it defaults to <code>~/inw_acd_cli</code>
    <code>$ln_dir</code> is user-defined as the directory to place the symlink into. it defaults to <code>/usr/local/bin</code>
  2. If necissary, we update the <code>fs.inotify.max_user_watches</code> setting in <code>/etc/sysctl.conf</code>
    I needed to increase it it to 4,194,304, you may not have to at all. I have 1,983,236 files on my drive.
    the command run is: <code>sudo echo "fs.inotify.max_user_watches=$m_u_w" >> /etc/sysctl.conf</code>
    <code>$m_u_w</code> is user-defined. It defaults to the current value of <code>/proc/sys/fs/inotify/max_user_watches</code>
  3. If necissary, we implement the <code>sysctl.conf</code> update immediately.
    the command run is: <code>sudo sysctl -p /etc/sysctl.conf</code>
