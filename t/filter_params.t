use strict;
use warnings;

use Test::More tests => 7;

use Test::LWP::Recorder;

my $ua = Test::LWP::Recorder->new({
    record => 1,
    cache_dir => 't/LWPtmp',
    filter_params => [ 'filterme' ],
});


# Same URL parameter strings should return the same result
{
    my @pairs = (
        [ "foo=a&bar=b", "foo=a&bar=b" ],
        [ "foo=a&bar=b", "bar=b&foo=a" ],
        [ "foo=a&bar=b", "bar=b&foo=a&filterme=c" ],
        [ "foo=a&bar=b&filterme=c", "bar=b&foo=a&filterme=d" ],
    );

    for my $pair (@pairs) {
        my @results = map { $ua->_filter_all_params($_) } @$pair;
        ok(
            $results[0] eq $results[1],
            sprintf("Got matching param string for '%s' and '%s'", @$pair)
        ) or diag sprintf("Got '%s' for '%s',\nBut '%s' for '%s'", $results[0], $pair->[0], $results[1], $pair->[1]);
    }
}

# Different URL parameter strings should return different result
{
    my @pairs = (
        [ "bar=a", "bar=b" ],
        [ "foo=a&bar=b", "foo=c&bar=b" ],
        [ "foo=a&bar=b", "foo=a&bar=c" ],
    );

    for my $pair (@pairs) {
        my @results = map { $ua->_filter_all_params($_) } @$pair;
        ok(
            $results[0] ne $results[1],
            sprintf("Got mis-matching param string for '%s' and '%s'", @$pair)
        ) or diag sprintf("Got '%s' for '%s' and '%s'!", $results[0], @$pair);
    }
}
