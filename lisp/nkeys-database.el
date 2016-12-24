(provide 'nkeys-database)
(defun nkeys-database(prefix key mode)
  (let(
       variable
       )
    (if mode
        (setq variable (nkeys-database2 (concat prefix
                                                (if (eq mode t)
                                                    (concat (symbol-name major-mode) "-map")
                                                  (symbol-name mode)
                                                  )
                                                )
                                        key
                                        )
              )
      )
    (if (or
         (and mode (not (boundp variable)))
         (not mode)
         )
        (setq variable (nkeys-database2 prefix key))
      )
    variable
    )
  )
(defun nkeys-database2(prefix key)
  (setq key (nkeys-database-array-or-event-to-string key))
  (let(
       (name	(concat prefix (nkeys-database-cook key))
                )
       )
    (intern name)
    )
  )
(defun nkeys-database-get(prefix key &optional mode)
  (let(
       (variable  (nkeys-database prefix key mode))
       )
    (if (boundp variable)
        (eval variable))
    )
  )
(defun nkeys-database-set(prefix key value &optional mode)
  (set (nkeys-database prefix key mode)
       value
       )
  )

(defun nkeys-database-array-or-event-to-string(key)
  (if (not (stringp key))
      (progn
        (if  (arrayp key)
            (setq key (elt key 0)))
        
        (if (and (functionp 'event-to-character)
                 (eventp key)
                 )
            (setq key (char-to-string (event-to-character key)))
          )
        )
    )
  key
  )




(defun nkeys-database-cook(s1)
  "convert 's1', a key sequence in string form, to a printable representation."
  ;; For example [single quotes used for clarity]:
  ;;
  ;; (nkeys-database-cook '\t') == '_tab'
  ;; (nkeys-database-cook '^F') == '_C-f'
  ;; (nkeys-database-cook '\346') == '_M-f'
  (setq s1 (nkeys-database-array-or-event-to-string s1))

  (let(
       (len	(if s1 (length s1)	0)
                )
       (x1	0)
       (x2	0)
       (s2	"")
       c1
       )
    (while   (> len x1)
      (setq c1 (elt s1 x1)
            s2 (concat s2
                       (cond
                        ((<= c1 26)     ; compare with ^Z
                         (format "_C-%c" (+ c1 96))
                         )
                        ((> c1 127)
                         (format "_M-%c" (- c1 128))
                         )
                        ((= c1 ?\\)
                         "_back-slash")
                        ((= c1 ?\")
                         "_double-quote")
                        ((= c1 ?\')
                         "_quote")
                        ((= c1 ?\t)
                         "_space")
                        ((= c1 ?\t)
                         "_tab")
                        ((= c1 ?_)
                         "_underscore")
                        (t
                         (format "%c" c1)
                         )
                        )             ; cond
                       )
            )
      (setq               x1 (1+ x1))
      )
    s2
    )
  )
(defun nkeys-database-thaw(s1)
  "inverse of nkeys-database-cook"
  (let(
       (len	(if s1 (length s1)	0)
                )
       (x1	0)
       (x2	0)
       (s2	"")
       c1
       )
    (while   (> len x1)
      (setq c1 (elt s1 x1)
            x1 (1+ x1)
            s2 (concat s2
                       (progn
                         (if (= c1 ?_)
                             (progn
                               (setq c1 (elt s1 x1))
                               (cond
                                ((= c1 ?C)
                                 (setq x1 (+ x1 2)
                                       c1 (elt s1 x1)
                                       c1 (- c1 96)
                                       x1 (1+ x1)
                                       )
                                 )
                                ((= c1 ?M)
                                 (setq x1 (+ x1 2)
                                       c1 (elt s1 x1)
                                       c1 (+ c1 128)
                                       x1 (1+ x1)
                                       )
                                 )
                                ((= c1 ?b)
                                 (setq c1 ?\\
                                       x1 (+ x1 (length "back-slash"))
                                       )
                                 )
                                ((= c1 ?d)
                                 (setq c1 ?\"
                                       x1 (+ x1 (length "double-quote"))
                                       )
                                 )
                                ((= c1 ?q)
                                 (setq c1 ?'
                                       x1 (+ x1 (length "quote"))
                                       )
                                 )
                                ((= c1 ?s)
                                 (setq c1 32	; space bar
                                       x1 (+ x1 (length "space"))
                                       )
                                 )
                                ((= c1 ?t)
                                 (setq c1 ?\t
                                       x1 (+ x1 (length "tab"))
                                       )
                                 )
                                ((= c1 ?u)
                                 (setq c1 ?_
                                       x1 (+ x1 (length "underscore"))
                                       )
                                 )
                                (t (error "nkeys-database-thaw: "))
                                )
                               )
                           )
                         (format "%c" c1)
                         )
                       )
            )
      )
    s2
    )
)

