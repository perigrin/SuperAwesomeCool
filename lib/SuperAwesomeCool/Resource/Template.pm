package SuperAwesomeCool::Resource::Template;
use Moose;
extends 'Magpie::Resource';
use Magpie::Constants;
use Data::Dumper::Concise;
use aliased 'Plack::Middleware::TemplateToolkit' => 'TT';

has [qw(root extension dir_index)] => (
    isa      => 'Str',
    is       => 'ro',
    required => 1,
);

sub GET {
    my $self = shift;
    my $ctxt = shift;

    my $tt = TT->new(
        root      => $self->root,
        extension => $self->extension,
        dir_index => $self->dir_index,
    );

    $tt->prepare_app;

    my $env = $self->request->env;
    my $ext = $self->extension;
    $env->{PATH_INFO} .= '.tt2' unless $env->{PATH_INFO} =~ m/(?:\/|\.tt2)$/;
    warn $env->{PATH_INFO};

    my $r = $tt->call($env);

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
