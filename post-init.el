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

;; When Delete Selection mode is enabled, typed text replaces the selection
;; if the selection is active.
(delete-selection-mode 1)

;;; Theme various
;; toggles line wrap and visual line navigation
(global-visual-line-mode 1)

;; Display of line numbers in the buffer:
(setq-default display-line-numbers-type 'relative)
(dolist (hook '(prog-mode-hook text-mode-hook conf-mode-hook))
  (add-hook hook #'display-line-numbers-mode))

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
  :config
  (spacious-padding-mode)
  ;; The depths of hell i had to go through for this shit to work,
  ;; don't touch this ever again, i don't know why there are 1500 ways to set faces in emacs
  (set-face-attribute 'mode-line-active nil :background (face-background 'mode-line)))


;; Set the maximum level of syntax highlighting for Tree-sitter modes
(setq treesit-font-lock-level 4)

(unless (and (eq window-system 'mac)
             (bound-and-true-p mac-carbon-version-string))
  ;; Enables `pixel-scroll-precision-mode' on all operating systems and Emacs
  ;; versions, except for emacs-mac.
  ;;
  ;; Enabling `pixel-scroll-precision-mode' is unnecessary with emacs-mac, as
  ;; this version of Emacs natively supports smooth scrolling.
  ;; https://bitbucket.org/mituharu/emacs-mac/commits/65c6c96f27afa446df6f9d8eff63f9cc012cc738
  (setq pixel-scroll-precision-use-momentum nil) ; Precise/smoother scrolling
  (pixel-scroll-precision-mode 1))

;; Paren match highlighting
(add-hook 'after-init-hook #'show-paren-mode)

;; Display the time in the modeline
(add-hook 'after-init-hook #'display-time-mode)

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

;;;; C/C++
(defun 42-indent-setup ()
      (setq-local indent-tabs-mode t)
      (setq-local tab-width 4)
      (setq-local c-ts-mode-indent-offset 4)
      (setq-local c-ts-common-indent-offset 4))

(use-package c-ts-mode
  :ensure nil
  :hook
  (c-ts-mode . 42-indent-setup))

(use-package c++-ts-mode
  :ensure nil
  :hook
  (c++-ts-mode . 42-indent-setup))
