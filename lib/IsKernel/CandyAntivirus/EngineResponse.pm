package IsKernel::CandyAntivirus::EngineResponse;

use warnings;
use strict;
use v5.14;

sub new
{
	(my $class, my $response, my $status) = @_;
	my $self = {};
	
	$self->{"PrintResponse"} = $response;
	$self->{"LogResponse"} = localtime." ".$response;
	$self->{"Status"} = $status;
	bless $self, $class;	
	return $self;
}

sub get_print_response()
{
	my $self = shift;
	return $self->{"PrintResponse"};
}

sub get_log_response()
{
	my $self = shift;
	return $self->{"LogResponse"};
}

sub get_status()
{
	my $self = shift;
	return $self->{"Status"};
}

1;