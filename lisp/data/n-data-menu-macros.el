(setq n-data-menu-macros (list
			  (cons ? "/cygdrive/c/users/nsproul/z/Dropbox/emacs/lisp/macros/xxxx.el")
			  (cons ?q "$dp/emacs/lisp/macros/facts-from-column-format-to-q-a-format.el")
			  (cons ?r (list
				    "Ravenswood"
				    (cons ?d "$dp/emacs/lisp/macros/rm_commas_inside_of_doubly_quoted_strings.el")
				    (cons ?s "$dp/emacs/lisp/macros/create_summary_csv.el")
				    )
				)
			  (cons ?K "$dp/emacs/lisp/macros/ks.el")
			  (cons ?z (list
                                    ""
				    ;; meta analysis gt.year 2002
				    ;; then go to ~/work/ts/meta/logs/out_ts/k.buys
				    ;; then go to ~/work/ts/meta/logs/out_ts/k.sells,
				    ;; and for each do step 1.
				    ;;
				    ;; Do step b for buys, step s for sells
				    (cons ?1 "$dp/emacs/lisp/macros/get_prices_from_within_gt_yearly_output.el")
				    (cons ?b "$dp/emacs/lisp/macros/gt_yearly_get_profit_for_buys.el")
				    (cons ?s "$dp/emacs/lisp/macros/gt_yearly_get_profit_for_sells.el")

				    ;; then calculate the percent profit per trade.
				    (cons ?p "$dp/emacs/lisp/macros/gt_yearly_calculate_profit_in_percent_per_day.el")
				    (cons ?S "$dp/emacs/lisp/macros/gt_yearly_summarize.el")
				    )
				)
			  (cons ?! "$dp/emacs/lisp/macros/put_next_from_m-o.el")
			  (cons ?a "$dp/emacs/lisp/macros/add-number-and-c-n.el")
			  (cons ?A "$dp/emacs/lisp/macros/note_another_way_to_say.el")
			  (cons ?c "$dp/emacs/lisp/macros/teacher__execute_all_copies_in_buffer.el")
			  (cons ?d "$dp/emacs/lisp/macros/teacher_restore_defaults_and_go.el")
			  (cons ?e "$dp/emacs/lisp/macros/EasyLanguage_cp_to_emacs_with_name_from_m-o.el")
			  (cons ?k "$dp/emacs/lisp/macros/k.el")
			  (cons ?K "$dp/emacs/lisp/macros/kill_perl_stack_starting_from_Main_and_ending_with_current_search_pattern.el")
			  (cons ?l "$dp/emacs/lisp/macros/log-all-pt.el")
			  (cons ?o "$dp/emacs/lisp/macros/override-base_old.el")
			  (cons ?p "$dp/emacs/lisp/macros/execute_all_pcS_in_shell.el")
			  (cons ?r "$dp/emacs/lisp/macros/teacher-format-review-answer.el")
			  (cons ?s "$dp/emacs/lisp/macros/save_rvw_on_current_file_of_corrections.el")
			  )
      )
