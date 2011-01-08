package Bookshelf::Controller::Item;

use strict;
use warnings;

use base 'Mojolicious::Controller';

# 標準モジュール
use Encode qw(decode);
use LWP::UserAgent;

# 追加モジュール
use URI::Amazon::APA;
use XML::Simple;
use YAML::Syck;
$YAML::Syck::ImplicitUnicode = 1;

# デバッグ出力用
use Data::Dumper;

# /item/az:asin
sub amazon {
    my $self = shift;

    my $asin = $self->param('asin');

    my $u = URI::Amazon::APA->new( $self->config->('amazon.endpoint') );
    $u->query_form(
        Service       => 'AWSECommerceService',
        Operation     => 'ItemLookup',
        Condition     => 'All',
        ItemId        => $asin,
        ResponseGroup => 'Images,ItemAttributes',
        AssociateTag  => $self->config->('amazon.AssociateTag'),
    );

    $u->sign(
        key    => $self->config->('amazon.key'),
        secret => $self->config->('amazon.secret'),
    );

    my $ua = LWP::UserAgent->new;
    my $r  = $ua->get($u);
    if ( $r->is_success ) {
        my $xml_parser = XML::Simple->new(
            ForceArray => [
                'Item',     'ImageSet', 'ItemLink', 'Author',
                'Director', 'Creator'
            ]
        );
        my $info = $xml_parser->XMLin( $r->content );
        $self->stash( output => YAML::Syck::Dump($info) );
        $self->stash( item   => $info->{Items}{Item}[0] );
    }
    else {
        $self->redirect_to( $self->url_for('index')->to_abs );

        #        $self->stash(output => $r->status_line.$r->as_string);
    }
}

1;

