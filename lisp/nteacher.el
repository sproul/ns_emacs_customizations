(provide 'nteacher)
(setq nteacher-lang-to-noun-markers-hash  (make-hash-table :test 'equal))
(defun nteacher-mode-meat()
  (let(
       (map             (make-sparse-keymap))
       )
    (define-key map "\C-m" 'nteacher-set-noun-recordkeeping)
    (define-key map "\M--" 'nteacher-browse-dictionary-for-this-word)

    (use-local-map map)
    )
  (setq major-mode 'nteacher-mode
	mode-name "nteacher"
	)
  )
(defun nteacher-noun-marker-hash-make-key(lang noun-marker)
  (concat lang "/" noun-marker)
  )

(defun nteacher-noun-marker-put(lang noun-marker)
  (let(
       (key     (nteacher-noun-marker-hash-make-key lang noun-marker))
       )
    (puthash key (gethash lang (nteacher-noun-markers-hash-for lang)))
    )
  )
(defun nteacher-noun-markers-hash-for(lang)
  (if (not (gethash lang nteacher-lang-to-noun-markers-hash))
      (puthash lang (make-hash-table :test 'equal) nteacher-lang-to-noun-markers-hash))
  (gethash lang nteacher-lang-to-noun-markers-hash)
  )
(defun nteacher-loop-over-noun-markers-for(lang fn)
  (let(
       (noun-markers-hash       (gethash lang nteacher-lang-to-noun-markers-hash))
       )
    (maphash fn noun-markers-hash)
    )
  )

(defun nteacher-singularize-noun(lang possibly-plural-noun)
  (setq possibly-plural-noun (cond
                              ((string= lang "German")
                               (cond
                                ((string-match "en$" possibly-plural-noun) (nstr-replace-regexp possibly-plural-noun "n$" ""))
                                (t possibly-plural-noun)
                                )
                               )
                              ((string= lang "Spanish")
                               (cond
                                ((string-match "s$" possibly-plural-noun) (nstr-replace-regexp possibly-plural-noun "s$" ""))
                                (t possibly-plural-noun)
                                )
                               )
                              ((string= lang "Italian")
                               (cond
                                ((string-match "i$" possibly-plural-noun) (nstr-replace-regexp possibly-plural-noun "i$" "o"))
                                ;;((string-match "e$" possibly-plural-noun) (nstr-replace-regexp possibly-plural-noun "e$" "a"))
                                (t possibly-plural-noun)
                                )
                               )
                              ((string= lang "French")
                               (cond
                                ;;((string-match "eux$" possibly-plural-noun) (nstr-replace-regexp possibly-plural-noun "eux$" "eu"))
                                ((string-match "eaux$" possibly-plural-noun) (nstr-replace-regexp possibly-plural-noun "eaux$" "eau"))
                                ((string-match "s$" possibly-plural-noun) (nstr-replace-regexp possibly-plural-noun "s$" ""))
                                (t possibly-plural-noun)
                                )
                               )
                              )
        )
  )
(defun nteacher-lang()
  (save-excursion
    (forward-line 0)
    (if (and (n-s "'")
             (or (looking-at "\\(Italian\\)")
                 (looking-at "\\(Spanish\\)")
                 (looking-at "\\(English\\)")
                 (looking-at "\\(French\\)")
                 (looking-at "\\(German\\)")
                 )
             )
        (nre-pat 1)
      (error "nteacher-lang: ")
      )
    )
  )

(defun nteacher-grab-token()
  (nstr-replace-regexp (n-grab-token nil t) "[,:]$" "")  ;; these "accent" chars precede an alphabetical character; if they are at the word's end, that means they are punctuation, not accents
  )


(defun nteacher-browse-dictionary-for-this-word()
  (interactive)
  (let(
       (word    (nteacher-grab-token))
       cleanedWord
       )
    (setq cleanedWord (nstr-replace-regexp word "[/\\^`:,]" ""))
    (nhtml-browse nil (concat "http://dictionary.reverso.net/" (nstr-downcase (nteacher-lang)) "-english/" cleanedWord))
    )
  )

(defun nteacher-push-loc-at-likely-next-interesting-spot()
  (save-excursion
    (if (or
         (not (nteacher-advance-past-next-noun-marker-on-this-line)) ;; this succeeds if there is a (second) noun marker remaining on this line
         (progn
           (end-of-line)
           (if (n-s "'\\(French\\|Spanish\\|Italian\\|German\\)' =>")
               (progn
                 (forward-line 0)
               
                 
                 
                 (end-of-line)
                 (forward-word -1)
                 ;;(nteacher-advance-past-next-noun-marker-on-this-line)



                 )
             )
           )
         )
        (n-loc-push)
      )
    )
  )

(defun nteacher-looking-at-noun-marker(lang noun-marker)
  ;;(setq noun-marker (nstr-trim noun-marker))
  (let(
       (key (concat lang "/" noun-marker))
       (noun-markers-hash       (nteacher-noun-markers-hash-for lang))
       )
    (puthash key t noun-markers-hash)
    )
  (looking-at noun-marker)
  )
(defun nteacher-advance-past-next-noun-marker-on-this-line()
  nil
  ;; figure this out later...
  ;;(save-restriction
  ;;(n-narrow-to-line)
  ;;(let(
  ;;hit
  ;;)
  ;;(nteacher-loop-over-noun-markers-for (nteacher-lang) '(lambda(noun-marker val)
  ;;(if (and (not hit)
  ;;(n-s noun-marker)
  ;;)
  ;;(setq hit t)
  ;;)
  ;;(n-trace "looked for %s" noun-marker)
  ;;)
  ;;)
  ;;hit
  ;;)
  ;;)
  )

(defun nteacher-fixup-line()
  (save-restriction
    (save-excursion
      (n-narrow-to-line)
      (forward-line 0)
      ;; no need for the backslash-apostrophe; it complicates my search code, and apostrophes are ok since I'm switching to double quotes anyway
      (replace-regexp "=> '" "=> \"")
      (replace-regexp "\\\\'" "'")
      (replace-regexp "',$" "\",")
      )
    )
  )

(defun nteacher-set-noun-recordkeeping()
  (interactive)
  (nteacher-fixup-line)
  (let(
       canonical
       gender-guess
       number-guess
       (lang    (nteacher-lang))
       (noun    (nteacher-grab-token))
       singularized-noun
       )
    (setq singularized-noun (nteacher-singularize-noun lang noun))
    (insert singularized-noun)
    (insert ">@@>}")
    (n-r    ">@@>}" t)
    (skip-chars-backward (n-grab-token-chars))
    (if (string= lang "German")
        (progn
          (setq noun (nstr-capitalize noun))
          (save-excursion
            (capitalize-word 1)
            )
          )
      )
    (forward-word -1)
    (cond
     ((string= lang "German")
      (cond
       ((nteacher-looking-at-noun-marker lang "das ")                       (setq number-guess "n"  gender-guess "n" canonical "der"))
       ((nteacher-looking-at-noun-marker lang "dem ")              (setq number-guess "sd" gender-guess "m" canonical "der"))
       ((nteacher-looking-at-noun-marker lang "den ")              (setq number-guess "sa" gender-guess "m" canonical "der"))
       ((nteacher-looking-at-noun-marker lang "die ")               (setq number-guess "s"  gender-guess "f" canonical "der"))
       ((nteacher-looking-at-noun-marker lang "der ")                (setq number-guess "s"  gender-guess "m" canonical "der"))
       ((nteacher-looking-at-noun-marker lang "ein ")                (setq number-guess "s"  gender-guess "m" canonical "ein"))
       ((nteacher-looking-at-noun-marker lang "eine ")               (setq number-guess "s"  gender-guess "f" canonical "ein"))
       ((nteacher-looking-at-noun-marker lang "einem ")              (setq number-guess "sd" gender-guess "m" canonical "ein"))
       ((nteacher-looking-at-noun-marker lang "einen ")              (setq number-guess "sa" gender-guess "m" canonical "ein"))
       ((nteacher-looking-at-noun-marker lang "einer ")              (setq number-guess "sd" gender-guess "m" canonical "ein"))
       )
      )
     ((string= lang "Spanish")
      (cond
       ((nteacher-looking-at-noun-marker lang "el ")                (setq number-guess "s"  gender-guess "m" canonical "el"))
       ((nteacher-looking-at-noun-marker lang "la ")               (setq number-guess "s"  gender-guess "f" canonical "el"))
       ((nteacher-looking-at-noun-marker lang "las ")                     (setq number-guess "p" gender-guess "f" canonical "el"))
       ((nteacher-looking-at-noun-marker lang "los ")                     (setq number-guess "p" gender-guess "m" canonical "el"))
       ((nteacher-looking-at-noun-marker lang "un ")                (setq number-guess "s"  gender-guess "m" canonical "un"))
       ((nteacher-looking-at-noun-marker lang "una ")               (setq number-guess "s"  gender-guess "f" canonical "un"))
       )
      )
     ((string= lang "Italian")
      (cond
       ((nteacher-looking-at-noun-marker lang "l'")                (setq number-guess "s"  gender-guess "f" canonical "la"))
       ((nteacher-looking-at-noun-marker lang "i ")                (setq number-guess "p" gender-guess "m" canonical "il"))
       ((nteacher-looking-at-noun-marker lang "il ")            (setq number-guess "s"  gender-guess "m" canonical "il"))
       ((nteacher-looking-at-noun-marker lang "gli ")                (setq number-guess "p" gender-guess "m" canonical "il"))
       ((nteacher-looking-at-noun-marker lang "le ")                      (setq number-guess "p"  gender-guess "f" canonical "il"))
       ((nteacher-looking-at-noun-marker lang "lo ")            (setq number-guess "s"  gender-guess "m" canonical "il"))
       ((nteacher-looking-at-noun-marker lang "un ")            (setq number-guess "s"  gender-guess "m" canonical "un"))
       ((nteacher-looking-at-noun-marker lang "una ")            (setq number-guess "s"  gender-guess "f" canonical "un"))
       )
      )
     ((string= lang "French")
      (cond
       ((nteacher-looking-at-noun-marker lang "l'")                (setq number-guess "s"  gender-guess "m" canonical "le"))
       ((nteacher-looking-at-noun-marker lang "la ")                     (setq number-guess "s"  gender-guess "f" canonical "le"))
       ((nteacher-looking-at-noun-marker lang "le ")                (setq number-guess "s"  gender-guess "m" canonical "le"))
       ((nteacher-looking-at-noun-marker lang "les ")                           (setq number-guess "p" gender-guess "m" canonical "le"))
       ((nteacher-looking-at-noun-marker lang "un ")                (setq number-guess "s"  gender-guess "m" canonical "un"))
       ((nteacher-looking-at-noun-marker lang "une ")                     (setq number-guess "s"  gender-guess "f" canonical "un"))
       )
      )
     )
    (if number-guess
        (progn
          (insert "{" canonical)
          (delete-region (point) (progn
                                   (n-s "\\( \\|'\\)")
                                   (point)
                                   )
                         )
          (insert " ")
          (n-complete-leap)
          (insert number-guess)
          )
      )
    (nteacher-push-loc-at-likely-next-interesting-spot)
    (nteacher-update-dp-noun-recordkeeping lang singularized-noun gender-guess)
    )
  )

(defun nteacher-update-dp-noun-recordkeeping(lang noun gender-guess)
  (n-file-find (concat "$dp/teacher/grammar/" lang ".dp"))
  (goto-char (point-min))
  (if (not (n-s (concat "'" noun "'")))
      (progn
        (forward-line 2)
        (insert "'" noun "' => '',\n")
        (n-r "'" t)
        (if gender-guess
            (progn
              (insert gender-guess)
              (forward-word -1)
              )
          )
        )
    )
  )
