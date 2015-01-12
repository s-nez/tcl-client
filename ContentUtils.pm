package ContentUtils;

use strict;
use warnings;
use diagnostics;
use Exporter 'import';
our $VERSION = '1.00';
our @EXPORT  = qw(get_content download);
use LWP::Simple;
use File::Fetch;

sub eval_special_chars {
	my %special_chars = (
		'&#8217;' => '`',
		'&#8220;' => '"',
		'&#8221;' => '"'
	);
	foreach my $char (keys %special_chars) {
		$_[0] =~ s/$char/$special_chars{$char}/g;
	}
}

sub get_content {
	my ($url) = @_;
	my $webpage = get($url);
	my @content;
	while ($webpage =~ m|(?:>(?<desc>[\w(?:&#\d{2,4};)]+(?:\s+[\w(&#\d{2,4};)]+)*)</a></h3>  <div class="bodytype"> <p class="e"><img src="(?<image>http(?:s)?://tclhost\.com/\S+\.jpg)"/>)|g) {
		my ($description, $image) = ($+{desc}, $+{image});
		eval_special_chars($description);
		$image =~ s/\.jpg$/\.gif/;
		push @content, {DESCRIPTION => $description, IMAGE => $image};
	}
	return @content;
}

sub download {
	my ($url) = @_;
	my $ff = File::Fetch->new(uri => $url);
	return $ff->fetch() or die $ff->error;
}
