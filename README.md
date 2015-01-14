# tcl-client
A simple GTK client for [The Coding Love](http://thecodinglove.com/)

**WARNING! This is a work in progress by no means considered stable**

# Dependencies
The following Perl modules are required for the client to work correctly:
* [Gtk3](https://metacpan.org/pod/Gtk3)
* [LWP::Simple](https://metacpan.org/pod/LWP::Simple)
* [File::Fetch](https://metacpan.org/pod/File::Fetch)

If you're using Fedora, these modules can be installed with the following command:
    
    # yum install perl-Gtk3 perl-libwww-perl perl-File-Fetch

Under Arch Linux you are going to have to use cpan. First install cpanm:

	# sudo cpan App::cpanminus

And then use it to install perl modules:

	# sudo cpanm Gtk3
	# sudo cpanm LWP::Simple
	# sudo cpanm File::Fetch

(I got some errors here and had to --force Gtk3.)

# Known issues
* the GUI is not reponding while a new page is being downloaded
* some HTML character escapes are still not evaluated
* errors during page download are not handled
