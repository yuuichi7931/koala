0 9 * * * $HOME/.rbenv/shims/ruby $HOME/koala/scripts/daily.rb production >/dev/null 2>&1
10 * * * * $HOME/.rbenv/shims/ruby $HOME/koala/scripts/fetch.rb production > /dev/null 2>&1
