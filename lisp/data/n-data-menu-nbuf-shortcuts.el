(setq n-data-menu-nbuf-shortcuts-common
      (list
       ;; ./AppServer/config/cells/p69001p3/nodes/p69001p3/servers/server1/server.xml
       (cons ?: "$dp/data/HOSTS")
       (cons ?/ "$dp/doc/sensu.todo")
       (cons ?* "$dp/data/ahk_abc")
       (cons ?0 "$dp/home/.profile")
       (cons ?! "$dp/init/setup_unix")
       (cons ?) "$dp/cloud/lm/init_vm_on_boot_main.sh")
      (cons ?7 "$dp/doc/sensu.todo")
      (cons ?8 "$dp/doc/facts/ruby2.facts")
      (cons ?; (list "first_file_that_exists"
            "c:/app/Administrator/product/11.1.0/client_1/network/admin/tnsnames.ora"
            "c:/app/Administrator/product/11.1.0/client_1/network/admin/tnsnames.ora"
            )
      )
(cons ?K "$dp/bin/AutoHotkey/tmp.ahk")
(cons ?z "$dp/doc/facts/")
(cons ?Z "$dp/bin/AutoHotkey/eclipse_z_kill_all_and_launch.ahk")
(cons ?4 "$dp/doc/facts/j4.facts")
(cons ?9 (list
          ""
          (cons ?a "$dp/bin/perl/accounts.pl")
          (cons ?c (if (n-file-exists-p "/home/$USERNAME/.ssh/config")
                       "/home/$USERNAME/.ssh/config"
                     "$HOME/.ssh/config"
                     )
                )
          (cons ?h "$dp/data/h.17")
          (cons ?j "$dp/sensu/plugins/jvm_proc_limits.sh")
          (cons ?0 "$dp/data/b.10")
          (cons ?1 "$dp/data/b.11")
          (cons ?2 "$dp/data/b.12")
          (cons ?3 "$dp/data/b.13")
          (cons ?4 "$dp/data/b.14")
          (cons ?5 "$dp/data/b.15")
          (cons ?6 "$dp/data/b.16")
          (cons ?7 "$dp/data/b.17")
          (cons ?8 "$dp/data/b.18")
          (cons ?9 "$dp/data/b.19")
          (cons ?d "$dp/data/b.d")
          (cons ?I "/net/slc02qcv/scratch/nsproul/sensu/client_install.sh")
          (cons ?e "$dp/bin/sensu.client.all.eval")
          (cons ?i "$dp/bin/sensu/client_install.sh")
          (cons ?s "$dp/bin/sensu.op")
          )
      )
)
)
;;)
(setq n-data-menu-nbuf-shortcuts_p4adebridge
      (append
       n-data-menu-nbuf-shortcuts-common
       (list
        (cons ?g "$P4ROOT/Tools/cm/portlets/p42ade/prod/scripts/get-and-sum-build-v2.sh")
        (cons ?i "$P4ROOT/Tools/cm/portlets/p42ade/prod/scripts/promotebuild-init")
        (cons ?l "$P4ROOT/Tools/cm/portlets/p42ade/LS")
        (cons ?m "$P4ROOT/Tools/cm/portlets/p42ade/prod/scripts/batch-promote-p4-cl-to-ade-label")
        (cons ?M "$P4ROOT/Tools/cm/portlets/p42ade/main/scripts/promote-pagelet-p4-cl-to-ade-label")
        (cons ?t "$dp/bin/p42ade.can")
        )
       )
      )
(setq n-data-menu-nbuf-shortcuts_guide1209
      (append
       n-data-menu-nbuf-shortcuts-common
       (list
        (cons ?l "$dp/house/rental/guide/links")
        (cons ?m "$dp/house/rental/guide/midnight")
        (cons ?s "$dp/house/rental/guide/generate.sh")
        (cons ?S "$dp/sproul.github.io/guide1209/stickers.html")
        )
       )
      )
(setq n-data-menu-nbuf-shortcuts_json_flattener
      (append
       n-data-menu-nbuf-shortcuts-common
       (list
        (cons ?F "$dp/config_data_management/ms/json_flattener.rb")
        (cons ?f "$dp/config_data_management/ms/mongo_json_holder.rb")
        (cons ?m "$dp/config_data_management/ms/midnight.config_mongo_json_flattener")
        (cons ?M "$dp/config_data_management/ms/midnight.json_flattener")
        )
       )
      )

(setq n-data-menu-nbuf-shortcuts_mrc
      (append
       n-data-menu-nbuf-shortcuts-common
       (list
        (cons ?A "$mrc/bin/mrc.all")
        (cons ?a "$mrc/ucminjection/src/main/java/oracle/fmw/platform/maveninjection/FolderContent.java.old")
        (cons ?b "$mrc/bin/mrc.stage")
        (cons ?B "$mrc/bin/mrc.ucm")
        (cons ?c "/cygdrive/c/scratch/acmsmtv2074_us_oracle_com_16200__dav_content_idcplg")
        (cons ?C "/cygdrive/c/scratch/acmsmtv1045_us_oracle_com_16200__dav_content_idcplg")
        (cons ?i "$mrc/bin/mrc.inc")
        (cons ?I "$mrc/ucminjection/src/main/java/oracle/fmw/platform/maveninjection/InjectionController.java")
        (cons ?l (list
                  ""
                  (cons ?a "$DOWNLOADS/artifactory-oss-4.8.0/logs/artifactory.log")
                  (cons ?o "$mrc/ucminjection/src/main/resources/log4j.properties")
                  (cons ?O "/cygdrive/c/tmp/log.inject.txt")
                  (cons ?h (list
                            ""
                            (cons ?0 "/cygdrive/c/scratch/mavrepo/SOA.12.2.1.0.0/repositories/LS")
                            (cons ?1 "/cygdrive/c/scratch/mavrepo/SOA.12.2.1.1/repositories/LS")
                            )
                        )
                  (cons ?S (list
                            ""
                            (cons ?0 "/cygdrive/c/scratch/mavrepo/stagedRepo.SOA.12.2.1.0.0/repositories/ext-release-local/LS")
                            (cons ?1 "/cygdrive/c/scratch/mavrepo/stagedRepo.SOA.12.2.1.1/repositories/ext-release-local/LS")
                            )
                        )
                  (cons ?s "$dp/public-maven-repo-master/LS")
                  )
              )
        (cons ?M "$mrc/bin/mrc.ucm.multiprocess_upload")
        (cons ?r "$mrc/rvw")
        (cons ?R "$mrc/bin/mrc.roll_call.upload")
        (cons ?T "$mrc/bin/mrc.ucm.test")
        (cons ?s "$mrc/system.properties.src")
        (cons ?S "$HOME/system.properties.12.2.1.1")
        (cons ?u "$mrc/ucmprovider/src/main/java/oracle/fmw/platform/mavenfactory/filesystem/UCMPrimitives.java")
        )
       )
      )
(setq n-data-menu-nbuf-shortcuts_mrc_LSs n-data-menu-nbuf-shortcuts_mrc)

(setq n-data-menu-nbuf-shortcuts_faiza
      (append
       n-data-menu-nbuf-shortcuts-common
       (list
        (cons ?c "/etc/fmw_configuration_conf/config.properties")
        (cons ?C "/etc/mongod.conf")
        (cons ?d "/data/db")            ;; new mongo db location
        (cons ?D "/var/lib/mongo")      ;; old mongo db location
        (cons ?i "$dp/bin/faiza.init.sh")
        (cons ?l (if (n-file-exists-p "$CATALINA_LOG") "$CATALINA_LOG" "$CATALINA_HOME/logs/catalina.out"))
        (cons ?m "/var/log/mongodb/mongod.log")
        (cons ?s "$dp/bin/faiza.init")
        (cons ?w "$CATALINA_HOME/webapps/configuration")
        )
       )
      )
(setq n-data-menu-nbuf-shortcuts_lmbin
      (append
       n-data-menu-nbuf-shortcuts-common
       (list
	(cons ?c "$HOME/work/lm/bin/lm_update_classes_and_run_under_release.sh")
        ;;(cons ?e "/opt/apache2/logs/2010/06/")  ;; snickers
        (cons ?e "/opt/apache/httpd/logs/2010/06/") ;; wonkaha
        (cons ?j "$P4ROOT/Tools/SkyNet/vmautomation/labmanager3/src/scripts2/LM_ESX_servers_apply_ajax.js")
        (cons ?u "$P4ROOT/Tools/SkyNet/vmautomation/labmanager3/src/scripts2/u.js")
        )
       )
      )
(setq n-data-menu-nbuf-shortcuts_spree
      (append
       n-data-menu-nbuf-shortcuts-common
       (list
        (cons ?0 "/cygdrive/c/downloads/frey/t.sh")
        (cons ?d "$dp/rideaux/bin/db")
        (cons ?D "$R/db/development.sqlite3.out")
        (cons ?l "$R/log/fastdev.log")
        (cons ?i "$dp/rideaux/bin/spree.image_upload")
                                        ;(cons ?I "$dp/bin/spree.init")
        (cons ?I "$R/public/assets/products/")
        (cons ?R "$dp/rideaux/ori_data.rb")
        (cons ?r "$RAILS_ROOT/script/rideaux/ori_data.rb")
        (cons ?s "$dp/bin/s")
        (cons ?T "$TMP/images_todo")
        (cons ?y "$dp/rideaux/ori_data.yaml")
        (cons ?Y"$dp/rideaux/ori_data2.yaml")
        )
       )
      )
(setq n-data-menu-nbuf-shortcuts_monitor
      (append
       n-data-menu-nbuf-shortcuts-common
       (list
        (cons ?O "/tmp/cron_mon.summary.out")
        (cons ?O "/tmp/monitor_summary.out")
        (cons ?l "/tmp/monitor_logs/log")
        (cons ?L "/tmp/cron_mon.normal.out")
        (cons ?a "$HOME/work/monitor_ui/server/data/adc00jcu/apps.dat")
        (cons ?A "$HOME/work/monitor/data/adc00jcu/apps.dat")
        ;;(cons ?A "$P4ROOT/Tools/monitor_ui/server/data/adc00jcu/apps.dat")
        (cons ?c "$P4ROOT/Tools/monitor/cron.sh")
        (cons ?d "$P4ROOT/Tools/monitor/deploy.sh")
        (cons ?m "$P4ROOT/Tools/monitor/monitor.pl")
        (cons ?t "$P4ROOT/Tools/monitor/tests.sh")
        (cons ?T "$P4ROOT/Tools/monitor/midnight.tests")
        (cons ?C "$HOME/work/monitor/cron.sh")
        (cons ?D "$HOME/work/monitor/deploy.sh")
        (cons ?M "$HOME/work/monitor/monitor.pl")
        (cons ?T "$HOME/work/monitor/tests.sh")
        )
       )
      )
(setq n-data-menu-nbuf-shortcuts_monitor_ui
      (append
       n-data-menu-nbuf-shortcuts-common
       (if (n-file-exists-p "$P4ROOT/Tools/monitor/data/adc00jcu/apps.dat")
           (list
            (cons ?a "$P4ROOT/Tools/monitor_ui/server/data/wonkaha.devnet.plumtree.com/apps.dat")
            (cons ?A "$dp/p4/Tools/monitor_ui/server/data/adc00jcu/apps.dat")
            (cons ?d "$dp/p4/Tools/monitor_ui/deploy.sh")
            (cons ?f "$P4ROOT/Tools/monitor_ui/server/fhash.rb")
            (cons ?g "$P4ROOT/Tools/monitor_ui/server/data/adc00jcu/apps.dat")
            (cons ?h "$P4ROOT/Tools/monitor_ui/server/monitor.html")
            (cons ?j "$P4ROOT/Tools/monitor_ui/server/html/scripts/ui.js")
            (cons ?m "$P4ROOT/Tools/monitor_ui/server/midnight")
            (cons ?M "$P4ROOT/Tools/monitor_ui/server/midnight.ruby_unit")
            (cons ?p "$P4ROOT/Tools/monitor_ui/server/phash.rb")
            (cons ?s "$P4ROOT/Tools/monitor_ui/server/start_monitor_ui_server.sh")
            (cons ?t "$P4ROOT/Tools/monitor_ui/server/test_web.sh")
            (cons ?T "$P4ROOT/Tools/monitor_ui/server/test_hash.rb")
            (cons ?w "$P4ROOT/Tools/monitor_ui/server/web_hash.rb")
            )
         (list
          (cons ?a "$HOME/work/monitor_cron/data/adc00jcu/apps.dat")
          (cons ?A "$HOME/work/monitor_ui/server/data/adc00jcu/apps.dat")
          (cons ?f "$HOME/work/monitor_ui/server/fhash.rb")
          (cons ?g "$HOME/work/monitor_ui/server/data/adc00jcu/apps.dat")
          (cons ?h "$HOME/work/monitor_ui/server/monitor.html")
          (cons ?j "$HOME/work/monitor_ui/server/html/scripts/ui.js")
          (cons ?m "$HOME/work/monitor_ui/server/midnight")
          (cons ?M "$HOME/work/monitor_ui/server/midnight.ruby_unit")
          (cons ?p "$HOME/work/monitor_ui/server/phash.rb")
          (cons ?s "$HOME/work/monitor_ui/server/start_monitor_ui_server.sh")
          (cons ?t "$HOME/work/monitor_ui/server/test_web.sh")
          (cons ?T "$HOME/work/monitor_ui/server/test_hash.rb")
          (cons ?w "$HOME/work/monitor_ui/server/web_hash.rb")
          )
         )
       )
      )
(setq n-data-menu-nbuf-shortcuts_aimeweb2
      (append
       n-data-menu-nbuf-shortcuts-common
       (list
        (cons ?1 "$P4ROOT/Tools/Aime/analytics/aime100.js")
        (cons ?c "$P4ROOT/Tools/Aime/analytics/res/b_mozilla/common.js")
        (cons ?g "$P4ROOT/Tools/Aime/analytics/res/b_mozilla/prompts/globalfilterprompt.js:503")
        (cons ?p "$P4ROOT/Tools/Aime/analytics/res/b_mozilla/dashboards/portalscript.js:300")
        )
       )
      )

(setq n-data-menu-nbuf-shortcuts_agent
      (append
       n-data-menu-nbuf-shortcuts-common
       (list
        (cons ?c "$HOME/work/fmw_agent/cron.sh")
        (cons ?d "$HOME/work/fmw_agent/deploy.sh")
        (cons ?f "$HOME/work/fmw_agent/getFarmInfo.pm")
        (cons ?F "$HOME/work/fmw_agent/fmw_agent.sh")
        (cons ?g "$HOME/work/fmw_agent/generateAimeDb.pl")
        )
       )
      )
(setq n-data-menu-nbuf-shortcuts_buildcommon
      (append
       n-data-menu-nbuf-shortcuts-common
       (list
        (cons ?d (concat "$P4ROOT/Tools/build/buildcommon/main/test/test-" n-data-menu-nbuf-shortcuts_buildcommon-test "/scratch/_test_local_repository/components/RECENT/buildcommon-main/privatebuild/common-scripts/_buildcommon/scripts/ant/buildcommon/include/default-build.xml"))
        (cons ?D "$P4ROOT/Tools/build/buildcommon/main/scripts/src/_buildcommon/scripts/ant/buildcommon/include/default-build.xml")
        (cons ?e "$LOCAL_REPO/components/RECENT/buildcommon-main/privatebuild/common-scripts/_buildcommon/scripts/ant/buildcommon/include/default-build.xml")
        (cons ?j (concat "$P4ROOT/Tools/build/buildcommon/main/test/test-" n-data-menu-nbuf-shortcuts_buildcommon-test "/scratch/_test_local_repository/components/RECENT/buildcommon-main/privatebuild/common-scripts/_buildcommon/scripts/ant/common/antlib/java.xml"))
        (cons ?J "$P4ROOT/Tools/build/buildcommon/main/scripts/src/_buildcommon/scripts/ant/common/antlib/java.xml")
        (cons ?u "$LOCAL_REPO/components/RECENT/buildcommon-main/privatebuild/common-scripts/_buildcommon/scripts/ant/common/antlib/java.xml")
        )
       )
      )

(setq n-data-menu-nbuf-shortcuts_engine3
      (append
       n-data-menu-nbuf-shortcuts-common
       (list
        (cons ?e "$P4ROOT/Tools/build/engine3/dev/bin/engine.py")
        (cons ?s "$P4ROOT/Tools/build/engine3/dev/lib/stomp.py")
        )
       )
      )

(setq n-data-menu-nbuf-shortcuts_bugdb
      (append
       n-data-menu-nbuf-shortcuts-common
       (list
        (cons ?g "$P4ROOT/Tools/BugDB/webapp/bug/js/general.js")
        (cons ?G "$P4ROOT/Tools/BugDB/webapp/bug/js/bug_general.js")
        )
       )
      )


(setq n-data-menu-nbuf-shortcuts_sensu
      (append
       n-data-menu-nbuf-shortcuts-common
       (list
        (cons ?a "$dp/sensu/dist/server/server_bin/audience.json")
        (cons ?c "$dp/sensu/dist/server/etc/sensu/conf.d/check_cron.json")
        ;;(cons ?C "$dp/sensu/dist/server/cron_file_snippet")
        (cons ?d "$dp/bin/sensu.diff.alert_when_different")
        (cons ?i "$dp/sensu/client_install.sh")
        (cons ?g "$TMP/sensu_global.log")
        (cons ?I "$dp/bin/sensu.inc")
        (cons ?l "/tmp/notification_router.out")
        (cons ?L "/tmp/sensu/cron.daily.notification_router.out")
        (cons ?m "$dp/sensu/dist/server/server_bin/midnight")
        (cons ?n "/etc/nginx/nginx.conf")
        (cons ?o "/tmp/sensu_mail.out")
        (cons ?q (list
                  "queues"
                  ;; rabbitmq config discussed at http://www.rabbitmq.com/configure.html
                  (cons ?c "/etc/rabbitmq/rabbitmq.config")
                  )
              )
        (cons ?r (list
                  "$dp/sensu/dist/server/server_bin/notification_router.rb"
                  "/etc/sensu/server_bin/notification_router.rb"
                  )
              )
        (cons ?R "$dp/sensu/dist/server/server_bin/notification_router.sh")
        (cons ?s "$dp/sensu/dist/server/server_bin/sensu_checks.rb")
        (cons ?t "$dp/sensu/dist/server/server_bin/test_notification_router.sh")
        (cons ?u "$dp/sensu/dist/server/server_bin/u.rb")
        )
       )
      )
(setq n-data-menu-nbuf-shortcuts_lisp
      (append
       n-data-menu-nbuf-shortcuts-common
       (n-database-load "n-data-menu-lisp")
       )
      )
(setq n-data-menu-nbuf-shortcuts_site_cp
      (append
       n-data-menu-nbuf-shortcuts-common
       (list
        (cons ?a "$dp/python/site_cp/providers/admin.py")
        (cons ?B "$dp/python/site_cp/providers/bucket.py")
        (cons ?b (list
                  ""
                  (cons ?3 "$dp/python/site_cp/providers/bucket_s3.py")
                  (cons ?a "$dp/python/site_cp/providers/bucket_s3_amzn.py")
                  (cons ?g "$dp/python/site_cp/providers/bucket_s3_goog.py")
                  (cons ?d "$dp/python/site_cp/providers/bucket_disk.py")
                  )
              )
        (cons ?c (list
                  ""
                  (cons ?n "/etc/nginx/uwsgi.conf")
                  (cons ?s "$dp/python/site_cp/django_static/mule.css")
                  )
              )
        ;;(cons ?f "$dp/python/site_cp/fixup_html.rb")
        (cons ?f "$dp/python/site_cp/providers/server_flavor.py")
        (cons ?F "$dp/python/site_cp/ftp.can")
        (cons ?g "$dp/python/site_cp/test_gen_from_log.rb")
        (cons ?G "$dp/python/site_cp/test_gen_from_log.test")
        (cons ?h "$dp/python/site_cp/django_static/mule.htm")
        (cons ?H "$dp/python/site_cp/django_static/help/help.htm")
        ;;(cons ?H "$P4ROOT/Tools/monitor_ui/server/monitor.html")
        (cons ?j "$dp/python/site_cp/django_static/mule.js")
        (cons ?L "$TMP/devserver.9999.out")
        ;;(cons ?L "$dp/python/LS")
        (cons ?l (list
                  "load"
                  (cons ?b "$dp/python/site_cp/providers/load_balancer.py")
                  (cons ?r "$dp/python/site_cp/providers/load_reporter.py")
                  )
              )
        (cons ?m "$dp/python/site_cp/midnight.test.$HOSTNAME")
        (cons ?M "$dp/python/site_cp/django_static/min_migrate.htm")
        (cons ?o "$dp/python/site_cp/providers/models.py")
        (cons ?s "$dp/python/site_cp/providers/settings.py")
        (cons ?t "$dp/python/site_cp/tests.py")
        (cons ?T "$dp/python/site_cp/scripts/mule.test.sh")
        (cons ?u (list
                  ""
                  (cons ?r "$dp/python/site_cp/providers/urls.py")
                  (cons ?s "$dp/python/site_cp/providers/user.py")
                  )
              )
        (cons ?U "$dp/python/site_cp/providers/u.py")
        (cons ?v "$dp/python/site_cp/views.py")
        ;;(cons ?w "$dp/python/site_cp/providers/web_site.py")
        (cons ?w "$dp/python/site_cp/django_static/whitebox.control.htm")
        (cons ?W "$dp/python/site_cp/scripts/test/whitebox.test.sh")
        (cons ?d "$dp/python/site_cp/providers/web_site_snap.py")
        )
       )
      )
(setq n-data-menu-nbuf-shortcuts_site_cp__css n-data-menu-nbuf-shortcuts_site_cp)

(setq n-data-menu-nbuf-shortcuts_sel_js
      (append
       n-data-menu-nbuf-shortcuts-common
       (list
        (cons ?a "$P4ROOT/Dev/selenium-core/trunk/code/javascript/core/scripts/selenium-api.js")
        (cons ?b "$P4ROOT/Dev/selenium-core/trunk/code/javascript/core/scripts/selenium-browserbot.js")
        (cons ?e "$P4ROOT/Dev/selenium-core/trunk/code/javascript/core/scripts/selenium-executionloop.js")
        (cons ?h "$P4ROOT/Dev/selenium-core/trunk/code/javascript/core/scripts/htmlutils.js")
        (cons ?i "$P4ROOT/Dev/selenium-core/trunk/code/javascript/core/scripts/injection.html")
        (cons ?l "$P4ROOT/Dev/selenium-core/trunk/code/javascript/core/scripts/selenium-logging.js")
        (cons ?s "$P4ROOT/Dev/selenium-core/trunk/code/javascript/core/scripts/selenium-seleneserunner.js")
        (cons ?t "$P4ROOT/Dev/selenium-core/trunk/code/javascript/core/scripts/selenium-testrunner.js")
        (cons ?S "$P4ROOT/Dev/selenium-core/trunk/code/javascript/core/SeleneseRunner.html")
        (cons ?T "$P4ROOT/Dev/selenium-core/trunk/code/javascript/core/TestRunner.html")

        (cons ?x "$P4ROOT/Dev/selenium-rc_svn/trunk/core/code/build/image/doc.xml")
        (cons ?X "$SOCRATES/build/components/ATTEMPT/seleniumremotecontrol-dev-trunk/core/code/build/image/doc.xml")
        )
       )
      )
(setq n-data-menu-nbuf-shortcuts_skynet(append
                                        n-data-menu-nbuf-shortcuts-common
                                        (list
                                         (cons ?_ "$CATALINA_HOME/ras_data/__ras_global_obj_log.txt")
                                         (cons ?a "$UNIX_HOME/ras_startup_all.sh")
                                         (cons ?b "/home/nelsons/shared/p4/Tools/SkyNet/automationcore/src/conf/test.bashrc")
                                         (cons ?j "$P4ROOT/Tools/SkyNet/automationweb/ras/ROOT/ras/rsrc_static_client.js")
                                         (cons ?i "c:/inetpub/wwwroot/index.htm")
                                         (cons ?m "$P4ROOT/Tools/SkyNet/automationweb/ras/ROOT/ras/mock_rsrc_static_client.html")
                                         (cons ?M "$P4ROOT/Tools/SkyNet/automationweb/ras/ROOT/ras/mock_rsrc_editor.html")
                                         (cons ?r "$P4ROOT/Tools/SkyNet/automationweb/ras/ROOT/ras/rsrc_editor.js")
                                         (cons ?u "$P4ROOT/Tools/SkyNet/automationweb/ras/ROOT/ras/u.js")
                                         )
                                        )
      )

(setq n-data-menu-nbuf-shortcuts_domain (append
                                         n-data-menu-nbuf-shortcuts-common
                                         (list
                                          (cons ?s "$P4ROOT/Tools/BID/domain_model/domain/src/java/com/bea/bid/domain/SkynetBIDAssetsService.java")
                                          )
                                         )
      )

(setq n-data-menu-nbuf-shortcuts_java
      (append
       (list
        (cons ?b "e:/netscape/users/adynware/bookmark.htm")
        (cons ?c "e:/netscape/users/adynware/cookies.txt")
        (cons ?w "$dp/emacs/tags/tags.perl")
        )
       n-data-menu-nbuf-shortcuts-common
       )
      )

(setq n-data-menu-nbuf-shortcuts_trade
      (append
       (list
        (cons ?a "$HOME/work/adyn.com/httpdocs/see/data/all")
        (cons ?m "$HOME/work/adyn.com/cgi-bin/midnight.see")
        (cons ?r "$HOME/work/adyn.com/cgi-bin/see_data_refresh.sh")
        (cons ?s "$HOME/work/adyn.com/cgi-bin/see_data.cgi")
	)
       n-data-menu-nbuf-shortcuts-common
       )
      )
(setq n-data-menu-nbuf-shortcuts_teacher
      (append
       (list
        (cons ?1 "$dp/adyn/httpdocs/teacher/html/alln.htm")
        (cons ?2 "$dp/adyn/httpdocs/teacher/html/new2.js")
        (cons ?A "$dp/adyn/httpdocs/teacher/grammar/German.dp")
        (cons ?a "$dp/adyn/httpdocs/teacher/html/aa.htm")
        (cons ?a "$dp/adyn/httpdocs/teacher/grammar/German.dat.htm")
        (cons ?e "$dp/adyn/httpdocs/teacher/generic_grammar.pm")
        (cons ?E (list
                  "first_file_that_exists"
                  "/cygdrive/c/Program Files (x86)/Apache Software Foundation/Apache2.2/logs/error.log"
                  "/cygdrive/c/Program Files/Apache Software Foundation/Apache2.2/logs/error.log"
                  "/etc/httpd/logs/error_log"
                  "/var/log/apache2/error.log"   ;; /etc/apache2/apache2.conf
                  )
              )
        (cons ?f "$dp/adyn/httpdocs/teacher/grammar/French.dat.htm")
        (cons ?F "$dp/adyn/httpdocs/teacher/grammar/French.dp")
        (cons ?g "$dp/adyn/httpdocs/teacher/grammar.pm")
        (cons ?G "$dp/adyn/httpdocs/teacher/tx.pl")
        (cons ?h "$dp/adyn/httpdocs/teacher/html/teacher_history.java")
        (cons ?i "$dp/adyn/httpdocs/teacher/grammar/Italian.dat.htm")
        (cons ?I "$dp/adyn/httpdocs/teacher/grammar/Italian.dp")
        (cons ?j "$dp/adyn/httpdocs/teacher/html/teacher.java")
        (cons ?J "$dp/doc/facts/j2ee.facts")
        (cons ?k "$dp/adyn/httpdocs/teacher/t.sh")
        (cons ?l "/var/log/apache2/error.log")
        (cons ?m "$dp/teacher_servers/tomcat/webapps/teacher_server/src/teacher_server_package/teacher_server_main.java")
        (cons ?o "$dp/adyn/httpdocs/teacher/html/topicInstance.java")
                                        ;(cons ?o "$dp/adyn/httpdocs/teacher/o_token.pm")
        (cons ?p "$dp/adyn/httpdocs/teacher/Spanish_grammar.pm")
        (cons ?P "$dp/adyn/httpdocs/teacher/teacher.pm")
        (cons ?r "$dp/adyn/httpdocs/teacher/French_grammar.pm")
        (cons ?R "$dp/adyn/httpdocs/teacher/can/review/French.reviewed")
        (cons ?S "$dp/adyn/httpdocs/teacher/transform_into_flashcards.sh")
        (cons ?s "$dp/adyn/httpdocs/teacher/grammar/Spanish.dat.htm")
        (cons ?t "$dp/adyn/httpdocs/teacher/Italian_grammar.pm")
        (cons ?T "$dp/adyn/teacher/bin/teacher.test")
        ;;(cons ?T "$dp/adyn/httpdocs/teacher/transform_into_flashcards.pl")
        ;;(cons ?T "$dp/adyn/httpdocs/teacher/nmw_to_teacher_tmp_pm")
        (cons ?x "$dp/adyn/httpdocs/teacher/exercise_generator.pm")
        (cons ?w "$dp/adyn/httpdocs/teacher/translate_via_web.pl")
        )
       n-data-menu-nbuf-shortcuts-common
       )
      )

(setq n-data-menu-nbuf-shortcuts_8849
      (append
       (list
        (cons ?m "$dp/bin/ruby/midnight.ib.8949.gen")
        (cons ?r "$dp/bin/ruby/ib.8949.gen.rb")
        (cons ?s "$dp/bin/ib.8949.gen")
        )
       n-data-menu-nbuf-shortcuts-common
       )
      )
(setq n-data-menu-nbuf-shortcuts_channel
      (append
       (list
        (cons ?b "$dp/channel/bar.rb")
        (cons ?C "$dp/channel/config.txt")
        (cons ?G "$dp/channel/global.rb")
        (cons ?h "$dp/channel/heat_map.rb")
        (cons ?i "$dp/channel/data_input.rb")
        (cons ?l "$dp/channel/t_line.rb")
        (cons ?M "$dp/channel/main.rb")
        (cons ?m "$dp/channel/midnight")
        (cons ?o "$dp/channel/order.rb")
        (cons ?p "$dp/channel/position.rb")
        (cons ?P "$dp/channel/pivot.rb")
        (cons ?t "$dp/channel/trader.rb")
        (cons ?c (list
                  "channel_finder"
                  (cons ?l "$dp/channel/channel_finder__level_detector.rb")
                  (cons ?t "$dp/channel/channel_finder__trend_line_finder.rb")
                  )
              )
        (cons ?g "$dp/channel/ts.rb")
        (cons ?T "$dp/channel/test.rb")
        (cons ?u "$dp/channel/u.rb")
        )
       n-data-menu-nbuf-shortcuts-common
       )
      )

(setq n-data-menu-nbuf-shortcuts_ezlang
      (append
       (list
	(cons ?1 "$dp/adyn/httpdocs/teacher/html/base.190.html")
	(cons ?2 "$dp/adyn/httpdocs/teacher/html/base.192.html")
	(cons ?A "$dp/adyn/httpdocs/teacher/grammar/German.dp")
	(cons ?a "$dp/adyn/httpdocs/teacher/grammar/German.dat.htm")
	(cons ?d "$dp/ts/doc/dict")
	(cons ?e "$dp/adyn/httpdocs/teacher/generic_grammar.pm")
	(cons ?f "$dp/adyn/httpdocs/teacher/grammar/French.dat.htm")
	(cons ?F "$dp/adyn/httpdocs/teacher/grammar/French.dp")
	(cons ?g "$dp/adyn/httpdocs/teacher/grammar.pm")
	(cons ?G "$dp/adyn/httpdocs/teacher/tx.pl")
	(cons ?h "$dp/adyn/httpdocs/teacher/html/teacher_history.java")
	(cons ?i "$dp/adyn/httpdocs/teacher/grammar/Italian.dat.htm")
	(cons ?I "$dp/adyn/httpdocs/teacher/grammar/Italian.dp")
	(cons ?j "$dp/adyn/httpdocs/teacher/html/teacher.java")
	(cons ?k "$dp/adyn/httpdocs/teacher/t.sh")
	(cons ?m "$dp/adyn/httpdocs/teacher/html/teacher_minimal.java")
	(cons ?o "$dp/adyn/httpdocs/teacher/html/topicInstance.java")
					;(cons ?o "$dp/adyn/httpdocs/teacher/o_token.pm")
	(cons ?p "$dp/adyn/httpdocs/teacher/Spanish_grammar.pm")
	(cons ?P "$dp/adyn/httpdocs/teacher/teacher.pm")
	(cons ?r "$dp/adyn/httpdocs/teacher/French_grammar.pm")
	(cons ?S "$dp/adyn/httpdocs/teacher/grammar/Spanish.dp")
	(cons ?s "$dp/adyn/httpdocs/teacher/grammar/Spanish.dat.htm")
	(cons ?t "$dp/adyn/httpdocs/teacher/Italian_grammar.pm")
	(cons ?T "$dp/adyn/httpdocs/teacher/html/Italian.html")
	;;(cons ?T "$dp/adyn/httpdocs/teacher/nmw_to_teacher_tmp_pm")
	(cons ?x "$dp/adyn/httpdocs/teacher/exercise_generator.pm")
	(cons ?w "$dp/adyn/httpdocs/teacher/translate_via_web.pl")
	(cons ?z "$dp/adyn/httpdocs/teacher/t_debug_ProposeNotes.sh")
	)
       n-data-menu-nbuf-shortcuts-common
       )
      )
(setq n-data-menu-nbuf-shortcuts_logs_from_meta
      (append
       (list
	(cons ?0 "$dp/ts/meta/logs/security_entry.pm")
	(cons ?1 "$dp/ts/meta/logs/security_exit.pm")
	(cons ?a "$dp/ts/meta/logs/analyze_trades.pl")
	(cons ?b "$dp/ts/meta/logs/trades_from_ts_output_sorted_by_bar.pm")
	(cons ?B "$dp/ts/meta/logs/execute_trades_from_ts_output_sorted_by_bar.pl")
	(cons ?f "$dp/ts/meta/logs/strategy_pfr_record.pm")
	(cons ?F "$dp/adyn/httpdocs/teacher/grammar/French.dp")
	(cons ?g "$dp/adyn/httpdocs/teacher/grammar.pm")
	(cons ?G "$dp/adyn/httpdocs/teacher/tx.pl")
	(cons ?h "$dp/adyn/httpdocs/teacher/html/teacher_history.java")
	(cons ?i "$dp/adyn/httpdocs/teacher/grammar/Italian.dat.htm")
	(cons ?I "$dp/adyn/httpdocs/teacher/grammar/Italian.dp")
	(cons ?K "$dp/adyn/httpdocs/teacher/t.sh")
	(cons ?l "$dp/adyn/httpdocs/teacher/German_grammar.pm")
	(cons ?m "$dp/ts/meta/logs/money_manager.pm")
	(cons ?j "$dp/ts/meta/logs/security_obj.pm")
	(cons ?o "$dp/ts/meta/logs/security_order.pm")
	(cons ?p "$dp/ts/meta/logs/security_position.pm")
	(cons ?P "$dp/adyn/httpdocs/teacher/teacher.pm")
	(cons ?Q "c:/mysql/Docs/manual.txt")
	(cons ?q "$dp/ts/meta/logs/sort_into_bars.pl")
	(cons ?r "$dp/adyn/httpdocs/teacher/French_grammar.pm")
	(cons ?s "$dp/ts/meta/logs/trades_from_ts_output_for_one_symbol.pm")
	(cons ?S "$dp/ts/meta/logs/execute_trades_from_ts_output_for_one_symbol.pl")
	(cons ?t "$dp/ts/meta/logs/trades_from_ts_output.pm")
	(cons ?T "c:/Program Files/TradeStation/MyWork")
	(cons ?w "$dp/adyn/httpdocs/teacher/translate_via_web.pl")
	(cons ?z "$dp/adyn/httpdocs/teacher/t_debug_ProposeNotes.sh")
	)
       n-data-menu-nbuf-shortcuts-common
       )
      )
(setq n-data-menu-nbuf-shortcuts_ib
      (append
       (list
	(cons ?d "$dp/data/ib.ticker.ls_l.db")
	(cons ?D "/cygdrive/c/ts_logs/orders.dat")
	(cons ?f "$dp/bin/ib.order_from_ts")
	(cons ?g "$dp/bin/ib.ts.go")
	;;(cons ?G "$dp/bin/ib.ticker.get")
	(cons ?G "$dp/bin/ruby/ib_ts_test_generated.rb")
	(cons ?l "$dp/bin/ib.ticker.ls_l")
	(cons ?L "$dp/data/ib.ticker.ls_l.db")
	(cons ?m "$dp/ib/ib_cl/src/java/glen/Ib_cl.java")
	(cons ?o "$dp/ib/ib_cl/src/java/glen/n_order.java")
	(cons ?O "$dp/bin/ib.order")
	(cons ?s "$dp/ib/ib_cl/src/java/glen/n_security.java")
	;;(cons ?t "/cygdrive/c/Jts/dlinhqgk/tws.xml")
	(cons ?t "$dp/bin/ruby/ib.ts.rb")
	(cons ?T "$dp/bin/ruby/ib_ts_test.rb")
	)
       n-data-menu-nbuf-shortcuts-common
       )
      )
(setq n-data-menu-nbuf-shortcuts_craig
      (append
       (list
        (cons ?a "$dp/craig/prod/immigration/in/schema/all")
        (cons ?d "$dp/bin/ti_deploy")
        (cons ?f "$dp/bin/ruby/form.rb")
        (cons ?h "$TMP/craig/craig.htm")
        (cons ?H "$dp/craig/shared/html/")
        (cons ?i "$dp/craig/shared/html/scripts/ti.js")
        (cons ?M "$dp/craig/shared/gen/midnight")
        (cons ?m "$dp/bin/ruby/midnight.craig")
        (cons ?o "$dp/craig/prod/immigration/in/schema/all.rb")
        (cons ?r "$dp/bin/ruby/craig.rb")
        (cons ?R "$dp/craig/shared/html/scripts/remember_in_DOM.js")
        (cons ?s "$dp/craig/shared/html/scripts/suppress_irrelevance.js")
        (cons ?t "$dp/bin/ruby/form_test.rb")
        (cons ?T "$dp/craig/shared/gen/t.sh")
	)
       n-data-menu-nbuf-shortcuts-common
       )
      )
(setq n-data-menu-nbuf-shortcuts_ffiec
      (append
       (list
        (cons ?m "$dp/monr/ffiec/java/ffiec/com/monroe/FfiecMonitor.java")
	)
       n-data-menu-nbuf-shortcuts-common
       )
      )
(setq n-data-menu-nbuf-shortcuts_monr_vis
      (append
       (list
(cons ?a "$dp/monr/web/apps3/src/cash_sheet.asp")
(cons ?c "$dp/monr/web/apps3/src/common_client.js")
(cons ?C "$dp/monr/web/apps3/src/Contact.js")
(cons ?d "$dp/monr/web/apps3/all/default.htm")
(cons ?O "$dp/monr/web/apps3/src/common__shared_cs.js")
(cons ?u "$dp/monr/web/apps3/src/current.asp")
(cons ?e "$dp/monrmidnight.read_baseline_report")
(cons ?h "$dp/monr/web/apps3/src/history.asp")
(cons ?m "$dp/monr/web/apps3/src/modify_symbol.asp")
(cons ?M "$dp/python/site_cp/django_static/mule.htm")
(cons ?o "$dp/monr/web/apps3/src/order_ticket.asp")
(cons ?r "$dp/monr/web/apps3/src/rolodex.asp")
(cons ?R "$dp/monr/web/apps3/src/recon.asp")
(cons ?s "$dp/monr/web/apps3/src/common_server.js")
(cons ?S "$dp/monr/web/apps3/src/summary_activity.asp")
(cons ?t "$dp/monr/web/apps3/src/Trade.js")
(cons ?T "$dp/monr/web/apps3/src/test.asp")
(cons ?u "$dp/monr/web/apps3/z_util.js")
(cons ?U "$dp/monr/b2/update_trades.pl")
(cons ?V "$dp/monr/web/apps3/src/view_companies.asp")
(cons ?z "$HOME/work/monr/web/apps3/auth/z_util.js")
)
n-data-menu-nbuf-shortcuts-common
)
)
(setq n-data-menu-nbuf-shortcuts_monr_vis_prod
      (map 'list
           '(lambda(key-and-fn)
              (cons (car key-and-fn)
                    (if (stringp (cdr key-and-fn))
                        (nstr-replace-regexp (cdr key-and-fn) "DROP" "HOME/work")
                      (cdr key-and-fn)
                      )
                    )
              )
           n-data-menu-nbuf-shortcuts_monr_vis
           )
      )

(setq n-data-menu-nbuf-shortcuts_monr_trade
      (append
       (list
        (cons ?s "$dp/monroe/auto/trade/com/monroe/n_security.java")
	)
       n-data-menu-nbuf-shortcuts-common
       )
      )

(setq n-data-menu-nbuf-shortcuts_devops
      (append
       (list
        (cons ?d "$dp/data/lm.quota.vm.delete_log")
        (cons ?h "$dp/data/aria.data.hierarchy")
        (cons ?p "$dp/data/aria.data.persons")
        (cons ?m "$dp/bin/ruby/midnight.lm_csv")
        (cons ?r "$dp/bin/ruby/lm_csv.rb")
        )
       n-data-menu-nbuf-shortcuts-common
       )
      )
(setq n-data-menu-nbuf-shortcuts_config
      (append
       (list
        (cons ?O "$HOME/git/promotion-config/src/main/java/com/oracle/syseng/configuration/data/transformation/OrchestrationMapper.java.abhay")
        (cons ?o "$HOME/git/promotion-config/src/main/java/com/oracle/syseng/configuration/data/transformation/OrchestrationMapper.java")
	)
       n-data-menu-nbuf-shortcuts-common
       )
      )
(setq n-data-menu-nbuf-shortcuts_mongo_data_manager
      (append
       n-data-menu-nbuf-shortcuts-common
       (list
        (cons ?c "$dp/mongo_data_manager/src/config_mongo_json_holder.rb")
        (cons ?f "$dp/mongo_data_manager/src/json_flattener.rb")
        (cons ?m "$dp/mongo_data_manager/src/mongo_json_holder.rb")
        (cons ?M "$dp/mongo_data_manager/midnight.config_mongo_json_flattener")
        (cons ?s "$dp/mongo_data_manager/src/mongo_setting.rb")
        (cons ?t "$dp/mongo_data_manager/src/test.sh")
        (cons ?u "$dp/mongo_data_manager/src/u.rb")
        )
       )
      )
(setq n-data-menu-nbuf-shortcuts_rest_test_generator
      (append
       n-data-menu-nbuf-shortcuts-common
       (list
(cons ?1 "$dp/bin/rest_test_generator.sh.slcipau")
(cons ?b "$dp/rest_test_generator/weblog_2_tests/src/rest_test_generator.sh")
(cons ?f "$dp/rest_test_generator/weblog_2_tests/src/json_flattener.rb")
(cons ?i "$dp/rest_test_generator/weblog_2_tests/test/log")
(cons ?I "/net/slcipaq.u/scratch/pau_logs_selection/")
(cons ?L "$CATALINA_HOME/logs/catalina.out")
(cons ?m "$dp/rest_test_generator/midnight")
(cons ?t "$dp/rest_test_generator/local_test.sh")
(cons ?r "$dp/rest_test_generator/weblog_2_tests/src/rest_test_generator.rb")
(cons ?R "$dp/rest_test_generator/weblog_2_tests/src/rest_test_report.sh")
(cons ?u "$dp/rest_test_generator/weblog_2_tests/src/u.rb")
        )
       )
      )
