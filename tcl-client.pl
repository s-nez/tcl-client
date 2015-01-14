#! /usr/bin/perl
use strict;
use warnings;
use diagnostics;
use feature 'say';
use Gtk3 '-init';
use Glib 'TRUE', 'FALSE';
use ContentUtils;
use threads;
use threads::shared;
use Thread::Queue;

my @content : shared;
my $content_index          = -1;
my $pages_fetched : shared = 0;
my $base_url               = 'http://thecodinglove.com/page/';

my $page_queue  = Thread::Queue->new();
my $page_worker = threads->create(\&page_worker_thread);

# Worker thread that downloads page information
sub page_worker_thread {
    while (defined(my $page = $page_queue->dequeue())) {
        foreach my $post (get_content($page)) {
            $post->{IMAGE} = download($post->{IMAGE_URL});
			say 'downloaded';
            share($post);
            push @content, $post;
            ++$pages_fetched;
        }
    }
	return;
}

sub fetch_new_page {
    $page_queue->enqueue($base_url . ($pages_fetched + 1));
	return;
}

sub cleanup {
    foreach (@content) {
        unlink $_->{IMAGE};
    }
	return;
}

# Widgets
my $window = Gtk3::Window->new('toplevel');
$window->set_title("The Coding Love");
$window->set_position("mouse");
$window->set_default_size(400, 300);
$window->set_border_width(20);
$window->signal_connect(delete_event => sub { Gtk3->main_quit; });

my $vbox = Gtk3::Box->new('vertical',   5);
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
$hbox->set_homogeneous(TRUE);

$vbox->pack_start($label,       TRUE, TRUE, 10);
$vbox->pack_start($image_frame, TRUE, TRUE, 0);
$vbox->pack_start($hbox,        TRUE, TRUE, 0);

$window->add($vbox);

# Main program
$window->show_all;
Gtk3->main;
cleanup();
$page_queue->end();
$page_worker->join();

# Signal handlers
sub next_image {
    if ($content_index >= $#content) {
        loading_start();
        fetch_new_page();
    } else {
        ++$content_index;
        update_content();
    }
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
