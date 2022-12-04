# reddit-images
Downloads all .png and .jpg from a given subreddit and saves them to ~/Pictures/wallpapers/reddits/&lt;name of subreddit>

intended to be used with feh.

# usage
`
./reddit-images.sh wallpaper cyberpunk some_subreddit_that_does_not_exist
`

will get the latest 300 images (png/jpg) from each subreddit and download them into ~/Pictures/wallpapers/reddits/{wallpaper,cyberpunk}.
Subreddits that exist will get ignored obviously.

Change the MINSIZE in the script to change the minimal size (height or width) a picture needs to have to get downloaded (currently: 2000).
