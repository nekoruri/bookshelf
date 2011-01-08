package Bookshelf::Controller::User;

use strict;
use warnings;

use base 'Mojolicious::Controller';

# デバッグ出力用
use Data::Dumper;

# /user/{username}/
sub home {
    my $self = shift;

    my $username = $self->param('username');

    my $user = $self->db->search('users', { username => $username })->first;

    if (!$user) {
        $self->app->log->info("user not found[$username]");
        $self->redirect_to( '/' );
        return;
    }

    my $user_id = $user->id;

    $self->app->log->info("user_id: $user_id");

    my $rs = $self->db->resultset;
    $rs->add_select('items.item_from' => 'item_from');
    $rs->add_select('items.item_code' => 'item_code');
    $rs->from([]);
    $rs->add_join(
        user_items => [
            {
                type => 'inner',
                table => 'items',
                condition => 'user_items.item_id = items.id',
            },
        ],
    );
    $rs->add_where('user_items.user_id' => $user_id);
    $self->app->log->info("sql: ".$rs->as_sql);

    my $user_items = $rs->retrieve;
    $self->stash(user_items => $user_items);
}

1;

