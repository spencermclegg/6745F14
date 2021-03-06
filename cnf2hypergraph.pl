#!/usr/bin/perl
use String::Util "trim";

open CNF, @ARGV[0];
my @cnflines = <CNF>; #Get the lines from the CNF file
my $graphname = @ARGV[1];
open GRAPH, ">$graphname" or die $!;

my @linesplit = [];;
my @variables;
my $varcount;
my $clausecount;
my $clause =0;
for(my $l=0;$l<scalar @cnflines;$l++) #First parse through the file and find all the variables
{
   $line = @cnflines[$l];
   $line = trim($line);
   print "\nLine is ${line}\n";
   if($line =~ m/^p/) #line gives the variable and clause count;
   {
      @linesplit = split(' ',$line);
      $varcount= @linesplit[2];
      $clausecount= @linesplit[3];
      next;
   }
   
   if($line =~ m/^c/)
   {   
      next; #line is a comment
   }
   
   $clause++;
   @linesplit = split(/ /, $line);
   my $linecount=  scalar @linesplit -1;
   
   print "Number of variables is ${linecount}\n";
   for(my $i=0; $i<scalar @linesplit-1;$i++)
   {
      my $char = @linesplit[$i];
      $char =~ s/^[\-]//;
      print "Current variable is ${char}\n";
      my $index = new_variable(@variables,$char);
      if($index != -1) #Variable is in the list
      {
         print "Index where it should go is ${index}\n";
         push(@variables[$index],$clause);
      }
      else #Need to add variable to the list
      {
         print "Adding new variable\n";
         @varlist= ($char,$clause);
         push(@variables,[@varlist]);
      }
   }
   ;
}

print "\n";
#print scalar (@variables[1]);
print GRAPH "${varcount} ${clausecount} \n";
for $i (0 .. $#variables) 
{
   @part = @{ $variables[$i] } [ 1..$varcount];
   print GRAPH "@part\n";
}
close GRAPH;

sub new_variable()
{
   my @variables=@_[0..$#_-1];
   my $variable =$_[$#_];
   for(my $i=0;$i< scalar @variables;$i++)
   {
      if($variables[$i][0] == $variable)
      {
         print "Found ${variable} in list\n";
         return $i;
      }
   }
   print "Didn't find ${variable} in list\n";
   return -1;
}
