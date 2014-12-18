#!/usr/bin/perl
# Spencer Clegg
# spencermclegg@gmail.com
# DEC 2014
use String::Util "trim";
use List::Util qw( min max );
# --- Usage --- #
if (@ARGV == 0 && -t STDIN && -t STDERR) { 
    print STDERR "$0: USAGE: perl hmetis2poly.pl [CNF FILE] [HMETIS OUTPUT FILE] [OUTPUT FILENAME]\n";
    exit;
}

open INPUT_FILE, @ARGV[0]; #open CNF
my @input_file_lines = <INPUT_FILE>; #Get the lines from hmetis output
my $CNF_filename = @ARGV[0];
my $HMETIS_filename = @ARGV[1];
my $output_filename = @ARGV[2];
open OUTPUT_FILE, ">$output_filename" or die $!;
print "Input CNF: $CNF_filename\n";
print "Input HMETIS: $HMETIS_filename\n";
print "Output File: $output_filename\n";
# Write ring r = 0, ...from p cnf {num_variables} {num_clauses}
print OUTPUT_FILE "ring r = 0, (TBD)ld;\n\n";


# --- Converts from CNF to POLYS --- #
my @linesplit = [];
for(my $l=0;$l<scalar @input_file_lines;$l++) 
{
   $line = @input_file_lines[$l];
   $line = trim($line);
   @linesplit = split(' ',$line);
   $line_size = scalar @linesplit;
   if($line =~ m/^p/ || $line =~ m/^c/) 
   { 
     # skip comment and program lines
   }
   else
   {
     for(my $i=0;$i<$line_size;$i++) #each element in line
      {
       my $current_value = abs($linesplit[$i]);
       if ($linesplit[$i] == 0) #if you hit a "0" you are done.
       { 
          print OUTPUT_FILE  ";\n";
          last; 
       } 
       if ($i == 0) { print OUTPUT_FILE  "poly p${l} = c${l} + v${current_value}"; } #if first line      
       else { print OUTPUT_FILE " + v${current_value}"; }
      }
   }  
}

close INPUT_FILE; #close CNF
open INPUT_FILE, @ARGV[1]; # open HMETIS
my @input_file_lines = (); #clear array
my @input_file_lines = <INPUT_FILE>;
my @linesplit = (); #clear array

# --- Converts HMETIS output to IDEALS --- #
#find number of partitions (aka ideals)
my $number_of_lines = @input_file_lines;
my $number_of_ideals = 0;
for my $index ( 0..$number_of_lines-1)
{
  if ($number_of_ideals < $input_file_lines[$index])
  {
    $number_of_ideals = $input_file_lines[$index];
  }
}
# Adjusting for zero index
$number_of_ideals = $number_of_ideals + 1; 

#create the arrays for each ideal
for my $index ( 0..$number_of_ideals-1 )
{
    $ideal[$index][0] = "ideal I${index} =";
}
# put each ideal in right array
for my $line_num ( 0..$number_of_lines-1 )
{
   $current_line = @input_file_lines[$line_num];
   $current_line = trim($current_line);
   @linesplit = split(' ',$current_line);
   my $ideal_index = $linesplit[0];
   if ($line_num == 0) #first one, no + sign
   {
    push (@ideal[$ideal_index], "I${line_num}");
   }
   else # everything between
   {
    push (@ideal[$ideal_index], "+ I${line_num}");
   }
}

# write ideals to file
for my $index ( 0..$number_of_ideals-1 ) 
{
     print OUTPUT_FILE "@{$ideal[$index]};\n";
}
close INPUT_FILE; #close CNF
print "Done.\nSee $output_filename for results.";

