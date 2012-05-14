# git-playback

git-playback is a bash script that creates a visual playback of git commits. Use it like this:

    git clone git://github.com/mmozuras/git-playback.git
    cd /repository/you/want/to/playback
    sh /path/to/git-playback/git-playback file1 file2
    open playback.html

git-playback automatically uses the branch you're currently on. Output will be written to playback.html.
