use strict;
    
my $db__fileNamesCount;
my $db__testing;
my $db__verboseInit;
my $db__verbose;
my @db__fileNames;
my %db__children;
my %db__parents;
my %db__tags;

sub Init
{
  $| = 1; # turn off output buffering
  while (@ARGV)
  {
    $_ = shift @ARGV;
    if (/^-d$/)
    {
      my $file_tags_name = shift @ARGV;
      ReadTagsData($file_tags_name, 0);
    }
    elsif (/^-t$/)
    {
      $db__testing = 1;
    }
    elsif (/^-vi$/)
    {
      $db__verboseInit = 1;
      $db__verbose = 1;
    }
    elsif (/^-v$/)
    {
      $db__verbose = 1;
    }
    else
    {
      die "E unrecognized command line argument $_";
    }
  }
}

sub EliminateTagData
{
  my($fileName) = @_;
  my $j;
  for ($j = 0; $j < @db__fileNames; $j++)
  {
    if ($fileName eq $db__fileNames[$j])
    {
      if ($db__verbose) {print "EliminateTagData:db__fileNames[$j] = ''\n";}
      $db__fileNames[$j] = "";
      return;
    }
  }
}

sub MakeSafeRegexp
{
  my($s) = @_;
  $s =~ s/\+/\\+/g;
  $s =~ s/\*/\\*/g;
  return $s;
}


sub ReadTagsData
{
  my($file_prefix, $override_old_data) = @_;

  open(FILE_TAGS,    $file_prefix . ".tags"   )||die "E cannot open $file_prefix.tags\n";
  open(FILE_CLASSES, $file_prefix . ".classes")||die "E cannot open $file_prefix.classes\n";

  while (<FILE_CLASSES>)
  {
    if (/^(\w:)?\//)
    {
      # ignore file names for now.  This program does not purge
      # outdated hierarchy information, so it needn't keep track
      # of where the information came from.
      ;
    }
    elsif (/^$/)
    {
      # by the same token, ignore purged file names for now
      ;
    }
    elsif (/^(.*)>(.*) /)
    {
      my($parent, $child) = ($1, $2);
      if ($parent)
      {
        my $value = $db__children{$parent};
        if (!defined $value)
        {
          $db__children{$parent} = $child . ";";
        }
        else
        {
          my $childRE = MakeSafeRegexp($child);
          if ($value !~ /$childRE;/)
          {
            $db__children{$parent} = $value . $child . ";";
          }
        }

        $value = $db__parents{$child};
        if (!defined $value)
        {
          $db__parents{$child} = $parent . ";";
        }
        elsif ($value !~ /$parent;/)
        {
          $db__parents{$child} = $value . $parent . ";";
        }
      }
      if ($db__verboseInit) {print "classes:parent/child:$parent/$child\n";}
    }
    else
    {
      die "E bad class data: $_";
    }
  }
  close(FILE_CLASSES);
                          
  while (<FILE_TAGS>)
  {
    if (/^,(.*)$/)
    {
      my $fileName = $1;	
      if ($override_old_data) 
      {
	EliminateTagData($fileName);
      }
      if ($db__verboseInit) {print "ReadClassesData:db__fileNames[$db__fileNamesCount]:'$fileName'\n";}
      $db__fileNames[$db__fileNamesCount++] = $fileName; 
    }
    elsif (/^$/)
    {
      if ($db__verboseInit) {print "ReadClassesData:db__fileNames[$db__fileNamesCount]:''\n";}
      $db__fileNames[$db__fileNamesCount++] = "";
    }
    elsif (/(\S+) (\d+ \d+)/)
    {
      my ($tag, $fileNumberAndOffset) = ($1, $2);
      if ($db__tags{$tag})
      {
	$db__tags{$tag} = $db__tags{$tag} . ":" . $fileNumberAndOffset;
      }
      else
      {
	$db__tags{$tag} = $fileNumberAndOffset;
      }
      #if ($db__verboseInit) {print "ReadTagsData:tag:$tag:db__tags{$tag}:$db__tags{$tag}\n";}
    }
    elsif (/^$/)
    {
      if ($db__verboseInit) {print "ReadTagsData:db__fileNames[$db__fileNamesCount]:''\n";}
      $db__fileNames[$db__fileNamesCount++] = "";
    }
    elsif (/^([\.\w]+)>([\.\w]+)$/)
    {
      my($parent, $child) = ($1, $2);
      if ($db__children{$parent} !~ /$child:/)
      {
	$db__children{$parent} = $db__children{$parent} . $child . ":";
      }
      if ($db__parents{$child} !~ /$parent:/)
      {
	$db__parents{$child} = $db__parents{$child} . $parent . ":";
      }
      if ($db__verboseInit) {print "tags:parent:$parent, child:$child\n";}
    }
    else
    {
      die "E bad tag data: $_";
    }
  }
  close(FILE_TAGS);
}

sub Search
{
  my($name, $secondarySearch) = @_;
                                                  
  my($hit, @hits, $name_index, $hitString, $offset);
  $hitString = $db__tags{$name};
  if (!defined $hitString)
  {
    $hitString = "";
  }
  
  if ($db__verbose) {print "Search($name): $hitString\n";}
  
  @hits = split(/:/, $hitString);
  if (@hits==0)
  {
    # If nothing was found, lowercase the name and try one more time.
    #
    # For languages which are not case sensitive, I have stored the names in all lowercase
    # (so far this just means easy language only).
    # 
    if (!defined $secondarySearch)
    {
      $name =~ s/(.*)/\L$1/;
      return Search($name, 1);
    }
    return 0;
  }
                                                                                  
  foreach $hit (@hits)
  {
    if ($hit =~ /^(\d+) (\d+)$/)
    {
      $offset = $1;
      $name_index = $2;
      if ($db__fileNames[$name_index])
      {
	print "F $db__fileNames[$name_index]\nO $offset\n";
      }
    }
    else
    {
      die "E bad tag data: $db__tags{$name}";
    }                                                                                
  }
  print "X\n";
  return 1;
}
                        
sub SearchHierarchically
{
  my($contextString, $name, $callCount) = @_;
  if ($callCount++ > 100)
  {
    print "E the inheritance hierarchy could be looping\n";
    return 0;
  }
  if ($db__verbose) {print "SearchHierarchically($contextString, $name, $callCount)\n";}
  if ($contextString)
  {
    my(@contextList) = split(/:/, $contextString);
    my $context;
    foreach $context (@contextList)
    {
      if (Search($context . ":" . $name))
      {
	return 1;
      }
      if (SearchHierarchically($db__parents{$context}, $name, $callCount))
      {
	return 1;
      }
    }
  }
}
sub Go
{
  my($context, $j, $name);

  while (<STDIN>)
  {
    if (/N (.*)$/)
    {
      my $filesWhoseTagsWillBeUpdated = $1;
      system("sh ./generate.sh $filesWhoseTagsWillBeUpdated $db__fileNamesCount");
      print "T tag data generation complete\n";
      ReadTagsData($filesWhoseTagsWillBeUpdated, 1);
    }
    elsif (/C (.*)$/)
    {
      my $parent = $1;
      my @hits = split(/:/, $db__children{$parent});
      if (@hits > 0)
      {
        print "C\n";
        my $hit;
        foreach $hit (@hits) { print $hit, "\n";}
      }
    }
    elsif (/Z (.*)$/)
    {
      my $operation = $1;
      if ($operation eq "dump file names")
      {
        for (my $j = 0; $j<scalar(@db__fileNames); $j++)
        {
          print "$j :$db__fileNames[$j]\n";
        }
        exit(0);
      }
      else
      {
        die "unrecognized operation $operation"
      }
    }
    elsif (/P (.*)$/)
    {
      my $child = $1;
      my @hits = split(/:/, $db__parents{$child});
      if (@hits > 0)
      {
        print "P\n";
        my $hit;
        foreach $hit (@hits) { print $hit, "\n";}
      }
    }
    elsif (/^(.*): (.*)$/)
    {
      $context = $1;
      $name = $2;
      if (!SearchHierarchically($context, $name, 0)
      && !Search($name))
      {
        print "E can't find $name\n";
      }
    }
    else
    {
      die "E bad command: $_";
    }

    if ($db__testing) {exit(0);}
  }
}


Init();
Go();
exit(0);

# result:
#SearchHierarchically(, nsimple-kill-line, 1)
#Search(nsimple-kill-line): 464 187
#F $HOME/work/emacs/lisp/nsimple.el
#O 464
#X
# 
# test with: perl -w $dp/emacs/tags/db.pl -v -d $HOME/tmp/tags/main
#: nsimple-kill-line
