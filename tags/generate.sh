:
category=$1

date

if [ -z "$category" ]; then
        category=main
fi


initial_file_count=$2
if [ -n "$initial_file_count" ]; then
        initial_file_count="-n $initial_file_count"
fi


echo $path
Init()
{
        outputCategory=main
        out=$NELSON_HOME/tmp/tags
        mkdir -p $out
        flist=$out/main.flist
        if [ -z "$category" ]; then
                category="main";
        fi

        cd       $dp/emacs/tags

        if [ -d "$ext" ]; then
                touch $ext/em.tag	# hack to support resolving EM strings in extensity codeline's tag database -- see parse.pl
        fi
}

UncompressLisp()
{
        lispDir="$1"
        find $lispDir -name '*.el.gz' |
        while read fn; do
                base=`echo $fn|sed -e 's/.gz$//'`
                if [ ! -f "$base" ]; then
                        echo decompressing $fn...  >&2
                        cp -p $fn $fn.old
                        gzip -d $fn
                fi 
        done
}

GenerateListOfFiles()
{
        category=$1
        case "$category" in
                new)
                        flist=$out/$category.flist;
                        outputCategory=$category;
                ;;
                lisp)
                        (
                        find $dp/emacs/lisp -name '*.el' -print
                        if [ -n "$CYGWIN_EMACS_LISP" ]; then
                                #if [ ! -f "$CYGWIN_EMACS_LISP/simple.el" ]; then
                                if [ ! -f "$CYGWIN_EMACS_LISP/progmodes/ruby-mode.el" ]; then
                                        UncompressLisp "$CYGWIN_EMACS_LISP"
                                fi
                                find $CYGWIN_EMACS_LISP  -name '*.el' -print
                                find `dirname $CYGWIN_EMACS_LISP`/site-lisp  -name '*.el' -print
                        fi
                        ) > $flist
                ;;
                main)
                        GenerateListOfFiles lisp
                        if [ -d $HOME/work/monitor_ui ]; then
                                find $HOME/work/monitor_ui -name '*.js' -print >> $flist
                                find $HOME/work/monitor_ui -name '*.html' -print >> $flist
                        fi
                        if [ -d $DROP/channel ]; then
                                find $DROP/channel -name '*.rb' -print >> $flist
                        fi
                ;;
                *)
                        sh -x $dp/emacs/tags/list_files_to_be_tagged.ksh > $flist
                ;;
        esac
}

GenerateTags()
{
        cat $flist|perl -w parse.pl $initial_file_count -o $out/$outputCategory
        
        perl -w post_parse.pl $out/main.classes > $out/main.classes.pre_post_parse
        sed -i -e 's;/home/nelsons/;$HOME/;' $out/main.tags
}

Init
GenerateListOfFiles $category
GenerateTags
#MassageTags                    disable because this complicates purging the tags database of obsolete info
date

exit
sh -x $dp/emacs/tags/generate.sh &
exit
( $dp/bin/find.all; sh -x $dp/emacs/tags/generate.sh ; date) &
exit
 sh -x $dp/emacs/tags/generate.sh ; date &
exit
(sleep 4000;  $dp/bin/find.all; sh -x $dp/emacs/tags/generate.sh teacher; date) &
exit
sh $dp/emacs/tags/generate.sh