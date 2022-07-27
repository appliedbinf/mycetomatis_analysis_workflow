#!/usr/bin/perl -w
use strict;

my @isolates;


while (<DATA>){
	chomp $_;
	push(@isolates, $_);
}

foreach my $isolate (@isolates){
	print STDERR "Getting GIs for $isolate\n";
	
	my %reads;
	
	open READS, "<$isolate-notMycetomatis.fa" or die "Cannot open $isolate FASTA file: $!\n";
	while (<READS>){
		next if ($_ !~ m/^>/);
		
		chomp $_;
		
		$_ =~ s/>//;
		
		$reads{$_} = 1;
	}	
	close READS;
	
	my %lines;
	my $last = "";
	
	open BLAST, "<$isolate.nrdb.blastOut" or die "Cannot open $isolate.nrdb.blastOut: $!\n";
	while(<BLAST>){
		chomp $_;
		
		my ($query, $subject, undef, undef, undef, $pident, $qcovs, @vals) = split(/\t/,$_);
		
		next if ($query eq $last);
		
		next if (! exists $reads{$query});
		
		my @pieces = split(/\|/, $subject);
		
		$lines{$query} = $pieces[1]."\t".$pident."\t".$qcovs; 
		
		$last = $query;
	}
	close BLAST;
	
	open OUT, ">$isolate.gi" or die "Cannot open $isolate gi: $!\n";
	print OUT "Read ID\tGI\tPident\tQcovs\n";
	foreach my $key (keys %lines){
		print OUT $key."\t".$lines{$key}."\n";
	}
	close OUT;
	
	
}


__DATA__
Myc_16