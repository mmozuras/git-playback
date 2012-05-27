# git-playback

git-playback is a bash script that creates a visual playback of git commits. Use it like this:

    git clone git://github.com/mmozuras/git-playback.git
    cd /repository/you/want/to/playback
    sh /path/to/git-playback/git-playback.sh file1 file2
    open playback.html

Output will be written to playback.html. Use left and right arrows to navigate.

To see a list of available options run git-playback with --help.

# Installing

You can also install git-playback to make it work like every other git command. Simply copy git-playback.sh to where the rest of the git scripts are stored. There's also a make command for that:

    make install

This will make 'git playback' command available.
