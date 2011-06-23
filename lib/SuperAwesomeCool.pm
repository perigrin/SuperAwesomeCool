package SuperAwesomeCool;
use Moose;
use Bread::Board::Declare;
use Plack::Builder;
use Plack::Middleware::Magpie;

has template_root => (
    isa   => 'Str',
    is    => 'ro',
    value => './root/src',
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
            '/static' =>
              [ 'Magpie::Resource::File', { root => './root/static' } ],
            '/' => $s->param('template_resource'),
        };
    },
    dependencies => [qw(template_resource)],
);

has app => (
    isa       => 'Plack::Component',
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
        return $urlmap;
    },
    handles      => ['to_app'],
    dependencies => ['resource_map'],
);

1;
__END__
