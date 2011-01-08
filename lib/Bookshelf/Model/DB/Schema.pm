package Bookshelf::Model::DB::Schema;
use DBIx::Skinny::Schema;
use DBIx::Skinny::InflateColumn::DateTime::Auto;

use Data::Dumper;
use YAML::Syck ();
local $YAML::Syck::ImplicitUnicode = 1;

install_table amazon_item_cache => schema {
    pk 'asin';
    columns qw(asin item_yaml updated_at);
};

install_table items => schema {
    pk 'id';
    columns qw(id item_from idem_code registered_at);
};

install_table users => schema {
    pk 'id';
    columns qw(id username);
};

install_table user_items => schema {
    pk ['user_id', 'item_id'];
    columns qw(user_id item_id status status_history_yaml);
};

install_inflate_rule '^.+_yaml$' => callback {
    inflate {
        my $value = shift;
        my $hashref = eval { YAML::Syck::Load($value) };
        if ($@) {
            #TODO: 不正YAML時どうするかを決める
            return;
        }
        return $hashref;
    };
    deflate {
        my $value = shift;
        my $yaml = YAML::Syck::Dump($value);
        return $yaml;
    };
};

1;
