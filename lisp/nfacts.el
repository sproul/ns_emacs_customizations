;;
;; Code to edit facts files and also to execute a elisp based teacher.
;; Calls out to transform1_into_flashcards.sh to create actual teacher data

(provide 'nfacts)
(setq nfacts-debug nil)
(setq nfacts-table-set-default-size (if nfacts-debug 1 50))
(setq nfacts-hand-set-default-size (/ nfacts-table-set-default-size (if nfacts-debug 1 3)))
(setq nfacts-current-facts-file nil)
(setq nfacts-debug-mode t)
(setq nfacts-edit-in-progress nil)
(setq nfacts-by-qa  (make-hash-table :test 'equal))
(setq nfacts-success-rate 0.5)  ;; ranges 0..1, if it is close to 1 then we want to increase the hand set size; if it is close to 0 we want to reduce the handset size
(setq nfacts-tracing t)

(setq nfacts-flush-values (make-hash-table :test 'equal))
(puthash "weight" t nfacts-flush-values)

(defun nfacts-mode-meat()
  (interactive)
  (nhtml-mode)
  (setq major-mode 'nfacts-mode
        mode-name "nfacts mode"
	indent-line-function	'(lambda() nil)	;; undo nhtml-mode -> njavascript-mode's setting
        )
  (setq n-completes
        (append nsimple-shared-completes
                (append
                 n-completes
                 (list
                  (list	"^;$"	'nfacts-generate-empty-exercises)
                  )
                 )
                )
	)
  (define-key (current-local-map) "\C-cm" 'nfacts-delete)
  (define-key (current-local-map) "\C-x\C-s" 'nfacts-randomly-scramble)
  (define-key (current-local-map) "\C-y" 'nfacts-yank)
  (define-key (current-local-map) "\M-c" 'nfacts-run)
  (define-key (current-local-map) "\M-p" 'nfacts-yank-to-the-right)
  (define-key (current-local-map) "\M-\C-p" 'nfacts-lpr)
  (define-key (current-local-map) "\M-\C-t" 'nfacts-transpose-lines)
  ;;(define-key (current-local-map) "\M-i" 'nfacts-highlight)
  (define-key (current-local-map) "\M-\"" 'nfacts-dupe-and-invert)
  )

(defun nfacts-topic-of-last-exercise-if-any()
  (save-restriction
    (widen)
    (save-excursion
      (if (and (n-r "^q\n")
               (progn
                 (forward-line 1)
                 (n-s "^[^#]")
                 )
               (progn
                 (forward-line 0)
                 (looking-at "\\([^\n]+\\): ")
                 )
               )
          (nre-pat 1)
        )
      )
    )
  )

(defun nfacts-generate-empty-exercises()
  (let(
       (topicIfAny (nfacts-topic-of-last-exercise-if-any))
       emptyExercise
       )
    (setq emptyExercise (concat "q\n"
                                (if topicIfAny
                                    (concat topicIfAny ": ")
                                  ""
                                  )
                                "@@\na\n@@\n"
                                )
          )
    (n-complete-replace ";$" (nstr-* 5 emptyExercise))
    )
  )

(defun nfacts-get-q-a()
  (save-restriction
    (nfacts-narrow-to-current)
    (let(
         (q     (buffer-substring-no-properties (progn
                                    (goto-char (point-min))
                                    (n-s "^q$" t)
                                    (forward-line 1)
                                    (point)
                                    )
                                  (progn
                                    (n-s "^a$" t)
                                    (forward-line 0)
                                    (point)
                                    )
                                  )
                )
         (a     (buffer-substring-no-properties (progn
                                    (n-s "^a$" t)
                                    (forward-line 1)
                                    (point)
                                    )
                                  (progn
                                    (goto-char (point-max))
                                    (point)
                                    )
                                  )
                )
         )
      (cons q a)
      )
    )
  )
(defun nfacts-dupe-and-invert()
  (interactive)

  (let(
       (qA (nfacts-get-q-a))
       )
    (save-restriction
      (nfacts-narrow-to-current)
      (goto-char (point-max))
      (let(
           (q (cdr qA))
           (a (car qA))
           )
        (if (string-match "ruby equivalent to " a)
            (setq a (nstr-replace-regexp a "ruby equivalent to " "")
                  q (concat "Java equivalent to " q)
                  )
          )
        (insert "q\n"
                q
                "a\n"
                a
                )
        )
      )
    )
  )

(defun nfacts-get-id(qa)
  (gethash "id" qa)
  )
(defun nfacts-set-id(id qa)
  (if (integerp id)
      (setq id (int-to-string id)))
  (puthash "id" id qa)
  )

(defun nfacts-yank-to-the-right( &optional goLeftInstead)
  (interactive "P")
  (yank)
  (save-restriction
    (call-interactively 'narrow-to-region)
    (goto-char (point-min))

    (if (not goLeftInstead)
	(progn
	  (nsimple-marginalize-region 70 (point-min) (point-max))
	  (nsimple-indent-cmd 48)
	  )
      (nsimple-marginalize-region 48 (point-min) (point-max))
      )
    )
  )
(defun nfacts-lpr()
  (interactive)
  (untabify (point-min) (point-max))
  (nfacts-stop-wrapping 122)
  (require 'n-lpr)
  (call-interactively 'n-lpr)
  )
;; this seems a bit overlappy w/ nsimple-marginalize-region -- is it just to preserve the indentation that we have this?  seems like it would be better to combine...
(defun nfacts-stop-wrapping(maxCol)
  (save-excursion
    (untabify (point-min) (point-max))
    (goto-char (point-min))

    (let(
	 indent
	 )
      (while (not (eobp))
	(end-of-line)
	(if (<= (current-column) maxCol)
	    (progn
	      (forward-line 1)
	      (end-of-line)
	      )
	  (forward-char (- maxCol (current-column)))

	  (save-restriction
	    (save-excursion
	      (narrow-to-region (point) (progn
					  (forward-line 0)
					  (point)
					  )
				)
	      )
	    (if (n-r " ")
		(progn
		  (delete-horizontal-space)
		  )
	      )
	    )

	  (setq overflow (buffer-substring-no-properties (point) (save-excursion
						     (end-of-line)
						     (point)
						     )
					   )
		)
	  (delete-region (point) (save-excursion
				   (end-of-line)
				   (point)
				   )
			 )
	  (nsimple-back-to-indentation)
	  (setq indent (current-column))

	  (end-of-line)
	  (insert "\n")

	  (indent-to-column indent)
	  (insert overflow)
	  )
	)
      )
    )
  )
(defun nfacts-indent-to-answer()
  (interactive)
  (insert "\n")
  (if (looking-at "[ \t]*$")
      (indent-to-column 48)
    (nsimple-kill-to-end-of-line)
    (nfacts-yank-to-the-right)
    )
  )
(defun nfacts-narrow-to-current()
  (narrow-to-region (progn
                      (if (not (looking-at "^q$"))
                          (n-r "^q$" t))
                      (point)
                      )
                    (progn
                      (end-of-line)
                      (if (n-s "^q\\(uestion\\)?$")
                          (forward-line 0)
                        (goto-char (point-max))
                        )
                      (point)
                      )
                    )
  )

(defun nfacts-transpose-lines( &optional arg)
  (interactive "P")
  (if (not arg)
      (call-interactively 'nsimple-transpose-lines)
    (save-restriction
      (nfacts-narrow-to-current)
      (let(
           (oldQuestion	(nsimple-cut-region
                         (progn
                           (goto-char (point-min))
                           (nsimple-delete-line 1)
                           (point)
                           )
                         (progn
                           (n-s "^a$" t)
                           (nsimple-delete-line 1)
                           (point)
			   )
			 )
			)
	   (oldAnswer	(nsimple-cut-region
			 (point)
			 (point-max)
			 )
			)
	   )
	(insert "q\n" oldAnswer "a\n" oldQuestion)
	)
      )
    )
  )
;;(defun nfacts-highlight()
;;  (interactive)
;;  (let(
;;       (n (n-read-number "how many words? " nil t))
;;       )
;;    (forward-char 1)
;;    (forward-word -1)
;;    (insert "!!")
;;    (forward-word n)
;;    (insert "!!")
;;    )
;;  )
(defun nfacts-run()
  (interactive)
  (setq nfacts-current-facts-file (buffer-file-name))
  ;;(message "c-ompile-to-teacher-data, q-uiz, w-rite edit changes and resume quiz")
  (let(
       (cmd ?c) ; (if nfacts-edit-in-progress ?w ?c)) ;; (read-char))
       )
    (cond
     ((eq ?c cmd)
      (nfacts-compile-to-teacher-data)
      )
     ((eq ?q cmd)
      (nfacts-quiz-start)
      )
     ((eq ?w cmd)

      (condition-case nil
	  (progn
            (exit-recursive-edit)
            )
	(error (setq nfacts-edit-in-progress nil))
        )
      )
     )
    )
  (nfacts-summarize)
  )
(defun nfacts-compile-to-teacher-data()
  (save-some-buffers t)
  (n-host-shell-cmd-visible (format "sh $dp/adyn/teacher/transform1_into_flashcards.sh -browse %s" (nfn-prefix)))
  )
(defun nfacts-delete()
  "delete the current exercise; it is not the last one, then replace it with the last exercise so as to maintain the correspondence between exercises and IDs in this file"
  (interactive)
  (let(
       (targetExerciseBegin (progn
                              (if (not (looking-at "^q$"))
                                  (n-r "^q$" t))
                              (point)
                              )
                            )
       (targetExerciseEnd (progn
                            (end-of-line)
                            (if (n-s "^q$")
                                (forward-char -1)
                              (goto-char (point-max))
                              )
                            (point)
                            )
                          )
       targetExercise
       )
    (setq targetExercise (buffer-substring-no-properties targetExerciseBegin targetExerciseEnd))
    (delete-region targetExerciseBegin targetExerciseEnd)
    (if (not (eobp))
	(insert (save-excursion
		  (goto-char (point-max))
		  (nfacts-delete)
		  )
		)
      )
    targetExercise
    )
  )
(defun nfacts-to-list()
  "make a list of cons (each cons containing a q+a pair) for the data in the current file"
  (let(
       l qa q a
	 )
    (save-excursion
      (goto-char (point-min))
      (while (n-s "^q$")
	(forward-line 1)
	(setq q (buffer-substring-no-properties (point)
                                                (progn
                                                  (n-s "^a$")
                                                  (forward-line -1)
                                                  (end-of-line)
                                                  (point)
                                                  )
                                                )
	      a (buffer-substring-no-properties (progn
                                                  (n-s "^a$")
                                                  (forward-line 1)
                                                  (point)
                                                  )
                                                (progn
                                                  (if (n-s "^q$")
                                                      (progn
                                                        (forward-line -1)
                                                        (end-of-line)
                                                        )
                                  (goto-char (point-max))
                                                    )
                                                  (point)
                                                  )
                                                )
	      qa (cons q a)
	      l  (cons qa l)
	      )
	)
      l
      )
    )
  )

(defun nfacts-from-list(l)
  (let(
       q a
	 )
    (while l
      (setq q (caar l)
	    a (cdar l)
	    l (cdr l)
	    )
      (insert "q\n" q "\na\n" a "\n")
      )
    )
  )


(defun nfacts-randomly-scramble()
  (interactive)
  (let(
       (l (nfacts-to-list))
       )
    (delete-region (point-min) (point-max))
    
    (setq l (nlist-randomly-scramble l))
    
    (nfacts-from-list l)
    )
  )
(defun nfacts-yank()
  (interactive)
  (save-restriction
    (narrow-to-region (point) (point))
    (call-interactively 'yank)

    ;; join lengthy comments so they fill my very wide output
    (goto-char (point-min))
    (while (n-s "^# ")
      (nsimple-join-lines "^# ")
      )

    (replace-regexp "•" "*")

    (goto-char (point-min))
    (replace-regexp "’" "'")

    (goto-char (point-min))
    (replace-regexp "“" "'")

    (goto-char (point-min))
    (replace-regexp "”" "'")

    (goto-char (point-min))
    (replace-regexp "[’-™]" "")

    (goto-char (point-min))
    (replace-regexp "^[ \t]*" "")

    (goto-char (point-min))
    (replace-regexp "[ \t]+$" "")

    (goto-char (point-min))
    (replace-regexp "\n+$" "\n")

    (goto-char (point-min))
    (replace-regexp "^[Qq]uestion" "q")

    (goto-char (point-min))
    (replace-regexp "^[Aa]nswer" "a")

    (goto-char (point-min))
    (while (n-s "^[qa]$")
      (forward-char -1)
      (or (looking-at "q")
          (error "nfacts-yank: out of order"))
      (forward-line 1)
      (n-s "^[qa]$" t)
      (forward-char -1)
      (or (looking-at "a")
          (error "nfacts-yank: missing answer"))
      (forward-line 1)
      )

    (goto-char (point-min))
    (while (n-s "^[Ll]ist ")
      (delete-char -5)
      (insert "ul")
      (funcall (nkeys-binding " "))      ; expand into an HTML unordered list
      )

    (goto-char (point-min))
    (while (n-s "\\([^<>\n]+\\) links to \\([^ \t\n]*/[^<>, \t\n]*\\)")
      (let(
           (what (n--pat 1))
           (url (n--pat 2))
           )
        (setq url (nstr-replace-regexp url "HTTP:" "http:"))
        (setq url (nstr-replace-regexp url "^\\([^h]\\)" "http:\\1"))
        (delete-region (point) (progn
                                 (n-r what t)
                                 (point)
                                 )
                       )
        (insert "<a href='" url "'>" what "</a>")
        )
      )
    (goto-char (point-min))
    (replace-regexp "^#" " #") ;; for bringing in, e.g., Ruby code

    (goto-char (point-max))
    )
  (n-file-save-cmd)
  )

(defun nfacts-strip-crap(s)
  (nstr-replace-regexp
   (nstr-replace-regexp
    (nstr-replace-regexp s "^#.*" "")
    "\n+" "\n")
   "^\n+" "")
  )


(defun n-trace-hash(h &optional header)
  (if (not header)
      (setq header ""))
  (n-trace "= %s ================================================" header)
  (loop for key being the hash-keys of h do
        (n-trace "%s  -> %s" key (gethash key h))
        )
  (n-trace "EOD")
  )

(defun nfacts-get-qa-key(qa)
  (concat (gethash "q" qa)
          "\n"
          (gethash "a" qa)
          )
  )
(defun nfacts-verify-uniqueness(qa)
  (let(
       (key (nfacts-get-qa-key qa))
       )
    (if (gethash key nfacts-by-qa)
        (progn
          (n-trace "duplicate exercise seen: id=%s" (nfacts-get-id qa))
          (read-char)
          )
      ;;(n-trace "verified uniquesness of id=%s" (nfacts-get-id qa))
      (puthash key qa nfacts-by-qa)
      )
    )
  )

(defun nfacts-load-exercise(&optional qa skipUniquenessCheck)
  (if qa
      (setq skipUniquenessCheck t)
    (setq qa (make-hash-table :test 'equal))
    )
  (save-restriction
    (nfacts-narrow-to-current)
    (let(
         (q (nfacts-strip-crap (buffer-substring-no-properties (progn
                                                   (goto-char (point-min))
                                                   (forward-line 1)
                                                   (point)
                                                   )
                                                 (progn
                                                   (n-s "^a$" t)
                                                   (forward-line 0)
                                                   (point)
                                                   )
                                                 )
                               )
            )
         (a (nfacts-strip-crap (buffer-substring-no-properties (progn
                                                   (forward-line 1)
                                                   (point)
                                                   )
                                                 (progn
                                                   (goto-char (point-max))
                                                   (point)
                                                   )
                                                 )
                               )
            )
         )
      (if (string= "@@\n" a)
          nil ;; placeholder for expansion -- just ignore
        (puthash "src.fn" (buffer-file-name) qa)
        (puthash "q" q qa)
        (puthash "a" a qa)
        (goto-char (point-min))
        (if (n-s "^#id=")
            (progn
              (n-narrow-to-line)
              (forward-line 0)
              (forward-char 1)
              (while (n-s "\\([0-9a-zA-Z_]+\\)=\\([^;]+\\);")
                (let(
                     (key (nre-pat 1))
                     (val (nre-pat 2))
                     )
                  (puthash key val qa)
                  (if (not (equal key "id"))
                      (puthash key t nfacts-flush-values))
                  )
                )
              )
          )
        (if (not skipUniquenessCheck)
            (nfacts-verify-uniqueness qa))

        ;;(n-trace-hash qa "loaded exercise")
        qa
        )
      )
    )
  )
(defun nfacts-quiz-start--add-and-gather-exercises()
  (widen)

  (goto-char (point-min))
  (let(
       (id-counter 1)
       idWasAdded
       exercises
       )
    (clrhash nfacts-by-qa)
    (while (n-s "^q$")
      (let(
           (ex (nfacts-load-exercise))
           id
           weight
           )
        (if ex
            (progn
              (setq id (gethash "id" ex))
              (if id
                  (progn
                    (setq weight (nfacts-get-weight ex))
                    (if idWasAdded
                        (progn
                          (error "nfacts: exercise id=%s follows ID-less exercise" id)
                          )
                      )
                    (setq id-counter (1+ (string-to-int id)))
                    )
                (end-of-line)
                (insert "\n#id=" (format "%d" id-counter) ";")
                (nfacts-set-id id-counter ex)
                (setq id id-counter
                      weight 0
                      id-counter (1+ id-counter)
                      idWasAdded t
                      )
                )
              (if (>= weight 0)
                  (setq exercises (cons ex exercises))
                )
              )
          )
        )
      )
    (if (not exercises)
        (error "nfacts-quiz-start--add-and-gather-exercises: nothing gathered"))
    (reverse exercises)
    )
  )

(if (not (functionp 'shuffle-vector))
    (defun shuffle-vector(x)
      (message "Nelson's shuffle-vector placeholder")
      (read-char)
      )
  )


(defun nfacts-choose-table-set(exercises)
  (let(
       (v (nlist-make-vector exercises))
       )
    (nlist-slice (shuffle-vector v) 0 nfacts-table-set-default-size t)
    )
  )
(defun nfacts-flush(qa)
  (save-excursion
    (widen)
    (goto-char (point-min))
    (n-s (concat "^#id=" (nfacts-get-id qa) ";") t)
    (nsimple-delete-line)
    (insert "#id=" (nfacts-get-id qa) ";")
    (maphash '(lambda(key val)
                (if (gethash key nfacts-flush-values)
                    (insert key "=" val ";"))
                )
             qa
             )
    (insert "\n")
    (save-buffer)
    )
  )

(defun nfacts-set-weight(qa weight)
  (puthash "weight" (int-to-string weight) qa)
  (gethash "weight" qa)
  ;;(nelisp-bp "nfacts-set-weight" "nfacts.el" 667);;;;;;;;;;;;;;;;;
  (nfacts-flush qa)
  )

(defun nfacts-get-weight(qa)
  (let(
       (weight (gethash "weight" qa))
       )
    (if weight
        (string-to-int weight)
      0
      )
    )
  )

(defun nfacts-add-to-weight(qa addend)
  (let(
       (weight  (+ addend (nfacts-get-weight qa)))
       )
    (nfacts-set-weight qa weight)
    )
  )
(defun nfacts-adjust-success-rate(latest)
  (setq nfacts-success-rate (/ (+ (* 9 nfacts-success-rate) latest) 10))
  )
(defun nfacts-trace(msg &rest args)
  (if  nfacts-tracing
      (progn
        (apply 'message (concat msg " (hit key to cont.)") args)
        (read-char)
        )
    )
  )
(defun nfacts-edit(qa)
  (nfacts-goto qa)
  (let(
       (nfacts-edit-in-progress t)
       )
    (recursive-edit)
    )
  (n-file-save-cmd)
  (nfacts-load-exercise qa)
  (delete-other-windows)
  (goto-char (point-min))
  )
(defun nfacts-goto(qa)
  (n-file-find (gethash "src.fn" qa))
  (widen)
  (goto-char (point-min))
  (n-s (concat "^#id=" (nfacts-get-id qa)) t)
  (nfacts-narrow-to-current)
  )
(defun nfacts-get-set-listing--summary(qa)
  (let(
       (q (gethash "q" qa))
       (weight (nfacts-get-weight qa))
       (id (nfacts-get-id qa))
       )
    (concat id ":\tw" (int-to-string weight) "\t" (nstr-replace-regexp q "\n.*" "") "...")
    )
  )
(defun nfacts-get-set-listing(set)
  (let(
       (sl "")
       )
    (while set
      (setq sl (concat sl (nfacts-get-set-listing--summary (car set)) "\n")
            set (cdr set)
            )
      )
    sl
    )
  )
(defun nfacts-debug-info()
  (concat
   "hand-set ======================\n"
   (nfacts-get-set-listing nfacts-hand-set)
   "table-set =====================\n"
   (nfacts-get-set-listing nfacts-table-set)
   )
  )
(defun nfacts-banish(qa)
  (nfacts-set-weight qa -999)
  )
(defun nfacts-increase-interest(qa)
  (let(
       (weight (nfacts-get-weight qa))
       )
    ;; make sure exercises that are a struggle don't disappear too quickly
    (nfacts-add-to-weight qa 2)
    )
  )
(defun nfacts-seen-before(qa)
  (not (null (gethash "weight" qa)))
  )

(defun nfacts-reduce-interest(qa)
  (nfacts-add-to-weight qa -1)

  ;;(if (nfacts-seen-before qa)
  ;;    (nfacts-add-to-weight qa -1)
  ;;  ;; this is the first time the user has seen this card.
  ;;  ;; Since the user discarded it immediately, let's assume they don't want to see it again anytime
  ;;  ;; soon.  So we won't banish it altogether (-999), but we'll put in deeper in the hole than -1.
  ;;  (nfacts-set-weight qa -500)
  ;;  )
  )

(defun nfacts-quiz-display(q srcFn)
  (let(
       (x (format "%s, %d/%d\n\n%s (hit a key to cont.)\n%s" srcFn (length nfacts-hand-set) (length nfacts-table-set) q (if nfacts-debug-mode (nfacts-debug-info) "")))
       sizeInLines
       )
    (setq sizeInLines (nstr-count-lines q))
    (if (< sizeInLines 8)
        (progn
          (message "%s" x)
          (read-char)
          )
      (switch-to-buffer "*nfacts-tmp*")
      (insert x)
      (read-char)
      (kill-buffer (current-buffer))
      )
    )
  )

(defun nfacts-quiz(qa &optional thisIsAretry)
  (let(
       (srcFn (nstr-replace-regexp
               (nstr-replace-regexp (gethash "src.fn" qa) ".*/" "")
               ".facts$"
               "")
              )
       (q (gethash "q" qa))
       (a (gethash "a" qa))
       done
       cmd
       )
    (nfacts-quiz-display q srcFn)
    (while (not done)
      (setq cmd (progn
                  (message "%s\na-add new one,b-ack,d-iscard this one, D-iscard forever, e-dit, n-ext, r-eplace this one, x-delete, z-suspend, Z-toggle-debug, 1,2,3... jump to links" a)
                  (read-char)
                  )
            done t
            )

      (if (eq cmd ? ) (setq cmd ?n))

      (cond
       ((eq cmd ?a)
        (setq nfacts-hand-set (nlist-rotate2 nfacts-hand-set))
        (if nfacts-table-set
            (setq nfacts-hand-set (cons (car nfacts-table-set) nfacts-hand-set)
                  nfacts-table-set (cdr  nfacts-table-set)
                  )
          (message "cannot add because table set is empty")
          )
        (nfacts-increase-interest qa)
        )
       ((eq cmd ?d)
        (setq nfacts-hand-set (cdr nfacts-hand-set))
        (nfacts-reduce-interest qa)
        )
       ((eq cmd ?D)
        (setq nfacts-hand-set (cdr nfacts-hand-set))
        (nfacts-banish qa)
        )
       ((eq cmd ?e)
        (nfacts-edit qa)
        )
       ((eq cmd ?n)
        (setq nfacts-hand-set (nlist-rotate2 nfacts-hand-set))
        (nfacts-increase-interest qa)
        )
       ((eq cmd ?r)
        (setq nfacts-hand-set (cdr nfacts-hand-set))
        (nfacts-reduce-interest qa)
        (if nfacts-table-set
            (setq
             nfacts-hand-set (cons (car nfacts-table-set) nfacts-hand-set)
             nfacts-table-set (cdr  nfacts-table-set)
             )
          (message "just discarded because table set is empty")
          )
        (nfacts-adjust-success-rate 1)
        )
       ((eq cmd ?x)
        (nfacts-goto qa)
        (nfacts-delete)
        (widen)
        (setq nfacts-hand-set (cdr nfacts-hand-set))
        )
       ((eq cmd ?z)
        (recursive-edit)
        )
       ((eq cmd ?Z)
        (setq nfacts-debug-mode (not nfacts-debug-mode))
        )
       ((and (>= cmd ?0) (<= cmd ?9))
        (nfacts-quiz-load-link cmd a)
        (setq done nil)
        )
       )
      )
    )
  (if (and (not thisIsAretry)
           nfacts-table-set
           (not nfacts-hand-set)
           )
      (setq nfacts-hand-set (list (car nfacts-table-set))
            nfacts-table-set (cdr nfacts-table-set)
            )
    )
  nfacts-hand-set
  )

(defun nfacts-quiz-load-link(cmd a)
  (let(
       (url (and (string-match (concat "\t" (char-to-string cmd) ".*\t\t\t*\\([^\t].*\\)\n") a)
                 (nre-pat 1 a)
                 )
            )
       )
    (n-host-shell-cmd (concat "browser " url))
    )
  )
;; (nfacts-quiz-load-link ?3 "lskdfj lsdjflk lsdkjf \n\t3\tz:/work/facts/grammar/Spanish/Spanish_vt_hacer.html\n")

(defun nfacts-too-hard-p()
  (< nfacts-success-rate 0.3)
  )

(defun nfacts-too-easy-p()
  (> nfacts-success-rate 0.7)
  )

(defun nfacts-summarize()
  (n-file-find nfacts-current-facts-file)
  (let(
       (exCount (nre-grep-count "^#id="))
       (masteredCount (nre-grep-count "^#id=.*;weight=-"))
       (troubleCount (nre-grep-count "^#id=.*;weight=[^-0]"))
       masteryRatio
       troubleRatio
       )
    (setq masteryRatio (n-math-percentage masteredCount exCount))
    (setq troubleRatio (n-math-percentage troubleCount exCount))
    (message "%0.1f%% ok, %0.1f%% trouble (%d/%d/%d) -- hit a key" masteryRatio troubleRatio masteredCount troubleCount exCount)
    (read-char)
    )
  )


(defun nfacts-quiz-start()
  (interactive)
  (let(
       (exercises (nfacts-quiz-start--add-and-gather-exercises))
       all
       )
    (setq all       (nfacts-choose-table-set exercises)
          nfacts-hand-set  (nlist-slice all 0 nfacts-hand-set-default-size t)
          nfacts-table-set (nlist-slice all nfacts-hand-set-default-size nil t)
          nfacts-success-rate 0.5
          )
    )
  (while (nfacts-quiz (car nfacts-hand-set)))

  (n-file-save-cmd)
  )
;;(n-file-find "~/work/doc/facts/ruby2.facts")
;;(n-file-find "~/work/doc/facts/verb_do")
;;(nfacts-run)
