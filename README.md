# git-playback

git-playback is a bash script that creates a visual playback of git commits. Use it like this:

    git clone git://github.com/mmozuras/git-playback.git
    cd /repository/you/want/to/playback
    sh /path/to/git-playback/git-playback.sh file1 file2
    open playback.html

Output will be written to playback.html. Use left and right arrows to navigate.

To see a list of available options run git-playback with --help.

# Installing

You can also install git-playback to make it work like every other git command. Just run:

    make install

This will make 'git playback' available.
