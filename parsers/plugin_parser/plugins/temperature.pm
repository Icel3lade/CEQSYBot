push(@modules,"temperature");

if ($message =~ /^${sl}${cm}ftc\s+(-?[0-9]*.*[0-9]*)$/i) {
    my $answer = (5/9) * ($3 - 32);
    ACT('MESSAGE',$target,"$receiver: $answer°C");
    return 1;
}

if ($message =~ /^${sl}${cm}ctf\s+(-?[0-9]*.*[0-9]*)$/i) {
    my $answer = (9/5) * $3 + 32;
    ACT('MESSAGE',$target,"$receiver: $answer°F");
    return 1;
}

if ($message =~ /^${sl}${cm}help\s+temperature$/i) {
    ACT('MESSAGE',$receiver,"The temperature module supports the following commands:");
    ACT('MESSAGE',$receiver,"    !ftc N                                    - Transform N degrees Farenheit to Celcius.");
    ACT('MESSAGE',$receiver,"    !ctf N                                    - Transform N degrees Celcius to Farenheit.");
    return 1;
}

return 0;
