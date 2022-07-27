#!/usr/bin/perl -w
# Purpose: Filter out reads with 4+ Ns in a row
# Creation Date  : Jan 7, 2020
# Modified/Updated for Myc_16 runs	:	April 25, 2020
#
#############################################################

use strict;


while (my $file = <DATA>){
	
	chomp $file;

	open OUT, ">$file-filter.fa" or die "Cannot open $file-filter.fa: $!\n";

	open FILE, "<nonHum-$file.R1.fa" or die "Cannot open nonHum-$file.R1.fa: $!\n";
	print STDERR "Filtering reads from $file R1\n";

	while (<FILE>){
		chomp $_;
		my $sequence = <FILE>;
		chomp $sequence;
		if ($sequence =~ m/N{4,}/){
			next;
		}
		else {
			print OUT $_."\n".$sequence."\n";
		}
	}
	close FILE;
	
	
	open FILE, "<nonHum-$file.R2.fa" or die "Cannot open nonHum-$file.R2.fa: $!\n";
	print STDERR "Filtering reads from $file R2\n";
	while (<FILE>){
		chomp $_;
		my $sequence = <FILE>;
		chomp $sequence;
		if ($sequence =~ m/N{4,}/){
			next;
		}
		else {
			print OUT $_."\n".$sequence."\n";
		}
	}
	close FILE;
	
	close OUT;
}

__DATA__
Myc_16
