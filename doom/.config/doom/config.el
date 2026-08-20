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
      org-journal-file-format "%Y-%m-%d")

(after! org-noter
  (setq org-noter-notes-search-path '("~/org/"))

  ;; Auto-highlight the text selected in the PDF when inserting a precise note
  (setq org-noter-highlight-selected-text t)
  )

(after! org
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
