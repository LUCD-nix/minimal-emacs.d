;;; post-init.el --- most packages go here  -*- lexical-binding: t; -*-

;;; Custom file
;; This is already set in early-init.el
;; (setq custom-file "~/.config/emacs/custom.el")
(load custom-file 'noerror 'nomessage)

;;; No dir-locals.el
(setq enable-dir-local-variables nil)


;;; Electric pair mode
;; Enable automatic insertion and management of matching pairs of characters
;; (e.g., (), {}, "") globally using `electric-pair-mode'.
(use-package elec-pair
  :ensure nil
  :commands (electric-pair-mode
             electric-pair-local-mode
             electric-pair-delete-pair)
  :hook (after-init . electric-pair-mode))

;;; Misc
;; Allow Emacs to upgrade built-in packages, such as Org mode
(setq package-install-upgrade-built-in t)

;; It seems this is needed
(use-package compat)

;; expand region
(defun er/add-text-mode-expansions ()
  (make-variable-buffer-local 'er/try-expand-list)
  (setq er/try-expand-list (append
                            er/try-expand-list
                            '(mark-paragraph
                              mark-page))))

(use-package expand-region
  :ensure t
  :hook
  (text-mode . er/add-text-mode-expansions)
  :bind ("C-," . er/expand-region))

(use-package multiple-cursors
  :bind
  (("C-c u" . mc/edit-lines)
   ("C->" . mc/mark-next-like-this)
   ("C-<" . mc/mark-previous-like-this)
   ("C-c C->" . mc/mark-all-like-this)))

(use-package embark
  :ensure
  :init
  ;; makes it possible to search what comes after a prefix (try C-x C-h)
  (setq prefix-help-command #'embark-prefix-help-command)
  :bind
  (("C-." . embark-act)
   ("C-;" . embark-dwim) ; might also want M-. since it acts a bit like xref
   ("C-h B" . embark-bindings)
   (:map minibuffer-local-map
         ("C-M-l" . embark-collect)
         ("C-M-e" . embark-export)
         ("C-SPC" . embark-select))))

(use-package embark-consult
  :ensure t
  :after embark)

(use-package embark-org
  :ensure nil
  :after embark)


;; some saner defaults for wgrep
(use-package wgrep
  :ensure t
  :commands wgrep
  :config
  (setq wgrep-auto-save-buffer t)
  (setq wgrep-change-readonly-file t)
  :bind (:map grep-mode-map
              ("e" . wgrep-change-to-wgrep-mode)
              ("C-x C-q" . wgrep-change-to-wgrep-mode)))

;; When Delete Selection mode is enabled, typed text replaces the selection
;; if the selection is active.
(delete-selection-mode 1)

;;; Theme various

(use-package kanagawa-themes
  :ensure t
  :config
  (let ((inhibit-redisplay t))
     ;; Disable all active themes
    (mapc #'disable-theme custom-enabled-themes)
    ;; Load the built-in theme
    (load-theme 'kanagawa-lotus t)))

(use-package mood-line
  :config
  (mood-line-mode)
  ;; Use pretty Fira Code-compatible glyphs
  :custom
  (mood-line-glyph-alist mood-line-glyphs-fira-code))

(use-package spacious-padding
  :after  kanagawa-themes
  ;; This does not survive a 'load-theme' for macro shenanigans reasons
  ;; way better than what i had before, no touchy!
  :custom-face
  (mode-line-active ((t (:background ,(face-background 'mode-line)))))
  :config
  (spacious-padding-mode))

(use-package emacs
  :ensure nil
  :config
  ;; toggles line wrap and visual line navigation
  (global-visual-line-mode 1)

  ;; Display of line numbers in the buffer:
  (setq-default display-line-numbers-type 'relative)
  (dolist (hook '(prog-mode-hook text-mode-hook conf-mode-hook))
    (add-hook hook #'display-line-numbers-mode))

  ;; Set the maximum level of syntax highlighting for Tree-sitter modes
  (setq treesit-font-lock-level 4)

  (global-text-scale-adjust +1)

  ;; enable pixel-scrolling (mac has it by default)
  (unless (and (eq window-system 'mac)
               (bound-and-true-p mac-carbon-version-string))
    (setq pixel-scroll-precision-use-momentum nil)
    (pixel-scroll-precision-mode 1))

  ;; Paren match highlighting
  (add-hook 'after-init-hook #'show-paren-mode)

  ;; Display the time in the modeline
  (setq display-time-24hr-format t)
  (add-hook 'after-init-hook #'display-time-mode))

;;; which-key
(use-package which-key
  :ensure nil ; builtin
  :commands which-key-mode
  :hook (after-init . which-key-mode)
  :custom
  (which-key-idle-delay 1.0)
  (which-key-idle-secondary-delay 0.25)
  (which-key-add-column-padding 1)
  (which-key-max-description-length 40))

;;; Winner and window dividers
;; Track changes in the window configuration, allowing undoing actions such as
;; closing windows.
(setq winner-boring-buffers '("*Completions*"
                                "*Minibuf-0*"
                                "*Minibuf-1*"
                                "*Minibuf-2*"
                                "*Minibuf-3*"
                                "*Minibuf-4*"
                                "*Compile-Log*"
                                "*inferior-lisp*"
                                "*Fuzzy Completions*"
                                "*Apropos*"
                                "*Help*"
                                "*cvs*"
                                "*Buffer List*"
                                "*Ibuffer*"
                                "*esh command on file*"))
(add-hook 'after-init-hook #'winner-mode)

;; Window dividers separate windows visually. Window dividers are bars that can
;; be dragged with the mouse, thus allowing you to easily resize adjacent
;; windows.
;; https://www.gnu.org/software/emacs/manual/html_node/emacs/Window-Dividers.html
(add-hook 'after-init-hook #'window-divider-mode)

;;; Dired stuff
;; Constrain vertical cursor movement to lines within the buffer
(setq dired-movement-style 'bounded-files)

;; dired: Group directories first
(with-eval-after-load 'dired
  (let ((args "--group-directories-first -ahlv"))
    (when (or (eq system-type 'darwin) (eq system-type 'berkeley-unix))
      (if-let* ((gls (executable-find "gls")))
          (setq insert-directory-program gls)
        (setq args nil)))
    (when args
      (setq dired-listing-switches args))))

;;; Some minibuffer config
;; Enables visual indication of minibuffer recursion depth after initialization.
(add-hook 'after-init-hook #'minibuffer-depth-indicate-mode)

;; Configure Emacs to ask for confirmation before exiting
(setq confirm-kill-emacs 'y-or-n-p)



;;; Vertico/Marginalia/Consult stack
;; Enable rich annotations using the Marginalia package
(use-package marginalia
  ;; Bind `marginalia-cycle' locally in the minibuffer.  To make the binding
  ;; available in the *Completions* buffer, add it to the
  ;; `completion-list-mode-map'.
  :bind (:map minibuffer-local-map
         ("M-A" . marginalia-cycle))
  ;; The :init section is always executed.
  :init
  ;; Marginalia must be activated in the :init section of use-package such that
  ;; the mode gets enabled right away. Note that this forces loading the
  ;; package.
  (marginalia-mode))

;; Enable Vertico.
;; Note that most of the little setting from https://github.com/minad/vertico
;; are already configured by default by minimal-emacs, hence why they aren't
;; here
(use-package vertico
  :custom
  (vertico-resize t) ;; Grow and shrink the Vertico minibuffer
  (vertico-cycle t) ;; Enable cycling for `vertico-next/previous'
  :init
  (vertico-mode))

;; Orderless
;; see variable `orderless-affix-dispatch-alist' for usage
;; (most interesting is the suff/prefix `&' which searches for annotations
(use-package orderless
  :custom
  (orderless-component-separator #'orderless-escapable-split-on-space)
  (completion-styles '(orderless flex substring basic))
  ;; prefer partial completion - that is wildcards - when searching for files
  (completion-category-overrides '((file (styles partial-completion orderless flex substring basic))))
  (completion-category-defaults nil) ;; Disable defaults, use our settings
  (completion-pcm-leading-wildcard t)) ;; Emacs 31: partial-completion behaves like substring

;; Example configuration for Consult, taken from: https://github.com/minad/consult
;; I am far from using eveything here, consider narrowing down
(use-package consult
  ;; Replace bindings. Lazily loaded by `use-package'.
  :bind (;; C-c bindings in `mode-specific-map'
         ("C-c M-x" . consult-mode-command)
         ("C-c h" . consult-history)
         ("C-c k" . consult-kmacro)
         ("C-c m" . consult-man)
         ("C-c i" . consult-info)
         ([remap Info-search] . consult-info)
         ;; C-x bindings in `ctl-x-map'
         ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command
         ("C-x b" . consult-buffer)                ;; orig. switch-to-buffer
         ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
         ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
         ("C-x t b" . consult-buffer-other-tab)    ;; orig. switch-to-buffer-other-tab
         ("C-x r b" . consult-bookmark)            ;; orig. bookmark-jump
         ("C-x p b" . consult-project-buffer)      ;; orig. project-switch-to-buffer
         ;; Custom M-# bindings for fast register access
         ("M-#" . consult-register-load)
         ("M-'" . consult-register-store)          ;; orig. abbrev-prefix-mark (unrelated)
         ("C-M-#" . consult-register)
         ;; Other custom bindings
         ("M-y" . consult-yank-pop)                ;; orig. yank-pop
         ;; M-g bindings in `goto-map'
         ("M-g e" . consult-compile-error)
         ("M-g r" . consult-grep-match)
         ("M-g g" . consult-goto-line)             ;; orig. goto-line
         ("M-g M-g" . consult-goto-line)           ;; orig. goto-line
         ("M-g o" . consult-outline)               ;; Alternative: consult-org-heading
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)
         ;; M-s bindings in `search-map'
         ("M-s d" . consult-fd)
         ("M-s c" . consult-locate)
         ("M-s g" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)
         ;; Isearch integration
         ("M-s e" . consult-isearch-history)
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)         ;; orig. isearch-edit-string
         ("M-s e" . consult-isearch-history)       ;; orig. isearch-edit-string
         ("M-s l" . consult-line)                  ;; needed by consult-line to detect isearch
         ("M-s L" . consult-line-multi)            ;; needed by consult-line to detect isearch
         ;; Minibuffer history
         :map minibuffer-local-map
         ("M-s" . consult-history)                 ;; orig. next-matching-history-element
         ("M-r" . consult-history))                ;; orig. previous-matching-history-element

  ;; The :init configuration is always executed (Not lazy)
  :init
  ;; we might want to change this
  (setq consult-preview-key 'any)

  ;; Tweak the register preview for `consult-register-load',
  ;; `consult-register-store' and the built-in commands.  This improves the
  ;; register formatting, adds thin separator lines, register sorting and hides
  ;; the window mode line.
  (advice-add #'register-preview :override #'consult-register-window)
  (setq register-preview-delay 0.5)

  ;; Use Consult to select xref locations with preview
  ;; also works for project-grep etc.
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  ;; Configure other variables and modes in the :config section,
  ;; after lazily loading the package.
  :config

  ;; Optionally configure the narrowing key.
  ;; Both < and C-+ work reasonably well.
  (setq consult-narrow-key "<"))

;; cape is mostly useful when we have some specific functions we want to add
;; to a given mode. In the future it will be overridden in prog-mode to use
;; eglot's completions instead
(use-package cape
  :bind ("M-p" . cape-prefix-map)
  :init
  ;; eglot will eventually supersede these with the its own suggestions
  (add-hook 'completion-at-point-functions #'cape-keyword)
  (add-hook 'completion-at-point-functions #'cape-file)
  (add-hook 'completion-at-point-functions #'cape-dabbrev)
  (add-hook 'completion-at-point-functions #'cape-history))

(use-package corfu
  ;; Optional customizations
  :custom
  (corfu-cycle t)                ;; Enable cycling for `corfu-next/previous'
  (corfu-quit-at-boundary nil)   ;; Never quit at completion boundary
  (corfu-on-exact-match 'insert) ;; Configure handling of exact matches

  ;; Enable Corfu only for certain modes. See also `global-corfu-modes'.
  :hook ((prog-mode . corfu-mode)
         (shell-mode . corfu-mode)
         (eshell-mode . corfu-mode))
  :init
  ;; Enable optional extension modes:
  (corfu-history-mode)
  (corfu-popupinfo-mode))


;;; Start server on emacs start
;; Configure the built-in Emacs server to start after initialization,
;; allowing the use of the emacsclient command to open files in the
;; current session.
(use-package server
  :ensure nil
  :commands server-start
  :hook
  (after-init . server-start))

;;; Backups, reading modified files to buffers (autorevert)
;; Enabled backups save your changes to a file intermittently
(setq make-backup-files t)
(setq vc-make-backup-files t)
(setq kept-old-versions 10)
(setq kept-new-versions 10)

;; Auto-revert is a feature that automatically updates the
;; contents of a buffer to reflect changes made to the underlying file
;; on disk.
(use-package autorevert
  :ensure nil
  :commands (auto-revert-mode global-auto-revert-mode)
  :hook
  (after-init . global-auto-revert-mode)
  :init
  ;; (setq auto-revert-verbose t)
  (setq auto-revert-interval 3)
  (setq auto-revert-remote-files nil)
  (setq auto-revert-use-notify t)
  (setq auto-revert-avoid-polling nil))

;; Recentf is a package that maintains a list of recently
;; accessed files, making it easier to reopen files you have worked on
;; recently.
(use-package recentf
  :ensure nil
  :commands (recentf-mode recentf-cleanup)
  :hook
  (after-init . recentf-mode)

  :init
  (setq recentf-auto-cleanup (if (daemonp) 300 'never))
  (setq recentf-exclude
        (list "\\.tar$" "\\.tbz2$" "\\.tbz$" "\\.tgz$" "\\.bz2$"
              "\\.bz$" "\\.gz$" "\\.gzip$" "\\.xz$" "\\.zip$"
              "\\.7z$" "\\.rar$"
              "COMMIT_EDITMSG\\'"
              "\\.\\(?:gz\\|gif\\|svg\\|png\\|jpe?g\\|bmp\\|xpm\\)$"
              "-autoloads\\.el$" "autoload\\.el$"))

  :config
  ;; A cleanup depth of -90 ensures that `recentf-cleanup' runs before
  ;; `recentf-save-list', allowing stale entries to be removed before the list
  ;; is saved by `recentf-save-list', which is automatically added to
  ;; `kill-emacs-hook' by `recentf-mode'.
  (add-hook 'kill-emacs-hook #'recentf-cleanup -90))

;; savehist is a feature that preserves the minibuffer history between
;; sessions. It saves the history of inputs in the minibuffer, such as commands,
;; search strings, and other prompts, to a file. This allows users to retain
;; their minibuffer history across Emacs restarts.
(use-package savehist
  :ensure nil
  :commands (savehist-mode savehist-save)
  :hook
  (after-init . savehist-mode)
  :init
  (setq history-length 300)
  (setq savehist-autosave-interval 600))

;; enables Emacs to remember the last location within a file
;; upon reopening. This feature is particularly beneficial for resuming work at
;; the precise point where you previously left off.
(use-package saveplace
  :ensure nil
  :commands (save-place-mode save-place-local-mode)
  :hook
  (after-init . save-place-mode)
  :init
  (setq save-place-limit 400))

;;; Programming :
;; Bless github:renzmann for making this
(use-package treesit-auto
  :ensure t 
  :custom
  (treesit-auto-install 'prompt)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

;;;; Magit
;; the version of transient that's builtin is too old for magit
;; :ensure t is not needed but best be clear about it
(use-package transient
  :ensure t)
(use-package magit
  :after transient
  :ensure t)

;;;; Paredit (possibly more than just elisp)
(use-package paredit
  :hook
  (emacs-lisp-mode . (lambda () (electric-indent-local-mode -1)
                                  (electric-pair-local-mode -1)
                                  (enable-paredit-mode)))
  :bind (:map paredit-mode-map
              ;; make electric-like indent on RET
              ("RET" . paredit-newline)
              ("C-j" . nil)
              ;; keep M-s for `search-mode-map'
              ("M-s" . nil)
              ("M-S" . nil)
              ("M-n" . paredit-splice-sexp)
              ("M-N" . paredit-split-sexp)))

;;;; Elisp
(use-package outline
  :ensure nil
  :commands outline-minor-mode
  :hook
  ((emacs-lisp-mode . outline-minor-mode)
   ;; Use " ▼" instead of the default ellipsis "..." for folded text to make
   ;; folds more visually distinctive and readable.
   (outline-minor-mode
    .
    (lambda()
      (let* ((display-table (or buffer-display-table (make-display-table)))
             (face-offset (* (face-id 'shadow) (ash 1 22)))
             (value (vconcat (mapcar (lambda (c) (+ face-offset c)) "▼"))))
        (set-display-table-slot display-table 'selective-display value)
        (setq buffer-display-table display-table))))))

;;;; Markdown (nowadays that counts as programming) (move somewhere else later)
(use-package markdown-mode)

;;;; gptel and gptel-agent
(use-package gptel
  :ensure t
  :init
  ;; ~/.authinfo is removed from the sources list by init.el in favour of
  ;; ~/.authinfo.gpg only which makes a lot of sense but is more trouble
  ;; than it is worth right now for a single gpt key
  (setq auth-sources (list "~/.authinfo" "~/.authinfo.gpg" "~/.netrc"))
  (setq gptel-api-key 'gptel-api-key-from-auth-source)
  (setq gptel-include-reasoning 'ignore))

(use-package gptel-agent)

;;;; GDB
(use-package gdb-mi
  :ensure nil
  :defer t
  :config
  (gdb-many-windows)
  (setq gdb-show-main t))

;;;; C/C++
(defun 42-indent-setup ()
      (setq-local indent-tabs-mode t)
      (setq-local tab-width 4)
      (setq-local c-ts-mode-indent-offset 4)
      (setq-local c-ts-common-indent-offset 4)
      (custom-set-variables '(c-ts-mode-indent-style 'bsd))
      (etags-regen-mode))

(use-package c-ts-mode
  :ensure nil
  ;; using hooks in reverse here, but hey, it works
  :hook
  (c-ts-mode . 42-indent-setup))

(use-package c++-ts-mode
  :ensure nil
  :hook
  (c++-ts-mode . 42-indent-setup))

;;; Org mode, :bind and C-a inspired by prelude emacs
(use-package org
  :ensure nil
  :bind
  ("C-c l" . org-store-link)
  ("C-c a" . org-agenda)
  ("C-c c" . org-capture)
  ("C-c b" . org-switchb)
  ;; keep expand-region in org mode map
  ;; `org-cycle-agenda-files' which was bound to C-,
  ;; is also available on C-'
  (:map org-mode-map
        ("C-," . nil))
  :config
  (add-hook 'org-mode-hook (lambda () (org-indent-mode +1)))
  (define-key org-mode-map (kbd "C-a") 'org-beginning-of-line))
