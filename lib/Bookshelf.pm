package Bookshelf;

use strict;
use warnings;

use base 'Mojolicious';

# 追加モジュール
use Config::Merge;

sub startup {
    my $self = shift;

    # 設定ファイル読み込み
    my $config = Config::Merge->new( $self->home->rel_file('config') );
    $self->helper( config => sub { return $config; } );

    # 各種設定
    $self->types->type( html => 'text/html; charset=utf-8' );
    $self->app->hook(
        after_dispatch => sub {
            shift->res->headers->header(
                'X-Content-Type-Options' => 'nosniff' );
        }
    );
    $self->app->secret( $config->('session.secret') );

    # Routes
    my $r = $self->routes;
    $r->namespace('Bookshelf::Controller');
    $r->any('/item/az:asin')->to('item#amazon')->name('item');
}

1;
