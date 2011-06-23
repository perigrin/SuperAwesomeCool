package SuperAwesomeCool;
use Moose;
use Bread::Board::Declare;
use Plack::Builder;
use Plack::Middleware::Magpie;

has resource_map => (
    isa   => 'HashRef',
    is    => 'ro',
    block => sub {
        my $s = shift;
        {
            '/static'      => ['Magpie::Resource::File', { root => './root/static'} ],
            '/'            => $s->param('template_resource'),
        };
    },
    dependencies => [
        qw(
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
