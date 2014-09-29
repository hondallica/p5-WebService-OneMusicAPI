package WebService::OneMusicAPI;
use JSON::XS;
use Cache::LRU;
use Net::DNS::Lite;
use Furl;
use URI;
use URI::QueryParam;
use Carp;
use Moo;
use namespace::clean;
our $VERSION = "0.01";


$Net::DNS::Lite::CACHE = Cache::LRU->new( size => 512 );

has 'user_key' => (
    is => 'rw',
    isa => sub { $_[0] },
    required => 1,
    default => sub { $ENV{ONEMUSICAPI_API_KEY} },
);

has 'http' => (
    is => 'rw',
    required => 1,
    default  => sub {
        my $http = Furl::HTTP->new(
            inet_aton => \&Net::DNS::Lite::inet_aton,
            agent => 'WebService::OneMusicAPI/' . $VERSION,
            headers => [ 'Accept-Encoding' => 'gzip',],
        );
        return $http;
    },
);


sub request {
    my ( $self, $path, $query_param ) = @_;

    my $query = URI->new;
    $query->query_param( 'user_key', $self->user_key );
    map { $query->query_param( $_, $query_param->{$_} ) } keys %$query_param;

    my ($minor_version, $code, $message, $headers, $content) = 
        $self->http->request(
            scheme => 'http',
            host => 'api.onemusicapi.com',
            path_query => "20140520/$path$query",
            method => 'GET',
    );

    my $data = decode_json( $content );

=pod
    if ( defined $data->{results}{error} ) {
        my $type = $data->{results}{error}{type};
        my $message = $data->{results}{error}{message};
        confess "$type: $message";
    } else {
        return $data;
    }
=cut
}


1;
__END__

=encoding utf-8

=head1 NAME

WebService::OneMusicAPI - A simple and fast interface to the OneMusicAPI API

=head1 SYNOPSIS

    use WebService::OneMusicAPI;

    my $one_music_api = new WebService::OneMusicAPI(user_key => 'YOUR_API_KEY');


=head1 DESCRIPTION

The module provides a simple interface to the OneMusicAPI API. To use this module, you must first sign up at http://www.onemusicapi.com/ to receive an API key.

=head1 METHODS

These methods usage: http://www.onemusicapi.com/docs/20140520/reference/


=head1 LICENSE

Copyright (C) Hondallica.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Hondallica E<lt>hondallica@gmail.comE<gt>

=cut
