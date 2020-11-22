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

sub bin {
  my $self = shift;
  return pack("CCC",$self->{r},$self->{g},$self->{b});
}

sub set {
  my $self = shift;
  my ($r,$g,$b) = @_;
  $self->{r} = $r;
  $self->{g} = $g;
  $self->{b} = $b;
}

sub setcolor {
  my $self = shift;
  my $c = shift;
  $self->{r} = $c->{r};
  $self->{g} = $c->{g};
  $self->{b} = $c->{b};
}

package colorstripe;
sub new {
  my $class = shift;
  my %options = @_;

  my $self = { len => 0, %options, led => [] };
  bless($self, $class);

  for (my $i = 0; $i < $self->{len}; $i++) {
    push(@{$self->{led}},color->new());
  }

  return $self;
}

sub addLed {
  my $self = shift;
  my (@toadd) = @_;

  push(@{$self->{led}}, @toadd);

  return @toadd;
}


sub len {
  my $self = shift;

  return $#{$self->{led}};
}

sub print {
  my $self = shift;
  for (my $i=0; $i <= $self->len(); $i++) {
    print "$i:";
    $self->{led}[$i]->print();
    print "\n";
  }
}

sub bin {
  # returned packed binary for mqtt
  my $self = shift;
  my $outbin;

  for (my $i=0; $i <= $self->len(); $i++) {
    $outbin .=     $self->{led}[$i]->bin();
  }
  return $outbin;
}

sub setall {
  my $self = shift;
  my ($r,$g,$b) = @_;

  for (my $i=0; $i <= $self->len(); $i++) {
    $self->{led}[$i]->set($r,$g,$b);
  }
}

sub setallcolor {
  my $self = shift;
  my $c = shift;

  for (my $i=0; $i <= $self->len(); $i++) {
    $self->{led}[$i]->setcolor($c);
  }
}

1;
