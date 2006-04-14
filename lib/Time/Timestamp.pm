package Time::Timestamp;
use base 'DateTime';

use 5.008006;
use strict;
use warnings;
use HTTP::Date qw( str2time );

our $VERSION = '1.00';

# CONSTRUCTOR

sub new {
	my ($class,%data) = @_;
	if(!$data{ts}) { die 'missing ts!'; }
	my $self = DateTime->from_epoch(epoch => normalize($data{ts})); # so we can create the obj, tmp E needed
	bless ($self,$class);

	$self->set_time_zone(uc($data{tz})) if($data{tz});
	return $self;
}

# METHODS

sub set_time_zone {
	# get a wierd error if you dont uc() it.. wrap it.
	my ($self,$v) = @_;
	$self->SUPER::set_time_zone(uc($v)) if(defined($v));
}

sub tsIso {
	my $self = shift;
	my $iso = $self->hms();
	$iso =~ s/^T//;
	return $self->ymd().' '.$iso;
}

# ACCESSORS/MODIFIERS

# FUNCTIONS

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
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Time::Timestamp - Perl extension the easy manipulation of timestamps (subclass of datetime)

=head1 SYNOPSIS

  use Time::Timestamp;
  my $t = Time::Timestamp->new(ts => time) or Time::Timestamp->new(ts => $strTime); (see HTTP::Date::str2time for list of stringtypes)
  print $t->tsIso()."\n";
  print $->eepoch()."\n";
  $t->set_time_zone('est');

=head1 DESCRIPTION

This takes the best of DateTime / HTTP::Date and mixes them together. HTTP::Date has some great date parsing capability, so we use that to translate most any time format and store it as a DateTime obj. Everything is calculated and stored as eepoch, so local timezone won't be an issue util you need to translate.

=head1 OBJECT ORIENTED METHODS

=head2 set_time_zone

  This cleans up the DateTime::set_time_zone. It gets fussy if you don't send it in uppercase.

=head2 tsIso

  This returns the ts in ISO format 'yyyy-dd-mm 00:00:00'

=head1 PROCEDURAL METHODS

=head2 normalize

  returns the eepoch version of your string (interface to HTTP::Date::str2time)
  my $t = Time::Timetamp::normalize($strTime,$TZ);


=head1 SEE ALSO

  DateTime
  HTTP::Date

=head1 AUTHOR

Wes Young, E<lt>saxguard9-cpan@yahoo.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by Wes Young

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.6 or,
at your option, any later version of Perl 5 you may have available.


=cut
