#! /usr/bin/perl
use strict;
use warnings;
use diagnostics;
use feature 'say';
use Gtk3 '-init';
use Glib 'TRUE', 'FALSE';
use ContentUtils;

my @content;
my $content_index = -1;
my $pages_fetched = 0;
my $base_url = 'http://thecodinglove.com/page/';
my $download_dir = '/tmp/tcl-client';

sub fetch_new_page {
	++$pages_fetched;
	foreach my $post (get_content($base_url . $pages_fetched)) {
		$post->{IMAGE} = download($post->{IMAGE}, $download_dir);
		push @content, $post;
	}
}

sub cleanup {
	foreach (@content) {
		unlink $_->{IMAGE};
	}
	rmdir $download_dir;
}

############ Widgets ############ 
my $window = Gtk3::Window->new('toplevel');
$window->set_title("The Coding Love");
$window->set_position("mouse");
$window->set_default_size(400, 300);
$window->set_border_width(20);
$window->signal_connect (delete_event => sub { Gtk3->main_quit; } );

my $vbox = Gtk3::Box->new('vertical', 5);
my $hbox = Gtk3::Box->new("horizontal", 5);

my $label = Gtk3::Label->new('Epic gifs for developers!');

my $button_next = Gtk3::Button->new("Next");
$button_next->signal_connect('clicked' => \&next_image);

my $button_prev = Gtk3::Button->new("Previous");
$button_prev->signal_connect('clicked' => \&prev_image);

my $image_frame = Gtk3::Frame->new();
$image_frame->set_size_request(300, 300);

my $img = Gtk3::Image->new_from_file('./tcl_logo.png');
$image_frame->add($img);

my $spinner = Gtk3::Spinner->new;
$spinner->start;

$hbox->pack_start($button_prev, TRUE, TRUE, 0);
$hbox->pack_start($button_next, TRUE, TRUE, 0);
$hbox->set_homogeneous (TRUE);

$vbox->pack_start($label, TRUE, TRUE, 10);
$vbox->pack_start($image_frame, TRUE, TRUE, 0);
$vbox->pack_start($hbox, TRUE, TRUE, 0);

$window->add($vbox);
################################# 

$window->show_all;
mkdir $download_dir unless (-d $download_dir);
Gtk3->main;
cleanup();

############ Signal handlers ############ 
# All signal handlers return false, so that GTK doesn't freak out
sub next_image {
	if ($content_index >= $#content) {
		fetch_new_page();
	}
	++$content_index;
	update_content();
	return;
}

sub prev_image {
	if ($content_index > 0) {
		--$content_index;
		update_content();
	}
	return;
}

sub loading_start {
	$image_frame->remove($image_frame->get_children());
	$image_frame->add($spinner);
	$spinner->show();
	return;
}

sub update_content {
	if ($image_frame->get_children() != $img) {
		$image_frame->remove($image_frame->get_children());
		$image_frame->add($img);
		$img->show();
	}
	$label->set_text($content[$content_index]->{DESCRIPTION});
	$img->set_from_file($content[$content_index]->{IMAGE});
	return;
}
########################################
