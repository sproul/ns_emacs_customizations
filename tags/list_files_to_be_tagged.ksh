:
# put together the list of files for the tags generation.
# This script assumes that find.all has already run.
#

temporary=$tmp/find_

F()
{
        if [ -d $1 ]; then
                find $1 -print
        fi
}


Get_overrides_list_fn()
{
        if [ -d "c:/" ]; then
                echo "c:/init/taggable_dirs.txt"
        else
                echo __nop__
        fi
}


FindFiles()
{
        override_for_this_machine=`Get_overrides_list_fn`
        if [ -f $override_for_this_machine ]; then
                cat $override_for_this_machine|grep -v '#'|
                while [ 1 ]; do
                        read fn
                        if [ -z "$fn" ]; then
                                break
                        fi
                        F `eval "echo $fn"`	# eval is there to handle vars
                done
        else
                case `hostname` in
                        *)
                                #F $P4ROOT/Tools/selenium/javascript -print
                                #F $P4ROOT/Dev/selenium-rc_svn/trunk
                                #F $P4ROOT/Common/xdk -print
                                #F $P4ROOT/Tools -print
                                #F $HOME/downloads/j2sdk1.4.2_06/src -print
                                #F $P4ROOT/Common/xpunit -print
                                #F $P4ROOT/Common/openkernel/main -print
                                #F $P4ROOT/P2/portalproduct/main -print
                                #F $P4ROOT/P2/portalserver/main -print
                                #F $P4ROOT/P2/portaltests/main -print
                                #F $P4ROOT/P2/portalui/main -print
                                #F $P4ROOT/P2/portaluitests/main -print
                                #F $P4ROOT/P2/portalvm/main -print
                                #F $NELSON_HOME/work/doc -name '*.html.txt' -print
                                
                                if [ -n "$CYGWIN_EMACS_LISP" ]; then
                                        F $CYGWIN_EMACS_LISP -naem '*.el'
                                fi
                                
                                #F $HOME/work/monitor_ui/server/html -type f
                                F $dp/emacs/lisp -name '*.el' -print
                                #F $P4ROOT/Tools/build/buildcommon/main -print | grep -v /scratch/
                                #F c:/XEmacs/XEmacs-21.4.18/lisp -name '*.el' -print
                                #F $NELSON_HOME/man -print
                        ;;
                esac
        fi
}

Prune()
{
        # retain filenames with interesting suffixes
        sed -n	\
        -e '/\/teacher\/sample\//d' 	\
        -e '/\/javax\/resource\/cci/d'	\
        -e '/\/xpunitTemp\//d'	\
        -e '/\.el$/p' 	\
        -e '/src\/sunw\/io\/Serializable.java/d'	\
        -e '/\/tester\//d' 	\
        -e '/\.cpp$/p' 	\
        -e '/\.h$/p' 	\
        -e '/\.i$/p' 	\
        -e '/\.ez$/p' 	\
        -e '/\.cgi$/p' 	\
        -e '/\.py$/p' 	\
        -e '/\.tcl$/p' 	\
        -e '/\.faq$/p' 	\
        -e '/\.htm.txt$/p' 	\
        -e '/\manual.txt$/p' 	\
        -e '/\.htm$/p' 	\
        -e '/\.html$/p' 	\
        -e '/\__shared_c.js$/d' 	\
        -e '/\__shared_s.js$/d' 	\
        -e '/html\/vt.js$/d' 	\
        -e '/html\/new.js$/d' 	\
        -e '/\.html.txt$/p' 	\
        -e '/\/update\/.*.java$/d' 	\
        -e '/\.jav$/p' 	\
        -e '/\.java$/p' 	\
        -e '/\.js$/p' 	\
        -e '/\.asp$/p' 	\
        -e '/\.man$/p'	\
        -e '/\.perl$/p' 	\
        -e '/\.pl$/p'	\
        -e '/\.pm$/p' 	\
        -e '/\.xml$/p' 	\
        -e '/\.tag$/p'|sed	\
        -e /\\/qa\\/fixes\\/largesoft\\//d	\
        -e /emacs\\/tags\\/k\\./d	\
        -e /\\/lisp\\./d	\
        -e /\\/perl\\./d	\
        -e /\\/samples\\./d	\
        -e /\\/sample\\./d	\
        -e /mks.*perl/d	\
        -e /starters_for_generated_files/d	\
        -e /backup\\//d	\
        -e /\\/can\\//d	\
        -e /\\/ORANT\\//d	\
        -e /\\/old\./d	\
        -e /\\/post_install_diskette\\//d	\
        -e /Netscape\\/SuiteSpot/d	\
        -e /ext_web_root\\/pre_/d	\
        -e /Program\\/NetHelp\\/Netscape_/d	\
        -e /tmp\\//d	\
        -e /largesoft.*\\.htm/d	\
        -e /c:\\/WINNT/d	\
        -e /backup\\./d	\
        -e /\\.o\\./d	\
        -e /whitelight.stuff/d	\
        -e /verify/d	\
        -e /sounds/d	\
        -e /\\/can\\//d	\
        -e /c:\\/old\\//d	\
        -e /emacs.script/d	\
        -e '/pso\/standard\/imports\/Bkg/d'	\
        -e '/pso\/standard\/imports\/ApplParms/d'	\
        -e /gnuwin32/d	\
        -e /\\/2html\\//d	\
        -e '/faq.*.html/d'	| sort
}

MakeNamesValidOnBothUnixAndWindows()
{
        if [ -x /bin/sed ]; then
                sed=/bin/sed
        elif [ -d "c:/" ]; then
                sed=sed.exe
        else
                sed=sed
        fi
        if [ -z "$P4ROOT" ]; then
                P4ROOT=__P4ROOT__unset__
        fi
       
        $sed -e "s;$P4ROOT;\$P4ROOT;" -e "s;$NELSON_HOME/man;\$NELSON_HOME/man;" -e "s;$NELSON_HOME/work;\$NELSON_HOME/work;" -e "s;$NELSON_HOME/downloads;\$NELSON_HOME/downloads;" -e "s;$HOME;\$HOME;"
}

FindFiles $* | Prune | MakeNamesValidOnBothUnixAndWindows

exit
sh -x $HOME/work/emacs/tags/list_files_to_be_tagged.ksh
exit
sh -x $HOME/work/emacs/tags/list_files_to_be_tagged.ksh > k; grep event_horiz k | wc
