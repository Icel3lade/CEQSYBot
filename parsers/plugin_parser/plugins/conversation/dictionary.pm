push(@modules,"dictionary");

if ($message =~ /^${sl}${cm}define\s+([a-zA-Z0-9_#-]+)$/i) {
    my $word = $3;
    my $upper = uc $word;

    ACT('LITERAL',undef,"check_persistence_domain_exists>dictionary");
    my $dictloaded = <STDIN>;
    $dictloaded =~ s/[\r\n\t\s]+$//;
    if (!$dictloaded) {
        ACT('LITERAL',undef,"load_persistence_file>dictionary");
    }

    ACT('LITERAL',undef,"get_persistent_value>dictionary>$upper");
    my $definition = <STDIN>;
    $definition =~ s/[\r\n\t\s]+$//;
    if ($definition) {
        ACT('MESSAGE',$target,"$receiver: $word means: $definition");
    }
    else {
        ACT('MESSAGE',$target,"$receiver: No definition found for $word.");
    }
    return 1;
}

if ($message =~ /^${sl}${cm}set-define\s+([a-zA-Z0-9_#-]+)\s+(.+)$/i) {
    my $word = uc $3;
    my $definition = $4;

    ACT('LITERAL',undef,"check_persistence_domain_exists>dictionary");
    my $dictloaded = <STDIN>;
    $dictloaded =~ s/[\r\n\t\s]+$//;
    if (!$dictloaded) {
        ACT('LITERAL',undef,"load_persistence_file>dictionary");
    }

    ACT('LITERAL',undef,"set_persistent_value>dictionary>$word>$definition");
    ACT('LITERAL',undef,"save_persistence_file>dictionary");
    ACT('MESSAGE',$target,"$receiver: Definition added.");
    return 1;
}

if ($message =~ /^${sl}${cm}undefine\s+([a-zA-Z0-9_#-]+)(?:\s+.+)?$/i) {
    my $word = uc $3;
    
    ACT('LITERAL',undef,"check_persistence_domain_exists>dictionary");
    my $dictloaded = <STDIN>;
    $dictloaded =~ s/[\r\n\t\s]+$//;
    if (!$dictloaded) {
        ACT('LITERAL',undef,"load_persistence_file>dictionary");
    }

    if(CheckPerm($sender, "dictionary", $target, $target)) {
        ACT('LITERAL',undef,"del_persistent_value>dictionary>$word");
        ACT('LITERAL',undef,"save_persistence_file>dictionary");
        ACT('MESSAGE',$target,"$receiver: Definition removed.");
    }
    return 1;
}

if ($message =~ /^${sl}${cm}help\s+dictionary$/i) {
    ACT('MESSAGE',$receiver,"The dictionary module supports the following commands:");
    ACT('MESSAGE',$receiver,"    !define STRING                            - Gives the definition of STRING.");
    ACT('MESSAGE',$receiver,"    !set-define STRING TEXT                   - Sets the definition of STRING to mean TEXT.");
    ACT('MESSAGE',$receiver,"    !undefine STRING                          - Removes the definition of STRING.");
    return 1;
}

return 0;
