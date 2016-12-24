use strict;
use adynware::utility;
use nutil;

package parse;

my $tags__current_file_position;
my @tags__classes;
my $tags__file_name_echoed_to_classes = 0;
my $tags__raw_input_file_name;
my $tags__raw_input_file_basename;
my $__trace;
my $tags__testing;
my $tags__file_ordinal = 0; # wasn't being init'ed -- was getting uninit error...

sub Init
{
  while (@ARGV)
  {
    $_ = shift @ARGV;
    if (/^-n$/)
    {
      $tags__file_ordinal = shift @ARGV;
    }
    elsif (/^-o$/)
    {
      my $output_prefix = shift @ARGV;
      open(TAGS,    ">" . $output_prefix . ".tags"   )||die "cannot open $output_prefix.tags\n";
      open(CLASSES, ">" . $output_prefix . ".classes")||die "cannot open $output_prefix.classes\n";
    }
    elsif (/^-t$/)
    {
      $tags__testing = 1;
    }
    elsif (/^-v$/)
    {
      $__trace = 1;
    }
    else
    {
      die "unrecognized command line argument $_";
    }
  }
}

sub Cleanup
{
  close(CLASSES);
  close(TAGS);
}

sub AddSubclass
{
  my($parent, $child) = @_;
  if ($__trace) {print "AddSubclass($parent, $child)\n";}

  return if $parent eq $child;

  if (!$tags__file_name_echoed_to_classes)
  {
    $tags__file_name_echoed_to_classes=1;
    print CLASSES "$tags__raw_input_file_name\n";
  }

  #warn "parse::AddSubclass: parent" unless defined $parent;
  #warn "parse::AddSubclass: child" unless defined $child;
  #warn "parse::AddSubclass: tags__current_file_position" unless defined $tags__current_file_position;
  #warn "parse::AddSubclass: tags__file_ordinal" unless defined $tags__file_ordinal;

  print CLASSES "$parent>$tags__raw_input_file_name!$child $tags__current_file_position $tags__file_ordinal\n";
}

sub PushClass
{
  my($class) = @_;
  push(@tags__classes, $class);
  if ($__trace) {print "PushClass($class)\n";}
}

sub PopClass
{
  pop(@tags__classes);
  if ($__trace) {print "PopClass()\n";}
}

sub Tag
{
  my($what, $definitely, $lowerCase) = @_;
  if ($__trace) {print "Tag($what, " . nutil::ToString($definitely) . ") \n";}

  if ($lowerCase)
  {
    $what =~ s/(.*)/\L$1/;
  }

  if (!$definitely)
  {
    if ($what =~ /^main$/)	# pointless to tag the many mains

    #|| ($what =~ /^.$/))	# single-character names are too common


    {
      if ($__trace) {print "Tag: rejecting either 'main' or single char\n";}

      return;
    }
  }
  if ($what =~ /(\S+)\s/)
  {
    if ($tags__testing) {print "error: bad tag :$what: at $tags__raw_input_file_name:$tags__current_file_position\n";}

    #system("cp " . $tags__raw_input_file_name . "e:/users/nelson/work/ntags/k.man");
    $what = $1;
  }

  printf(TAGS "%s %d %d\n", $what, $tags__current_file_position, $tags__file_ordinal);
  if (scalar(@tags__classes) > 0)
  {
    print "parse::Tag($what): tagging for $tags__classes[0]\n" if $__trace;
    printf(TAGS "%s:%s %d %d\n", $tags__classes[0], $what, $tags__current_file_position, $tags__file_ordinal);
  }
  else
  {
    print "parse::Tag($what): not tagging for a class\n" if $__trace;
  }

  #if (defined $allCase && $allCase)
  #{
  #$what =~ s/(.*)/\U$1/;
  #Tag($what, $definitely);
  #
  #$what =~ s/(.*)/\L$1/;
  #Tag($what, $definitely);
  #}
}

sub changeToBlanks
{
  my($s) = @_;
  $s =~ s/./ /g;
  return $s;
}

sub TagMySqlDoc
{
  while (<INPUT>)
  {
    my $line = $_;
    if ($line =~ /^`(\w+).* Syntax$/
    ||  $line =~ /^`(\w+)\(.*\)'$/)
    {
      my $name = $1;
      Tag($name, 1, 1);
    }
    $tags__current_file_position+=length($line);
  }
}

sub chompM
{
  $_ =~ s/[\n]*$//;
}


sub TagAntDoc
{
  while (<INPUT>)
  {
    chompM;
    my $line = $_;
    if ($line =~ m{^>>.*/(\w+).html$})
    {
      my $name = $1;
     
      Tag($name, 1, 1);
    }
    $tags__current_file_position+=length($line);
  }
}

sub TagFlattenedEZ
{
  while (<INPUT>)
  {
    if (/^(\S+) \(.*\)$/)
    {
      my $name = $1;
      Tag($name, 0, 1);
      return;
    }
  }
}

sub TagEZ
{
  my($fn) = @_;
  if ($fn =~ m{/([^/]+)/([^/]+)\.ez$})
  {
    my $type = $1;
    my $name = $2;
    Tag($name, 0, 1);
  }
}


sub TagPythonHtml
{
  my($fn) = @_;
  while (<INPUT>)
  {
    if (m{<a name=".*?"><tt class="method">(.*?)</tt></a>}
    ||  m{<a name=".*?"><tt>(.*?)</tt></a>})
    {
      Tag($1, 1, 0);
    }
  }
}

sub TagC
{
  my $curlyBraceCnt=0;
  while (<INPUT>)
  {
    s/{\s*}//g;
   
    if ($__trace) {print "current class:$tags__classes[0]: $curlyBraceCnt, ", scalar(@tags__classes), "\t ||$_";}

    if (/^\s*namespace\b/)
    {
      if (!/{/)
      {
        <INPUT>;
      }
      next;
    }
    s/"(.*?)"/'"' . changeToBlanks($1) . '"'/eg;
    s/"(.*?)"/'"' . changeToBlanks($1) . '"'/eg;

    if (/^\s*#\s*define\s+(\w+)/)
    {
      Tag($1);
    }
    elsif (/\bclass\s+(\w+)\s*;/	# forward class
    || /^\s*#/			# preprocessor directive
    || /\bstruct\s+(\w+)\s*;/	# forward struct
    || /^\s*[\/*]/			# comment
    || /default:/
    || /public:/
    || /private:/
    || /protected:/)
    {
      ;
    }
    elsif (/\bclass\s+(\w+)\s*:.*\b(\w+)/)
    {
      Tag($1);
      PushClass($1);
      AddSubclass($2, $1);
    }
    elsif (/\bclass\s+(\w+)[\s{]*$/)
    {
      Tag($1);
      PushClass($1);
      AddSubclass("", $1);
    }
    elsif (/\bstruct\s+(\w+)[^;]*$/
    || /\benum\s+(\w+)/
    || /\bunion\s+(\w+)/)
    {
      Tag($1);
      # hack: treat enum's and unions like classes to
      # enable tagging enum values and union fields
      # (as if they were class data fields)
      PushClass($1);
    }
    elsif (/\bstruct[{\s]*$/
    || /\benum[{\s]*$/
    || /\bunion[{\s]*$/)
    {
      PushClass("-");	# anonymous struct, union or enum
    }
    elsif ($curlyBraceCnt <= scalar(@tags__classes))
    {
      if (/typedef.*\b(\w+)\s*\)\s*\(/		# function pointer, e.g., typedef B (V* WNDENUMPROC)(a,b);
      || /\btypedef\s.*\s(\w+)\s*;/)
      {
        Tag($1);
      }
      elsif (/^[^{;,()]*\b([_\w]+)::(~?[_\w]+)\s?\([^;]*$/)	# procedure declaration in a class, eg, cls::func()...
      {
        my($class, $func) = ($1, $2);
        PushClass($class);
        Tag($func);
        PopClass();
      }
      elsif
      (/^[^{;,()]*\b(~?[_\w]+)\s?\([^;]*$/	# procedure declaration
      || /(~?\w+)\s?\(.*{/		# inline procedure
      || /(\w+)\s*:[^:]/		# bit field
      || /(\w+)\s*[=;\[]/		# variable
      || /^typedef\s+\w+\s(\w+)/)
      {
        Tag($1);
      }
      #
      # hacks: catch comma-separated variables
      if (/^[^,\(]*\b(\w+)\s*,\s*/)
      {
        Tag($1);		# in "a, b, c": Tag("a")
        if (/^[^,\(]*\b\w+\s*,\s*(\w+)\s*,/)
        {
          Tag($1);	# in "a, b, c": Tag("b")
        }
      }
    }
    if (/\{/)
    {
      $curlyBraceCnt++;
    }
    if (/\}/)
    {
      $curlyBraceCnt--;
      if ($curlyBraceCnt < scalar(@tags__classes))
      {
	PopClass();
      }
    }
    $tags__current_file_position+=length($_);
  }
}

sub TagRuby
{
  print "TagRuby called\n" if $__trace;

  $tags__current_file_position=0;
  while (<INPUT>)
  {
    if (/^\sattr_accessor :(\w+)/
    || /^\s*def (\w+)/
    || /^\s*([A-Z]+) =/
    || /^\s*class (\w+)/)
    {
      Tag($1);
    }
    $tags__current_file_position+=length($_);
  }
}

sub TagPerlHtml
{
  Tag($_[0], 1);
}

sub TagWebGeneratorObjects
{
  while (<INPUT>)
  {
    if (/anchor (\w+)/
    or  /chunk (\w+)/)
    {
      Tag($1);
    }
    $tags__current_file_position+=length($_);
  }
}

sub TagHtmlAsManPage
{
  my $title="";
  while (<INPUT>)
  {
    $tags__current_file_position+=length($_);
    if (/<title>/i)
    {
      if (m{<TITLE>(\w+) \([A-Z][^<\n]+\)</TITLE>}i)
      {
	Tag($1);	# TradeStation doc, e.g., ~/work/ts/doc/html/PercentRankArray_function_.htm
      }

      last;
    }
  }
  my $current_class;
  my $current_classShortened;
  while (<INPUT>)
  {

    if ((/Class\s+(\S+)/)
    || (/Interface\s+(\S+)/))
    {
      $current_class = $1;
      Tag($current_class);
      if ($current_class =~ /\.(\w+)$/)
      {
	$current_classShortened = $1;
	Tag($current_classShortened);
      }
      $tags__current_file_position+=length($_);
      last;
    }
    $tags__current_file_position+=length($_);
  }
  while (<INPUT>)
  {
    if (/ extends .*>(.*)<\/a>/)
    {
      AddSubclass($1, $current_classShortened);
    }
    elsif (/public .* (\w+)\(.*(\)|,)\s*$/)
    {
      Tag($1);
    }
    $tags__current_file_position+=length($_);
  }
}

sub TagHtml
{
  TagHtmlAsManPage();

  $tags__current_file_position = 0;
  seek(INPUT, 0, 0) || die "seek failed";
  TagJavaScript();

  $tags__current_file_position = 0;
  seek(INPUT, 0, 0) || die "seek failed";
  TagWebGeneratorObjects();
}

sub TagJava
{
  my $curlyBraceCnt=0;
  my $current_class;
  my $inComment = 0;
  my $length = 0;
  my $package = "";

  while (<INPUT>)
  {
    my $line = $_;
    $tags__current_file_position+=$length;
    $length = length($line);

    $inComment and $line =~ s{.*?\*/}{$inComment = 0, ""}e;
    next if $inComment;

    $line =~ s{//.*}{};
    $line =~ s/\\"//g;
    $line =~ s/".*?"//g;
    $line =~ s{/\*.*?\*/}{}g;		# remove comments
    $line =~ s{/\*.*}{$inComment = 1, ""}eg;
    $line =~ s/\bthrows\s+\w+(\s*,\s*\w+)*//;

    if ($line =~ s/\bimplements\s+.*,\s*$//)
    {
      <INPUT>;	# swallow the next line, which contains names of interfaces which have been implemented -- we don't care
    }
    else
    {
      $line =~ s/\bimplements\s+.*//;
    }

    $_ = $line;

    if ($__trace) {print "current class:$tags__classes[0]: $curlyBraceCnt, ", scalar(@tags__classes), "\t ||$_";}

    if (/^\s*package\s+([\.\w]+)/)
    {
      $package = $1 . ".";
    }
    elsif ((/^\s*[\/*]/)			# comment
    || (/^\s*import\s+/)
    || (/^\s*implements\s+/))
    {
      ;
    }
    elsif (/\b(class|interface)\s+([\.\w]+)\s+extends\s+([\.\w]+)/)
    {
      $current_class = $2;
      my $base_class = $3;

      if ($package && $base_class =~ /\.$current_class$/)
      {
	# e.g., class EventObject extends java.util.EventObject
	$current_class = $package . $current_class;
      }
      Tag($current_class);
      PushClass($current_class);
      AddSubclass($base_class, $current_class);
    }
    elsif (/\bclass\s+([\.\w]+)/
    || /\binterface\s+([\.\w]+)/
    || /\bclass\s+([\.\w]+)\s+implements/)
    {
      $current_class = $1;
      Tag($current_class);
      PushClass($current_class);
      AddSubclass("", $current_class);
    }
    elsif ($curlyBraceCnt <= scalar(@tags__classes))
    {
      if (/^\s*new\s+.*/)
      {
	;
      }
      elsif
      (/^[^{;,]*\b(\w+)\s?\([^;]*$/	# procedure declaration
      || /(\w+)\s?\(.*{/		# inline procedure
      || /(\w+)\s*[=;]/)		# variable
      {
        my $item = $1;
        die "expected item to be non-null; from $line in $tags__raw_input_file_name:$tags__current_file_position" unless defined $item;
        if (!defined $current_class)
        {
          # e.g., $P4ROOT/Tools/devkit.sisyphus/sisyphus.prc.generator/data/sisyphus.prc.content/TemplateObjectAssert.java is a fragment:
          if ($tags__raw_input_file_name !~ m{/Template})	
          {
            warn "expected current_class to be non-null; at $line in $tags__raw_input_file_name:$tags__current_file_position; is this file a fragment?";
          }
          return;
        } 
	# don't tag constructors in java:
	if ($item ne $current_class)
	{
	  Tag($item);
	}
      }
      #
      # hacks: catch comma-separated variables
      if (/^[^,\(]*\b(\w+)\s*,\s*/)
      {
	Tag($1);		# in "a, b, c": Tag("a")
	if (/^[^,\(]*\b\w+\s*,\s*(\w+)\s*,/)
	{
	  Tag($1);	# in "a, b, c": Tag("b")
	}
      }
    }
    if (/\{/)
    {
      $curlyBraceCnt++;
    }
    if (/\}/)
    {
      $curlyBraceCnt--;
      if ($curlyBraceCnt < scalar(@tags__classes))
      {
	PopClass();
      }
    }
  }
}

sub TagPython
{
  my $current_class = undef;
  my $triplyQuoted = 0;
  my $length = 0;
  my $package = "";

  while (<INPUT>)
  {
    my $line = $_;
    $tags__current_file_position+=$length;
    $length = length($line);

    if ($triplyQuoted)
    {
      if ($line =~ m{"""})
      {
        $triplyQuoted = 0;
      }
      next;
    }
    elsif ($line =~ s{"""}{})
    {
      if ($line !~ m{"""})
      {
        $triplyQuoted = 1;
      }
      next;
    }

    $line =~ s{#.*}{};
    $line =~ s/\\"//g;
    $line =~ s/".*?"//g;

    if (/^\s*class\s+(\w+)\s*:/)
    {
      $current_class = $1;

      PopClass() if $current_class;

      Tag($current_class);
      PushClass($current_class);
      AddSubclass("", $current_class);
    }
    elsif (/^\s*class\s+([\.\w]+)\s*\(\s*([\.\w]+)\s*\)\s*:/)
    {
      $current_class = $1;
      my $base_class = $2;

      PopClass() if $current_class;

      Tag($current_class);
      PushClass($current_class);
      AddSubclass($base_class, $current_class);
    }
    elsif (/^def\s+(\w+)\s*\(.*\)\s*:/)
    {
      my $func = $1;
      if ($current_class)
      {
        $current_class = undef;
        PopClass();
      }
      Tag($func);
    }
    elsif (/\s+def\s+(\w+)\s*\(.*\)\s*:/)
    {
      my $f = $1;
      Tag($f);
    }
  }
}

sub TagJavaScriptLine
{
  if (/^\s*function\s+(\w+)\s*\(/
  || /^var\s+(\w+)\s*/
  || /\.(\w+)\s*=\s*function\s*\(/)
  {
    Tag($1);
  }
  elsif (/(\w+).prototype.(\w+)\s*=/)
  {
    PushClass($1);
    Tag($2);
  }
}

sub TagJavaScript
{
  while (<INPUT>)
  {
    #if ($__trace) {print "current class:$tags__classes[0]: ", scalar(@tags__classes), "\t ||$_";}

    TagJavaScriptLine();
    $tags__current_file_position+=length($_);
  }
}

sub TagLisp
{
  print "TagLisp called\n" if $__trace;

  $tags__current_file_position=0;
  while (<INPUT>)
  {
    if (/^\(setq\s+([^\s]+)/
    || /^\(def\w+\s+([^\s(]+)/
    || /^\(n-host-file-set\s+([^\s]+)/)
    {
      Tag($1);
    }
    $tags__current_file_position+=length($_);
  }
}

sub TagFlattenedPerlDoc
{
  $tags__current_file_position=0;
  while (<INPUT>)
  {
    if (m{^([a-z]\w*)})
    {
      Tag($1);
    }
    elsif (/^    -(\w)  /)		# should I have limited this to ($tags__raw_input_file_name =~ m{perlfunc.html.txt$})?
    {
      Tag($1, 1);
    }
    $tags__current_file_position+=length($_);
  }
}

sub TagTags
{
  $tags__current_file_position=0;
  while (<INPUT>)
  {
    if (/^([^:]*):/)
    {
      Tag($1);
    }
    $tags__current_file_position+=length($_);
  }
}

sub TagPerl
{
  $tags__current_file_position=0;
  while (<INPUT>)
  {
    if (/^sub\s+(\w+)/
    or  /^my\s+([@%\$]\w+)/)
    {
      Tag($1);
    }
    elsif (/^package\s+([:\w]+)/)
    {
      my $current_class = $1;
      Tag($current_class);
      PushClass($current_class);
      AddSubclass("", $current_class);
    }
    elsif (/\bISA\s*=\s*qw\(([:\w]+)\);/)
    {
      my $parent = $1;
      if (scalar(@tags__classes) > 0)
      {
        my $child = $tags__classes[0];
        AddSubclass($parent, $child);
      }
    }
    $tags__current_file_position+=length($_);
  }
}

sub TagAnt
{
  $tags__current_file_position=0;
  
  my $className = $tags__raw_input_file_basename;
  $className =~ s/\..*//;
  
  PushClass($className);
  
  while (<INPUT>)
  {
    if (/^\s*<(property|target|macrodef|presetdef)\s*$/)
    {
      $tags__current_file_position+=length($_);
      $_ = <INPUT>;
      if (/^\s*name\s*=\s*"([-\w\.]+)"/)
      {
        Tag($1);
      }
    }
    elsif (/^\s*<(property|target|macrodef|presetdef)\s*name\s*=\s*"([-\w\.]+)"/)
    {
      Tag($2);
    }
    $tags__current_file_position+=length($_);
  }
  PopClass();
}

sub TagEla
{
  # /e.t$/ => templates
}

sub TagMan
{
  my $title="";
  while (<INPUT>)
  {
    $tags__current_file_position+=length($_);
    if (/^NAME/)
    {
      last;
    }
  }
  while (<INPUT>)
  {
    $title = $title . $_;
    if (/[-,]$/)
    {
      next;
    }
    last;
  }
  if ($__trace) {print "raw title:$title:\n";}

  # rejoin tokens split at line ends:
  $title =~ s/-\n\s+//;

  # join the title lines
  $title =~ s/\n/ /;

  if ($__trace) {print "dehyphenated title:$title:\n";}
 
  if ($title =~ /(.*)\s-\s.*/)
  {
    $title = $1;
  }
  if ($__trace) {print "truncated title:$title:\n";}

  my @tokens = split(/,\s+/, $title);
 
  if ($__trace) {print "raw tokens[0]:$tokens[0]:\n";}
  if ($__trace) {print "raw tokens[$#tokens]:$tokens[$#tokens]:\n";}

  if (scalar(@tokens) > 0)
  {
    # fix up the first token: remove leading blanks:
    if ($tokens[0] =~ /^\s+(\S+)\b/)
    {
      $tokens[0] = $1;
    }

    # fix up the last token: remove trailing garbage:
    $tokens[$#tokens] =~ s/^(\S+)\s/$1/;

    my $token;
    foreach $token (@tokens)
    {
      Tag($token);
    }
  }
}

sub GenerateEMTags
{
  my($extCodeline) = @_;
  my $tagsFileName = $extCodeline . "/em.tag";
  my $tags = new IO::File("> $tagsFileName") or utility::Die "could not open $tagsFileName: $!";

  my $resourcesFileName = $extCodeline . "/largesoft/i18n/ExtensityResources.java";
  my $resources = new IO::File("< $resourcesFileName");

  if (!defined $resources or !$resources)
  {
    print STDERR "parse.pl: could not open $resourcesFileName.  Continuing...\n";
    return;
  }


  my $messagesFileName = $extCodeline . "/largesoft/i18n/StaticMessageKey.java";
  my $messages = new IO::File("< $messagesFileName") or utility::Die "could not open $messagesFileName: $!";

  my %messageVariable = ();
  while (<$resources>)
  {
    if (/StaticMessageKey.([^,]*),\s*"([^"]*)"/)
    {
      #c:\DEV\Beefcakebeta/largesoft/i18n/ExtensityResources.java:854:             {StaticMessageKey.Message924,   "Guest"},
      $messageVariable{$1} = $2;
      #print "settting $1: $messageVariable{$1}\n";
    }
  }
  while (<$messages>)
  {
    if (/String\s+(\w+)\s*=\s*"@*([^@"]*)"/)
    {
      # $ext/largesoft/i18n/StaticMessageKey.java:930:  public static final String Message924 = "@@EM924";
      my($mVar, $emS) = ($1, $2);
      if (defined $messageVariable{$mVar})
      {
        #print "$emS:$mVar: $messageVariable{$mVar}\n";
        print $tags "$emS: $messageVariable{$mVar}\n";
      }
    }
  }


  $tags->close();
  $resources->close();
  $messages->close();
}

sub ExpandEnvVars
{
  my($s) = @_;
  $s =~ s/\$([\w_]+)/$ENV{"$1"}/eg;
  $s =~ s/\${([\w_]+)}/$ENV{"$1"}/eg;

  return $s;
}

Init();

if ($ENV{'EXT'} and -d $ENV{'EXT'} and -d "$ENV{'EXT'}/largesoft")
{
  GenerateEMTags($ENV{'EXT'});
}

while (<STDIN>)
{
  chomp;
  $tags__raw_input_file_name = $_;
  $tags__raw_input_file_name =~ s/$//;
  
  $tags__raw_input_file_basename = $tags__raw_input_file_name;
  $tags__raw_input_file_basename =~ s{.*/}{};

  my $fn = ExpandEnvVars($tags__raw_input_file_name);

  print TAGS ",", $tags__raw_input_file_name, "\n";

  print "Got $fn\n" if $__trace;

  if (!open(INPUT, $fn))
  {
    print "Could not open $fn\n" if $__trace;
  }
  else
  {
    $tags__current_file_position=1; # emacs goto-char is 1-based
    $tags__file_name_echoed_to_classes=0;
    @tags__classes = ();

    $_ = $tags__raw_input_file_name;
    if (/\/antfunc.html.txt$/)	{TagAntDoc();}
    elsif (/.asp$/)		{TagJavaScript();}
    elsif (/.c$/)		{TagC();}
    elsif (/.cgi$/)		{TagPerl();}
    elsif (/.cpp$/)		{TagC();}
    elsif (/.el$/)		{TagLisp();}
    elsif (/.ez$/)		{TagEZ($tags__raw_input_file_name);}
    elsif (/.h$/)		{TagC();}
    elsif (m{/nmanual/pod/perlfunc/(\w+).html$})	{TagPerlHtml($1);}

    #elsif (m{/Python/Doc/lib/.*html$}i)	{TagPythonHtml($tags__raw_input_file_name);}
    #elsif (/.html?$/)          {TagHtml();}    	# class browser confused by extra hits so I'm not tagging anymore
    elsif (/.html?$/)           {TagJavaScript();}	# get js bits, if there are any
    elsif (/.html?.txt$/)	{TagFlattenedEZ();}
    elsif (/.java?$/)		{TagJava();}
    elsif (/.js$/)		{TagJavaScript();}
    elsif (/.man$/)		{TagMan();}
    elsif (/mysql\/Docs\/manual.txt$/)		{TagMySqlDoc();}
    elsif (/.perl$/)		{TagPerl();}
    elsif (/perl.*.html.txt$/)	{TagFlattenedPerlDoc();}
    elsif (/.pl$/)		{TagPerl();}
    elsif (/.pm$/)		{TagPerl();}
    elsif (/.py$/)		{TagPython();}
    elsif (/.rb$/)		{TagRuby();}
    elsif (/.tag$/)		{TagTags();}
    elsif (/.xml$/)		{TagAnt();}
    elsif (m{/include/.*.h$})	{TagC();}
    close(INPUT);
  }
  $tags__file_ordinal++;
}

Cleanup();

# xtest with: cd $HOME/work/emacs/tags/;cat k.list|perl -w parse.pl -v -n 1 -o k; echo k.tags; cat k.tags; # echo k.classes; cat k.classes
# xtest with: cd $HOME/work/emacs/tags/;cat k.list|perl -w parse.pl -n 1 -o k; echo k.tags; cat k.tags; echo k.classes; cat k.classesrr