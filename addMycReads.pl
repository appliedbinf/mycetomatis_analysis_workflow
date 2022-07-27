#!/usr/bin/perl -w
use strict;


my @isolates;


while(<DATA>){
	chomp $_;
	push(@isolates, $_);
}


foreach my $isolate (@isolates){
	
	my $last = "";
	
	open FILE, "<$isolate.fungaldb.blastOut" or die "Cannot open $isolate.fungaldb.blastOut: $!\n";
	open OUT, ">>$isolate.taxid" or die "Cannot open $isolate.taxid: $!\n";
	
	print STDERR "Retrieving BLAST results for $isolate\n";
	
	while (<FILE>){
		chomp $_;
		
		my ($query, $subject, undef, undef, undef, $pident, $qcovs, undef) = split(/\t/,$_);		
		
		if ($query eq $last){
			next;
		}
		else {
			next if ($pident < 75 || $qcovs < 75);
			
			if ($subject =~ m/(^GAD)||(^WOG)||(^LCT)|(^Madurella_mycetomatis)/){
				print OUT $query."\t.\t".$pident."\t".$qcovs."\t100816\n";
			}
		}
		
		$last = $query;
		
	}
	
	close FILE;
	close OUT;
}


__DATA__
Myc_16