package Time::Timestamp;
use base 'DateTime';

=head1 NAME

Time::Timestamp - Perl extension the easy manipulation of timestamps (subclass of datetime)

=head1 SYNOPSIS

  use Time::Timestamp;
  my $t = Time::Timestamp->new(ts => time) or Time::Timestamp->new(ts => $strTime,time_zone => 'local');
  print $t->tsIso()."\n";
  print $->eepoch()."\n";

  $t->set_time_zone('local');
  $t->set_time_zone('America/New_York');
  $t->set_time_zone('UTC');

=head1 DESCRIPTION

This takes the best of DateTime / HTTP::Date and mixes them together. HTTP::Date has some great date parsing capability, so we use that to translate most any time format and store it as a DateTime obj. Everything is calculated and stored as eepoch, so local timezone won't be an issue util you need to translate.


=cut

use 5.008006;
use strict;
use warnings;
use HTTP::Date qw( str2time );

our $VERSION = '1.01';


=head1 OBJECT ORIENTED METHODS

=head2 new()

Object Constructor. Uses HTTP::Date to parse date strings.

Accepts:

  ts => [int|string], defaults to time()
  time_zone => [int|string], defaults to 'UTC' (hint, using time_zone => 'local' is a good thing, then use the epoch() for saving ;-))

=cut


sub new {
	my ($class,%parms) = @_;
	die('missing ts!') unless($parms{ts});
	$parms{utc_warn} = 1 unless(defined($parms{utc_warn}));
	my $self = DateTime->from_epoch(epoch => normalize($parms{ts},$parms{time_zone}));
	bless ($self,$class);
	$self->set_time_zone($parms{time_zone});
	return $self;
}

=head2 tsIso()

This returns the ts in ISO format 'yyyy-dd-mm hh:mm:ss'. When passed a timezone string, it will return the translated time for that zone.

  $t->tsIso('UTC'); returns tsIso() for UTC.
  $t->tsIso('America/New_York'); returns tsIso for that timezone (same with 'local');
  $t->tsIso() will return a value for the stored timezone

The timezone of the Time::Timestamp object is changed for a moment to accomplish the translation, but is returned before the value is returned.

=cut

sub tsIso {
	my ($self,$tz) = @_;
	my ($oTz,$rv);
	if($tz){
		$oTz = $self->time_zone->name();
		$self->set_time_zone($tz);
	}
	my $iso = $self->hms();
	$iso =~ s/^T//;
	$rv = $self->ymd().' '.$iso;
	$self->set_time_zone($oTz) if($oTz);
	return $rv;
}

=head2 tsIsoShort()

Returns the ts in ISO shorthand format 'yyyyddmmhhmmss'. Good for serial revisioning. When passed a timezone string, it will return the translated time for that zone.

  $t->tsIsoShort('UTC'); returns tsIso() for UTC.
  $t->tsIsoShort('America/New_York'); returns tsIso for that timezone (same with 'local');
  $t->tsIsoShort() will return a value for the stored timezone

The timezone of the Time::Timestamp object is changed for a moment to accomplish the translation, but is returned before the value is returned.

=cut

sub tsIsoShort {
	my ($self,$tz) = @_;
	return $self->year().$self->month().$self->day().$self->hour().$self->minute().$self->second() unless($tz);
	my $oTz = $self->time_zone->name();
	$self->set_time_zone($tz);
	my $rv = $self->year().$self->month().$self->day().$self->hour().$self->minute().$self->second();
	$self->set_time_zone($oTz);
	return $rv;
}

=head1 PROCEDURAL METHODS

=head2 normalize()

Returns the eepoch version of your string (interface to HTTP::Date::str2time)

  my $t = Time::Timetamp::normalize($strTime,$TZ);

=cut

sub normalize {
	my ($v,$tz) = @_;
	for ($v) {
		# epcoch
		if (/\d{10}/) { return $v; } 	# return if we already sent it an epoch
		my $t = str2time($v,$tz);	# try to date_parse() it with HTTP::Date;
		die 'Un-recognized time format: '.$v if(!$t);
		return $t;
	}
}

1;
__END__

=head1 SEE ALSO

DateTime,DateTime::Timezone,HTTP::Date

=head1 AUTHOR

Wes Young, E<lt>saxguard9-cpan@yahoo.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by Wes Young

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.6 or,
at your option, any later version of Perl 5 you may have available.


=cut
