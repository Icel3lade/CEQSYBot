package permissions;

# Set user permissions.
# Account: *!account@* has priority over Nick!*@Host combinations.
# Nick/Ident/Host: these are dependent on each other, but all permutations of nick, ident and host in each set are valid. (The '~' character in some ident strings is ignored!)

# Permission: these are organized per channel, with '*' denoting *all* channels.
# The permission 'all' is a mask that allows all permissions for that channel.
# The channel "*" overrides all others in the configuration; thus any permission in the "*" set ALSO holds for each other channel.
# Giving 'all' permission on the "*" channel makes all other configurations obsolete and is not recommended.

# Possible permissions are:             (list may not be complete)
# { '#achannel'     =>  ['quote','karma','vote','dictionary','roulette','op','voice','speak','quiet','topic','invite','join','part','kick','ban','unban'], },
# { '#mychannel'    =>  ['all'], },
# { '*'             =>  ['karma'], },
# eg. above user has (all) the listed permissions in #achannel, and ALL possible permissions in #mychannel, and the 'karma' permission in every channel on the network.

# All matching is done in lowercase. Accountnames, nicknames, idents, hosts and perms are converted automatically.
# Channelnames in this config are not converted and should always be in lowercase. (due to perl's handling of hash keys)
# Only nickname, ident, host and channelname allow '*' as wildcard.
my @useraccess = (
    #{   'account' =>    ['users_chanserv_account_name','users_other_chanserv_account_name'],
    #    'nick' =>       ['users_nickname','users_other_nickname','nickname_with_*_wildcard'],
    #    'ident' =>      ['users_ident_string','users_other_ident_string','ident_with_*_wildcard'],
    #    'host' =>       ['users_hostmask_with_optional_*_wildcards','another.hostmask.com'],
    #    'perm' =>       { 'lowercase_channelname_with_optional_*_wildcards'    =>  ['permissions','as','a','comma','seperated','list','or','keyword:','all'],
    #                      '*'                                                  =>  ['this','set','of','permissions','holds','for','all','channels'],
    #                    },
    #},
    {   'account' =>    ['MyBot'],
        'nick' =>       ['MyBot','MyBot*'],
        'ident' =>      ['ircbot'],
        'host' =>       ['CEQSY/CEQSY','*.domain.com'],
        'perm' =>       { '*'       =>  ['all'], # The bot has all permissions everywhere.
                        },
    },
    {   'account' =>    ['Admin','Admin2'],  # NickServ account
        'nick' =>       ['Nickname','Nickname_Wildcard*'], # user nickname
        'ident' =>      ['user','quassel'], # user ident string
        'host' =>       ['CEQSY/IceBlade','*.domain.com'], #hostname
        'perm' =>       {'#ceqsy'   =>  ['all'],
                         '#channel1' => ['all'],
                         '#channel2' => ['all'],
                         '*'        =>  ['quote','karma','vote','dictionary','roulette','op','voice','speak','quiet','topic','invite','join','part','kick','ban','unban'],
                        },
    },
    ###
    {   'account' =>    ['FOR_ALL_USERS'], # Everyone!
        'nick' =>       ['*'],
        'ident' =>      ['*'],
        'host' =>       ['*'],
        'perm' =>       {'#channel1' =>  ['quote','karma','vote','dictionary','roulette','speak','topic','invite','join'],
                         '#channel2' => ['quote','karma','vote','dictionary','roulette',,'voice','speak','quiet','topic','invite'],
                         '*'        =>  ['join'], #allows everyone to tell the bot to join their channel.
                        },
    },
    
); #end @useraccess

sub get_permissions {
    return @useraccess;
}
