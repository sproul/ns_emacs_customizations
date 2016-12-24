(provide 'ndcm)
(setq ndcm-file "~/work/a3x/nelson.dcm")
(if (not (boundp ' ndcm-mode-map))
    (setq ndcm-mode-map (make-sparse-keymap)))

(defun ndcm-mode-meat()
  (interactive)
  (setq major-mode 'ndcm-mode
        mode-name "ndcm mode"
        )
  (setq n-completes
        (append nsimple-shared-completes
                (list
                 (list	".*{$"	'n-complete-dft	"Ctrl-@@}@@")
                 (list	"^a$"	'n-complete-add-and-append	"add-word /t \"@@" "\" @ @@")
                 (list	"^p$"	'n-complete-dft	"unctuate \"@@\" @@")
                 )
                )
        )
  (use-local-map ndcm-mode-map)
  (define-key ndcm-mode-map " " 'n-complete-or-space)
  )
(defun ndcm-define-token()
  (interactive)
  (ndcm-enter-line "add-word /t @@/g \"" "\" @ @@")
  )
(defun ndcm-punctuate-token()
  (interactive)
  (ndcm-enter-line "punctuate \"" "\" @@")
  )
(defun ndcm-enter-line(prefix suffix)
  (let(
       (token	(n-grab-token))
       )
    (n-loc-push)
    (n-file-find ndcm-file)
    (forward-line 0)
    (insert prefix token suffix"\n")
    (forward-line -1)
    )
  )

