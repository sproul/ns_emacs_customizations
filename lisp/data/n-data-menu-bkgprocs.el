(setq n-data-menu-bkgprocs
      (list
       (cons ?a "AmexRemitBkg") ;AutoApprovalBkg (cons ?a "APExportCommon")
       (cons ?A "APBkg")  ;; AirTouchAPExport;
       (cons ?d "DocumentumAPExportBkg")
       (cons ?D "DlnqntSubmitNotifier")
       (cons ?e "DocumentExportBkg")
       (cons ?h "HRBkg")
       (cons ?H (list
		 ""
		 (cons ?p "HboImportBkg")
		 (cons ?t "HboImportTasksBkg")
		 )
	     )
       (cons ?i "AirTouchImport")
       (cons ?p "PayrollBkg")
       (cons ?s "SaraLeeAmexRemitBkg")
       (cons ?t "TSChecker")
       (cons ?u "UpdateBkgproc")
       (cons ?v "APVerifyBkg")
       (cons ?V "APVerifyRobot")
       )
      )
