(provide 'npt)

(defun npt-browse()
  (let(
       (host	(nmenu "host"))
       (op	(nmenu "pt-op"))
       )
    (n-host-shell-cmd-visible (format "browser pt/%s/%s &" host op))
    )
  )
