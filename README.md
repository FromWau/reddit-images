# reddit-images
Downloads all .png and .jpg from a given subreddit and saves them to ~/Pictures/wallpapers/reddits/&lt;name of subreddit>

intended to be used with feh.

# usage
```
Usage: /home/fromml/.local/bin/reddit-images [--limit <value>] [--minsize <value>] [--include-animated] [--output-dir <directory>] [--no-fzf] [--debug] <subreddit1> [<subreddit2> ...]
Options:
  --limit             Set the limit value (default: 2000)
  --minsize           Set the minsize value (default: 300)
  --include-animated  Include animated content
  --output-dir        Set the output directory for saving images (default: ~/Pictures/wallpapers/reddits)
  --no-fzf            Skip user selection of the downloaded files to get deleted
  --debug             Sets the log level to debug
  --help              Display this help message
Subreddits:
  One or more subreddit names must be provided
```

will get the latest 300 images (png/jpg) from each subreddit and download them into ~/Pictures/wallpapers/reddits/{wallpaper,cyberpunk}.
Subreddits that exist will get ignored obviously.

Change the MINSIZE in the script to change the minimal size (height or width) a picture needs to have to get downloaded (currently: 2000).
