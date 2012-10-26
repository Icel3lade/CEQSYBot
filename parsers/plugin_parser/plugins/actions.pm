push(@modules,"actions");

if ($message =~ /^ACTION\s+(.+)\s+$self.*$/) {
    if ($1 eq 'kicks') {
        ACT('ACTION',$target,"kicks $sender");
    }
    elsif ($1 eq 'hugs') {
        ACT('ACTION',$target,"♥");
    }
    elsif ($1 eq 'kisses') {
        ACT('ACTION',$target,"calls the police");
    }
    elsif (($1 eq 'slaps') || ($1 eq 'hits') || ($1 eq 'punches')) {
        ACT('MESSAGE',$target,"I may have deserved that.");
    }
    elsif (($1 eq 'murders') || ($1 eq 'kills') || ($1 eq 'shoots')){
        ACT('ACTION',$target,"dies... :(");
    }
    return 1;
}

if ($message =~ /^${sl}${cm}help\s+actions$/i) {
    ACT('MESSAGE',$receiver,"The actions module allows $self to respond to actions that users make.");
    return 1;
}

return 0;
