;;; Copyright (C) 2010, 2011 Rocky Bernstein <rocky@gnu.org>
;;; gdb debugger

(eval-when-compile (require 'cl))

(require 'load-relative)
(require-relative-list '("../../common/regexp" "../../common/loc") "dbgr-")

(defvar dbgr-pat-hash)
(declare-function make-dbgr-loc-pat (dbgr-loc))

(defvar dbgr-gdb-pat-hash (make-hash-table :test 'equal)
  "hash key is the what kind of pattern we want to match:
backtrace, prompt, etc.  the values of a hash entry is a
dbgr-loc-pat struct")

(declare-function make-dbgr-loc "dbgr-loc" (a b c d e f))

;; regular expression that describes a gdb location generally shown
;; before a command prompt. NOTE: we assume annotate 1!
(setf (gethash "loc" dbgr-gdb-pat-hash)
      (make-dbgr-loc-pat
       :regexp "^\\(.+\\):\\([0-9]+\\):\\([0-9]+\\):beg:0x\\([0-9a-f]+\\)"
       :file-group 1
       :line-group 2
       :char-offset-group 3))

(setf (gethash "prompt" dbgr-gdb-pat-hash)
      (make-dbgr-loc-pat
       :regexp   "^(gdb) "
       ))

;;  regular expression that describes a "breakpoint set" line
(setf (gethash "brkpt-set" dbgr-gdb-pat-hash)
      (make-dbgr-loc-pat
       :regexp "^Breakpoint \\([0-9]+\\) at 0x\\([0-9a-f]*\\): file \\(.+\\), line \\([0-9]+\\).\n"
       :num 1
       :file-group 3
       :line-group 4))

(setf (gethash "gdb" dbgr-pat-hash) dbgr-gdb-pat-hash)

(provide-me "dbgr-gdb-")

