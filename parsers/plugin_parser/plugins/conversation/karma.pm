push(@modules,"karma");

if ($message =~ /^${sl}${cm}([a-zA-Z0-9\s_#-]+)\?(.+)?$/i) {
    my $word = $3;
    my $upper = uc $word;
    $upper =~ s/[\r\n\t\s]+$//;
    $upper =~ s/^[\r\n\t\s]+//;
    if($upper) {
        ACT('LITERAL',undef,"check_persistence_domain_exists>karma");
        my $dictloaded = <STDIN>;
        $dictloaded =~ s/[\r\n\t\s]+$//;
        if (!$dictloaded) { ACT('LITERAL',undef,"load_persistence_file>karma"); }

        ACT('LITERAL',undef,"get_persistent_value>karma>$upper");
        my $value = <STDIN>;
        $value =~ s/[\r\n\t\s]+$//;
        if ($value) {
            ACT('MESSAGE',$target,"KARMA: $word: $value");
        }
        else {
            ACT('MESSAGE',$target,"KARMA: $word: 0");
        }
    }
    return 1;
}

if ($message =~ /^${sl}${cm}karma\s+([a-zA-Z0-9\s_#-]+)$/i) {
    my $word = $3;
    my $upper = uc $word;
    $upper =~ s/[\r\n\t\s]+$//;
    $upper =~ s/^[\r\n\t\s]+//;
    if($upper) {
        ACT('LITERAL',undef,"check_persistence_domain_exists>karma");
        my $dictloaded = <STDIN>;
        $dictloaded =~ s/[\r\n\t\s]+$//;
        if (!$dictloaded) { ACT('LITERAL',undef,"load_persistence_file>karma"); }

        ACT('LITERAL',undef,"get_persistent_value>karma>$upper");
        my $value = <STDIN>;
        $value =~ s/[\r\n\t\s]+$//;
        if ($value) {
            ACT('MESSAGE',$target,"KARMA: $word: $value");
        }
        else {
            ACT('MESSAGE',$target,"KARMA: $word: 0");
        }
    }
    return 1;
}

if ($message =~ /^${sl}${cm}([a-zA-Z0-9\s_#-]+)\+\+(.+)?$/i) {
    my $word = $3;
    my $upper = uc $word;
    $upper =~ s/[\r\n\t\s]+$//;
    $upper =~ s/^[\r\n\t\s]+//;
    if($upper) {
        ACT('LITERAL',undef,"check_persistence_domain_exists>karma");
        my $dictloaded = <STDIN>;
        $dictloaded =~ s/[\r\n\t\s]+$//;
        if (!$dictloaded) { ACT('LITERAL',undef,"load_persistence_file>karma"); }

        ACT('LITERAL',undef,"get_persistent_value>karma>$upper");
        my $value = <STDIN>;
        $value =~ s/[\r\n\t\s]+$//;
        if ($value) {
            $value++;
        }
        else {
            $value = 1;
        }
      
        ACT('LITERAL',undef,"set_persistent_value>karma>$upper>$value");
        ACT('LITERAL',undef,"save_persistence_file>karma");
        ACT('MESSAGE',$target,"KARMA: $word: $value");
    }
    return 1;
}

if ($message =~ /^${sl}${cm}([a-zA-Z0-9\s_#-]+)--(.+)?$/i) {
    my $word = $3;
    my $upper = uc $word;
    $upper =~ s/[\r\n\t\s]+$//;
    $upper =~ s/^[\r\n\t\s]+//;
    if($upper) {
        ACT('LITERAL',undef,"check_persistence_domain_exists>karma");
        my $dictloaded = <STDIN>;
        $dictloaded =~ s/[\r\n\t\s]+$//;
        if (!$dictloaded) { ACT('LITERAL',undef,"load_persistence_file>karma"); }

        ACT('LITERAL',undef,"get_persistent_value>karma>$upper");
        my $value = <STDIN>;
        $value =~ s/[\r\n\t\s]+$//;
        if ($value) {
            $value--;
        }
        else {
            $value = -1;
        }
      
        ACT('LITERAL',undef,"set_persistent_value>karma>$upper>$value");
        ACT('LITERAL',undef,"save_persistence_file>karma");
        ACT('MESSAGE',$target,"KARMA: $word: $value");
    }
    return 1;
}

if ($message =~ /^${sl}${cm}set-?karma\s+([a-zA-Z0-9\s_#-]+)\s+([\+\-0-9]+)$/i) {
    my $word = $3;
    my $upper = uc $word;
    my $value = $4;
    $upper =~ s/[\r\n\t\s]+$//;
    $upper =~ s/^[\r\n\t\s]+//;
    if($upper) {
        if(CheckPerm($sender, "karma", $target, $target)) {
            ACT('LITERAL',undef,"check_persistence_domain_exists>karma");
            my $dictloaded = <STDIN>;
            $dictloaded =~ s/[\r\n\t\s]+$//;
            if (!$dictloaded) { ACT('LITERAL',undef,"load_persistence_file>karma"); }
          
            ACT('LITERAL',undef,"set_persistent_value>karma>$upper>$value");
            ACT('LITERAL',undef,"save_persistence_file>karma");
            ACT('MESSAGE',$target,"KARMA: $word: $value");
        }
    }
    return 1;
}

if ($message =~ /^${sl}${cm}help\s+karma$/i) {
    ACT('MESSAGE',$receiver,"The karma module supports the following commands:");
    ACT('MESSAGE',$receiver,"    !karma STRING                             - Returns the karma value of STRING.");
    ACT('MESSAGE',$receiver,"    !STRING?                                  - Returns the karma value of STRING.");
    ACT('MESSAGE',$receiver,"    !STRING(++|--)                            - Adds or substracts from STRING's karma value.");
    ACT('MESSAGE',$receiver,"    !set-karma STRING N                       - Set an arbitrary value for STRING.");
    return 1;
}

return 0;
