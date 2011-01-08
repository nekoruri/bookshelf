package Bookshelf;

use strict;
use warnings;

use base 'Mojolicious';

use Bookshelf::Model::DB;

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

    # model生成とDB接続
    my $db = Bookshelf::Model::DB->new({
        dsn => $config->('db.dsn'),
        username => $config->('db.username'),
        password => $config->('db.password'),
        connect_options => { mysql_enable_utf8 => 1, mysql_auto_reconnect => 1 },
    });
    $self->helper( db => sub { return $db; } );

    # Routes
    my $r = $self->routes;
    $r->namespace('Bookshelf::Controller');
    $r->get('/item/az:asin')->to('item#amazon')->name('item');
    $r->get('/user/:username')->to('user#home')->name('home');
}

1;
