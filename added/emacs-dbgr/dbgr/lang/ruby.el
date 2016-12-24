;;; Copyright (C) 2010 Rocky Bernstein <rocky@gnu.org>
;;; Common Ruby constants and regular expressions.
(eval-when-compile (require 'cl))

(require 'load-relative)
(require-relative-list '("../common/regexp" "../common/loc" "../common/track") 
		       "dbgr-")


(defconst dbgr-rails-backtrace-loc-pat
  (make-dbgr-loc-pat
   :regexp "^\\([^:]+\\):\\([0-9]+\\)\\(?:[:]in `.*'\\)?"
   :file-group 1
   :line-group 2)
  "A dbgr-loc-pat struct that describes a Rails backtrace (or
traceback) line."  )

(defconst dbgr-ruby-backtrace-loc-pat
  (make-dbgr-loc-pat
   :regexp "^[ \t]+from \\([^:]+\\):\\([0-9]+\\)\\(?: in `.*'\\)?"
   :file-group 1
   :line-group 2)
  "A dbgr-loc-pat struct that describes a Ruby backtrace (or
traceback) line."  )

(defconst dbgr-rubinius-backtrace-loc-pat
  (make-dbgr-loc-pat
   :regexp "^\\(?:\\[0;3[1-4]m\\)?[ \t]+.* at \\([^:]+\\):\\([0-9]+\\)"
   :file-group 1
   :line-group 2)
  "A dbgr-loc-pat struct that describes a Rubinius backtrace (or
traceback) line."  )

(defconst dbgr-rubinius-Xagent-backtrace-loc-pat
  (make-dbgr-loc-pat
   :regexp "^\\(?:\\[0;3[1-4]m\\)?0x[a-f0-9]\\{8\\}: .* in \\([^:]+\\):\\([0-9]+\\) ([+][0-9]+)"
   :file-group 1
   :line-group 2)
  "A dbgr-loc-pat struct that describes a Rubinius Xagent backtrace (or
traceback) line."  )

(defconst dbgr-ruby-dollar-bang
      (make-dbgr-loc-pat
       :regexp "^[ \t]*[[]?\\(.+\\):\\([0-9]+\\):in `.*'"
       :file-group 1
       :line-group 2)
  "A dbgr-loc-pat that struct that describes a Ruby $! string."
)

;; FIXME: there is probably a less redundant way to do the following
;; FNS. 
(defun dbgr-rails-goto-backtrace-line (pt)
  "Display the location mentioned by the Rails backtrace line
described by PT."
  (interactive "d")
  (dbgr-goto-line-for-pt pt "rails-backtrace"))

(defun dbgr-rubinius-goto-Xagent-backtrace-line (pt)
  "Display the location mentioned by the Rubinius Xagent- backtrace line
described by PT."
  (interactive "d")
  (dbgr-goto-line-for-pt pt "rubinius-backtrace-Xagent"))

(defun dbgr-ruby-goto-backtrace-line (pt)
  "Display the location mentioned by the Ruby backtrace line
described by PT."
  (interactive "d")
  (dbgr-goto-line-for-pt pt "backtrace"))

(defun dbgr-ruby-goto-dollarbang-backtrace-line (pt)
  "Display the location mentioned by a Ruby $! backtrace line
described by PT."
  (interactive "d")
  (dbgr-goto-line-for-pt pt "dollar-bang"))

(defun dbgr-ruby-populate-command-keys (&optional map)
  "Bind the debugger function key layout used by many debuggers.

\\{dbgr-example-map-standard}"
  (define-key map (kbd "C-c !!") 'dbgr-ruby-goto-dollarbang-backtrace-line)
  (define-key map (kbd "C-c !b") 'dbgr-ruby-goto-backtrace-line)
  (define-key map (kbd "C-c !r") 'dbgr-rails-goto-backtrace-line)
  )


;; Some things common to all trepan debuggers (Rubinius and Ruby 1.9.2)
(defconst dbgr-trepan-frame-start-regexp
  "\\(?:^\\|\n\\)\\(-->\\|   \\)")

(defconst dbgr-trepan-frame-num-regexp
  "#\\([0-9]+\\)")

(defconst dbgr-trepan-frame-line-regexp
  "[ \t\n]+at line \\([0-9]+\\)\\(?:\n\\|$\\)")


(provide-me "dbgr-lang-")
