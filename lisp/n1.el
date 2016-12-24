(provide 'n1)
(defun n-assoc( key list &optional noMatchOk)
  "like assoc but eek (unless optional NO_MATCH_OK is non-nil) if no hit, assumes key is a string, and returns cdr, not whole elt"
  (if (not (stringp key))
      (error "n-assoc called without string"))
  (let(
       (hit	(assoc key list))
       )
    (cond
     (hit (cdr hit))
     (noMatchOk nil)
     (t (error "couldn't find %s" key))
     )
    )
  )



(setq n-print-buf-cnt nil)
(defun n-print (&rest args)
  "n1.el: write MSGs to the nas output buffer, returns the concatenation"
  (save-excursion
    (set-buffer (get-buffer-create "*n-output*"))
    (goto-char (point-max))
    (let(
         (msg	(apply 'format args))
         )
      (insert msg)
      (if n-print-buf-cnt
          (progn
            (setq n-print-buf-cnt (1+ n-print-buf-cnt))
            (if (> n-print-buf-cnt 1000)
                (progn
                  (setq n-print-buf-cnt 0)
                  (n-print-flush)
                  )
              )
            )
        )
      msg
      )
    )
  )


(defun n-dired-get-filename (short)
  (dired-get-filename short t))

(defvar n-xdired-fast nil
  "is n-xdired operating in 'fast' mode?")

(defvar n-xdired-fastness-enabled nil
  "*is n-xdired 'fast' mode enabled?")

(defun n-get-line(&optional arg)
  (save-excursion
    (let(
         (line (buffer-substring-no-properties (progn
                                                 (forward-line 0)
                                                 (point)
                                                 )
                                               (progn
                                                 (end-of-line)
                                                 (point)
                                                 )
                                               )
               )
         )
      (cond
       ((string= arg 'remove-leading-whitespace)
        (setq line (nstr-replace-regexp line "^[ \t]*" ""))
        )
       )
      line
      )
    )
  )

(defun n-xdired-loadx-init()
  "n1.el: load the list of commonly-used directories (for use by n-xdired, etc.)"
  (interactive)
  (let(
       (oldBuf (get-buffer n-local-ff-db-bn))
       )
    (if (and n-local-ff-db-fn (file-readable-p n-local-ff-db-fn))
        (progn
          (if oldBuf
              (kill-buffer oldBuf))
          (find-file n-local-ff-db-fn)
          (rename-buffer n-local-ff-db-bn)
          (setq n-xdired-fastness-enabled t)
          (bury-buffer (current-buffer))
          )
      (setq n-xdired-fastness-enabled nil)
      )
    )
  )

(defun n-zap( bufName)
  (let(
       (buf	(get-buffer bufName))
       )
    (if buf
        (nbuf-kill buf))
    (setq buf (get-buffer-create bufName))
    (set-buffer buf)
    buf
    )
  )

(defun n-xdired-echo-dir-contents( dir)
  "echo the files in DIR which look interesting"
  (n-xdired dir
            ".+\\(\\.c\\)\\|\\(\\.man\\)\\|\\(\\.h\\)\\|\\(\\.el\\)"
            'n-echo))


(defun n-ffile-exists-p( fN)
  "n1.el: Like file-exists-p 'cept EMACS wildcards are ok; uses fast db"
  (interactive "sExp for files: ")
  (if n-xdired-fastness-enabled
      (progn
        (set-buffer n-local-ff-db-bn)
        (goto-char (point-min))
        (re-search-forward fN (point-max) t)
        )
    nil
    )
  )

(defun n-xdired-init(dir regex)
  "n1.el: initialize the environment for n-xdired.  Return the function which
   will be used to extract the name of the current file being worked on"
  (setq n-xdired-fast (n-ffile-exists-p dir))
  (if n-xdired-fast
      (let(
           (beg  (progn
                   (forward-line 0)
                   (point)
                   )
                 )
           (end  (let(
                      (matchLen (length dir))
                      )
                   (while (and (not (eobp))
                               (not (eq nil (string-match dir (buffer-substring-no-properties (point)
                                            (progn
                                                                                                (forward-char matchLen)
                                                                                                (point)
                                                                    )
                                                              )
                                            )
                                    )
                               )
                          )
                     (forward-line 1)
                     (forward-line 0)
                   )
                   (forward-line 0)
                   (point)
                 )
           )
        )
        ;
        ; The directory is one of the ones in our list.
        ; Narrow n-local-ff-db-bn buffer to show only the
        ; contents of the directory and its descendants.
        ;
        (narrow-to-region beg end)
        (goto-char (point-min))
        'n-fast-get-filename
      )
      (progn	; not fast
        (dired dir)
        (goto-char (point-min))
        (forward-line 1)
        'n-dired-get-filename
      )
  )
)

(defun n-fast-get-filename(short)
  "n1.el: if SHORT is t, get the short filename from the current line
   of the xdired list buffer; otherwise get the LONG filename"
  (if short
      (buffer-substring-no-properties (progn
                          (end-of-line)
                          (point)
                        )
                        (progn
                          (re-search-backward "/" (forward-line 0) nil)
                          (match-beginning 0)
                        )
      )
      (n-get-line)
  )
)

(defun n-xdired (dir regex doit &optional pred attention dontRecurse)
  "n1.el: recursively find all files under DIR which match REGEX, and invoke
   DOIT on them.
Optionally supply a predicate PRED which prunes the files they are acted upon.
If optional ATTENTION is non-nil, then the editor flips out to get your attention when the job is done.
If optional DONT_RECURSE is non-nil...

Ignores symbolic directory links, SCCS directories."
  (save-excursion
    (let (
          file-regex
          longFn
          shortFn
          (xdired-get-filename (n-xdired-init (expand-file-name dir) regex))
          )
      
      (if n-xdired-fast
          (setq file-regex (concat "/" regex "$"))
        (setq file-regex (concat " " regex "\\($\\| ->\\)")))
                                        ;
                                        ; first execute 'doit on all files
                                        ;
      (while (and (not (eobp)) 
                  (re-search-forward file-regex (point-max) t ))
        (setq longFn (funcall xdired-get-filename nil))
        (if (and longFn
                 (not (file-directory-p longFn)
                      )
                 (or (eq pred nil)
                     (save-excursion
                       (funcall pred longFn))
                     )
                 )
            (save-excursion
              (funcall doit longFn))
          )
        (forward-line 1)
        )
      
      (if n-xdired-fast
          (widen)
        (if (not dontRecurse)
            (progn
                                        ;
                                        ; now recurse down subdirectories
                                        ;
              (goto-char (point-min))
              (forward-line 1)
              (while (not (eobp))
                (setq longFn  (funcall xdired-get-filename nil)
                      shortFn (funcall xdired-get-filename t))
                (if (and longFn
                         (file-directory-p longFn)
                         (not (string-equal "."  shortFn))                 
                         (not (string-equal "SCCS" shortFn))
                         (not (file-symlink-p longFn))
                         (not (string-equal ".." shortFn))
                         )
                    (n-xdired longFn regex doit pred)
                  )
                (forward-line 1)
                )
              (kill-buffer (current-buffer)) ; get rid of the dired buffer
              )                         ; progn
          )                             ; if recursing
        ) 	; if n-xdired-slow
      )   ; let
    )     ; save-excursion
  (if attention
      (batch-attention "Done"))
  )

(defun n-ff (dir regexp)
  "n1.el: file find"
  (interactive "DTop directory:
sFile name regexp: ")
  (n-xdired dir regexp 'n-echo)
  )

(defun n-echo( longFn)
  "n1.el: echo FILE_NAME to *n-output*"
  (n-print "%s\n" longFn)
  )

(defun n-open-line()
  " create a new line above the current one"
  (interactive)

  ;;(forward-line 0)    Doesn't actually go to the beginning of the line in Shell mode
  (if (eq -1 (forward-line -1))
      (progn
        (goto-char (point-min))
        (insert "\n")
        (forward-line -1)
        )
    (end-of-line)
    (insert "\n")
    )
  (require 'n-comment)
  (if (not (n-comment-p 1))
      (indent-according-to-mode)
    (insert n-comment-boln " ")
    (n-comment-indent)
    )
)
