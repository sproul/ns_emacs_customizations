use strict;
use diagnostics;
use Ndmp;
use IO::File;

my %tokenToICArray = ();
my %childICtoParentToken = ();

sub Build_arrays
{
  my($parsePlOutput) = @_;
  $parsePlOutput->seek(0,0);

  while (<$parsePlOutput>)
  {
    chomp;
    if (/(.*)>(.*) (\d+) (\d+)$/)
    {
      my ($parentToken, $childIC, $offset, $parsePlOutputileNumber) = ($1, $2, $3, $4);
      die "unexpectedly formatted child IC: $childIC" unless $childIC =~ /(.*)!(.*)/;
      my ($childFn, $childToken) = ($1, $2);

      #print STDERR "$parentToken, $childIC, $offset, $parsePlOutputileNumber >>> $childFn, $childToken\n";

      $childICtoParentToken{$childIC} = $parentToken;

      my $childICArray = $tokenToICArray{$childToken};
      if (!defined $childICArray)
      {
	$childICArray = [ $childIC ];
	$tokenToICArray{$childToken} = $childICArray;
      }
      else
      {
	push @$childICArray, $childIC;
      }
    }
    else
    {
       # $_ is just a file name
    }
  }
}

sub GetICArray
{
  my($token) = @_;

  my $ICArray = $tokenToICArray{$token};
  die "no ICArray for $token" if (!defined $ICArray);

  return $ICArray;
}

sub TokenIsUnique
{
  my($token) = @_;

  my $ICArray = GetICArray($token);
  return scalar(@$ICArray) == 1;
}

sub TokenIsUnknown
{
  my($token) = @_;

  return 1 if !$token;

  return (!defined $tokenToICArray{$token});
}

sub CountIdenticalLeadingChars
{
  my($s, $s2) = @_;

  my $countOfIdenticalLeadingChars;
  if ("$s;$s2" =~ /^(.*)(.*);\1/)
  {
    $countOfIdenticalLeadingChars = length($1);
  }
  else
  {
    $countOfIdenticalLeadingChars = 0;
  }
  return $countOfIdenticalLeadingChars;
}

sub GetFnFromIC
{
  my($IC) = @_;
  die "bad $IC" if $IC !~ /(.*)!/;
  my $fn = $1;
  return $fn;
}

sub GetSuffix
{
  my($fn) = @_;
  die "no suffix" if $fn !~ m{\.([^\./]+)$};
  my $suffix = $1;
  return $suffix;
}

sub GetSameLangSuffixes
{
  my($fn) = @_;
  my $suffix = GetSuffix($fn);
  my $sameLangSuffixes = $suffix;
  if ($suffix =~ /^(cpp|c|h)$/)
  {
    $sameLangSuffixes = "(cpp|c|h)";
  }
  elsif ($suffix =~ /^(cgi|pm|pl)$/)
  {
    $sameLangSuffixes = "(cgi|pm|pl)";
  }
  elsif ($suffix =~ /^(jav|java)$/)
  {
    $sameLangSuffixes = "(jav|java)";
  }

  return $sameLangSuffixes;
}

sub GetFnsForSameLang
{
  my($childIC, $ICarrayRef) = @_;

  my $childFn = GetFnFromIC($childIC);
  my $sameLangSuffixes = GetSameLangSuffixes($childFn);
  my @fnArray = ();
  foreach my $IC (@$ICarrayRef)
  {
    my $fn = GetFnFromIC($IC);
    if ($fn =~ /\.$sameLangSuffixes$/)
    {
      push @fnArray, $fn;
    }
  }
  if (!@fnArray)
  {
    if ($childFn ne "\$P4ROOT/Tools/build/engine2/lib/builder.py"
    &&  $childFn ne "\$P4ROOT/Tools/build/engine2/lib/common.py")
    {
      Ndmp::A("ICarrayRef", @$ICarrayRef);
      # 
      # didn't shoot these problems -- but I just want to mark 'em as having been seen.   -ns 8.4.2005
      warn "GetFnsForSameLang($childIC, [cf above]): no matches for $childFn";
    }
    else
    {
      warn "some known but never shot problems were seen in post parse for $childFn";
    }

    return (undef, undef);
  }
  return ($childFn, @fnArray);
}

sub FindICbyFn
{
  my($fn, $ICarrayRef) = @_;
  foreach my $IC (@$ICarrayRef)
  {
    return $IC if $fn eq GetFnFromIC($IC);
  }

  die "no match for $fn";
}

sub ChooseBestMatch
{
  my($childIC, $parentToken) = @_;
  my $parentICarrayRef = GetICArray($parentToken);
  my ($childFn, @fnArray) = GetFnsForSameLang($childIC, $parentICarrayRef);
  
  return undef unless defined $childFn;
  
  my $maxMatchCount = 0;
  my $bestMatchFn = undef;
  if (@fnArray == 1)
  {
    $bestMatchFn = $fnArray[0];
  }
  else
  {
    foreach my $fn (@fnArray)
    {
      my $countOfIdenticalLeadingChars = CountIdenticalLeadingChars($childFn, $fn);
      if ($countOfIdenticalLeadingChars > $maxMatchCount)
      {
	$maxMatchCount = $countOfIdenticalLeadingChars;
	$bestMatchFn = $fn;
      }
    }
  }
  my $bestMatchIC = FindICbyFn($bestMatchFn, $parentICarrayRef);
  return $bestMatchIC;
}


sub Print_leanData
{
  my($parsePlOutput) = @_;
  $parsePlOutput->seek(0,0);

  while (<$parsePlOutput>)
  {
    chomp;
    my $line = $_;
    if ($line =~ /(.*)>(.*) (\d+) (\d+)$/)
    {
      my ($parentToken, $childIC, $offset, $parsePlOutputFileNumber) = ($1, $2, $3, $4);
      die "unexpectedly formatted child IC: $childIC" unless $childIC =~ /(.*)!(.*)/;
      my ($childFn, $childToken) = ($1, $2);

      my $parentIC;
      if (TokenIsUnknown($parentToken) || TokenIsUnique($parentToken))
      {
	$parentIC = $parentToken;
      }
      else
      {
        $parentIC = ChooseBestMatch($childIC, $parentToken);
        next unless defined $parentIC;
      }

      if (TokenIsUnique($childToken))
      {
	$childIC = $childToken;
      }
      print "$parentIC>$childIC $offset $parsePlOutputFileNumber\n";
    }
    else
    {
      #####################print "$line\n";
    }
  }
}

sub Main
{
  my $parsePlOutputFn = $ARGV[0];
  my $parsePlOutput = new IO::File("< $parsePlOutputFn") || die "cannot open $parsePlOutputFn";

  Build_arrays($parsePlOutput);
  Print_leanData($parsePlOutput);

  $parsePlOutput->close();
}
  
Main();
