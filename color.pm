package color;

use warnings;
use strict;

=head1 Name

Color - my color class


=cut

sub new {
  my $class = shift;
  my %options = @_;

  my $self = { r => 0, g => 0, b => 0, %options };
  bless($self, $class);
  return $self;
}

sub r { shift->{r} }
sub g { shift->{g} }
sub b { shift->{b} }

sub print {
  my $self = shift;
  print "(" . $self->{r} .
	"," . $self->{g} .
	"," . $self->{b} . ")";
}


1;

