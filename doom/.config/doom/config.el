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
;;(setq doom-font ')

(setq display-line-numbers-type 'relative)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Keep `scrolloff = 8' worth of context around the cursor, like the Neovim config.
(setq scroll-margin 8)

;; `<C-d>zz' / `<C-u>zz' / `nzzzv' / `Nzzzv' in the Neovim config: recenter the
;; window after every half-page scroll or search jump so the cursor never ends
;; up pinned to the top/bottom edge.
(advice-add #'evil-scroll-up :after (lambda (&rest _) (recenter)))
(advice-add #'evil-scroll-down :after (lambda (&rest _) (recenter)))
(advice-add #'evil-search-next :after (lambda (&rest _) (recenter)))
(advice-add #'evil-search-previous :after (lambda (&rest _) (recenter)))

;; `<M-j>/<M-k> -> cnext/cprev zz' in the Neovim config: recenter after
;; jumping between diagnostics or xref results. Flymake hooks into
;; `next-error-function', so `]e'/`[e' (bound to next-error/previous-error)
;; cover diagnostic navigation too.
(advice-add #'next-error :after (lambda (&rest _) (recenter)))
(advice-add #'previous-error :after (lambda (&rest _) (recenter)))

;; `mzJ`z' in the Neovim config: keep the cursor in place when joining lines
;; instead of jumping to the join point.
(advice-add #'evil-join :around
            (lambda (orig-fn &rest args)
              (let ((marker (point-marker)))
                (apply orig-fn args)
                (goto-char marker)
                (set-marker marker nil))))

;; `:m \"'>+1<CR>gv=gv\"` / `:m \"'<-2<CR>gv=gv\"` in the Neovim config: move
;; the lines spanned by the Visual selection down/up by one line, reindent,
;; and reselect. Uses Evil's own visual type (char/line/block), so this works
;; the same in visual block mode as in the Neovim mapping.
(defun dchang/move-visual-selection-lines (direction)
  "Move the lines spanned by the Visual selection one line up (DIRECTION -1)
or down (DIRECTION 1), reindent them, and restore the selection."
  (let* ((type (evil-visual-type))
         (beg-line (line-number-at-pos (region-beginning)))
         (end-line (line-number-at-pos (region-end)))
         (line-count (1+ (- end-line beg-line)))
         (last-line (line-number-at-pos (point-max))))
    (when (if (> direction 0)
              (<= (+ end-line direction) last-line)
            (>= (+ beg-line direction) 1))
      (let (text new-beg new-end)
        (save-excursion
          (goto-char (point-min))
          (forward-line (1- beg-line))
          (setq text (delete-and-extract-region
                      (point) (progn (forward-line line-count) (point))))
          (forward-line direction)
          (setq new-beg (point))
          (insert text)
          (setq new-end (point))
          (indent-region new-beg new-end))
        (evil-visual-select new-beg (1- new-end) type)))))

(map! :v "J" (cmd! (dchang/move-visual-selection-lines 1))
      :v "K" (cmd! (dchang/move-visual-selection-lines -1)))

;; `colorcolumn = 80' in the Neovim config: a visual guide at column 80.
(setq-default fill-column 80)
(add-hook 'prog-mode-hook #'display-fill-column-indicator-mode)

;; `updatetime = 50' in the Neovim config: shorten the idle delay before
;; eldoc and flymake refresh, so hover docs and diagnostics feel snappier.
(setq eldoc-idle-delay 0.2)
(setq flymake-no-changes-timeout 0.3)


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
