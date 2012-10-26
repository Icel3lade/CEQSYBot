#!/usr/bin/perl

use strict;
use warnings;

sub parse_command {
    my ($command, $pipeid) = @_;
    $command =~ s/[\r\n]+$//;
    debug_output("Received API call: $command");

    #my $validhashkey = '[a-zA-Z0-9_#\-]+';
    my $validhashkey = '[A-Za-z0-9\[\]\\\\`\s_\^{}|\-#&\+\.!]+';
    my $validpersistfile = '[a-zA-Z0-9_#\-]+';
    my $validpersistkey = '[A-Za-z0-9\[\]\\\\`\s_\^{}|\-#&\+\.!]+'; #[a-zA-Z0-9\s_#\-]+';

    if ($command =~ /^ssm>(.+)$/) {
        send_server_message($1);
        if ($1 =~ /^NICK (.+)$/) { set_core_value('nick',$1); }
    }
    elsif ($command =~ /^send_server_message>(.+)$/) {
        send_server_message($1);
        if ($1 =~ /^NICK (.+)$/) { set_core_value('nick',$1); }
    }
    elsif ($command =~ /^send_pipe_message>($validhashkey)>(.+)$/) {
        send_pipe_message($1,$2);
    }
    elsif ($command =~ /^join (.+)$/) {
        send_server_message('JOIN ' . $1);
    }


    elsif ($command =~ /^get_core_value>($validhashkey)$/) {
        if (my $value = &get_core_value($1)) {
            &send_pipe_message($pipeid,"$value");
        }
        else {
            &send_pipe_message($pipeid,"");
        }
    }
    elsif ($command =~ /^get_config_value>($validhashkey)$/) {
        if (my $value = &get_config_value($1)) {
            &send_pipe_message($pipeid,"$value");
        }
        else {
            &send_pipe_message($pipeid,"");
        }
    }
    elsif ($command =~ /^get_variable_value>($validhashkey)$/) {
        if (my $value = &get_variable_value($1)) {
            &send_pipe_message($pipeid,"$value");
        }
        else {
            &send_pipe_message($pipeid,"");
        }
    }



    elsif ($command =~ /^set_core_value>($validhashkey)>(.+)$/) {
        &set_core_value($1,$2);
    }
    elsif ($command =~ /^set_config_value>($validhashkey)>(.+)$/) {
        &set_config_value($1,$2);
    }
    elsif ($command =~ /^set_variable_value>($validhashkey)>(.+)$/) {
        &set_variable_value($1,$2);
    }
    elsif ($command =~ /^clear_variable_value>($validhashkey)>?$/) {
        &set_variable_value($1,"");
    }


    elsif ($command =~ /^check_pipe_exists>($validhashkey)$/) {
        if (&check_pipe_exists($1)) {
            &send_pipe_message($pipeid,"1");
        }
        else {
            &send_pipe_message($pipeid,"");
        }
    }
    elsif ($command =~ /^kill_pipe>($validhashkey)$/) {
        &kill_pipe($1);
    }
    elsif ($command =~ /^run_command>($validhashkey)>(.+)$/) {
        &run_command($1,$2);
    }



    elsif ($command =~ /^sleep>([0-9\.]+)$/) {
        select(undef,undef,undef,$1);
    }
    elsif ($command =~ /^shutdown>$/) {
        &event_output("API call from $pipeid asked for a shutdown.");
        exit;
    }
    elsif ($command =~ /^reconnect>$/) {
        &event_output("API call from $pipeid asked for a reconnection.");
        &reconnect();
    }
    elsif ($command =~ /^reload_config>$/) {
        event_output("API call from $pipeid asked for a configuration reload.");
        &read_configuration_file(&get_core_value('home_directory') . '/configurations/' . &get_core_value('configuration_file'));
    }
    elsif ($command =~ /^reload>$/) {
        event_output("API call from $pipeid asked for a configuration reload.");
        &read_configuration_file(&get_core_value('home_directory') . '/configurations/' . &get_core_value('configuration_file'));
    }
    elsif ($command =~ /^log>($validhashkey)>(.+)$/) {
        &normal_output($1,$2);
    }

    elsif ($command =~ /^get_persistent_value>($validpersistfile)>($validpersistkey)$/) {
        if (my $value = &get_persistent_value($1,$2)) {
        &send_pipe_message($pipeid,"$value");
        }
        else {
        &send_pipe_message($pipeid,"");
        }
    }
    elsif ($command =~ /^set_persistent_value>($validpersistfile)>($validpersistkey)>(.+)$/) {
        &set_persistent_value($1,$2,$3);
    }
    elsif ($command =~ /^del_persistent_value>($validpersistfile)>($validpersistkey)$/) {
        &del_persistent_value($1,$2);
    }
    elsif ($command =~ /^del_all_persistent_values>($validpersistfile)$/) {
        &del_all_persistent_values($1);
    }
    elsif ($command =~ /^clear_persistence_file>($validpersistfile)$/) {
        &clear_persistence_file($1);
    }
    elsif ($command =~ /^read_persistence_file>($validpersistfile)$/) {
        &read_persistence_file($1);
    }
    elsif ($command =~ /^load_persistence_file>($validpersistfile)$/) {
        &read_persistence_file($1);
    }
    elsif ($command =~ /^save_persistence_file>($validpersistfile)$/) {
        &save_persistence_file($1);
    }
    elsif ($command =~ /^save_all_persistence_files>$/) {
        &save_all_persistence_files();
    }
    elsif ($command =~ /^check_persistence_domain_exists>($validpersistfile)$/) {
        if (&check_persistence_domain_exists($1)) {
        &send_pipe_message($pipeid,"1");
        }
        else {
        &send_pipe_message($pipeid,"");
        }
    }

    else {
        &error_output("Unknown API call: $command");
    }
}
    
1;
