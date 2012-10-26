push(@modules,"vote");
my $home_path = $home_folder;
    $home_path =~ s/parsers\/plugin_parser//g;

my $sempath = ($home_path.'persistent/'.$server_network.'/vote_'.$target.'.sem');

my @abc = qw ( A B C D E F G H I J K L M N O P Q R S T U V W X Y Z );

sub c2f { #channel_to_filename
    my $c2fs = uc $_[0];
    $c2fs =~ s/[^a-zA-Z0-9_#\-]//;
    return $c2fs;
}

sub checkload {
    my $file = c2f($_[0]);
    ACT('LITERAL',undef,"check_persistence_domain_exists>vote_".$file);
    my $dictloaded = <STDIN>;
    $dictloaded =~ s/[\r\n\t\s]+$//;
    if (!$dictloaded) { ACT('LITERAL',undef,"load_persistence_file>vote_".$file); }
}


sub update_topic {
    my $chanstr = $_[0];
    my $self = $_[1];
    
    checkload($target);

    ACT('LITERAL',undef,"get_persistent_value>vote_".c2f($target).">UseTopic");
    my $topicvote = <STDIN>;
    $topicvote =~ s/[\r\n\t\s]+$//;
    if ($topicvote eq "True") {
        my $topicstr = "";
        ACT('LITERAL',undef,"get_persistent_value>vote_".c2f($target).">Question");
        my $value = <STDIN>;
        $value =~ s/[\r\n\t\s]+$//;
        ACT('LITERAL',undef,"get_persistent_value>vote_".c2f($target).">NrOptions");
        my $nroptions = <STDIN>;
        $nroptions =~ s/[\r\n\t\s]+$//;
        if ($value && $nroptions) {
            $topicstr = "VOTE: ".$value;
            
            ACT('LITERAL',undef,"get_persistent_value>vote_".c2f($target).">Option_0");
            my $option = <STDIN>;
            $option =~ s/[\r\n\t\s]+$//;
            ACT('LITERAL',undef,"get_persistent_value>vote_".c2f($target).">Option_0_count");
            my $o_count = <STDIN>;
            $o_count =~ s/[\r\n\t\s]+$//;
            $o_count = 0 if (!$o_count);
            my $results = "RESULTS: ".$abc[0].": ".$option." [".$o_count."]";
            
            for(my $i=1; $i < $nroptions; $i=$i+1) {
                $option = "";
                $o_count = "0";
                ACT('LITERAL',undef,"get_persistent_value>vote_".c2f($target).">Option_".$i);
                $option = <STDIN>;
                $option =~ s/[\r\n\t\s]+$//;
                ACT('LITERAL',undef,"get_persistent_value>vote_".c2f($target).">Option_".$i."_count");
                $o_count = <STDIN>;
                $o_count =~ s/[\r\n\t\s]+$//;
                $o_count = 0 if (!$o_count);
                $results = $results." | ".$abc[$i].": ".$option." [".$o_count."]";
            }
            
            $topicstr = $topicstr." : ".$results;
            if(CheckOps($chanstr)) {
                ACT('TOPIC',$chanstr,$topicstr);
            } else {
                ACT('MESSAGE','chanserv',"op ".$chanstr." ".$self);
                sleep 4;
                ACT('TOPIC',$chanstr,$topicstr);
                sleep 2;
                ACT('MESSAGE','chanserv',"deop ".$chanstr." ".$self);
            }
        }
    }
}

if ($message =~ /^${sl}${cm}v(?:ote)?\??\s*$/i) {

    if($sender eq $target) {
        ACT('MESSAGE',$target,"This function only works in a channel.");
        return 1;
    }

    open (VOTESEMA, ">", $sempath) or die("Can't open semaphore $!\n");
    flock VOTESEMA, LOCK_EX or die("Can't lock semaphore $!\n");

    checkload($target);

    ACT('LITERAL',undef,"get_persistent_value>vote_".c2f($target).">Question");
    my $value = <STDIN>;
    $value =~ s/[\r\n\t\s]+$//;
    ACT('LITERAL',undef,"get_persistent_value>vote_".c2f($target).">NrOptions");
    my $nroptions = <STDIN>;
    $nroptions =~ s/[\r\n\t\s]+$//;
    
    if ($value && $nroptions) {
        ACT('MESSAGE',$target,"VOTE: $value");
        
        ACT('LITERAL',undef,"get_persistent_value>vote_".c2f($target).">Option_0");
        my $option = <STDIN>;
        $option =~ s/[\r\n\t\s]+$//;
        my $options = "Options: ".$abc[0].": ".$option;
        
        for(my $i=1; $i < $nroptions; $i=$i+1) {
            $option = "";
            ACT('LITERAL',undef,"get_persistent_value>vote_".c2f($target).">Option_".$i);
            $option = <STDIN>;
            $option =~ s/[\r\n\t\s]+$//;
            $options = $options." | ".$abc[$i].": ".$option;
        }
        
        ACT('MESSAGE',$target,"VOTE: $options");
    }
    else {
        ACT('MESSAGE',$target,"VOTE: There is currently no vote active.");
    }

    flock VOTESEMA, LOCK_UN;
    close(VOTESEMA);

    return 1;
}

if ($message =~ /^${sl}${cm}v(?:ote)?\s+([A-Za-z\t\s]+)$/i) {
    my $choice = uc $3;
    $choice =~ s/[\r\n\t\s]+//;

    if($sender eq $target) {
        ACT('MESSAGE',$target,"This function only works in a channel.");
        return 1;
    }

    open (VOTESEMA, ">", $sempath) or die("Can't open semaphore $!\n");
    flock VOTESEMA, LOCK_EX or die("Can't lock semaphore $!\n");

    if($choice) {
        checkload($target);

        ACT('LITERAL',undef,"get_persistent_value>vote_".c2f($target).">NrOptions");
        my $nroptions = <STDIN>;
        $nroptions =~ s/[\r\n\t\s]+$//;
        
        my $delresult = "";
        my $addresult = "";
        
        if ($nroptions) {
            
            my $validvotes = "";
            for(my $i=0; $i < $nroptions; $i=$i+1) {
                $validvotes = $validvotes.$abc[$i];
            }
            if($choice =~ /[^${validvotes}]+/i) {
                ACT('MESSAGE',$target,"VOTE: ".$sender." I didn't understand your vote. Please use the syntax: !vote ".$validvotes);
                return 1;
            }
            my $v_count = 0;
            my ($option, $o_count);
            
            ACT('LITERAL',undef,"get_persistent_value>vote_".c2f($target).">Vote_".uc $sender);
            my $prevvote = <STDIN>;
            $prevvote =~ s/[\r\n\t\s]+$//;
            if ($prevvote) {
                ACT('MESSAGE',$target,"VOTE: ".$choice." replaces previous vote: ".$prevvote);
                
                # Removing previous votes from tally:
                for(my $i=0; $i < $nroptions; $i=$i+1) {
                    $option = "";
                    $o_count = "0";
                    ACT('LITERAL',undef,"get_persistent_value>vote_".c2f($target).">Option_".$i);
                    $option = <STDIN>;
                    $option =~ s/[\r\n\t\s]+$//;
                    ACT('LITERAL',undef,"get_persistent_value>vote_".c2f($target).">Option_".$i."_count");
                    $o_count = <STDIN>;
                    $o_count =~ s/[\r\n\t\s]+$//;
                    $o_count = 0 if (!$o_count);
                    
                    if ($prevvote =~ /${abc[$i]}/i ) {
                        $o_count--;
                        ACT('LITERAL',undef,"set_persistent_value>vote_".c2f($target).">Option_".$i."_count>".$o_count);
                        $delresult = "(".$abc[$i].": ".$option.")" if ($v_count == 0);
                        $delresult = $delresult." AND "."(".$abc[$i].": ".$option.")" if ($v_count != 0);
                        $v_count++;
                    }
                }
                ACT('MESSAGE',$target,"VOTE: ".$sender." revoked vote for: ".$delresult);
            }
            #else {
                #ACT('MESSAGE',$target,"VOTE: ".$choice);
            #}
            
            $v_count = 0;
                        
            for(my $i=0; $i < $nroptions; $i=$i+1) {
                $option = "";
                $o_count = "0";
                ACT('LITERAL',undef,"get_persistent_value>vote_".c2f($target).">Option_".$i);
                $option = <STDIN>;
                $option =~ s/[\r\n\t\s]+$//;
                ACT('LITERAL',undef,"get_persistent_value>vote_".c2f($target).">Option_".$i."_count");
                $o_count = <STDIN>;
                $o_count =~ s/[\r\n\t\s]+$//;
                $o_count = 0 if (!$o_count);
                
                if ($choice =~ /${abc[$i]}/i ) {
                    $o_count++;
                    ACT('LITERAL',undef,"set_persistent_value>vote_".c2f($target).">Option_".$i."_count>".$o_count);
                    $addresult = "(".$abc[$i].": ".$option.")" if ($v_count == 0);
                    $addresult = $addresult." AND "."(".$abc[$i].": ".$option.")" if ($v_count != 0);
                    $v_count++;
                }
            }

            ACT('LITERAL',undef,"set_persistent_value>vote_".c2f($target).">Vote_".uc $sender.">$choice");
            ACT('LITERAL',undef,"save_persistence_file>vote_".c2f($target));
            ACT('MESSAGE',$target,"VOTE: ".$sender." voted for: ".$addresult);
            sleep 1;
            update_topic($target,$self);
        }
        else {
            ACT('MESSAGE',$target,"VOTE: There is currently no vote active.");
        }
    }
    else {
        ACT('MESSAGE',$target,"VOTE: ".$sender." I didn't understand your vote.");
    }

    flock VOTESEMA, LOCK_UN;
    close(VOTESEMA);

    return 1;
}

if ($message =~ /^${sl}${cm}vote-results?\s*$/i) {
    
    if($sender eq $target) {
        ACT('MESSAGE',$target,"This function only works in a channel.");
        return 1;
    }

    open (VOTESEMA, ">", $sempath) or die("Can't open semaphore $!\n");
    flock VOTESEMA, LOCK_EX or die("Can't lock semaphore $!\n");

    checkload($target);

    ACT('LITERAL',undef,"get_persistent_value>vote_".c2f($target).">Question");
    my $value = <STDIN>;
    $value =~ s/[\r\n\t\s]+$//;
    ACT('LITERAL',undef,"get_persistent_value>vote_".c2f($target).">NrOptions");
    my $nroptions = <STDIN>;
    $nroptions =~ s/[\r\n\t\s]+$//;
    
    if ($value && $nroptions) {
        ACT('MESSAGE',$target,"VOTE: $value");
        
        ACT('LITERAL',undef,"get_persistent_value>vote_".c2f($target).">Option_0");
        my $option = <STDIN>;
        $option =~ s/[\r\n\t\s]+$//;
        ACT('LITERAL',undef,"get_persistent_value>vote_".c2f($target).">Option_0_count");
        my $o_count = <STDIN>;
        $o_count =~ s/[\r\n\t\s]+$//;
        $o_count = 0 if (!$o_count);
        
        my $results = "Results: ".$abc[0].": ".$option." [".$o_count."]";
        
        for(my $i=1; $i < $nroptions; $i=$i+1) {
            $option = "";
            $o_count = "0";
            ACT('LITERAL',undef,"get_persistent_value>vote_".c2f($target).">Option_".$i);
            $option = <STDIN>;
            $option =~ s/[\r\n\t\s]+$//;
            ACT('LITERAL',undef,"get_persistent_value>vote_".c2f($target).">Option_".$i."_count");
            $o_count = <STDIN>;
            $o_count =~ s/[\r\n\t\s]+$//;
            $o_count = 0 if (!$o_count);
            $results = $results." | ".$abc[$i].": ".$option." [".$o_count."]";
        }
        
        ACT('MESSAGE',$target,"VOTE: $results");
    }
    else {
        ACT('MESSAGE',$target,"VOTE: There is currently no vote active.");
    }

    flock VOTESEMA, LOCK_UN;
    close(VOTESEMA);

    return 1;
}

if ($message =~ /^${sl}${cm}new-vote\s+([^|]+)(.*)\s*$/i) {
    my $question = $3;
    my $options = $4;
    $question =~ s/[\r\n\t\s]+$//;
    $question =~ s/^[\r\n\t\s]+//;
    $options =~ s/[\r\n\t\s]+$//;
    $options =~ s/^[\r\n\t\s]+//;

    if($sender eq $target) {
        ACT('MESSAGE',$target,"This function only works in a channel.");
        return 1;
    }

    open (VOTESEMA, ">", $sempath) or die("Can't open semaphore $!\n");
    flock VOTESEMA, LOCK_EX or die("Can't lock semaphore $!\n");

    if(CheckPerm($sender, "vote", $target, $target)) {
    
        checkload($target);

        if($question) {
            if ($options) {
                ## Clear previous poll.
                ACT('LITERAL',undef,"del_all_persistent_values>vote_".c2f($target));
                ACT('LITERAL',undef,"clear_persistence_file>vote_".c2f($target));
                
                #ACT('MESSAGE',$target,"Question: ".$question);
                ACT('LITERAL',undef,"set_persistent_value>vote_".c2f($target).">Question>".$question);
                
                my $optioncount = 0;
                while( $options =~ /([^|]+)/gi ) {
                    my $opt = $1;
                    $opt =~ s/[\r\n\t\s]+$//;
                    $opt =~ s/^[\r\n\t\s]+//;
                    #ACT('MESSAGE',$target,"Option: ".$opt);
                    ACT('LITERAL',undef,"set_persistent_value>vote_".c2f($target).">Option_".$optioncount.">".$opt);
                    ACT('LITERAL',undef,"set_persistent_value>vote_".c2f($target).">Option_".$optioncount."_count>0");
                    $optioncount++;
                }

                ACT('LITERAL',undef,"set_persistent_value>vote_".c2f($target).">NrOptions>".$optioncount);
                ACT('LITERAL',undef,"set_persistent_value>vote_".c2f($target).">UseTopic>False");
                ACT('LITERAL',undef,"save_persistence_file>vote_".c2f($target));
                ACT('MESSAGE',$target,"VOTE: Created a new poll. Use !vote to see it and !vote-results to check the results.");
            }
            else {
                ACT('MESSAGE',$target,"VOTE: Error. I don't understand the options.");
            }
        }
        else {
            ACT('MESSAGE',$target,"VOTE: Error. I don't understand the question.");
        }
    }

    flock VOTESEMA, LOCK_UN;
    close(VOTESEMA);

    return 1;
}

if ($message =~ /^${sl}${cm}set-vote\s+(.+)\s*$/i) {
    my $question = $3;
    $question =~ s/[\r\n\t\s]+$//;
    $question =~ s/^[\r\n\t\s]+//;

    if($sender eq $target) {
        ACT('MESSAGE',$target,"This function only works in a channel.");
        return 1;
    }

    open (VOTESEMA, ">", $sempath) or die("Can't open semaphore $!\n");
    flock VOTESEMA, LOCK_EX or die("Can't lock semaphore $!\n");

    if(CheckPerm($sender, "vote", $target, $target)) {

        checkload($target);

        if($question) {
            #ACT('MESSAGE',$target,"Question: ".$question);
            ACT('LITERAL',undef,"set_persistent_value>vote_".c2f($target).">Question>".$question);
            ACT('LITERAL',undef,"save_persistence_file>vote_".c2f($target));
            ACT('MESSAGE',$target,"VOTE: Updated the polls question. Use !vote to see it and !vote-results to check the results.");
            sleep 1;
            update_topic($target,$self);
        }
        else {
            ACT('MESSAGE',$target,"VOTE: Error. I don't understand the question.");
        }
    }

    flock VOTESEMA, LOCK_UN;
    close(VOTESEMA);

    return 1;
}

if ($message =~ /^${sl}${cm}set-vote-options\s+(.+)\s*$/i) {
    my $options = $3;
    $options =~ s/[\r\n\t\s]+$//;
    $options =~ s/^[\r\n\t\s]+//;
    
    if($sender eq $target) {
        ACT('MESSAGE',$target,"This function only works in a channel.");
        return 1;
    }

    open (VOTESEMA, ">", $sempath) or die("Can't open semaphore $!\n");
    flock VOTESEMA, LOCK_EX or die("Can't lock semaphore $!\n");

    if(CheckPerm($sender, "vote", $target, $target)) {
        checkload($target);

        if ($options) {
            my $optioncount = 0;
            while( $options =~ /([^|]+)/gi ) {
                my $opt = $1;
                $opt =~ s/[\r\n\t\s]+$//;
                $opt =~ s/^[\r\n\t\s]+//;
                #ACT('MESSAGE',$target,"Option: ".$opt);
                ACT('LITERAL',undef,"set_persistent_value>vote_".c2f($target).">Option_".$optioncount.">".$opt);
                #ACT('LITERAL',undef,"set_persistent_value>vote_".c2f($target).">Option_".$optioncount."_count>0");
                $optioncount++;
            }

            ACT('LITERAL',undef,"set_persistent_value>vote_".c2f($target).">NrOptions>".$optioncount);
            ACT('LITERAL',undef,"save_persistence_file>vote_".c2f($target));
            ACT('MESSAGE',$target,"VOTE: Updated the polls options. Use !vote to see it and !vote-results to check the results.");
            sleep 1;
            update_topic($target,$self);
        }
        else {
            ACT('MESSAGE',$target,"VOTE: Error. I don't understand the options.");
        }
    }

    flock VOTESEMA, LOCK_UN;
    close(VOTESEMA);

    return 1;
}


if ($message =~ /^${sl}${cm}set-vote-topic\s+([TF]).*\s*$/i) {
    my $useit = uc $3;
    $useit =~ s/[\r\n\t\s]+$//;
    $useit =~ s/^[\r\n\t\s]+//;
    
    if($sender eq $target) {
        ACT('MESSAGE',$target,"This function only works in a channel.");
        return 1;
    }

    open (VOTESEMA, ">", $sempath) or die("Can't open semaphore $!\n");
    flock VOTESEMA, LOCK_EX or die("Can't lock semaphore $!\n");

    if(CheckPerm($sender, "vote", $target, $target)) { 
        if(CheckPerm($sender, "topic", $target, $target)) {
            checkload($target);

            if($useit && ($useit eq "F")) {
                ACT('LITERAL',undef,"set_persistent_value>vote_".c2f($target).">UseTopic>False");
                ACT('LITERAL',undef,"save_persistence_file>vote_".c2f($target));
                ACT('MESSAGE',$target,"VOTE: Updated poll to not use the topic.");
            }
            if($useit && ($useit eq "T")) {
                ACT('LITERAL',undef,"set_persistent_value>vote_".c2f($target).">UseTopic>True");
                ACT('LITERAL',undef,"save_persistence_file>vote_".c2f($target));
                ACT('MESSAGE',$target,"VOTE: Updated poll to use the topic.");
                update_topic($target,$self);
            }
            if(!$useit) {
                ACT('MESSAGE',$target,"VOTE: Please use the syntax '!set-vote-topic T' or '!set-vote-topic F' for true and false respectively.");
            }
        }
    }

    flock VOTESEMA, LOCK_UN;
    close(VOTESEMA);

    return 1;
}


if ($message =~ /^${sl}${cm}revoke-vote$/i) {
    
    if($sender eq $target) {
        ACT('MESSAGE',$target,"This function only works in a channel.");
        return 1;
    }

    open (VOTESEMA, ">", $sempath) or die("Can't open semaphore $!\n");
    flock VOTESEMA, LOCK_EX or die("Can't lock semaphore $!\n");

    checkload($target);

    ACT('LITERAL',undef,"get_persistent_value>vote_".c2f($target).">NrOptions");
    my $nroptions = <STDIN>;
    $nroptions =~ s/[\r\n\t\s]+$//;
    
    my $delresult = "";
    
    if ($nroptions) {
        
        my $v_count = 0;
        my ($option, $o_count);
        
        ACT('LITERAL',undef,"get_persistent_value>vote_".c2f($target).">Vote_".uc $sender);
        my $prevvote = <STDIN>;
        $prevvote =~ s/[\r\n\t\s]+$//;
        if ($prevvote) {
            
            # Removing previous votes from tally:
            for(my $i=0; $i < $nroptions; $i=$i+1) {
                $option = "";
                $o_count = "0";
                ACT('LITERAL',undef,"get_persistent_value>vote_".c2f($target).">Option_".$i);
                $option = <STDIN>;
                $option =~ s/[\r\n\t\s]+$//;
                ACT('LITERAL',undef,"get_persistent_value>vote_".c2f($target).">Option_".$i."_count");
                $o_count = <STDIN>;
                $o_count =~ s/[\r\n\t\s]+$//;
                $o_count = 0 if (!$o_count);
                
                if ($prevvote =~ /${abc[$i]}/i ) {
                    $o_count--;
                    ACT('LITERAL',undef,"set_persistent_value>vote_".c2f($target).">Option_".$i."_count>".$o_count);
                    $delresult = "(".$abc[$i].": ".$option.")" if ($v_count == 0);
                    $delresult = $delresult." AND "."(".$abc[$i].": ".$option.")" if ($v_count != 0);
                    $v_count++;
                }
            }
            ACT('LITERAL',undef,"del_persistent_value>vote_".c2f($target).">Vote_".uc $sender);
            ACT('LITERAL',undef,"save_persistence_file>vote_".c2f($target));
            ACT('MESSAGE',$target,"VOTE: ".$sender." revoked vote for: ".$delresult);
            sleep 1;
            update_topic($target,$self);
        }
        else {
            ACT('MESSAGE',$target,"VOTE: ".$sender." you didn't vote yet.");
        }
    }
    else {
        ACT('MESSAGE',$target,"VOTE: There is currently no vote active.");
    }

    flock VOTESEMA, LOCK_UN;
    close(VOTESEMA);

    return 1;
}

if ($message =~ /^${sl}${cm}clear-vote-question$/i) {
    
    if($sender eq $target) {
        ACT('MESSAGE',$target,"This function only works in a channel.");
        return 1;
    }

    open (VOTESEMA, ">", $sempath) or die("Can't open semaphore $!\n");
    flock VOTESEMA, LOCK_EX or die("Can't lock semaphore $!\n");

    if(CheckPerm($sender, "vote", $target, $target)) {
        ACT('LITERAL',undef,"del_all_persistent_values>vote_".c2f($target));
        ACT('LITERAL',undef,"clear_persistence_file>vote_".c2f($target));
        ACT('MESSAGE',$target,"VOTE: The question has been deleted.");
    }

    flock VOTESEMA, LOCK_UN;
    close(VOTESEMA);

    return 1;
}


if ($message =~ /^${sl}${cm}help\s+vote$/i) {
    ACT('MESSAGE',$receiver,"The vote module supports the following commands: (Note that this command ONLY works in channels, and each channel can only have a single poll at a time.)");
    ACT('MESSAGE',$receiver,"    !vote[?]                                  - Gives the current question available for voting.");
    ACT('MESSAGE',$receiver,"    !v[?]                                     - Gives the current question available for voting.");
    ACT('MESSAGE',$receiver,"    !v[ote] ABCXYZ                            - Enters a vote for the combination of options given as a concatenation of the characters available as options in the current vote.");
    ACT('MESSAGE',$receiver,"                                              - Repeating this will remove a user's previous vote and replace it with the new results.");
    sleep 1;
    ACT('MESSAGE',$receiver,"    !vote-result[s]                           - Gives the current question's results.");
    ACT('MESSAGE',$receiver,"    !new-vote STRING | OPTION [ | OPTION]     - Creates a new vote question with possible options given as a | (pipe) delimited set of options. Topic defaults to False.");
    ACT('MESSAGE',$receiver,"    !set-vote STRING                          - Replaces the vote's question (Does not change the options, see below)");
    ACT('MESSAGE',$receiver,"    !set-vote-options OPTION [ | OPTION]      - Replaces the vote's options. This does NOT reset the database, so be carefull not to change the order of the options when fixing a typo.");
    ACT('MESSAGE',$receiver,"    !set-vote-topic (T[rue]|F[alse])          - Puts the results of the current vote in the topic if set to T.");
    sleep 1;
    ACT('MESSAGE',$receiver,"                                              - Setting this to F(alse) does NOT revert the topic back to the original string, it just disables overwriting the topic when a vote is done.");
    ACT('MESSAGE',$receiver,"    !revoke-vote                              - Revokes the user's latest vote.");
    ACT('MESSAGE',$receiver,"    !clear-vote-question                      - Deletes the current vote question, options, and all results.");
    return 1;
}

return 0;
