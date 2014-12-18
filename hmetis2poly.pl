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
my $output_filename = @ARGV[2];
open OUTPUT_FILE, ">$output_filename" or die $!;

# Write ring r = 0, ...from p cnf {num_variables} {num_clauses}
print "ring r = 0, (TBD)ld;\n\n";


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
          print ";\n";
          last; 
       } 
       if ($i == 0) { print "poly p${l} = c${l} + v${current_value}"; } #if first line      
       else { print " + v${current_value}"; }
      }
   }  
}

close INPUT_FILE; #close CNF
open INPUT_FILE, @ARGV[1]; # open HMETIS
my @input_file_lines = (); #clear array
my @linesplit = (); #clear array
my @input_file_lines = <INPUT_FILE>;
# --- Converts HMETIS output to IDEALS --- #
#find number of partitions (aka ideals)
my $number_of_lines = @input_file_lines;
my $number_of_ideals = 0;
for my $index ( 0..$number_of_lines-1)
{
print "number_of_ideals:$number_of_ideals    compare: $input_file_lines[$index]   index: $index\n";
  if ($number_of_ideals < $input_file_lines[$index])
  {
    $number_of_ideals = $input_file_lines[$index];
  }
print "number_of_ideals:$number_of_ideals\n";
}
#print "\n\n\n$number_of_ideals\n\n\n";

#create the arrays for each ideal
for my $index ( 0..$number_of_ideals-1 )
{
    $ideal[$index][0] = "ideal I${index} =";
}
# put each ideal in right array
for my $line_num ( 0..$number_of_ideals-1 )
{
   $current_line = @input_file_lines[$line_num];
   $current_line = trim($current_line);
   @linesplit = split(' ',$current_line);
   my $ideal_index = $linesplit[0]; 
   push (@ideal[$ideal_index], " + I${line_num}");
}

# write ideals to file
for my $index ( 0..$number_of_ideals-1 ) 
{
     print "@{$ideal[$index]}\n";
}

close INPUT_FILE; #close CNF
print "Done.\nSee $output_filename for results.";

