#!/usr/bin/perl
use strict;
use warnings;
use diagnostics;
use feature 'say';
use ContentUtils;

my @colors = ("\033[32m", "\033[33m");
my $color = 0;
for (get_content('http://thecodinglove.com')) {
	print $colors[$color];
	$color = !$color;
	say 'Description: ', $_->{DESCRIPTION}, "\nImage: ", $_->{IMAGE_URL};
}
