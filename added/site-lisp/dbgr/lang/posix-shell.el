;;; Copyright (C) 2010 Rocky Bernstein <rocky@gnu.org>
;;;
;;; Common POSIX-Shell like constants and regular expressions.
;;; Actually a lot of this is not about POSIX shell as it is about the
;;; common-ness of bashdb, zshdb, and kshdb. But since those are the
;;; *only* debuggers I know of for POSIX shells, it's not too much of
;;; a stretch to think of this as for all "shell".
(eval-when-compile (require 'cl))

(require 'load-relative)
(require-relative-list '("../common/regexp" "../common/loc" "../common/track") 
		       "dbgr-")

(defconst dbgr-shell-backtrace-loc-pat
  (make-dbgr-loc-pat
   :regexp "^[ \t]+from \\([^:]+\\):\\([0-9]+\\)\\(?: in `.*'\\)?"
   :file-group 1
   :line-group 2)
  "A dbgr-loc-pat struct that describes a Shell backtrace (or
traceback) line."  )

(defconst dbgr-shell-frame-start-regexp
  "\\(?:^\\|\n\\)\\(->\\|##\\)")

(defconst dbgr-shell-frame-num-regexp
  "\\([0-9]+\\)")

(defconst dbgr-shell-frame-file-regexp
  "[ \t\n]+\\(?:in\\|from\\) file `\\(.+\\)'")

(defconst dbgr-shell-frame-line-regexp
  "[ \t\n]+at line \\([0-9]+\\)\\(?:\n\\|$\\)")

(provide-me "dbgr-lang-")
