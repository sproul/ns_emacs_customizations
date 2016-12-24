(setq next-migrate-rows nil)
(setq next-migrate-beforesAndAfters nil)

(defun next-migrate-put(srcFn &optional destFn)
  (if (not destFn)
      (setq destFn srcFn))
  
  (setq destFn (concat "$ext/pso/$extdataset/V0/Data/$extdataset/" destFn))
  (n-file-find destFn)
  (if (n-file-exists-p destFn) ; n.b., n-file-find doesn't create a file
      (nsyb-cm "lock")
    (nsyb-cm "add")
    )
  
  (goto-char (point-max))
  (insert (cdr (assoc srcFn next-migrate-rows)))
  (nre-transform)
  )


(defun next-migrate-init(fn)
  (n-file-find fn)
  (setq next-migrate-rows (cons (cons fn
				      (buffer-substring-no-properties (point-min) (point-max))
				      )
				next-migrate-rows
				)
	)
  (next-migrate-init-beforesAndAfters next-migrate-beforesAndAfters fn)
  )

(defun next-migrate-init-beforesAndAfters(beforesAndAfters fn)
  (n-file-find fn)
  (goto-char (point-min))
  (while (not (eobp))
    (setq beforesAndAfters (cons (cons (nsql-get-col-text)
				       (next-alloc-bobid)
				       )
				 beforesAndAfters
				 )
	  )
    (forward-line 1)
    )
  beforesAndAfters
  )

(defun next-migrate-rule()
  (if (not (string= "albr_defn" (nsql-get-table-name)))
      (error "next-migrate-rule: "))
  
  (setq next-migrate-rows nil)
  (setq next-migrate-beforesAndAfters nil)
  
  (require 'next)
  (next-use-my-bobids)
  
  (require 'nsql)
  (nsql-find-where)
  
  (next-migrate-init "br_defn.txt")
  (next-migrate-init "br_template.txt")
  (next-migrate-init "br_instance.txt")
  (next-migrate-init "br_organization_br.txt")
  (next-migrate-init "br_parameter.txt")
  
  (require 'nre)
  (nre-init-transform next-migrate-beforesAndAfters)
  
  (next-migrate-put "br_defn.txt")
  (next-migrate-put "br_template.txt" "br_template_pso.txt")
  (next-migrate-put "br_instance.txt")
  (next-migrate-put "br_organization_br.txt")
  (next-migrate-put "br_parameter.txt")
  )
