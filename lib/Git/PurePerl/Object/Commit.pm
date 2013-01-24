package Git::PurePerl::Object::Commit;
use Moose;
use MooseX::StrictConstructor;
use Moose::Util::TypeConstraints;
use Encode qw/decode/;
use namespace::autoclean;

extends 'Git::PurePerl::Object';

has 'kind' =>
    ( is => 'ro', isa => 'ObjectKind', required => 1, default => 'commit' );
has 'tree_sha1'   => ( is => 'rw', isa => 'Str', required => 0 );
has 'parent_sha1s' => ( is => 'rw', isa => 'ArrayRef[Str]', required => 0, default => sub { [] });
has 'author' => ( is => 'rw', isa => 'Git::PurePerl::Actor', required => 0 );
has 'authored_time' => ( is => 'rw', isa => 'DateTime', required => 0 );
has 'committer' =>
    ( is => 'rw', isa => 'Git::PurePerl::Actor', required => 0 );
has 'committed_time' => ( is => 'rw', isa => 'DateTime', required => 0 );
has 'comment'        => ( is => 'rw', isa => 'Str',      required => 0 );
has 'encoding'       => ( is => 'rw', isa => 'Str',      required => 0 );
has 'gpg_signature'  => ( is => 'rw', isa => 'Str',      required => 0 );
has 'merge_tag'      => ( is => 'rw', isa => 'Str',      required => 0 );

my %method_map = (
    'tree'     => [ 'tree_sha1',     '-' ],  # single line, single value
    'parent'   => [ 'parent_sha1s',  '@' ],  # multiple lines, multiple values
    'gpgsig'   => [ 'gpg_signature', '=' ],  # multiple lines, single value
    'mergetag' => [ 'merge_tag',     '=' ],
);

my %time_attr = (
    'author'    => 'authored_time',
    'committer' => 'committed_time',
);

sub BUILD {
    my $self = shift;
    return unless $self->content;
    my @lines = split "\n", $self->content;
    my %header;
    while ( my $line = shift @lines ) {
        my ( $key, $value ) = split / /, $line, 2;
        push @{$header{$key}}, $value;
        $header{''} = $header{$key} if $key;
    }
    delete $header{''};
    $header{encoding}
        ||= [ $self->git->config->get(key => "i18n.commitEncoding") || "utf-8" ];
    my $encoding = $header{encoding}->[-1];
    for my $key ( keys %header ) {
        my ( $attr, $type ) = @{ $method_map{$key} || [ $key, '-' ] };
        $header{$key} = [ map decode( $encoding, $_ ), @{ $header{$key} } ];

        if ( $key eq 'committer' or $key eq 'author' ) {
            my @data = split ' ', $header{$key}[-1];
            my ( $email, $epoch, $tz ) = splice( @data, -3 );
            $email = substr( $email, 1, -1 );
            my $name = join ' ', @data;
            my $actor
                = Git::PurePerl::Actor->new( name => $name, email => $email );
            $self->$attr($actor);
            $attr = $time_attr{$attr};
            my $dt
                = DateTime->from_epoch( epoch => $epoch, time_zone => $tz );
            $self->$attr($dt);
        }
        else {
            my $value
                = $type eq '-' ? $header{$key}[-1]
                : $type eq '@' ? $header{$key}
                : $type eq '=' ? join( "\n", @{ $header{$key} } ) . "\n"
                :   die "Unknown type $type in $attr handler for $key";
            $self->$attr($value);
        }
    }
    $self->comment( decode($encoding, join "\n", @lines) );
}

sub tree {
    my $self = shift;
    return $self->git->get_object( $self->tree_sha1 );
}

sub parent_sha1 {
    return shift->parent_sha1s->[0];
}
  
sub parent {
    my $self = shift;
    return $self->git->get_object( $self->parent_sha1 );
}

sub parents {
    my $self = shift;
    
    return map { $self->git->get_object( $_ ) } @{$self->parent_sha1s};
}

__PACKAGE__->meta->make_immutable;

