#!/usr/bin/perl
use String::Util "trim";

open INPUT_FILE, @ARGV[0]; #open CNF
my @input_file_lines = <INPUT_FILE>; #Get the lines from hmetis output
my $output_filename = @ARGV[2];
open OUTPUT_FILE, ">$output_filename" or die $!;

# Write ring r = 0, ...from p cnf {num_variables} {num_clauses}
print "ring r = 0, (TBD)ld;\n\n";


# for each line (ignore c and p)
#   for each element in each line
#      file poly p1 = v{element} + v{element} ...until 0
my @linesplit = [];

for(my $l=0;$l<scalar @input_file_lines;$l++) 
{
   $line = @input_file_lines[$l];
   $line = trim($line);
   if($line =~ m/^p/ || $line =~ m/^c/) #skip comment and program lines
   {
     @linesplit = split(' ',$line);
     for(my $i=0;$i<scalar @linesplit;$i++) #each element in line
     {
       if ($linesplit[$i] == 0) { last }; #if you hit a "0" you are done.
       else if ($i == 0) { print "poly p{$l} = c${l}" }; #if first line      
       else { print " + v$i" };
     }
   }
}

close INPUT_FILE; #close CNF
open INPUT_FILE, @ARGV[1]; # open HMETIS
my @input_file_lines = (); #clear array
my @input_file_lines = <INPUT_FILE>;
# Then for (total lines of hmetis)
#   for each linenumber containing {i}
#  Write ideal I{i} = p{linenumber} + p{linenumber}
for(my $l=0;$l<scalar @input_file_lines;$l++) 
{
   $line = @input_file_lines[$l];
   $line = trim($line);
   @linesplit = split(' ',$line);
   if @ideal${linesplit[0]}[0] #if array exists
   {
     push @ideal${linesplit[0]}, "p${l}";
   }
   else #if array doesn't exist
   {
     our @ideal${linesplit[0]} = "p${l}";
   }
}

for(my $l=0;$l<scalar @input_file_lines;$l++) 
{
   $line = @input_file_lines[$l];
   $line = trim($line);
   @linesplit = split(' ',$line);
   if @ideal${linesplit[0]}[0] #if array exists
   {
     print "ideal I${linesplit[0]} = @ideal${linesplit[0]}\n"
   }
}

close INPUT_FILE; #close CNF

