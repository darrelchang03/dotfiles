;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-dracula)

(setq display-line-numbers-type 'relative)
(setq scroll-margin 8)
(setq-default fill-column 80)
(add-hook 'prog-mode-hook #'display-fill-column-indicator-mode)

;; Auto reload file, if external change is detected every 2s
(global-auto-revert-mode 1)
(setq auto-revert-interval 2)

;; Shorten idle delay refresh, so hover docs and diagnostics feel snappier.
(setq eldoc-idle-delay 0.2)
(setq flymake-no-changes-timeout 0.3)
;; Auto save buffer when window goes out of focus, to prevent org sync issues
(focus-autosave-mode 1)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")
(setq org-roam-directory (file-truename "~/org/roam/"))

(setq org-journal-dir "~/org/journal/"
      org-journal-file-format "%Y-%m-%d.org"
      org-journal-date-format "%A, %B %d %Y")

;; Commit (and push) every save under `org-directory' so notes written on one
;; machine aren't stranded there. The mode, `gac-automatically-push-p' and
;; `gac-automatically-add-new-files-p' are all set by ~/org/.dir-locals.el, so
;; the behaviour travels with the repo; only the machine-wide knobs are here.
(use-package! git-auto-commit-mode
  :defer t
  :init
  (setq
   ;; gac shells out to git once per save. `focus-autosave-mode' above saves on
   ;; every window switch, so without a debounce that's a commit per switch;
   ;; this folds a burst of saves into one. A commit still pending when a buffer
   ;; is killed gets flushed by gac's `kill-buffer-hook', so nothing is lost.
   gac-debounce-interval 60
   ;; Without this `gac-commit' uses `shell-command', which pops a
   ;; *Shell Command Output* window on every save.
   gac-silent-message-p t
   ;; Also set in .dir-locals.el, but that value alone isn't enough: with a
   ;; debounce, `gac--after-save' runs from a timer and reads this variable in
   ;; whatever buffer happens to be current, not the org buffer holding the
   ;; dir-local binding. The global default is what actually gets consulted.
   gac-automatically-add-new-files-p t)

  :config
  ;; gac's `gac-push' fires a bare `git push' and its sentinel only ever
  ;; `message's the status, so a rejected push scrolls away unnoticed and the
  ;; commits silently pile up locally. Rebase onto the upstream and retry when
  ;; that happens, and escalate a genuine failure to a warning that stays put.
  (defun my/gac-push (buffer)
    "Push BUFFER's repo, rebasing onto the upstream if the push is rejected."
    (let* ((dir (file-name-directory (buffer-file-name buffer)))
           (default-directory dir)
           (proc (start-process-shell-command
                  "git-auto-push" "*git-auto-push*"
                  ;; Only pull when the push is actually rejected, so the common
                  ;; case stays one round trip and leaves the tree alone.
                  "git push || (git pull --rebase --autostash && git push)")))
      (set-process-filter proc #'gac-process-filter)
      (set-process-sentinel
       proc
       (lambda (proc _status)
         (when (memq (process-status proc) '(exit signal))
           (let ((code (process-exit-status proc)))
             (unless (zerop code)
               (let ((git-dir (expand-file-name
                               ".git" (or (locate-dominating-file dir ".git") dir))))
                 (display-warning
                  'git-auto-commit
                  (format "Auto-push failed in %s (exit %s).%s See *git-auto-push*."
                          (abbreviate-file-name dir) code
                          (if (or (file-exists-p (expand-file-name "rebase-merge" git-dir))
                                  (file-exists-p (expand-file-name "rebase-apply" git-dir)))
                              " A rebase is half-finished -- resolve it before saving again."
                            ""))
                  :warning)))))))))
  (advice-add #'gac-push :override #'my/gac-push))

(after! org-noter
  (setq org-noter-notes-search-path '("~/org/"))
  ;; Auto-highlight the text selected in the PDF when inserting a precise note
  (setq org-noter-highlight-selected-text t))

(defun my/update-org-agenda-files (&rest _)
  (setq org-agenda-files
        (seq-remove
         (lambda (f) (string-match-p "/\\." f))   ; skip hidden dirs like .git
         (directory-files-recursively "~/org/" "\\.org$"))))
;; `org-agenda-prepare' is the single entry point every agenda-type command
;; funnels through before it computes its file list, so this also covers
;; `org-todo-list', `org-tags-view', `org-search-view' and the custom commands.
(advice-add 'org-agenda-prepare :before #'my/update-org-agenda-files)

(after! org-agenda
  (require 'org-super-agenda)
  ;; The grouping is implemented as advice installed by this minor mode; without
  ;; it every `org-super-agenda-groups' binding below is inert.
  (org-super-agenda-mode +1)

  ;; org-super-agenda stamps a copy of `org-agenda-mode-map' onto every group
  ;; header as a `keymap' text property, and Emacs consults that property before
  ;; evil's state maps -- so on a header line `j'/`k' fell through to
  ;; `org-agenda-goto-date'/`org-agenda-capture' and `gg', `/' etc. were dead.
  ;; Emptying the map makes header lines fall through to evil like any other
  ;; line. (Bind into this map instead if you ever want header-only commands.)
  (setq org-super-agenda-header-map (make-sparse-keymap))

  ;; With the default `auto', tags are right-aligned to the window edge, which
  ;; pads every tagged line out to full width and leaves olivetti nothing to
  ;; center. -1 collapses that padding to a single space during generation;
  ;; `my/org-agenda-center' pushes the tags back out once the agenda's natural
  ;; width is known.
  (setq org-agenda-tags-column -1)

  ;; Hourly rungs from 7am to 10pm, in place of org's default two-hourly
  ;; 8am-8pm, plus `remove-match' so an hour that already holds a timed entry
  ;; doesn't also get a rung sorting in just underneath it. The two filler
  ;; strings in the remaining slots keep their defaults, which resolve to
  ;; box-drawing glyphs on a graphical frame and ASCII on a terminal.
  (setf (nth 0 org-agenda-time-grid) '(daily today require-timed remove-match)
        (nth 1 org-agenda-time-grid) (number-sequence 700 2200 100))

  (defun my/org-agenda-within-days-p (item days)
    (org-super-agenda--when-with-marker-buffer (org-super-agenda--get-marker item)
      (let ((cutoff (+ (org-today) days))
            (scheduled (org-entry-get (point) "SCHEDULED"))
            (deadline (org-entry-get (point) "DEADLINE")))
        (or (and scheduled (<= (org-time-string-to-absolute scheduled) cutoff))
            (and deadline (<= (org-time-string-to-absolute deadline) cutoff))))))

  ;; The todo block is restricted to the main sequence's keywords on purpose:
  ;; movies.org and books.org declare their own `#+TODO:' sequences, so a bare

  ;; `alltodo' would drag the whole watchlist in here.
  (add-to-list 'org-agenda-custom-commands
               '("s" "Super Agenda"
                 ((agenda ""
                          ((org-agenda-span 'day)
                           (org-agenda-show-log '(state))
                           (org-super-agenda-groups
                            '((:name "Completed Habits"
                               :and (:log state :habit t)
                               :order 3)
                              (:discard (:log t))
                              (:name "Habits"
                               :habit t
                               :order 2)
                              (:name "Daily Schedule"
                               :time-grid t
                               :order 1)
                              (:name "Today"
                               :anything t
                               :order 4)))))
                  (todo "TODO|STRT|PROJ|WAIT|HOLD|LOOP"
                        ((org-agenda-overriding-header "")
                         (org-agenda-sorting-strategy
                          '(timestamp-up priority-down category-keep))
                         (org-super-agenda-groups
                          '((:discard (:habit t))
                            (:discard (:date today))
                            (:name "Important"
                             :priority "A"
                             :order 1)
                            (:name "In Progress"
                             :todo ("STRT" "PROJ")
                             :order 2)
                            (:name "Upcoming"
                             ;; Todos/deadlines/scheduled within the next 2
                             ;; weeks; anything further out (or undated)
                             ;; falls through to "Eventually" below.
                             :pred (lambda (item)
                                     (my/org-agenda-within-days-p item 14))
                             :order 3)
                            (:name "Unscheduled"
                             :date nil
                             :order 4))))))))

  (add-to-list 'org-agenda-custom-commands
               '("b" "Backlog"
                 ((todo "SOMEDAY|IDEA"
                        ((org-agenda-overriding-header "")
                         (org-super-agenda-groups
                          '((:name "Someday"
                             :todo "SOMEDAY")
                            (:name "Ideas"
                             :todo "IDEA"))))))))

  (add-to-list 'org-agenda-custom-commands
               '("r" "Weekly Recap"
                 ((agenda ""
                          ((org-agenda-overriding-header "Completed This Week")
                           (org-agenda-start-day "-6d")
                           (org-agenda-span 7)
                           (org-agenda-show-log 'closed)
                           (org-agenda-entry-types '())))))))

(after! org
  ;; doom's default (sequence "TODO(t)" "PROJ(p)" "LOOP(r)" "STRT(s)"
  ;; "WAIT(w)" "HOLD(h)" "IDEA(i)" "|" "DONE(d)" "KILL(k)"), plus SOMEDAY.
  (setq org-todo-keywords
        '((sequence
           "TODO(t)"
           "PROJ(p)"
           "LOOP(r)"
           "STRT(s)"
           "WAIT(w)"
           "HOLD(h)"
           "IDEA(i)"
           "SOMEDAY(S)"
           "|"
           "DONE(d)"
           "KILL(k)")
          (sequence
           "[ ](T)"
           "[-](S)"
           "[?](W)"
           "|"
           "[X](D)")
          (sequence
           "|"
           "OKAY(o)"
           "YES(y)"
           "NO(n)")))

  ;; Doom's default lang/org module starts the agenda 3 days in the past
  (setq org-agenda-start-day "+0d"
        org-agenda-span 7)

  ;; Widen the habit consistency-graph column so it isn't clipped.
  (setq org-habit-graph-column 60)

  (setq org-log-done 'time)

  (setq org-list-demote-modify-bullet
        '(("+" . "-") ("-" . "+") ("*" . "+") ("1." . "a.")))

  (setq org-src-content-indentation 0)
  (setq org-extend-today-until 4)

  (setq org-refile-use-outline-path 'file
        org-refile-allow-creating-parent-nodes 'confirm)

  (setq org-outline-path-complete-in-steps nil)

  (setq my/people-list '("Eric" "Randy" "Nij" "Johnny" "Liam" "Henry" "Matt" "Nate" "Pall" "Nerissa"))

  ;; ---------- MOVIES ------------
  (add-to-list 'org-capture-templates
               '("m" "Movie to watchlist" entry
                 (file "movies.org")
                 "* TOWATCH %^{Title} %^g"
                 :empty-lines 1))

  (add-to-list 'org-capture-templates
               '("M" "Movie watched" entry
                 (file "movies.org")
                 "* WATCHED %^{Title} %^g
:PROPERTIES:
:DATE_WATCHED: %^u
:WATCHED_WITH: %(string-join (completing-read-multiple \"Watched with: \" my/people-list) \" \")
:RATING: %^{Rating}
:END:
%?"
                 :empty-lines 1))

  (defun my/movie-mark-watched ()
    "Promote the movie at point to WATCHED and prompt for watch data."
    (interactive)
    (org-todo "WATCHED")
    (org-set-property "DATE_WATCHED"
                      (with-temp-buffer
                        (org-time-stamp '(16) t)
                        (buffer-string)))
    (org-set-property "WATCHED_WITH"
                      (string-join
                       (completing-read-multiple "Watched with: " my/people-list) " "))
    (org-set-property "RATING" (read-string "Rating: ")))

  ;; ---------- BOOKS ------------
  (add-to-list 'org-capture-templates
               '("b" "Book to read" entry
                 (file "books.org")
                 "* TOREAD %^{Title} %^g"
                 :empty-lines 1))

  ;; full log of a finished book
  (add-to-list 'org-capture-templates
               '("B" "Book read" entry
                 (file "books.org")
                 "* READ %^{Title} %^g
:PROPERTIES:
:AUTHOR: %^{Author}
:DATE_STARTED: %^u
:DATE_READ: %^u
:RATING: %^{Rating}
:RECOMMENDED_BY: %(string-join (completing-read-multiple \"Recommended by: \" my/people-list) \", \")
:REREAD: %^{Reread times|0}
:OPENLIBRARY: [[https://openlibrary.org/isbn/%^{ISBN}][Open Library]]
:END:
%?"
                 :empty-lines 1))

  (defun my/book-mark-reading ()
    "Promote the book to READING and set DATE_STARTED."
    (interactive)
    (org-todo "READING")
    (org-set-property "DATE_STARTED"
                      (with-temp-buffer
                        (org-time-stamp '(16) t)   ; inactive date prompt
                        (buffer-string))))

  ;; --- promote a book to READ, fill in the finish data ---
  (defun my/book-mark-read ()
    (interactive)
    (org-todo "READ")
    ;; only ask for a start date if one isn't already set
    (unless (org-entry-get nil "DATE_STARTED")
      (org-set-property "DATE_STARTED"
                        (with-temp-buffer
                          (org-time-stamp '(16) t)
                          (buffer-string))))
    (org-set-property "DATE_READ"
                      (with-temp-buffer
                        (org-time-stamp '(16) t)
                        (buffer-string)))
    (org-set-property "RATING" (read-string "Rating: "))
    (org-set-property "RECOMMENDED_BY"
                      (string-join
                       (completing-read-multiple "Recommended by: " my/people-list) ", "))
    (org-set-property "REREAD" (read-string "Reread times: " "0")))

  (map! :after org
        :map org-mode-map
        :localleader
        (:prefix ("SPC" . "custom")
                 "m" #'my/movie-mark-watched
                 "b" #'my/book-mark-reading
                 "B" #'my/book-mark-read))
  )

(after! org-modern
  (setq org-modern-star 'replace)
  ;; Alternate glyph set (org-bullets classic look) — uncomment to switch:
  ;; (setq org-modern-replace-stars "◉○✸✿✤")
  )


(after! projectile
  (setq projectile-project-search-path '("~/personal")))

;; Recenter when moving diagnostics
(advice-add #'next-error :after (lambda (&rest _) (recenter)))
(advice-add #'previous-error :after (lambda (&rest _) (recenter)))

(after! evil
  (define-key evil-visual-state-map (kbd "J") 'drag-stuff-down)
  (define-key evil-visual-state-map (kbd "K") 'drag-stuff-up)

  ;; `mzJ`z' in the Neovim config: keep the cursor in place when joining lines
  ;; instead of jumping to the join point.
  (advice-add #'evil-join :around
              (lambda (orig-fn &rest args)
                (let ((marker (point-marker)))
                  (apply orig-fn args)
                  (goto-char marker)
                  (set-marker marker nil))))

  ;; `<C-d>zz' / `<C-u>zz' / `nzzzv' / `Nzzzv' in the Neovim config: recenter the
  ;; window after every half-page scroll or search jump so the cursor never ends
  ;; up pinned to the top/bottom edge.
  (advice-add #'evil-scroll-up :after (lambda (&rest _) (recenter)))
  (advice-add #'evil-scroll-down :after (lambda (&rest _) (recenter)))
  (advice-add #'evil-search-next :after (lambda (&rest _) (recenter)))
  (advice-add #'evil-search-previous :after (lambda (&rest _) (recenter)))
  )


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `with-eval-after-load' block, otherwise Doom's defaults may override your
;; settings. E.g.
;;
;;   (with-eval-after-load 'PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look them up).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
