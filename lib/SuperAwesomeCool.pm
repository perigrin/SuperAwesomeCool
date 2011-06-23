package SuperAwesomeCool;
use Moose;
use Bread::Board::Declare;

use Plack::Builder;
use Plack::Middleware::Magpie;

use Data::Printer;

has dsn => (
    isa   => 'Str',
    is    => 'ro',
    value => 'dbi:SQLite:site.db'
);

has kioku => (
    isa          => 'SuperAwesomeCool::KiouDB',
    is           => 'ro',
    dependencies => ['dsn'],
);

has reservation_resource => (
    isa   => 'HashRef',
    is    => 'ro',
    block => sub {
        my $s = shift;
        {
            class  => 'SuperAwesomeCool::Resource::Reservation',
            params => { kioku => $s->param('kioku') }
        };
    },
    dependencies => ['kioku'],
);

has user_resource => (
    isa   => 'HashRef',
    is    => 'ro',
    block => sub {
        my $s = shift;
        {
            class  => 'SuperAwesomeCool::Resource::User',
            params => { kioku => $s->param('kioku') }
        };
    },
    dependencies => ['kioku'],
);

has resource_map => (
    isa   => 'HashRef',
    is    => 'ro',
    block => sub {
        my $s = shift;
        {
            '/'            => 'SuperAwesomeCool::Resource::Template',
            '/user'        => $s->param('user_resource'),
            '/reservation' => $s->param('reservation_resource'),
        };
    },
    dependencies => [ 'user_resource', 'reservation_resource' ],
);

has app => (
    reader    => 'to_app',
    lifecycle => 'Singleton',
    block     => sub {
        my ($s) = @_;
        my $resources = $s->param('resource_map');
        my $urlmap = Plack::App::URLMap->new( DEBUG => 1 );
        while ( my ( $path, $resource ) = each %$resources ) {
            my $builder = Plack::Builder->new;
            if ( ref $resource eq 'HASH' ) {
                $builder->add_middleware( 'Magpie',
                    pipeline => [ $resource->{class} => $resource->{params} ],
                );
            }
            else {
                $builder->add_middleware( 'Magpie', resource => $resource );
            }
            $urlmap->map( $path => $builder->to_app );
        }
        return $urlmap->to_app;
    },
    dependencies => ['resource_map'],
);

1;
__END__
