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
  my %opt = (
	r => 0, 
	g => 0,
	b => 0, @_);

  $self->{r} = $opt{r};
  $self->{g} = $opt{g};
  $self->{b} = $opt{b};

  return $self;
}

sub setcolor {
  my $self = shift;
  my $c = shift;
  $self->{r} = $c->{r};
  $self->{g} = $c->{g};
  $self->{b} = $c->{b};

  return $self;
}

sub dimby {
  my $self = shift;
  my %opt = (
	p => 0, @_);

  if ($opt{p} > 0 && $opt{p} <= 100) {
    my $x = 256-$opt{p}*256/100;
    $self->{r} %= $x;
    $self->{g} %= $x;
    $self->{b} %= $x;
  }
  return $self;
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
  return $self;
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


sub dimby {
  my $self = shift;
  my %opt = (
        p => 50,
        @_);

  for (my $i=0; $i <= $self->len(); $i++) {
    $self->{led}[$i]->dimby(%opt);
  }
  return $self;
}

sub fill {
  my $self = shift;
  my %opt = (
        start => 0,
	end => $self->len(),
	len => 0,
	every => 1,
	r => 0, g => 0, b => 0,
        @_);

  $opt{start} = 0 if ($opt{start} < 0);
  $opt{start} = $self->len() if ($opt{start} > $self->len());

  if ($opt{len} > 0) {
    $opt{end} = $opt{start} + $opt{len};
  }

  $opt{end} = 0 if ($opt{end} < 0);
  $opt{end} = $self->len() if ($opt{end} > $self->len());

  my ($r,$g,$b);
  if ($opt{color}) {
    $r = $opt{color}->r();
    $g = $opt{color}->g();
    $b = $opt{color}->b();
  } else {
    $r = $opt{r};
    $g = $opt{g};
    $b = $opt{b};
  }

  for (my $i=$opt{start}; $i <= $opt{end};  $i += $opt{every}) {
    $self->{led}[$i]->set(r=>$r,g=>$g,b=>$b);
  }
  return $self;
}

sub fade {
  my $self = shift;
  my %opt = (
        start => 0,
	len => 3,
        @_);

  $opt{start} = 0 if ($opt{start} < 0);
  $opt{start} = $self->len() if ($opt{start} > $self->len());
  $opt{end} = $opt{start} + $opt{len}-1;
  $opt{end} = $self->len() if ($opt{end} > $self->len());

  my $c1 = $opt{color1} ? $opt{color1} : $self->{led}[$opt{start}];
  my $c2 = $opt{color2} ? $opt{color2} : $self->{led}[$opt{end}];

  my $rdistance = ($c2->r() - $c1->r()) * 256;
  my $gdistance = ($c2->g() - $c1->g()) * 256;
  my $bdistance = ($c2->b() - $c1->b()) * 256;

  my $divisor = $opt{len} ? $opt{len} : 1;

  my $rdelta = int($rdistance / $divisor);
  my $gdelta = int($gdistance / $divisor);
  my $bdelta = int($bdistance / $divisor);

  $rdelta *= 2;
  $gdelta *= 2;
  $bdelta *= 2;

  my $r = $c1->r() *512;
  my $g = $c1->g() *512;
  my $b = $c1->b() *512;

  for (my $i=$opt{start}; $i <= $opt{end};  $i++) {
    $self->{led}[$i]->set(r => int($r/512), g => int($g/512), b => int($b/512));
    $r += $rdelta;
    $g += $gdelta;
    $b += $bdelta;
  }
  return $self;
}

sub percent {
# $ledstripe->percent(start => 5, len => 100,
#        color1 => color->new(r=>5),
#        color2 => color->new(b=>5),
#        percent => 25);
  my $self = shift;
  my %opt = (
	start => 0,
	end => $self->len(),
	len => 0,
	percent => 50,
	@_);

  if ($opt{len} > 0) {
    $opt{end} = $opt{start} + $opt{len};
  } else {
    $opt{len} = $opt{end} - $opt{start};
  }

  # start = 5, len = 50, percent = 50, end = 55
  # color1= 5..30, color2= 31..55
  $self->fill(start => $opt{start},
	len => $opt{len} * $opt{percent}/100,
	color => $opt{color1});
  $self->fill(start => $opt{start} + $opt{len} * $opt{percent}/100,
	len => $opt{len} * (100-$opt{percent})/100,
	color => $opt{color2});

  return $self;
}
  

sub setallcolor {
  my $self = shift;
  my $c = shift;

  for (my $i=0; $i <= $self->len(); $i++) {
    $self->{led}[$i]->setcolor($c);
  }
  return $self;
}

sub setxcolor {
  my $self = shift;
  my $x = shift;
  my $c = shift;

  if ($x >= 0 && $x <= $self->{len}) {
     $self->{led}[$x]->setcolor($c);
  }
  return $self;
}

sub shiftl {
  my $self = shift;
  my $first = shift(@{$self->{led}});
  push(@{$self->{led}},$first);
  return $self;
}

sub shiftr {
  my $self = shift;
  my $last = pop(@{$self->{led}});
  unshift(@{$self->{led}},$last);
  return $self;
}


1;
