#!/bin/sh

# input: 1 fn
fn1=`full_path $1`
dest=$DROP/data/put


ForAllDestinationHosts()
{
        fn=$1

        case `hostname` in
                DC1)
                        allHosts=vms
                ;;
                vms)
                        allHosts=DC1
                ;;
                lt)
                        allHosts=g0
                ;;
                *)
                        allHosts=`cat $dest`
                ;;
        esac

        if [ -z "$allHosts" ]; then
                allHosts=wonkaha.us.oracle.com
        fi
        for host in $allHosts; do
                echo "$host:$fn"
        done
}

if [ -n "$DEST" ]; then
        total_dest=$DEST
else
        total_dest=`cat $dest`
fi
case "$total_dest" in
        G)
                export DEST=g0
                put $*
                fn1=`full_path "$fn1"  | sed -e "s;$HOME/;;"`
                
                echo "sshe $DEST put $fn1"
                sshe       $DEST put $fn1
                
                exit
        ;;
        work.daily*|work.weekly*)
                fn2=`sed -e "s;$DROP;$HOME/$total_dest;" <<< $fn1`
                d=`dirname "$fn2"`
                if [ ! -d "$d" ]; then
                        err $0: warning, $0 cannot find $d, so resetting dest to g0
                        echo g0 > $dest
                        $0 $*
                        exit
                fi
        ;;
        *)
                case `hostname` in
                        DC1)
                                #fn2=`sed -e 's;/cygdrive/c;//vms/c$;' <<< $fn1`
                                fn2=`sed -e 's;/cygdrive/c;/cygdrive/n;' <<< $fn1`
                                if [ ! -d "/cygdrive/n" ]; then
                                        if ! cmd /c net use n: '\\vms\c$' Nelson1 /user:nelson; then
                                                err "$0: cmd /c net use n: '\\vms\c$' Nelson1 /user:nelson failed, exiting..."
                                                exit 1
                                        fi
                                fi
                        ;;
                        vms)
                                #fn2=`sed -e 's;/cygdrive/c;//DC1/c$;' <<< $fn1`
                                fn2=`sed -e 's;/cygdrive/c;/cygdrive/n;' <<< $fn1`
                                if [ ! -d "/cygdrive/n" ]; then
                                        if ! cmd /c net use n: '\\DC1\c$' Nelson1 /user:nelson; then
                                                err "$0: cmd /c net use n: '\\DC1\c$' Nelson1 /user:nelson failed, exiting..."
                                                exit 1
                                        fi
                                fi
                        ;;
                        ip-*|*amazonaws.com|gce*)
                                # we're on AWS
                                case "$fn1" in
                                        $DROP/adyn/*)
                                                
                                case "$fn1" in
                                        $DROP/adyn/*)
                                                fn1=`echo $fn1|sed -e "s;$DROP/adyn/;/var/www/adyn.dev/;"`
                                                fn2=`echo $fn1|sed -e "s;dev/;prod/;"`
                                        ;;
                                        /var/www/adyn.dev/*)
                                                fn2=`echo $fn1|sed -e "s;dev/;prod/;"`
                                        ;;
                                        /var/www/adyn.prod/*)
                                                fn2=`echo $fn1|sed -e "s;prod/;dev/;"`
                                        ;;
                                        */root/*)
                                                fn2=`echo $fn1 | sed -e 's/root/ec2-user/' -e 's;^/ec2-user;/home/ec2-user;'`
                                                post_put_chown_to=ec2-user
                                        ;;
                                        */ec2-user/*)
                                                fn2=`echo $fn1 | sed -e 's/ec2-user/root/'`
                                                post_put_chown_to=root
                                        ;;
                                        *)
                                                err "$0: not sure what to do w/ $fn1, where to copy to?"
                                                exit 1
                                        ;;
                                esac
                        ;;
                        *)
                                if [ ! -f $dest ]; then
                                        touch $dest
                                fi
                                case "$fn1" in
                                        $HOME/*)
                                                fn2=`echo $fn1|sed -e "s;$HOME/;;"`
                                        ;;
                                        $DISCOVERY/*)
                                                fn2=`echo $fn1|sed -e "s;$DISCOVERY/;wrk/git/discovery/;"`
                                        ;;
                                        *)
                                                err "$0: error: unrecognized path fn1 "$fn1""
                                                exit 1
                       ;;
                                esac
                                fn2=`ForAllDestinationHosts "$fn2"`
                        ;;
                esac
        ;;
esac
