(provide 'ncom)
(defun ncom-connect(connection-name)
  (cond
   ((string= connection-name "l")
    (setq user-mail-address "nelson@adyn.com")
    
    (setq smtpmail-smtp-server "smtp.slip.net")
    ;;(setq smtpmail-smtp-server "smtp")
    
    (n-host-shell-cmd (format "macro -f $HOME/work/macro/macros/isp.covad"))
    (n-host-shell-cmd (format "sh -x dial_internet %s" "w"))
    )
   ((string= connection-name "x")
    (setq user-mail-address "nsproul@extensity.com")
    (setq smtpmail-smtp-server "smtp")
    (n-host-shell-cmd (format "macro -f $HOME/work/macro/macros/isp.ext"))
    )
   (t
    (message "ncom-connect: connection-name %s not recognized" connection-name)
    )
   )
  (n-database-set "user-mail-address" user-mail-address)
  (n-database-set "smtpmail-smtp-server" smtpmail-smtp-server)
  )
(defun ncom-disconnect()
  (n-host-shell-cmd (format "sh -x disconnect_internet"))
  )
