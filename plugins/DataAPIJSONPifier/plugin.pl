package MT::Plugin::DataAPIJSONPifier;
use strict;
use warnings;
use MT;

MT->add_plugin({
    id          => 'DataAPIJSONPifier',
    name        => 'DataAPIJSONPifier',
    version     => 0.01,
    description => 'Make Data API capable of JSONP request',
    author_name => 'jamadam',
    author_link => 'https://github.com/jamadam',
    registry => {
        plack_middlewares => [
            {
                name => 'JSONP',
                apply_to => [
                    'data_api',
                ],
            },
        ],
    }
});

1;
