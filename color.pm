package color;

use warnings;
use strict;

=head1 Name

Color - my color class


=cut

use constant {
	HUE_RED => 0, 
	HUE_ORANGE => 32, 
	HUE_YELLOW => 64, 
	HUE_GREEN => 96, 
	HUE_AQUA => 128, 
	HUE_BLUE => 160, 
	HUE_PURPLE => 192, 
	HUE_PINK => 224,
	HSV_SECTION_6 => 0x20,
	HSV_SECTION_3 => 0x40
};

sub new {
  my $class = shift;
  my %options = @_;

  my $self = { r => 0, g => 0, b => 0, h => 0, s => 0, v => 0, %options };
  bless($self, $class);
  return $self;
}

sub r { shift->{r} }
sub g { shift->{g} }
sub b { shift->{b} }
sub h { shift->{h} }
sub s { shift->{s} }
sub v { shift->{v} }

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

sub hsv2rgb {
  my $self = shift;
  # set the r,g,b values from h,s,v values

  my $value = $self->{v};
  my $saturation = $self->{s};
  my $invsat = 255 - $saturation;
  my $brightness_floor = int(($value * $invsat) / 256);
  my $color_amplitude = $value - $brightness_floor;

  my $section = int($self->{h} / HSV_SECTION_3);
  my $offset = $self->{h} % HSV_SECTION_3;

  my $rampup = $offset;
  my $rampdown = (HSV_SECTION_3 - 1) - $offset;

  my $rampup_amp_adj = int(($rampup * $color_amplitude) / (256/4));
  my $rampdown_amp_adj=int(($rampdown * $color_amplitude) / (256/4));

  my $rampup_adj_with_floor   = $rampup_amp_adj   + $brightness_floor;
  my $rampdown_adj_with_floor = $rampdown_amp_adj + $brightness_floor;
 
  if ($section) {
    if ($section == 1) {
      $self->{r} = $brightness_floor;
      $self->{g} = $rampdown_adj_with_floor;
      $self->{b} = $rampup_adj_with_floor;
    } else {
      $self->{r} = $rampup_adj_with_floor;
      $self->{g} = $brightness_floor;
      $self->{b} = $rampdown_adj_with_floor;
    }
  } else {
    $self->{r} = $rampdown_adj_with_floor;
    $self->{g} = $rampup_adj_with_floor;
    $self->{b} = $brightness_floor;
  }
  return $self;
}

sub rgb2hsv {
  my $self = shift;
  # set the h,s,v values from r,g,b values

  my $r = $self->{r};
  my $g = $self->{g};
  my $b = $self->{b};
  my ($h,$s,$v);

  my $desat = 255;
  $desat = $r if ($r < $desat);
  $desat = $g if ($g < $desat);
  $desat = $b if ($b < $desat);

  $r -= $desat;
  $g -= $desat;
  $b -= $desat;

  $s = 255 - $desat;
  if ($s != 255) {
    $s = int(255 - sqrt((255-$s)*256));
  }

  if (($r + $g + $b) == 0) {
    $self->{h} = 0;
    $self->{s} = 0;
    $self->{v} = 255-$s;
    return $self;
  }

  if ($s < 255) {
    $s = 1 if ($s == 0);
    my $scaleup = int(65535 / $s);
    $r = int($r * $scaleup / 256);
    $g = int($g * $scaleup / 256);
    $b = int($b * $scaleup / 256);
  }

  my $total = $r + $g + $b;

  if ($total < 255) {
    $total = 1 if ($total == 0);
    my $scaleup = int(65535 / $total);
    $r = int($r * $scaleup / 256);
    $g = int($g * $scaleup / 256);
    $b = int($b * $scaleup / 256);
  }

  $v = $total + $desat;
  $v = 255 if ($v > 255);
  $v = int(256.0 * sqrt($v / 256.0)) if ($v < 255);

  my $highest = $r;
  $highest = $g if ($g > $highest);
  $highest = $b if ($b > $highest);

  #define FIXFRAC8(N,D) (((N)*256)/(D))
  # scale8(i,scale)  i*(scale/256)
  # qsub8 a-b, result >=0

  if ($highest == $r) {
    if ($g == 0) {
      $h = (HUE_PURPLE + HUE_PINK) /2;
      my $qs8 = (($g - 85) + (171 - $r) - 4);
      $qs8 = 0 if ($qs8 < 0);
      $h += $qs8 * ((32*256/85) / 256);
    } elsif (($r - $g) > $g) {
      $h = HUE_RED;
      $h += $g * (32*256/85)/256;
    }
  } elsif ($highest == $g) {
    if ($b == 0) {
      $h = HUE_YELLOW;
      my $x = 171 - $r;
      $x = 0 if ($x < 0);
      my $radj = int($x * (47/256));

      $x = $g - 171;
      $x = 0 if ($x < 0);
      my $gadj = int($x * 97/256);
      my $rgadj = $radj + $gadj;
      my $hueadv= int($rgadj / 2);
      $h += $hueadv;
    } else {
      if (($g - $b) > $b) {
        $h = HUE_GREEN;
        $h += int($b * (32*256/85));
      } else {
        $h = HUE_AQUA;
        my $y = $b - 85;
        $y = 0 if ($y < 0);
        $h += int($y * (8*256/42)/256);
      }
    }
  } else { # highest == b
    if ($r == 0) {
      $h = HUE_AQUA + ((HUE_BLUE - HUE_AQUA) / 4);
      my $x = $b - 128;
      $x = 0 if ($x < 0);
      $h += int($x * (24*256/128)/256);
    } elsif (($b - $r) > $r) {
      $h = HUE_BLUE;
      $h += int($r * (32*256/85)/256);
    } else {
      $h = HUE_PURPLE;
      my $x = $r - 85;
      $x = 0 if ($x < 0);
      $h += int($x * (32*256/85)/256);
    }
  }

  $h += 1;

  $self->{h} = $h;
  $self->{s} = $s;
  $self->{v} = $v;
  return $self;
}

sub set {
  my $self = shift;
  my %opt = (
	r => 0, 
	g => 0,
	b => 0,
	h => 0,
	s => 0,
	v => 0, @_);

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
use Time::HiRes qw( usleep );
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
	len => 0,
        @_);

  $opt{start} = 0 if ($opt{start} < 0);
  $opt{start} = $self->len() if ($opt{start} > $self->len());
  $opt{end} = $opt{start} + $opt{len};
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
  my $self = shift;
  my %opt = (
	start => 0,
	end => $self->len(),
	len => 0,
	percent => 50,
	overlap => 0,
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

  if ($opt{overlap}) {
    my $border = $opt{start} + $opt{len} * $opt{percent}/100;
    $self->fade(start => ($border - $opt{overlap}/2), len => $opt{overlap});
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

sub transmit {
  my $self = shift;
  my %opt = (
        host => $self->{host},
        device => $self->{device},
        @_);

  my $bin = $self->bin();
  open(O, "|mosquitto_pub -h $opt{host} -t $opt{device} -s") || die "cannot open";
  print O "ledb ";
  print O $self->bin();
  close O || die "cannot close";
  return $self;
}

sub flash {
  my $self = shift;
  my %opt = (
        host => $self->{host},
        device => $self->{device},
	times => 10,
	interval => 1000, # milliseconds
        @_);

  my $dark = colorstripe->new(len=>$self->{len});

  for (my $i = 0; $i < $opt{times}; $i++) {
    $self->transmit(host=>$opt{host}, device=>$opt{device});
    ::Time::HiRes::usleep($opt{interval});
    $dark->transmit(host=>$opt{host}, device=>$opt{device});
    ::Time::HiRes::usleep($opt{interval});
  }
}

1;
