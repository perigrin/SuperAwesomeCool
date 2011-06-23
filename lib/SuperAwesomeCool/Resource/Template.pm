package SuperAwesomeCool::Resource::Template;
use Moose;
extends 'Magpie::Resource';
use Magpie::Constants;
use Data::Dumper::Concise;
use aliased 'Plack::Middleware::TemplateToolkit' => 'TT';

has root => ( isa => 'Str', is => 'ro', required => 1, );

sub GET {
    my $self = shift;
    my $ctxt = shift;
    my $r    = TT->new( root => $self->root, )->call( $self->request->env );

    unless ( $r->[0] == 200 ) {
        $self->set_error(
            {
                status_code        => $r->[0],
                additional_headers => $r->[1],
                reason             => join "\n",
                @{ $r->[2] },
            }
        );
    }

    $self->plack_response( Plack::Response->new(@$r) );

    return OK;
}

1;
