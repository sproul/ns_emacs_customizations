# Whatever it is you want to do, it should be forwarded to the 
# to top-level directories
PHONY=check test all
EXTRA_DIST=gcd.py gcd.rb

all: 

test: check

test_files := $(wildcard test-*.el)

CHECK_FILES = $(notdir $(test_files:.el=.run))

check: $(CHECK_FILES)

# FIGURE out how to DRY the run rules.
test-bp.run:
	(cd $(top_srcdir)/test && $(EMACS) -batch -Q -l $(@:.run=.el) )
test-bt-pydbgr.run:
	(cd $(top_srcdir)/test && $(EMACS) -batch -Q -l $(@:.run=.el) )
test-bt-rdebug.run:
	(cd $(top_srcdir)/test && $(EMACS) -batch -Q -l $(@:.run=.el) )
test-bt-ruby.run:
	(cd $(top_srcdir)/test && $(EMACS) -batch -Q -l $(@:.run=.el) )
test-bt-trepan.run:
	(cd $(top_srcdir)/test && $(EMACS) -batch -Q -l $(@:.run=.el) )
test-bt-trepanx.run:
	(cd $(top_srcdir)/test && $(EMACS) -batch -Q -l $(@:.run=.el) )
test-bt-zshdb.run:
	(cd $(top_srcdir)/test && $(EMACS) -batch -Q -l $(@:.run=.el) )
test-buf-bt.run:
	(cd $(top_srcdir)/test && $(EMACS) -batch -Q -l $(@:.run=.el) )
test-buf-cmd.run:
	(cd $(top_srcdir)/test && $(EMACS) -batch -Q -l $(@:.run=.el) )
test-core.run:
	(cd $(top_srcdir)/test && $(EMACS) -batch -Q -l $(@:.run=.el) )
test-dbgr.run:
	(cd $(top_srcdir)/test && $(EMACS) -batch -Q -l $(@:.run=.el) )
test-file.run:
	(cd $(top_srcdir)/test && $(EMACS) -batch -Q -l $(@:.run=.el) )
test-lang.run: 
	(cd $(top_srcdir)/test && $(EMACS) -batch -Q -l $(@:.run=.el) )
test-loc.run: 
	(cd $(top_srcdir)/test && $(EMACS) -batch -Q -l $(@:.run=.el) )
test-loc-regexp-trepan.run: 
	(cd $(top_srcdir)/test && $(EMACS) -batch -Q -l $(@:.run=.el) )
test-loc-regexp-trepanx.run: 
	(cd $(top_srcdir)/test && $(EMACS) -batch -Q -l $(@:.run=.el) )
test-lochist.run:
	(cd $(top_srcdir)/test && $(EMACS) -batch -Q -l $(@:.run=.el) )
test-pydbgr.run:
	(cd $(top_srcdir)/test && $(EMACS) -batch -Q -l $(@:.run=.el) )
test-rdebug.run:
	(cd $(top_srcdir)/test && $(EMACS) -batch -Q -l $(@:.run=.el) )
test-regexp.run:
	(cd $(top_srcdir)/test && $(EMACS) -batch -Q -l $(@:.run=.el) )
test-regexp-bashdb.run:
	(cd $(top_srcdir)/test && $(EMACS) -batch -Q -l $(@:.run=.el) )
test-regexp-pydbgr.run:
	(cd $(top_srcdir)/test && $(EMACS) -batch -Q -l $(@:.run=.el) )
test-regexp-trepan.run:
	(cd $(top_srcdir)/test && $(EMACS) -batch -Q -l $(@:.run=.el) )
test-regexp-trepanx.run:
	(cd $(top_srcdir)/test && $(EMACS) -batch -Q -l $(@:.run=.el) )
test-regexp-rdebug.run:
	(cd $(top_srcdir)/test && $(EMACS) -batch -Q -l $(@:.run=.el) )
test-regexp-zshdb.run:
	(cd $(top_srcdir)/test && $(EMACS) -batch -Q -l $(@:.run=.el) )
test-srcbuf.run:
	(cd $(top_srcdir)/test && $(EMACS) -batch -Q -l $(@:.run=.el) )
test-send.run:
	(cd $(top_srcdir)/test && $(EMACS) -batch -Q -l $(@:.run=.el) )
test-shortkey.run:
	(cd $(top_srcdir)/test && $(EMACS) -batch -Q -l $(@:.run=.el) )
test-track.run:
	(cd $(top_srcdir)/test && $(EMACS) -batch -Q -l $(@:.run=.el) )
test-track-mode.run:
	(cd $(top_srcdir)/test && $(EMACS) -batch -Q -l $(@:.run=.el) )

.PHONY: $(CHECK_FILES)

%: 
	$(MAKE) -C .. $@

