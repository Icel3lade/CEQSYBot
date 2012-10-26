push(@modules,"youtube");

#http://www.youtube.com/watch?v=ggg3C87UVCY&feature=g-vrec&context=G26ab0f5RVAAAAAAAADQ
#if ($message =~ /^${sl}${cm}?https?:\/\/(www)?\.youtu(be\.com|\.be)\/watch\?(([^&]+&?)*)$/i) {
if ($message =~ /^(.+)?(:?https?:\/\/)?(www\.)?youtu(be\.com|\.be)\/(?:watch)?\?(([^&]+&?)*)(?:\s+.*)?$/i) {
    if ($5 =~ /^(([^v][^&]+)&?)*(v=([a-zA-Z0-9-_]+))&?(([^v][^&]+)&?)*$/i) {
        $message = "$self: !youtube $4";
    }
    #rolls over into next block, so NO return 1; here!
}
if ($message =~ /^(.+)?(:?https?:\/\/)?(www\.)?youtu(be\.com|\.be)\/(([^&]+&?)*)(?:\s+.*)?$/i) {
    if ($5 =~ /^([a-zA-Z0-9-_]+).*$/i){
        $message = "$self: !youtube $1";
    }
    #rolls over into next block, so NO return 1; here!
}
if ($message =~ /^${sl}${cm}youtube ([a-zA-Z0-9-_]+)$/i) {
    require LWP::Simple;
    require LWP::UserAgent;
    my $vid = $3;
    my $url = "http://gdata.youtube.com/feeds/api/videos/$vid?v=2";
    my $request = LWP::UserAgent->new;
    $request->timeout(60);
    $request->env_proxy;
    $request->agent('Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.0)');
    $request->max_size('1024000');
    $request->parse_head(0);
    my $response = $request->get("$url");
    my $content = $response->decoded_content;

    if ($content =~ /<error><domain>GData<\/domain><code>InvalidRequestUriException<\/code><internalReason>Invalid id<\/internalReason><\/error>/) {
        ACT('MESSAGE',$target,"YouTube: That video does not exist.");
    }
    elsif ($content =~ /<title>(.+)<\/title>/) {
        my ($title, $uploader, $favorites, $views, $dislikes, $likes, $length, $length_m, $length_s, $restricted);
        $title = $1;
        $content =~ /<name>(.+)<\/name>/;
        $uploader = $1;
        $content =~ /<yt:statistics favoriteCount='([0-9]+)' viewCount='([0-9]+)'\/>/;
        ($favorites, $views) = ($1, $2);
        $content =~ /<yt:rating numDislikes='([0-9]+)' numLikes='([0-9]+)'\/>/;
        ($dislikes, $likes) = ($1, $2);
        $content =~ /<yt:duration seconds='([0-9]+)'\/>/;
        $length = $1;
        $length_m = int($length / 60);
        $length_s = $length % 60;
        $length_s = "0$length_s" if ($length_s =~ /^[0-9]$/);

        if ($content =~ /<media:restriction type='country'/) {
            $restricted = "(\x0307unavailable in some regions\x0F)";
        }
        else {
            $restricted = "(\x0314no region restrictions\x0F)";
        }
        ACT('MESSAGE',$target,"YouTube: \x02\"$title\"\x02 Length: \x0306$length_m:$length_s\x0F (Uploader: \x0303$uploader\x0F)");
	if ($server_network eq 'freenode') {
            ACT('MESSAGE',$target,"YouTube: \x0314$views\x0F views, \x0303$likes\x0F likes, \x0304$dislikes\x0F dislikes $restricted http://youtube.com/watch?v=$vid");
	}
        if ($receiver ne $sender) {
            ACT('MESSAGE',$target,"$receiver ^^^");
        }
    }
    return 1;
}

if ($message =~ /^${sl}${cm}help\s+youtube$/i) {
    ACT('MESSAGE',$receiver,"The youtube module supports the following commands:");
    ACT('MESSAGE',$receiver,"    !youtube STRING                           - Gives some information about the youtube video with identifier STRING.");
    ACT('MESSAGE',$receiver,"    http[s]://[www.]youtube.com/watch?STRING  - Gives some information about the youtube video with the given URL");
    return 1;
}

return 0;

