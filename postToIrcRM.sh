USER="TG9zdCB0aGUgZ2FtZSAuLi46KQ"
IRC_SERVER="irc.root-me.org"
IRC_PORT="6667"
CHANNEL="#root-me"
DEST=""
MSG=$1
(
 echo NICK $USER
 echo USER $USER $USER $USER :$USER
 sleep 1
 echo "JOIN $CHANNEL"
 sleep 1
 echo "PRIVMSG $CHANNEL" :$MSG
 sleep 1
 echo "QUIT"
 ) | nc $IRC_SERVER $IRC_PORT
