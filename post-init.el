;;; post-init.el --- most packages go here  -*- lexical-binding: t; -*-

(use-package kanagawa-themes
  :ensure t
  :config
  (let ((inhibit-redisplay t))
    ;; Disable all active themes
    (mapc #'disable-theme custom-enabled-themes)
    ;; Load the built-in theme
    (load-theme 'kanagawa-wave t)))

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

  ;; Personal preference
  (setq scroll-margin 10)

  ;; Display of line numbers in the buffer:
  (setq-default display-line-numbers-type 'relative)
  (dolist (hook '(prog-mode-hook text-mode-hook conf-mode-hook))
    (add-hook hook #'display-line-numbers-mode))

  ;; Set the maximum level of syntax highlighting for Tree-sitter modes
  (setq treesit-font-lock-level 4)

  (set-face-attribute 'default nil :height 150 :width 'ultra-condensed :weight
                      'normal :family "IosevkaTermSlab Nerd Font Mono")

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

(use-package marginalia
  :bind (:map minibuffer-local-map
         ("M-A" . marginalia-cycle))
  :init
  ;; Marginalia must be activated in the :init section of use-package such that
  ;; the mode gets enabled right away. Note that this forces loading the
  ;; package.
  (marginalia-mode))

(use-package vertico
  :custom
  (vertico-resize t) ;; Grow and shrink the Vertico minibuffer
  (vertico-cycle t) ;; Enable cycling for `vertico-next/previous'
  :init
  (vertico-mode))

(use-package orderless
  :custom
  (orderless-component-separator #'orderless-escapable-split-on-space)
  (completion-styles '(orderless flex substring basic))
  ;; prefer partial completion - that is wildcards - when searching for files
  (completion-category-overrides '((file (styles partial-completion orderless flex substring basic))))
  (completion-category-defaults nil) ;; Disable defaults, use our settings
  (completion-pcm-leading-wildcard t)) ;; Emacs 31: partial-completion behaves like substring

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

(use-package embark
  :ensure
  :init
  ;; makes it possible to search what comes after a prefix (try C-x C-h)
  (setq prefix-help-command #'embark-prefix-help-command)
  :bind
  (("C-." . embark-act)
   ("M-." . embark-dwim)
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

(use-package wgrep
  :ensure t
  :commands wgrep
  :config
  (setq wgrep-auto-save-buffer t)
  (setq wgrep-change-readonly-file t)
  :bind (:map grep-mode-map
              ("e" . wgrep-change-to-wgrep-mode)
              ("C-x C-q" . wgrep-change-to-wgrep-mode)))

(use-package elec-pair
  :ensure nil
  :commands (electric-pair-mode
             electric-pair-local-mode
             electric-pair-delete-pair)
  :hook (after-init . electric-pair-mode))

(use-package which-key
  :ensure nil ; builtin
  :commands which-key-mode
  :hook (after-init . which-key-mode)
  :custom
  (which-key-idle-delay 1.0)
  (which-key-idle-secondary-delay 0.25)
  (which-key-add-column-padding 1)
  (which-key-max-description-length 40))

(setq make-backup-files t)
(setq vc-make-backup-files t)
(setq kept-old-versions 10)
(setq kept-new-versions 10)

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

(use-package savehist
  :ensure nil
  :commands (savehist-mode savehist-save)
  :hook
  (after-init . savehist-mode)
  :init
  (setq history-length 300)
  (setq savehist-autosave-interval 600))

(use-package saveplace
  :ensure nil
  :commands (save-place-mode save-place-local-mode)
  :hook
  (after-init . save-place-mode)
  :init
  (setq save-place-limit 400))

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

(use-package server
  :ensure nil
  :commands server-start
  :hook
  (after-init . server-start))

(delete-selection-mode 1)

(setq enable-dir-local-variables nil)

(use-package compat)

(add-hook 'after-init-hook #'minibuffer-depth-indicate-mode)

(setq confirm-kill-emacs 'y-or-n-p)

;; Constrain vertical cursor movement to lines within the buffer
(use-package dired
  :ensure nil
  :config
  (setq dired-movement-style 'bounded-files)
  ;; dired: Group directories first
  (let ((args "--group-directories-first -ahlv"))
    (when (or (eq system-type 'darwin) (eq system-type 'berkeley-unix))
      (if-let* ((gls (executable-find "gls")))
          (setq insert-directory-program gls)
        (setq args nil)))
    (when args
      (setq dired-listing-switches args))))

(use-package etags
  :ensure nil
  ;; universal-ctags needs to be compiled and installed separately
  :config
  (setq etags-program-name "uctags -e --recurse --map-javascript=+.jsx")
  :hook
  (prog-mode . etags-regen-mode))

(use-package treesit-auto
  :ensure t 
  :custom
  (treesit-auto-install 'prompt)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

;; the version of transient that's builtin is too old for magit
;; :ensure t is not needed but best be clear about it
(use-package transient
  :ensure t)
(use-package magit
  :after transient
  :ensure t)

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
  (custom-set-variables '(c-ts-mode-indent-style 'bsd)))

(use-package c-ts-mode
  :ensure nil
  ;; using hooks in reverse here, but hey, it works
  :hook
  (c-ts-mode . 42-indent-setup))

(use-package c++-ts-mode
  :ensure nil
  :hook
  (c++-ts-mode . 42-indent-setup))

(use-package odin-ts-mode
  :ensure (:host github :repo "Sampie159/odin-ts-mode")
  ;; TODO : find way to install language grammar automatically
  :mode
  "\\.odin\\'")

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
  :init
  ;; lets us tangle this file on save
  (add-to-list 'safe-local-eval-forms
               '(add-hook 'after-save-hook #'org-babel-tangle t t))
  :config
  (add-hook 'org-mode-hook (lambda () (setq enable-local-eval 1)))
  (add-hook 'org-mode-hook (lambda () (org-indent-mode +1)))
  (define-key org-mode-map (kbd "C-a") 'org-beginning-of-line)
  (require 'org-tempo)
  ;; Specifying mode-line here because face-background returns nil
  ;; on unspecified
  (set-face-background
   'org-block (face-background 'mode-line)))

(use-package mu4e
  :ensure nil                           ; comes with mu (AUR in this case)
  :defer 20
  :config
  (setq mu4e-sent-folder   "/[Gmail]/Sent Mail"
        mu4e-drafts-folder "/[Gmail]/Drafts"  
        mu4e-trash-folder  "/[Gmail]/Bin"
        mu4e-refile-folder "/Archive")
  ;; setup some handy shortcuts
  ;; you can quickly switch to your Inbox -- press ``ji''
  ;; then, when you want archive some messages, move them to
  ;; the 'All Mail' folder by pressing ``ma''.
  (setq mu4e-maildir-shortcuts
        '( (:maildir "/INBOX"              :key ?i)
           (:maildir "/[Gmail]/Sent Mail"  :key ?s)
           (:maildir "/[Gmail]/Bin"      :key ?t)
           (:maildir "/[Gmail]/All Mail"   :key ?a)))

  (add-to-list 'mu4e-bookmarks
               ;; ':favorite t' i.e, use this one for the modeline
               '(:query "maildir:/INBOX" :name "Inbox" :key ?i :favorite t))

  ;; allow for updating mail using 'U' in the main view:
  (setq mu4e-get-mail-command "mbsync gmail")

  ;; something about ourselves
  (setq
   user-mail-address "lucascordu@gmail.com"
   user-full-name  "Lucas Correia Dupuy"
   message-signature
   "Lucas Correia Dupuy\n")

  ;; sending mail -- replace USERNAME with your gmail username
  ;; also, make sure the gnutls command line utils are installed
  ;; package 'gnutls-bin' in Debian/Ubuntu
  (require 'smtpmail)
  (setq message-send-mail-function 'smtpmail-send-it
        starttls-use-gnutls t
        smtpmail-starttls-credentials '(("smtp.gmail.com" 587 nil nil))
        smtpmail-auth-credentials
        '(("smtp.gmail.com" 587 "lucascordu@gmail.com" nil))
        smtpmail-default-smtp-server "smtp.gmail.com"
        smtpmail-smtp-server "smtp.gmail.com"
        smtpmail-smtp-service 587)

  ;; don't keep message buffers around
  (setq message-kill-buffer-on-exit t)

  ;; prefer plain text
  (with-eval-after-load "mm-decode"
    (add-to-list 'mm-discouraged-alternatives "text/html")
    (add-to-list 'mm-discouraged-alternatives "text/richtext"))

  ;; the default one with from/to instead of From
  (setq mu4e-headers-fields '((:human-date . 12) (:flags . 6) (:mailing-list . 10) (:from-or-to . 22) (:subject)))

  ;; fix mu4e/mbsync desync
  (setq mu4e-change-filenames-when-moving t)

  ;; sync with Gmail every 5 minutes (only when running)
  (setq mu4e-update-interval 300)

  ;; make mu4e the default for mail things
  (setq mail-user-agent 'mu4e-user-agent)
  (set-variable 'read-mail-command 'mu4e)

  ;; header view
  (setq mu4e-headers-draft-mark     '("D" . "")
        mu4e-headers-flagged-mark   '("F" . "")
        mu4e-headers-new-mark       '("N" . "")
        mu4e-headers-passed-mark    '("P" . "󰄾")
        mu4e-headers-replied-mark   '("R" . "󰼠")
        mu4e-headers-seen-mark      '("S" . "☑")
        mu4e-headers-trashed-mark   '("T" . "󰩺")
        mu4e-headers-attach-mark    '("a" . "")
        mu4e-headers-encrypted-mark '("x" . "")
        mu4e-headers-signed-mark    '("s" . "")
        mu4e-headers-unread-mark    '("u" . "")
        mu4e-headers-list-mark      '("l" . "")
        mu4e-headers-personal-mark  '("p" . "")
        mu4e-headers-calendar-mark  '("c" . "")

        mu4e-modeline-unread-items  '("U" . "")
        mu4e-modeline-all-read      '("R" . "☑")
        mu4e-modeline-new-items     '("N" . "")
        mu4e-modeline-all-clear     '("C" . " ")
        mu4e-use-fancy-chars t)

  ;; start mu4e in the background
  (mu4e 1))

;; This is already set in early-init.el
;; (setq custom-file "~/.config/emacs/custom.el")
(load custom-file 'noerror 'nomessage)
