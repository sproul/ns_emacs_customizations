lisp_files := $(wildcard *.el)
test_files := $(wildcard test/test-*.el)

EXTRA_DIST = $(lisp_files) $(test_files) README.textile

CHECK_FILES = $(notdir $(test_files:.el=.run))

lisp_LISP = $(lisp_files)

check: $(CHECK_FILES)


# FIGURE out how to DRY the run rules.
test-basic.run:
	(cd $(srcdir)/test && $(EMACS) -batch -Q -l $(@:.run=.el) )

.PHONY: $(CHECK_FILES)

if MAINTAINER_MODE

CL = ChangeLog
ChangeLog:
	git log --pretty --numstat --summary | $(GIT2CL) > $@

ACLOCAL_AMFLAGS=-I .

endif

test: check




