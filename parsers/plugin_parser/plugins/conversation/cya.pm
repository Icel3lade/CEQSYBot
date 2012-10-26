push(@modules,"cya");

if ($message =~ /^${sl}${cm}?\s*(nn|gnite|nite|truste|trusten|gn|gegroet|bye|ltrz|later|laters|laterz|ltr|bubaai|bai|bb|doei|doeg|dag|houdoe|mzzl|mzzlz|mzl|avé|tabbé|ciao|goodbye|goodnight|bonjour|bonsoir|adieu)\s*([\^\.!,:;PD\(\)\{\}\[\]<>\/\\]+)?\s*$/i) {
    ACT('MESSAGE',$target,"$receiver: cya!");
    return 1;
}

if ($message =~ /^${sl}${cm}help\s+cya$/i) {
    ACT('MESSAGE',$receiver,"The cya module simply tells the user cya.");
    return 1;
}

return 0;