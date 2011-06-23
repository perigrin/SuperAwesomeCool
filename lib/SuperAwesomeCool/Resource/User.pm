package SuperAwesomeCool::Resource::User;
use Moose;
extends 'Magpie::Resource';

use Magpie::Constants;

sub GET {
    my ( $self, $ctxt ) = @_;
    my $r = Plack::Response->new(200);
    $r->content_type('text/html');
    $r->body("User List");
    $self->plack_response($r);
    return OK;
}

1;
__END__