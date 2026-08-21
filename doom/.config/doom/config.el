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

;; `colorcolumn = 80' in the Neovim config: a visual guide at column 80.
(setq-default fill-column 80)
(add-hook 'prog-mode-hook #'display-fill-column-indicator-mode)

;; `updatetime = 50' in the Neovim config: shorten the idle delay before
;; eldoc and flymake refresh, so hover docs and diagnostics feel snappier.
(setq eldoc-idle-delay 0.2)
(setq flymake-no-changes-timeout 0.3)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")
(setq org-roam-directory (file-truename "~/org/roam/"))

(setq org-journal-dir "~/org/journal/"
      org-journal-file-format "%Y-%m-%d.org"
      org-journal-date-format "%A, %B %d %Y")

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

  ;; Loaded here rather than at startup: the only thing centered is the agenda.
  (require 'olivetti)

  ;; With the default `auto', tags are right-aligned to the window edge, which
  ;; pads every tagged line out to full width and leaves olivetti nothing to
  ;; center. -1 collapses that padding to a single space during generation;
  ;; `my/org-agenda-center' pushes the tags back out once the agenda's natural
  ;; width is known.
  (setq org-agenda-tags-column -1)

  ;; Doom stretches the habit consistency graph across a fixed fraction of the
  ;; window and pins it to the right edge, overriding `org-habit-graph-column'
  ;; buffer-locally on every agenda. That makes habit lines exactly as wide as
  ;; the window -- so there is nothing left to center -- and, since it measures
  ;; the window *after* olivetti has added margins, the graph would shrink a
  ;; little more each redraw. Dropping the hook restores the fixed column set
  ;; below in `after! org'.
  (remove-hook 'org-agenda-mode-hook #'+org-habit-resize-graph-h)

  ;; Hourly rungs from 7am to 10pm, in place of org's default two-hourly
  ;; 8am-8pm, plus `remove-match' so an hour that already holds a timed entry
  ;; doesn't also get a rung sorting in just underneath it. The two filler
  ;; strings in the remaining slots keep their defaults, which resolve to
  ;; box-drawing glyphs on a graphical frame and ASCII on a terminal.
  (setf (nth 0 org-agenda-time-grid) '(daily today require-timed remove-match)
        (nth 1 org-agenda-time-grid) (number-sequence 700 2200 100))

  ;; The todo block is restricted to the main sequence's keywords on purpose:
  ;; movies.org and books.org declare their own `#+TODO:' sequences, so a bare
  ;; `alltodo' would drag the whole watchlist in here.
  (add-to-list 'org-agenda-custom-commands
               '("s" "Super Agenda"
                 ((agenda ""
                          ((org-agenda-span 'day)
                           ;; Habits are matched first -- they carry a time, so
                           ;; `:time-grid' would otherwise swallow them. `:order'
                           ;; is what puts the schedule on top when displayed.
                           (org-super-agenda-groups
                            '((:name "Habits"
                               :habit t
                               :order 2)
                              (:name "Daily Schedule"
                               :time-grid t
                               :order 1)))))
                  (todo "TODO|STRT|PROJ|WAIT|HOLD|LOOP"
                        ((org-agenda-overriding-header "")
                         ;; A timestamp sort key is what makes org attach the
                         ;; `ts-date' property the `:date' selectors below read;
                         ;; with the default strategy every item looks undated.
                         (org-agenda-sorting-strategy
                          '(timestamp-up priority-down category-keep))
                         (org-super-agenda-groups
                          ;; The `:discard's must stay first -- groups are
                          ;; applied in list order. Habits are plain TODOs, and
                          ;; anything dated today is already listed in the
                          ;; agenda block above; both would be shown twice.
                          '((:discard (:habit t))
                            (:discard (:date today))
                            (:name "Important"
                             :priority "A"
                             :order 1)
                            (:name "In Progress"
                             :todo ("STRT" "PROJ")
                             :order 2)
                            (:name "Upcoming"
                             :date t
                             :order 3)
                            (:name "Eventually"
                             :anything t
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
                           ;; Log mode shows CLOSED-logged entries on the day
                           ;; they closed; entry-types nil suppresses the
                           ;; normal scheduled/deadline agenda listing so only
                           ;; those closed entries remain.
                           (org-agenda-show-log 'closed)
                           (org-agenda-entry-types '())))))))

;; ---------- AGENDA CENTERING ------------
;; Olivetti centers a buffer by growing the window margins until the text body
;; is `olivetti-body-width' columns wide, so the agenda has to be narrower than
;; the window before anything can happen. Left alone it never is: several parts
;; of it size themselves against the window rather than against their own
;; content -- right-aligned tags, the block separator rule, and (courtesy of
;; Doom) the habit consistency graph. Those are pinned to fixed values in
;; `after! org-agenda' above; what's left is to measure what the agenda
;; actually needs and hand that to olivetti.

(defvar-local my/org-agenda--fitted-width nil
  "Content width the agenda in this buffer was last centered on.")

(defun my/org-agenda--window ()
  "The live window displaying the current agenda buffer, if there is one."
  (let ((win (get-buffer-window (current-buffer) t)))
    (and (window-live-p win) win)))

(defun my/org-agenda--available-width (win)
  "Columns WIN can display, ignoring margins olivetti may already have set."
  (if (null win)
      (frame-width)
    (let ((margins (window-margins win)))
      (+ (window-width win) (or (car margins) 0) (or (cdr margins) 0)))))

(defun my/org-agenda--measure (win beg end)
  "Columns spanned by the widest screen line between BEG and END.
Measured through the display engine when WIN is available, so hidden link
syntax and the `display' properties org-modern decorates the agenda with
are counted as they are actually drawn rather than as raw characters. The
X-LIMIT argument of t lifts the wrap boundary, so an over-long line is
measured whole instead of being folded back into the window's width."
  (if win
      (ceiling (car (window-text-pixel-size win beg end t))
               (frame-char-width (window-frame win)))
    (let ((width 0))
      (save-excursion
        (goto-char beg)
        (while (< (point) end)
          (end-of-line)
          (setq width (max width (current-column)))
          (forward-line 1)))
      width)))

(defun my/org-agenda--align-tags (win target)
  "Right-align every tag group so that its line ends at column TARGET.
`org-agenda-align-tags' can't be reused here for two reasons. It counts
characters, but org-modern draws each tag as a label several columns wider
than its text, so a char-column alignment overshoots the fitted width. And
it copies the tag's text properties onto the padding it inserts, which
picks up the `invisible' property org-modern puts on tag delimiters -- the
padding then isn't drawn at all and the tags come out ragged. Taking the
properties from the start of the line instead still keeps the padding
hidden on entries an agenda filter has hidden, which is what the copying
is there for."
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward org-tag-group-re nil t)
      (let ((props (plist-put (copy-sequence
                               (text-properties-at (line-beginning-position)))
                              'face nil)))
        (goto-char (match-beginning 1))
        (delete-region (save-excursion (skip-chars-backward " \t") (point))
                       (point))
        (insert (org-add-props
                    (make-string
                     (max 1 (- target (my/org-agenda--measure
                                       win (line-beginning-position)
                                       (line-end-position))))
                     ?\s)
                    props))
        (goto-char (line-end-position))))))

(defun my/org-agenda--erase-separators ()
  "Blank every block separator rule, returning a marker for each one.
The rules are full-window-width by construction and would otherwise be the
widest lines in the buffer; `my/org-agenda--draw-separators' puts them back."
  (when (characterp org-agenda-block-separator)
    (let ((re (format "^%s+$"
                      (regexp-quote (char-to-string org-agenda-block-separator))))
          markers)
      (save-excursion
        (goto-char (point-min))
        (while (re-search-forward re nil t)
          (delete-region (match-beginning 0) (match-end 0))
          (push (point-marker) markers)))
      markers)))

(defun my/org-agenda--draw-separators (markers width)
  "Redraw the separator rules at MARKERS, WIDTH columns wide."
  (dolist (marker markers)
    (save-excursion
      (goto-char marker)
      (insert (make-string width org-agenda-block-separator)))
    (set-marker marker nil)))

(defun my/org-agenda--apply-width (width)
  "Give the agenda window a text body WIDTH columns wide."
  ;; Buffer-local because `olivetti-set-width' would set it globally, and it
  ;; also announces the new width in the echo area on every single redraw.
  (setq-local olivetti-body-width width)
  (if (bound-and-true-p olivetti-mode)
      (olivetti-set-buffer-windows)
    (olivetti-mode +1)))

(defun my/org-agenda-center ()
  "Center the agenda in a column just wide enough for its longest line."
  (when (derived-mode-p 'org-agenda-mode)
    (if (buffer-narrowed-p)
        (my/org-agenda--recenter-line)
      (my/org-agenda--recenter-buffer))))

(defun my/org-agenda--recenter-buffer ()
  "Measure the whole agenda and fit the window's text body to it."
  (let* ((inhibit-read-only t)
         (win (my/org-agenda--window))
         (separators (my/org-agenda--erase-separators))
         (content (my/org-agenda--measure win (point-min) (point-max)))
         (available (my/org-agenda--available-width win)))
    (setq my/org-agenda--fitted-width content)
    ;; Tags are re-aligned to the content width rather than to the body width:
    ;; aligning them to the body would make the longest line a column wider
    ;; than it was measured at, and every redraw would hand olivetti a column
    ;; more than the last.
    (unless (eq org-agenda-remove-tags t)
      (my/org-agenda--align-tags win content))
    ;; One spare column over the content: a terminal frame has no fringe to put
    ;; the continuation glyph in, so it reserves the last text column and a
    ;; line filling the body exactly would wrap.
    (my/org-agenda--apply-width (min (1+ content) available))
    ;; Olivetti splits the leftover columns evenly between the two margins, so
    ;; the body it settles on can be a column narrower than the one asked for.
    ;; Widen until the longest line genuinely fits, or until the margins are
    ;; gone and the agenda is simply wider than the window can show.
    (when win
      (let ((guard 8))
        (while (and (> guard 0)
                    (< (window-max-chars-per-line win) content)
                    (< olivetti-body-width available))
          (setq guard (1- guard))
          (my/org-agenda--apply-width (min (1+ olivetti-body-width) available)))))
    ;; The rules are excluded from the measurement above, so they are free to
    ;; span the text column without dragging the next redraw wider.
    (my/org-agenda--draw-separators
     separators
     (if win (min content (window-max-chars-per-line win)) content))))

(defun my/org-agenda--recenter-line ()
  "Bring a single rebuilt agenda line back into the fitted column.
`org-agenda-change-all-lines' -- which is how marking an entry or a habit
done redraws it -- calls `org-agenda-finalize' on a buffer narrowed to just
that line. Measuring there would refit the whole agenda to one line, so
reuse the width the last full redraw settled on instead."
  (when my/org-agenda--fitted-width
    (let* ((inhibit-read-only t)
           (win (my/org-agenda--window))
           (target my/org-agenda--fitted-width))
      (unless (eq org-agenda-remove-tags t)
        (my/org-agenda--align-tags win target))
      ;; The rebuilt line can come back wider than the column it has to live
      ;; in; widen rather than let it wrap. Its tags stay a little short of
      ;; the others until the next full redraw squares them up.
      (let ((width (my/org-agenda--measure win (point-min) (point-max))))
        (when (and win (> width target))
          (setq my/org-agenda--fitted-width width)
          (my/org-agenda--apply-width
           (min (1+ width) (my/org-agenda--available-width win))))))))

;; Depth 90 so this runs after org-modern's agenda finalizer, which decides how
;; some of the text is displayed and therefore how wide it ends up.
(add-hook 'org-agenda-finalize-hook #'my/org-agenda-center 90)


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
