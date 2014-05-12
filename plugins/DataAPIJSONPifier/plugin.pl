package MT::Plugin::DataAPIJSONPifier;
use strict;
use warnings;
use MT;

MT->add_plugin({
    id          => 'DataAPIJSONPifier',
    name        => 'Data API JSONPifier',
    version     => 0.01,
    description => 'Make Data API capable of JSONP request',
    author_name => 'jamadam',
    author_link => 'https://github.com/jamadam',
    registry    => is_psgi() ? psgi_registory() : cgi_registory(),
});

# apply Plack::Middleware::JSONP
sub psgi_registory {
    
    return {
        plack_middlewares => [
            {
                name => 'JSONP',
                apply_to => [
                    'data_api',
                ],
            },
        ],
    }
}

# just hacks internal and returns nothing
sub cgi_registory {
    
    require MT::App::DataAPI;
    
    my $current_format = \&MT::App::DataAPI::current_format;
    
    no warnings 'redefine';
    
    *MT::App::DataAPI::current_format = sub {
        
        my $preset  = $current_format->(@_);
        my $cb      = MT->instance->param('callback');
        
        if ($cb && $cb =~ /^[\w\.\[\]]+$/ &&
                                $preset->{mime_type} eq 'application/json') {
            return {
                mime_type   => 'text/javascript',
                serialize   => sub {
                    require MT::DataAPI::Format::JSON;
                    my $json = MT::DataAPI::Format::JSON::serialize($_[0]);
                    return "$cb($json)";
                },
            };
        }
        
        return $preset;
    };
    
    return {};
}

# detect if server is PSGI
sub is_psgi {
    
    # PSGI (Plack only for now)
    return 1 if defined $ENV{PLACK_ENV};
}

1;
