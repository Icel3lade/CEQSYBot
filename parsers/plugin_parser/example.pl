#!/usr/bin/perl -I/usr/share/perl5/ -I/usr/lib/perl5/

use strict;
use warnings;
use URI::Escape;
use Fcntl ':flock';
use FindBin;
use lib $FindBin::Bin;
use plugin_parse;

$| = 1;
my $home_folder = $FindBin::RealBin;
my ($script_id, $self, $incoming_message) = &startup_variables();
my ($server_chantype, $server_prefix, $server_modes, $server_network) = &fetch_server_variables();
my $valid_nick_characters = 'A-Za-z0-9\[\]\\\\`_\^{}|\-'; #matches: A-Za-z0-9[]\`_^{}|-
my $valid_chan_characters = $server_chantype.$valid_nick_characters;
my $valid_human_sender_regex = "([".$valid_nick_characters."]+)!~?([".$valid_nick_characters."]+)@(.+?)";
my ($event, $sender, $account, $hostname, $command, $target, $message, $receiver) = &parse_message($self, $incoming_message);
my ($sl, $cm, $version, $about, @modules, %botmodes);
sub load_plugin {
    my $plugin_name = shift;
    my $plugin_text;
    open(PLUGIN_FILE, $plugin_name) or ACT('LITERAL',undef,"error>Could not load plugin file: $plugin_name");
    while(<PLUGIN_FILE>) { $plugin_text .= $_; }
    close(PLUGIN_FILE);
    return eval($plugin_text);
}

####-----#----- ################## -----#-----####
####-----#----- BEGIN EDITING HERE -----#-----####
####-----#----- ################## -----#-----####

$sl = '(' . $self . ')?(.' . $self . ')?'.'[-;:,\s]*';
    #$sl stands for "start of line". For example: "CEQSY:"
$cm = '!'; #$cm stands for "command marker".
$version = "CEQSYBot v1.0";
$about = "I am CEQSY and I know it.";

if (($script_id eq '20')) {
    if(defined select(undef,undef,undef,5)) {
        #ACT('LITERAL',undef,"log>COOKIES>Sleeping 5");
    }
    # Server variables may have changed in those 5 seconds, so refetch them.
    ($server_chantype, $server_prefix, $server_modes, $server_network) = &fetch_server_variables();
    if($server_network eq 'freenode') {
        ACT('JOIN','#CEQSY',undef);
        ACT('JOIN','#channel1',undef);
        ACT('JOIN','#channel2',undef);
    }
    if ($server_network eq 'IRCnet') {
        ACT('JOIN','#CEQSY',undef);
        ACT('JOIN','#channel1',undef);
        ACT('JOIN','#channel2',undef);
    }
}

sub on_ping { }

sub on_private_message {
    if (
        &load_plugin("$home_folder/plugins/basic/ctcp.pm")
    ) {}

    $message = "$self: $message";
    &on_public_message();
}

sub on_public_message {
    if (
        &load_plugin("$home_folder/plugins/actions.pm")
        || &load_plugin("$home_folder/plugins/hug.pm")
        || &load_plugin("$home_folder/plugins/slap.pm")
        || &load_plugin("$home_folder/plugins/time.pm")
        
        || &load_plugin("$home_folder/plugins/staff/checkauth.pm")
        || &load_plugin("$home_folder/plugins/staff/channel.pm")
        || &load_plugin("$home_folder/plugins/staff/speak.pm")
        || &load_plugin("$home_folder/plugins/staff/op.pm")
        || &load_plugin("$home_folder/plugins/staff/voice.pm")
        || &load_plugin("$home_folder/plugins/staff/quiet.pm")
        
        || &load_plugin("$home_folder/plugins/conversation/quote.pm")
        || &load_plugin("$home_folder/plugins/conversation/vote.pm")
        || &load_plugin("$home_folder/plugins/conversation/dictionary.pm")
        || &load_plugin("$home_folder/plugins/conversation/yuno.pm")
        #|| &load_plugin("$home_folder/plugins/conversation/cya.pm")
        
        || &load_plugin("$home_folder/plugins/text_manipulation/reverse.pm")
        || &load_plugin("$home_folder/plugins/text_manipulation/encode.pm")
        || &load_plugin("$home_folder/plugins/internet/youtube.pm")
        
        || &load_plugin("$home_folder/plugins/games/dice.pm")
        || &load_plugin("$home_folder/plugins/games/eightball.pm")
        || &load_plugin("$home_folder/plugins/games/yesno.pm")
        || &load_plugin("$home_folder/plugins/games/roulette.pm")

        || &load_plugin("$home_folder/plugins/conversation/karma.pm")

        #|| &load_plugin("$home_folder/plugins/internet/ticket.pm")
        #|| &load_plugin("$home_folder/plugins/internet/translate.pm")
        #|| &load_plugin("$home_folder/plugins/internet/url-check.pm")
        #|| &load_plugin("$home_folder/plugins/temperature.pm")
        #|| &load_plugin("$home_folder/plugins/conversation/QMarkAPI.pm")
        
        || &load_plugin("$home_folder/plugins/basic/basic.pm") # Must be loaded last to show entire modules list in !help command.      
    ) { }
}

sub on_private_notice {
    $message = "$self: $message";
    &on_public_notice();
}

sub on_public_notice { }

sub on_join { }

sub on_part { }

sub on_quit { }

sub on_mode {
    if (
        &load_plugin("$home_folder/plugins/basic/modewhois.pm")
    ) {}
}

sub on_nick { }

sub on_kick { }

sub on_server_message {
    if (
        &load_plugin("$home_folder/plugins/basic/nick_bump.pm")
        || &load_plugin("$home_folder/plugins/basic/server_config.pm")
        || &load_plugin("$home_folder/plugins/basic/modewhois.pm")
    ) {}
}

sub on_error {
    ACT('LITERAL',undef,"log>APIERROR>$message");
}

####-----#----- ################# -----#-----####
####-----#----- STOP EDITING HERE -----#-----####
####-----#----- ################# -----#-----####
&fire_event($event);
