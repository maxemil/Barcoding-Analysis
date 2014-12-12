#! usr/bin/perl
#
#author: max emil schön, <max-emil.schoen@student.uni-tuebingen.de>
#last update: 01.07.14, 11:19
#
use strict;
use warnings;
my $usage="usage:  perl barcodeGap.pl Specs dist
			where Specs is a table containing all names 
			of sequences in dist and in another column the
			name of the (morpho)species. dist is a
			distance matrix computed from an alignment\n";
my $moSpec=shift or die $usage;
my $distM=shift or die $usage;

open SPEC, $moSpec or die "couldn't open $moSpec";
open DIST, $distM or die "couldn't open $distM";
open OUT, ">$distM.MinMax";

my @specs=<SPEC>;
my @names;
for(my $i=0;$i<scalar(@specs);$i++){
	my @line=split /\t/, $specs[$i];
	$names[$i]=$line[0];
	chomp($line[1]);
	$specs[$i]=$line[1];
}

my @morph=excludeMultiples(@specs);

my @dist=<DIST>;
foreach my $elem (@dist){chomp($elem)};
my @Max;
my @Min;
my @Mean;
my @count;
for(my $i=0;$i<scalar(@morph);$i++){
	$Max[$i]=-1;
	$Min[$i]=100000;
}


print scalar(@morph);
#for all species find the corresponding morphoIndex and look for the greatest intraspecific
#and smallest interspecific Distance and save it to the index in Min and Max
for(my $i=0; $i<scalar(@names);$i++){
	
	my $indexOfMorph=undef;
	
	for(my $j=0;$j<scalar(@morph);$j++){
		if($morph[$j] eq $specs[$i]){
			if(!$indexOfMorph){
				$indexOfMorph=$j;
			}else {
				print $specs[$i]."found twice!!!";
			}
			
		}
	}
	if(!$indexOfMorph && $indexOfMorph!=0) {print "spec not found: ".$specs[$i]."\n"};	
	#print $dist[$i];
	my @distances=split /\t/, $dist[$i+1];
	#print $distances[0]."\n";

	
	
	for(my $j=1;$j<scalar(@distances);$j++){

		if($specs[$i] eq $specs[$j-1] ){	
			$Mean[$indexOfMorph]+=$distances[$j];
			$count[$indexOfMorph]++;
			if($distances[$j]>$Max[$indexOfMorph]){
				$Max[$indexOfMorph]=$distances[$j];
				#if($distances[$j]>0.1){print $specs[$i]." (".$i.")\t".$specs[$j-1]." (".($j-1).")\n"};
			}
		}elsif($specs[$i] ne $specs[$j-1]){
			if($distances[$j]<$Min[$indexOfMorph]){
				$Min[$indexOfMorph]=$distances[$j];
			}
			#if($distances[$j]==0){
			#	print $names[$i]." (".$specs[$i].")\t".$names[$j-1]." (".$specs[$j-1].")\t".$distances[$j]."\n";
			#}
		}
	}
}


chomp($morph[0]);
print OUT "Morph\tMax\tMin\tMean\n";
my $mean;
for(my $i=0;$i<scalar(@morph);$i++){
	chomp($morph[$i]);
	$mean=$Mean[$i]/$count[$i];
	print OUT $morph[$i]."\t".$Max[$i]."\t".$Min[$i]."\t".$mean."\n";
}



close SPEC;
close DIST;
close OUT;

sub excludeMultiples {
	my @specs= @_;
	@specs=sort @specs;	
	my @morph;
	for (my $i=0;$i < scalar @specs; $i++)
	{
		if($specs[$i] ne $specs[$i-1])
		{
			push(@morph,$specs[$i]);
		}
	}	
	return @morph;
}
