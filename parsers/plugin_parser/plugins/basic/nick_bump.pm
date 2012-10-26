if ($command eq '433') {
    ACT('LITERAL',undef,'send_server_message>NICK ' . $self . '_');
    return 1;
}

return 0;
