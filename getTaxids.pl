#!/usr/bin/perl -w
use strict;


print STDERR "Calculating unique GIs\n";

my @gisToLook = `cat *.gi | cut -f2 | uniq | sort | uniq`;
my %gis;
my %map;

foreach my $gi (@gisToLook){
	next if($gi =~ m/GI/);
	
	chomp $gi;
	$gis{$gi} = 1;
}


print STDERR "Retrieving GIs to Taxids mapping\n";

open TAXID, "<../blast/analysis2/v1/nonMycReads/gis/taxids/nucl_wgs.accession2taxid" or die "Cannot open nucl_wgs.accession2taxid: $!\n";
<TAXID>;
while (<TAXID>){
	chomp $_;
	my (undef, undef, $taxid, $gi) = split(/\s+/, $_);
	if(defined $gis{$gi}){
		$map{$gi} = $taxid;
		delete $gis{$gi};
	}
	
	last if (scalar keys %gis == 0);
}
close TAXID;





my @isolates;

while (<DATA>){
	chomp $_;
	push(@isolates, $_);
}



foreach my $isolate (@isolates){
	print STDERR "Getting Taxids for $isolate\n";
	
	open GIS, "<$isolate.gi" or die "Cannot open $isolate GIs: $!\n";
	open OUT, ">$isolate.taxid" or die "Cannot open $isolate.taxid:$!\n";
	
	my $header = <GIS>;
	chomp $header;
	print OUT $header."\tTaxid\n";
	
	while (<GIS>){
		chomp $_;
		my (@pieces) = split(/\t/,$_);
		
		if (exists $map{$pieces[1]}){
			print OUT join("\t", @pieces, $map{$pieces[1]})."\n";
		}
		else {
			print OUT join("\t", @pieces, ".")."\n";
		}
		
	}	
	
	close GIS;
	close OUT;
	
}


__DATA__
Myc_16