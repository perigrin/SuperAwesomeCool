package SuperAwesomeCool;
use Moose;
use Bread::Board::Declare;
use Plack::Builder;
use Plack::Middleware::Magpie;

has dsn => (
    isa   => 'Str',
    is    => 'ro',
    value => 'dbi:SQLite:site.db'
);

has kioku => (
    isa          => 'SuperAwesomeCool::KiouDB',
    is           => 'ro',
    lifecycle    => 'Singleton',
    dependencies => ['dsn'],
);

has template_root => (
    isa   => 'Str',
    is    => 'ro',
    value => './root/src',
);

# if we can allow Instances of resources to be added to the pipeline
# we can change this to use constructor injection
#
# has user_resource => (
#     isa          => 'SuperAwesomeCool::Resource::User',
#     is           => 'ro',
#     dependencies => ['kioku'],
# );
#
# and potentially the "infer" magic that I don't really understand

has reservation_resource => (
    isa   => 'ArrayRef',
    is    => 'ro',
    block => sub {
        my $s = shift;
        [
            'SuperAwesomeCool::Resource::Reservation',
            { kioku => $s->param('kioku') }
        ];
    },
    dependencies => ['kioku'],
);

has user_resource => (
    isa   => 'ArrayRef',
    is    => 'ro',
    block => sub {
        my $s = shift;
        [ 'SuperAwesomeCool::Resource::User', { kioku => $s->param('kioku') } ];
    },
    dependencies => ['kioku'],
);

has template_resource => (
    isa   => 'ArrayRef',
    is    => 'ro',
    block => sub {
        my $s = shift;
        [
            'SuperAwesomeCool::Resource::Template',
            {
                root      => $s->param('template_root'),
                extension => '.tt2',
                dir_index => 'index.tt2',
            }
        ];
    },
    dependencies => ['template_root'],
);

has resource_map => (
    isa   => 'HashRef',
    is    => 'ro',
    block => sub {
        my $s = shift;
        {
            '/static'      => ['Magpie::Resource::File', { root => './root/static'} ],
            '/user'        => $s->param('user_resource'),
            '/reservation' => $s->param('reservation_resource'),
            '/'            => $s->param('template_resource'),
        };
    },
    dependencies => [
        qw(
          user_resource
          reservation_resource
          template_resource
          )
    ],
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
            $builder->add_middleware( 'Magpie', pipeline => $resource );
            $urlmap->map( $path => $builder->to_app );
        }
        return $urlmap->to_app;
    },
    dependencies => ['resource_map'],
);

1;
__END__
