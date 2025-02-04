;;; package --- Summary
(add-to-list 'load-path "~/.config/emacs/scripts/")

(require 'elpaca-setup)  ;; The Elpaca Package Manager
(require 'buffer-move)   ;; Buffer-move for better window management
(require 'eshell-prompt) ;; A fancy prompt for eshell

(defun dir-concat (dir file)
    "join path DIR with filename FILE correctly"
    (concat (file-name-as-directory dir) file))

(defvar user-cache-directory "~/.cache/emacs/"
  "Location where files created by emacs are placed.")


;;; Commentary:
;; Auto-revert in Emacs is a feature that automatically updates the
;; contents of a buffer to reflect changes made to the underlying file
;; on disk.
(add-hook 'after-init-hook #'global-auto-revert-mode)

;; recentf is an Emacs package that maintains a list of recently
;; accessed files, making it easier to reopen files you have worked on
;; recently.
(add-hook 'after-init-hook #'recentf-mode)

;; savehist is an Emacs feature that preserves the minibuffer history between
;; sessions. It saves the history of inputs in the minibuffer, such as commands,
;; search strings, and other prompts, to a file. This allows users to retain
;; their minibuffer history across Emacs restarts.
(add-hook 'after-init-hook #'savehist-mode)

;; save-place-mode enables Emacs to remember the last location within a file
;; upon reopening. This feature is particularly beneficial for resuming work at
;; the precise point where you previously left off.
(add-hook 'after-init-hook #'save-place-mode)

(setq save-place-file "~/.cache/emacs/places")
(setq transient-history-file "~/.cache/emacs/transient-history.el")

;; Expands to: (elpaca evil (use-package evil :demand t))
(use-package evil
    :ensure t
    :init      ;; tweak evil's configuration before loading it
    (setq evil-want-integration t  ;; This is optional since it's already set to t by default.
          evil-want-keybinding nil
          evil-vsplit-window-right t
          evil-split-window-below t
          evil-undo-system 'undo-redo)  ;; Adds vim-like C-r redo functionality
    (evil-mode 1))

(use-package evil-collection
  :after evil
  :config
  ;; Do not uncomment this unless you want to specify each and every mode
  ;; that evil-collection should works with.  The following line is here 
  ;; for documentation purposes in case you need it.  
  ;; (setq evil-collection-mode-list '(calendar dashboard dired ediff info magit ibuffer))
  (add-to-list 'evil-collection-mode-list 'help) ;; evilify help mode
  (evil-collection-init))

(use-package evil-tutor)

;; Using RETURN to follow links in Org/Evil 
;; Unmap keys in 'evil-maps if not done, (setq org-return-follows-link t) will not work
(with-eval-after-load 'evil-maps
  (define-key evil-motion-state-map (kbd "SPC") nil)
  (define-key evil-motion-state-map (kbd "RET") nil)
  (define-key evil-motion-state-map (kbd "TAB") nil))
;; Setting RETURN key in org-mode to follow links
  (setq org-return-follows-link  t)

(use-package all-the-icons
  :ensure t
  :if (display-graphic-p))

(use-package all-the-icons-dired
  :hook (dired-mode . (lambda () (all-the-icons-dired-mode t))))

(use-package all-the-icons-completion
  :ensure t
  :defer
  :hook (marginalia-mode . #'all-the-icons-completion-marginalia-setup)
  :init
  (all-the-icons-completion-mode))

(use-package nerd-icons
  ;; :custom
  ;; The Nerd Font you want to use in GUI
  ;; "Symbols Nerd Font Mono" is the default and is recommended
  ;; but you can use any other Nerd Font if you want
  ;; (nerd-icons-font-family "Symbols Nerd Font Mono")
  )

(use-package async
  :ensure t
  :init (dired-async-mode 1))

(setq backup-directory-alist '((".*" . "~/.local/share/Trash/files")))
;;(setq backup-directory-alist
;;      `(("." . ,(dir-concat user-cache-directory "backup")))
;;      backup-by-copying t ; Use copies
;;      version-control t ; Use version numbers on backups
;;      delete-old-versions t ; Automatically delete excess backups
;;      kept-new-versions 5 ; Newest versions to keep
;;      kept-old-versions 3 ; Old versions to keep
;;      )

(use-package beacon
  :ensure t
  :config
  (beacon-mode 1))

;; https://stackoverflow.com/questions/9547912/emacs-calendar-show-more-than-3-months

(use-package calfw)
(use-package calfw-org)
;;(use-package calendar)

(defun dt/year-calendar (&optional year)
  (interactive)
  (require 'calendar)
  (let* (
      (current-year (number-to-string (nth 5 (decode-time (current-time)))))
      (month 0)
      (year (if year year (string-to-number (format-time-string "%Y" (current-time))))))
    (switch-to-buffer (get-buffer-create calendar-buffer))
    (when (not (eq major-mode 'calendar-mode))
      (calendar-mode))
    (setq displayed-month month)
    (setq displayed-year year)
    (setq buffer-read-only nil)
    (erase-buffer)
    ;; horizontal rows
    (dotimes (j 4)
      ;; vertical columns
      (dotimes (i 3)
        (calendar-generate-month
          (setq month (+ month 1))
          year
          ;; indentation / spacing between months
          (+ 5 (* 25 i))))
      (goto-char (point-max))
      (insert (make-string (- 10 (count-lines (point-min) (point-max))) ?\n))
      (widen)
      (goto-char (point-max))
      (narrow-to-region (point-max) (point-max)))
    (widen)
    (goto-char (point-min))
    (setq buffer-read-only t)))

(defun dt/scroll-year-calendar-forward (&optional arg event)
  "Scroll the yearly calendar by year in a forward direction."
  (interactive (list (prefix-numeric-value current-prefix-arg)
                     last-nonmenu-event))
  (unless arg (setq arg 0))
  (save-selected-window
    (if (setq event (event-start event)) (select-window (posn-window event)))
    (unless (zerop arg)
      (let* (
              (year (+ displayed-year arg)))
        (dt/year-calendar year)))
    (goto-char (point-min))
    (run-hooks 'calendar-move-hook)))

(defun dt/scroll-year-calendar-backward (&optional arg event)
  "Scroll the yearly calendar by year in a backward direction."
  (interactive (list (prefix-numeric-value current-prefix-arg)
                     last-nonmenu-event))
  (dt/scroll-year-calendar-forward (- (or arg 1)) event))

(defalias 'year-calendar 'dt/year-calendar)

(use-package centaur-tabs
  :init
  (setq centaur-tabs-enable-key-bindings t)
  :config
  (setq centaur-tabs-style "bar"
        centaur-tabs-height 25
        centaur-tabs-set-icons t
	      centaur-tab-buffer-local-list '(("\\*scratch\\*" :hide t) ("\\*Warnings\\*" :hide t) ("\\*straight-process\\*" :hide t) ("\\*Messages\\*" :hide t) ("\\Tasks.org\\" :hide t))
        centaur-tabs-show-new-tab-button t
        centaur-tabs-set-modified-marker t
        centaur-tabs-modified-marker "•"
        centaur-tabs-show-navigation-buttons t
        ;; centaur-tabs-set-bar 'under
        centaur-tabs-set-bar 'over
        centaur-tabs-show-count nil
        centaur-tabs-label-fixed-length 15
        centaur-tabs-gray-out-icons 'buffer
        ;; centaur-tabs-plain-icons t
        x-underline-at-descent-line t
        centaur-tabs-left-edge-margin nil)
  (centaur-tabs-change-fonts (face-attribute 'default :font) 110)
  (centaur-tabs-headline-match)
  ;; (centaur-tabs-enable-buffer-alphabetical-reordering)
  ;; (setq centaur-tabs-adjust-buffer-order t)
  (centaur-tabs-mode t)
  (setq uniquify-separator "/")
  (setq uniquify-buffer-name-style 'forward)
  (defun centaur-tabs-buffer-groups ()
    "`centaur-tabs-buffer-groups' control buffers' group rules.

Group centaur-tabs with mode if buffer is derived from `eshell-mode' `emacs-lisp-mode' `dired-mode' `org-mode' `magit-mode'.
All buffer name start with * will group to \"Emacs\".
Other buffer group by `centaur-tabs-get-group-name' with project name."
    (list
     (cond
      ;; ((not (eq (file-remote-p (buffer-file-name)) nil))
      ;; "Remote")
      ((or (string-equal "*" (substring (buffer-name) 0 1))
           (memq major-mode '(magit-process-mode
                              magit-status-mode
                              magit-diff-mode
                              magit-log-mode
                              magit-file-mode
                              magit-blob-mode
                              magit-blame-mode
                              )))
       "Emacs")
      ((derived-mode-p 'prog-mode)
       "Editing")
      ((derived-mode-p 'dired-mode)
       "Dired")
      ((memq major-mode '(helpful-mode
                          help-mode))
       "Help")
      ((memq major-mode '(org-mode
                          org-agenda-clockreport-mode
                          org-src-mode
                          org-agenda-mode
                          org-beamer-mode
                          org-indent-mode
                          org-bullets-mode
                          org-cdlatex-mode
                          org-agenda-log-mode
                          diary-mode))
       "OrgMode")
      (t
       (centaur-tabs-get-group-name (current-buffer))))))
  :hook
  (dashboard-mode . centaur-tabs-local-mode)
  (term-mode . centaur-tabs-local-mode)
  (calendar-mode . centaur-tabs-local-mode)
  (org-agenda-mode . centaur-tabs-local-mode)
  :bind
  ("C-<prior>" . centaur-tabs-backward)
  ("C-<next>" . centaur-tabs-forward)
  ("C-S-<prior>" . centaur-tabs-move-current-tab-to-left)
  ("C-S-<next>" . centaur-tabs-move-current-tab-to-right)
  (:map evil-normal-state-map
        ("g t" . centaur-tabs-forward)
        ("g T" . centaur-tabs-backward)))


(defun my/centaur-tabs-buffer-groups ()
    (list
     (cond
      ;; ((member (buffer-name) '("*scratch*" "*Messages*" "*dashboard*" "*eww*")) "All")
      ((string-equal "newsrc-dribble" (buffer-name)) "Others")
      ((derived-mode-p 'gnus-mode) "All") ;; "Email")
      ((eq major-mode 'message-mode) "All")
      ((string-equal "*" (substring (buffer-name) 0 1)) "Others")
      ((string-match "org.*sidebar" (buffer-name)) "Others")
      ((string-match "<tree>" (buffer-name)) "Others")
      ((string-match "^TAGS.*" (buffer-name)) "Others")
      ((eq major-mode 'dired-mode) "dired")
      (t "All"))))
(setq centaur-tabs-buffer-groups-function #'my/centaur-tabs-buffer-groups)

(defun my/switch-tabs (&optional direction cycle-group)
  "Change tabs in direction `left' or `right' of current tab.  If not provided, then
    the keys to get to this function will look for `left' or `right' to set direction.
    Optional `cycle-group' is to move to next tab-group vs tab, default nil.  Using
    Escape key prefix will do groups." ;;gives keys > 1 for key ?91
  (interactive)
  (let* ((keys (mapcar #'event-basic-type (this-command-keys-vector)))
         (direction (if direction direction (if (or (member 'left keys)
                                                    (member 'home keys))
                                                'left
                                              'right)))
         (centaur-tabs-cycle-scope
          (if cycle-group
              'groups
            (if (> (length keys) 1) 'groups 'tabs))))
    (if (eq window-system 'mac)
        (mac-start-animation
         (selected-window)
         :type 'swipe :direction direction))
    (centaur-tabs-cycle (eq direction 'left))))

;; Cycle between tabs, only in current group.
(keymap-global-set "C-M-<right>" #'my/switch-tabs)
(keymap-global-set "C-M-<left>" #'my/switch-tabs)

;; (use-package company-tabnine
;;   :ensure t
;;   :after company
;;   :config
;;   ;; Set up company-tabnine as the primary backend
;;   (setq company-backends
;;         '((company-tabnine :separate company-capf company-dabbrev-code company-keywords company-files)))

;;   ;; Performance optimizations
;;   (setq company-tabnine-max-num-results 5) ;; Limit number of suggestions
;;   (setq company-tabnine-no-continue t) ;; Reset idle timer on all keystrokes
;;   (setq company-tabnine-wait 0.1) ;; Set response wait time

;;   ;; Additional configurations
;;   (setq company-tabnine-always-trigger t) 
;;   (setq company-tabnine-auto-balance nil) 
;;   (setq company-tabnine-auto-fallback t)
;;   (setq company-tabnine-context-radius 0)
;;   (setq company-tabnine-context-radius-after 0) 
;;   (setq company-tabnine-insert-arguments nil) 
;;   (setq company-tabnine-install-static-binary nil)  
;;   (setq company-tabnine-log-file-path nil) 
;;   (setq company-tabnine-max-restart-count 5) 
;;   (setq company-tabnine-show-annotation t) 
;;   (setq company-tabnine-use-native-json t) 
;;   (setq company-tabnine-binaries-folder "~/.TabNine") ;; Set binaries folder path
;;   )

(use-package tabnine
  :commands (tabnine-start-process)
  :hook (prog-mode . tabnine-mode)
  :ensure t
  :diminish "⌬"
  :custom
  (tabnine-wait 0)
  (tabnine-minimum-prefix-length 0)
  :hook (kill-emacs . tabnine-kill-process)
  :config
  (add-to-list 'completion-at-point-functions #'tabnine-completion-at-point)
  (tabnine-start-process)
  :bind
  (:map  tabnine-completion-map
	 ("<tab>" . tabnine-accept-completion)
	 ("TAB" . tabnine-accept-completion)
	 ("M-f" . tabnine-accept-completion-by-word)
	 ("M-<return>" . tabnine-accept-completion-by-line)
	 ("C-g" . tabnine-clear-overlay)
	 ("M-[" . tabnine-previous-completion)
	 ("M-]" . tabnine-next-completion)))

(use-package company
  ;; :after lsp-mode
  ;; :hook (lsp-mode . company-mode)
  :bind 
  (:map company-active-map
    ("C-n" . company-select-next)
    ("C-p" . company-select-previous)
    ("M-<" . company-select-first)
    ("M->" . company-select-last)
    ("<tab>" . company-complete-selection))
    ;;(:map lsp-mode-map
    ;;      ("<tab>" . company-indent-or-complete-common))
  :custom
  (company-minimum-prefix-length 1)
  (company-require-match nil)
  (company-idle-delay 0)
  ;; Number the candidates (use M-1, M-2 etc to select completions).
  (company-show-numbers t)
  (company-tooltip-offset-display 'lines) ;; scrollbar & lines
  (company-tooltip-align-annotations t)
  (setq  company-frontends
      '(company-pseudo-tooltip-unless-just-one-frontend-with-delay
        company-preview-frontend
        company-echo-metadata-frontend))
  (global-company-mode t))

(setq company-tooltip-limit 10)
(setq company-tooltip-minimum 4) ;; Ensure at least 4 candidates are visible
(setq company-tooltip-flip-when-above t) ;; Keep candidates visually consistent
(setq company-text-face-extra-attributes '(:weight bold :slant italic))

;; Add a fancy UI for company
(use-package company-box
  :after company
  :diminish
  :hook (company-mode . company-box-mode))

;;(use-package page-break-lines :ensure t)

(use-package dashboard
  :ensure t
  :init
  (setq initial-buffer-choice 'dashboard-open)
  (setq dashboard-set-heading-icons t)
  (setq dashboard-set-file-icons t)
  (setq dashboard-icon-type 'all-the-icons)
  (setq dashboard-show-shortcuts nil)
  (setq dashboard-projects-backend 'projectile) ;; Ensure projectile is used for projects
  (setq dashboard-banner-logo-title "I'll Walk My Own Path!")
  (setq dashboard-startup-banner 'logo) ;; use standard emacs logo as banner
  ;;(setq dashboard-startup-banner "~/.config/emacs/assets/emacs.png")  ;; use custom image as banner
  (setq dashboard-center-content t) ;; set to 't' for centered content
  (setq dashboard-items '((vocabulary)
                          (recents . 5)
                          (agenda . 5)
                          (bookmarks . 5)
                          (projects . 5)))

  ;;(setq dashboard-page-separator "\n\f\n")

  (setq dashboard-startupify-list '(dashboard-insert-banner
                                  dashboard-insert-newline
                                  dashboard-insert-banner-title
                                  dashboard-insert-newline
                                  dashboard-insert-init-info
                                  dashboard-insert-items))
  (setq dashboard-item-generators '(
                                    (vocabulary . gopar/dashboard-insert-vocabulary)
                                    (recents . dashboard-insert-recents)
                                    (bookmarks . dashboard-insert-bookmarks)
                                    (agenda . dashboard-insert-agenda) ;; Add agenda widget
                                    (projects . dashboard-insert-projects) ;; Add projects widget
                                    ))
    
  (defun gopar/dashboard-insert-vocabulary (list-size)
    (dashboard-insert-heading "Word of the Day:"
                              nil
                              (all-the-icons-faicon "newspaper-o"
                                                    :height 1.2
                                                    :v-adjust 0.0
                                                    :face 'dashboard-heading))
    (insert "\n")
    (let ((random-line nil)
          (lines nil))
      (with-temp-buffer
        (insert-file-contents (concat user-emacs-directory "assets/words"))
        (goto-char (point-min))
        (setq lines (split-string (buffer-string) "\n" t))
        (setq random-line (nth (random (length lines)) lines))
        (setq random-line (string-join (split-string random-line) " ")))
      (insert "    " random-line)))


  :config
  (dashboard-setup-startup-hook))

(use-package diminish
  :ensure t
  :init 
  (diminish 'visual-line-mode)
  (diminish 'subword-mode)
  (diminish 'beacon-mode)
  (diminish 'irony-mode)
  (diminish 'page-break-lines-mode)
  (diminish 'rainbow-delimiters-mode)
  (diminish 'auto-revert-mode)
  (diminish 'yas-minor-mode)
)

(use-package dired-open
  :config
  (setq dired-open-extensions '(("gif" . "sxiv")
                                ("jpg" . "sxiv")
                                ("png" . "sxiv")
                                ("mkv" . "mpv")
                                ("mp4" . "mpv"))))

(use-package peep-dired
  :after dired
  :hook (evil-normalize-keymaps . peep-dired-hook)
  :config
    (evil-define-key 'normal dired-mode-map (kbd "h") 'dired-up-directory)
    (evil-define-key 'normal dired-mode-map (kbd "l") 'dired-open-file) ; use dired-find-file instead if not using dired-open package
    (evil-define-key 'normal peep-dired-mode-map (kbd "j") 'peep-dired-next-file)
    (evil-define-key 'normal peep-dired-mode-map (kbd "k") 'peep-dired-prev-file)
)

(use-package drag-stuff
  :init
  (drag-stuff-global-mode 1)
  (drag-stuff-define-keys))

(setq ediff-split-window-function 'split-window-horizontally
      ediff-window-setup-function 'ediff-setup-windows-plain)

(defun dt-ediff-hook ()
  (ediff-setup-keymap)
  (define-key ediff-mode-map "j" 'ediff-next-difference)
  (define-key ediff-mode-map "k" 'ediff-previous-difference))

(add-hook 'ediff-mode-hook 'dt-ediff-hook)

(use-package embark
  :ensure t
:commands (embark-act
             embark-dwim
             embark-export
             embark-collect
             embark-bindings
             embark-prefix-help-command)

  :init
  (setq prefix-help-command #'embark-prefix-help-command)

  :config
  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

(use-package embark-consult
 :ensure t
 :hook
 (embark-collection-mode . consult-preview-at-point-mode))

(use-package flycheck
  :ensure t
  :defer t
  :diminish
  :init (global-flycheck-mode))

(use-package format-all
  :preface
  (defun ian/format-code ()
    "Auto-format whole buffer."
    (interactive)
    (if (derived-mode-p 'prolog-mode)
        (prolog-indent-buffer)
      (format-all-buffer)))
  :config
  (add-hook 'prog-mode-hook #'format-all-ensure-formatter))

(use-package evil-nerd-commenter)
(global-set-key (kbd "C-a") 'mark-whole-buffer)
(use-package general
  :config
  (general-evil-setup)
  
  ;; set up 'SPC' as the global leader key
  (general-create-definer dt/leader-keys
    :states '(normal insert visual emacs)
    :keymaps 'override
    :prefix "SPC" ;; set leader
    :global-prefix "M-SPC") ;; access leader in insert mode

  (dt/leader-keys
    "SPC" '(counsel-M-x :wk "Counsel M-x")
    "." '(find-file :wk "Find file")
    "=" '(perspective-map :wk "Perspective") ;; Lists all the perspective keybindings
    "/" '(evilnc-comment-or-uncomment-lines :wk "Comment lines")
    "TAB TAB" '(comment-line :wk "Comment lines")
    "u" '(universal-argument :wk "Universal argument"))
    

   (dt/leader-keys
    "a" '(:ignore t :wk "A.I.")
    "a a" '(ellama-ask-about :wk "Ask ellama about region")
    "a e" '(:ignore t :wk "Ellama enhance")
    "a e g" '(ellama-improve-grammar :wk "Ellama enhance wording")
    "a e w" '(ellama-improve-wording :wk "Ellama enhance grammar")
    "a i" '(ellama-chat :wk "Ask ellama")
    "a p" '(ellama-provider-select :wk "Ellama provider select")
    "a s" '(ellama-summarize :wk "Ellama summarize region")
    "a t" '(ellama-translate :wk "Ellama translate region"))
   
  (dt/leader-keys
    "b" '(:ignore t :wk "Bookmarks/Buffers")
    "b b" '(switch-to-buffer :wk "Switch to buffer")
    "b c" '(clone-indirect-buffer :wk "Create indirect buffer copy in a split")
    "b C" '(clone-indirect-buffer-other-window :wk "Clone indirect buffer in new window")
    "b d" '(bookmark-delete :wk "Delete bookmark")
    "b I" '(ibuffer :wk "Ibuffer")
    "b i" '(persp-ivy-switch-buffer :wk "Persp Ibuffer")
    "b k" '(kill-current-buffer :wk "Kill current buffer")
    "b K" '(kill-some-buffers :wk "Kill multiple buffers")
    "b l" '(list-bookmarks :wk "List bookmarks")
    "b m" '(bookmark-set :wk "Set bookmark")
    "b n" '(next-buffer :wk "Next buffer")
    "b p" '(previous-buffer :wk "Previous buffer")
    "b r" '(revert-buffer :wk "Reload buffer")
    "b R" '(rename-buffer :wk "Rename buffer")
    "b s" '(basic-save-buffer :wk "Save buffer")
    "b S" '(save-some-buffers :wk "Save multiple buffers")
    "b w" '(bookmark-save :wk "Save current bookmarks to bookmark file"))
  
  (dt/leader-keys
    "c" '(:ignore t :wk "Centaur Tabs")
    "c n" '(centaur-tabs-forward-tab :wk "Next Tab")
    "c p" '(centaur-tabs-backward-tab :wk "Previous Tab")
    "c c" '(centaur-tabs-close-tab :wk "Close Tab")
    "c r" '(centaur-tabs-rename-tab :wk "Rename Tab")
    "c l" '(centaur-tabs-list-tabs :wk "List Tabs")
    "c m" '(centaur-tabs-move-current-tab-to-left :wk "Move Tab Left")
    "c <left>" '(dt/scroll-year-calendar-backward :wk "Scroll year calendar backward")
    "c <right>" '(dt/scroll-year-calendar-forward :wk "Scroll year calendar forward")
    "c y" '(dt/year-calendar :wk "Show year calendar")
    "c t" '(centaur-tabs-move-current-tab-to-right :wk "Move Tab Right"))

  (dt/leader-keys
    "d" '(:ignore t :wk "Dired")
    "d d" '(dired :wk "Open dired")
    "d f" '(wdired-finish-edit :wk "Writable dired finish edit")
    "d j" '(dired-jump :wk "Dired jump to current")
    "d n" '(treemacs-find-file :wk "Open file in Treemacs")
    ;;"d n" '(neotree-dir :wk "Open directory in neotree")
    "d p" '(peep-dired :wk "Peep-dired")
    "d w" '(wdired-change-to-wdired-mode :wk "Writable dired"))

  (dt/leader-keys
    "e" '(:ignore t :wk "Ediff/Eshell/Eval/EWW")    
    "e b" '(eval-buffer :wk "Evaluate elisp in buffer")
    "e d" '(eval-defun :wk "Evaluate defun containing or after point")
    "e e" '(eval-expression :wk "Evaluate and elisp expression")
    "e f" '(ediff-files :wk "Run ediff on a pair of files")
    "e F" '(ediff-files3 :wk "Run ediff on three files")
    "e h" '(counsel-esh-history :which-key "Eshell history")
    "e l" '(eval-last-sexp :wk "Evaluate elisp expression before point")
    "e n" '(eshell-new :wk "Create new eshell buffer")
    "e r" '(eval-region :wk "Evaluate elisp in region")
    "e R" '(eww-reload :which-key "Reload current page in EWW")
    "e s" '(eshell :which-key "Eshell")
    "e w" '(eww :which-key "EWW emacs web wowser"))

  (dt/leader-keys
    "f" '(:ignore t :wk "Files")    
    "f c" '((lambda () (interactive)
              (find-file "~/.config/emacs/config.org")) 
            :wk "Open emacs config.org")
    "f e" '((lambda () (interactive)
              (dired "~/.config/emacs/")) 
            :wk "Open user-emacs-directory in dired")
    "f d" '(find-grep-dired :wk "Search for string in files in DIR")
    "f m" '(ian/format-code :wk "Format Buffer")
    "f g" '(counsel-grep-or-swiper :wk "Search for string current file")
    "f i" '((lambda () (interactive)
              (find-file "~/.config/emacs/init.el")) 
            :wk "Open emacs init.el")
    "f j" '(counsel-file-jump :wk "Jump to a file below current directory")
    "f l" '(counsel-locate :wk "Locate a file")
    "f r" '(counsel-recentf :wk "Find recent files")
    "f u" '(sudo-edit-find-file :wk "Sudo find file")
    "f U" '(sudo-edit :wk "Sudo edit file"))
  
  (dt/leader-keys
    "g" '(:ignore t :wk "Git")    
    "g /" '(magit-displatch :wk "Magit dispatch")
    "g ." '(magit-file-displatch :wk "Magit file dispatch")
    "g b" '(magit-branch-checkout :wk "Switch branch")
    "g c" '(:ignore t :wk "Create") 
    "g c b" '(magit-branch-and-checkout :wk "Create branch and checkout")
    "g c c" '(magit-commit-create :wk "Create commit")
    "g c f" '(magit-commit-fixup :wk "Create fixup commit")
    "g C" '(magit-clone :wk "Clone repo")
    "g f" '(:ignore t :wk "Find") 
    "g f c" '(magit-show-commit :wk "Show commit")
    "g f f" '(magit-find-file :wk "Magit find file")
    "g f g" '(magit-find-git-config-file :wk "Find gitconfig file")
    "g F" '(magit-fetch :wk "Git fetch")
    "g g" '(magit-status :wk "Magit status")
    "g i" '(magit-init :wk "Initialize git repo")
    "g l" '(magit-log-buffer-file :wk "Magit buffer log")
    "g r" '(vc-revert :wk "Git revert file")
    "g s" '(magit-stage-file :wk "Git stage file")
    "g t" '(git-timemachine :wk "Git time machine")
    "g u" '(magit-stage-file :wk "Git unstage file"))

 (dt/leader-keys
    "h" '(:ignore t :wk "Help")
    "h a" '(counsel-apropos :wk "Apropos")
    "h b" '(describe-bindings :wk "Describe bindings")
    "h c" '(describe-char :wk "Describe character under cursor")
    "h d" '(:ignore t :wk "Emacs documentation")
    "h d a" '(about-emacs :wk "About Emacs")
    "h d d" '(view-emacs-debugging :wk "View Emacs debugging")
    "h d f" '(view-emacs-FAQ :wk "View Emacs FAQ")
    "h d m" '(info-emacs-manual :wk "The Emacs manual")
    "h d n" '(view-emacs-news :wk "View Emacs news")
    "h d o" '(describe-distribution :wk "How to obtain Emacs")
    "h d p" '(view-emacs-problems :wk "View Emacs problems")
    "h d t" '(view-emacs-todo :wk "View Emacs todo")
    "h d w" '(describe-no-warranty :wk "Describe no warranty")
    "h e" '(view-echo-area-messages :wk "View echo area messages")
    "h f" '(describe-function :wk "Describe function")
    "h F" '(describe-face :wk "Describe face")
    "h g" '(describe-gnu-project :wk "Describe GNU Project")
    "h i" '(info :wk "Info")
    "h I" '(describe-input-method :wk "Describe input method")
    "h k" '(describe-key :wk "Describe key")
    "h l" '(view-lossage :wk "Display recent keystrokes and the commands run")
    "h L" '(describe-language-environment :wk "Describe language environment")
    "h m" '(describe-mode :wk "Describe mode")
    "h r" '(:ignore t :wk "Reload")
    "h r r" '((lambda () (interactive)
                (load-file "~/.config/emacs/init.el")
                (ignore (elpaca-process-queues)))
              :wk "Reload emacs config")
    "h t" '(load-theme :wk "Load theme")
    "h v" '(describe-variable :wk "Describe variable")
    "h w" '(where-is :wk "Prints keybinding for command if set")
    "h x" '(describe-command :wk "Display full documentation for command"))

  (dt/leader-keys
    "m" '(:ignore t :wk "Org")
    "m a" '(org-agenda :wk "Org agenda")
    "m e" '(org-export-dispatch :wk "Org export dispatch")
    "m i" '(org-toggle-item :wk "Org toggle item")
    "m t" '(org-todo :wk "Org todo")
    "m B" '(org-babel-tangle :wk "Org babel tangle")
    "m T" '(org-todo-list :wk "Org todo list"))

  (dt/leader-keys
    "i" '(:ignore t :wk "Custom")
    "i a" '(dt/insert-auto-tangle-tag :wk "Insert auto-tangle tag"))
  
  (dt/leader-keys
    "q" '(:ignore t :wk "Quit")
    "q q" '(evil-quit :wk " Quit Emacs"))
 
  (dt/leader-keys
    "m b" '(:ignore t :wk "Tables")
    "m b -" '(org-table-insert-hline :wk "Insert hline in table"))

  (dt/leader-keys
    "m d" '(:ignore t :wk "Date/deadline")
    "m d t" '(org-time-stamp :wk "Org time stamp"))

  (dt/leader-keys
    "o" '(:ignore t :wk "Open")
    "o d" '(dashboard-open :wk "Dashboard")
    "o e" '(elfeed :wk "Elfeed RSS")
    "o f" '(make-frame :wk "Open buffer in new frame")
    "o p" '(open-python-right-side :wk "Open Python REPL")
    "o F" '(select-frame-by-name :wk "Select frame by name"))

  ;; projectile-command-map already has a ton of bindings 
  ;; set for us, so no need to specify each individually.
  (dt/leader-keys
    "p" '(projectile-command-map :wk "Projectile")
    "P a" '(projectile-add-known-project :wk "Add root to known projects"))
  

(dt/leader-keys
  "r" '(:ignore t :wk "Org-roam")
  "r c" '(completion-at-point :wk "Completion at point")
  "r f" '(org-roam-node-find :wk "Find node")
  "r g" '(org-roam-graph :wk "Show graph")
  "r t" '(org-roam-dailies-goto-today :wk "Show today note")
  "r i" '(org-roam-node-insert :wk "Insert node")
  "r n" '(org-roam-capture :wk "Capture to node")
  "r d" '(:prefix "d" :wk "Dailies")
  "r d c" '(:prefix "c" :wk "Capture")
  "r d c c" '(org-roam-dailies-capture-today :wk "Capture Today")
  "r d c y" '(org-roam-dailies-capture-yesterday :wk "Capture Yesterday")
  "r d c t" '(org-roam-dailies-capture-tomorrow :wk "Capture Tomorrow")
  "r d c d" '(org-roam-dailies-capture-date :wk "Capture Specific Date")
  "r d g" '(:prefix "g" :wk "Go to")
  "r d g g" '(org-roam-dailies-goto-today :wk "Go to Today")
  "r d g y" '(org-roam-dailies-goto-yesterday :wk "Go to Yesterday")
  "r d g t" '(org-roam-dailies-goto-tomorrow :wk "Go to Tomorrow")
  "r d g d" '(org-roam-dailies-goto-date :wk "Go to Specific Date")
  "r d g n" '(org-roam-dailies-goto-next-note :wk "Go to Next Date")
  "r d g d" '(org-roam-dailies-goto-previous-note :wk "Go to Previous Date")
  "r s" '(org-id-get-create :wk "Create Small node inside buffer")
  "r a" '(org-roam-alias-add :wk "Create alias for a roam")
  "r r" '(org-roam-buffer-toggle :wk "Toggle roam buffer"))


  (dt/leader-keys
    "s" '(:ignore t :wk "Search")
    "s d" '(dictionary-search :wk "Search dictionary")
    "s m" '(man :wk "Man pages")
    "s o" '(pdf-occur :wk "Pdf search lines matching STRING")
    "s t" '(tldr :wk "Lookup TLDR docs for a command")
    "s w" '(woman :wk "Similar to man but doesn't require man"))

  (dt/leader-keys
    "t" '(:ignore t :wk "Toggle")
    "t c" '(company-mode :wk "Toggle Company Mode")
    "t e" '(eshell-toggle :wk "Toggle eshell")
    "t f" '(flycheck-mode :wk "Toggle flycheck")
    "t l" '(display-line-numbers-mode :wk "Toggle line numbers")
    "t n" '(treemacs :wk "Toggle Treemacs")
    ;;"t n" '(neotree-toggle :wk "Toggle neotree file viewer")
    "t o" '(org-mode :wk "Toggle org mode")
    "t r" '(rainbow-mode :wk "Toggle rainbow mode")
    "t t" '(visual-line-mode :wk "Toggle truncated lines")
    "t v" '(vterm-toggle :wk "Toggle vterm"))

  (dt/leader-keys
    "w" '(:ignore t :wk "Windows/Words")
    ;; Window splits
    "w c" '(evil-window-delete :wk "Close window")
    "w n" '(evil-window-new :wk "New window")
    "w s" '(evil-window-split :wk "Horizontal split window")
    "w v" '(evil-window-vsplit :wk "Vertical split window")
    ;; Window motions
    "w h" '(evil-window-left :wk "Window left")
    "w j" '(evil-window-down :wk "Window down")
    "w k" '(evil-window-up :wk "Window up")
    "w l" '(evil-window-right :wk "Window right")
    "w w" '(evil-window-next :wk "Goto next window")
    ;; Move Windows
    "w H" '(buf-move-left :wk "Buffer move left")
    "w J" '(buf-move-down :wk "Buffer move down")
    "w K" '(buf-move-up :wk "Buffer move up")
    "w L" '(buf-move-right :wk "Buffer move right")
    ;; Words
    "w d" '(downcase-word :wk "Downcase word")
    "w u" '(upcase-word :wk "Upcase word")
    "w =" '(count-words :wk "Count words/lines for buffer"))
)

(global-set-key (kbd "C-=") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)
(global-set-key (kbd "<C-wheel-up>") 'text-scale-increase)
(global-set-key (kbd "<C-wheel-down>") 'text-scale-decrease)

(use-package git-timemachine
  :after git-timemachine
  :hook (evil-normalize-keymaps . git-timemachine-hook)
  :config
    (evil-define-key 'normal git-timemachine-mode-map (kbd "C-j") 'git-timemachine-show-previous-revision)
    (evil-define-key 'normal git-timemachine-mode-map (kbd "C-k") 'git-timemachine-show-next-revision)
)

(use-package transient)

(use-package magit
:after transient)

(setq magit-show-long-lines-warning nil)

(use-package hl-todo
  :hook ((org-mode . hl-todo-mode)
         (prog-mode . hl-todo-mode))
  :config
  (setq hl-todo-highlight-punctuation ":"
        hl-todo-keyword-faces
        `(("TODO"       warning bold)
          ("FIXME"      error bold)
          ("HACK"       font-lock-constant-face bold)
          ("REVIEW"     font-lock-keyword-face bold)
          ("NOTE"       success bold)
          ("DEPRECATED" font-lock-doc-face bold))))

(use-package ivy
  :bind
  ;; Ivy bindings for resume and buffer switching
  (("C-c C-r" . ivy-resume)
   ("C-x B" . ivy-switch-buffer-other-window))
  :diminish
  :config
  (setq ivy-use-virtual-buffers t)  ;; Enable virtual buffers (recent files, etc.)
  (setq ivy-count-format "(%d/%d) ")  ;; Show counts in Ivy prompts
  (setq enable-recursive-minibuffers t)  ;; Allow recursive minibuffers (e.g., M-x inside M-x)
  (ivy-mode))  ;; Enable Ivy globally

(use-package counsel
  :after ivy
  :diminish
  :config
  (counsel-mode)  ;; Enable Counsel features
  (setq ivy-initial-inputs-alist nil))  ;; Removes starting ^ regex in M-x

(use-package all-the-icons-ivy-rich
  :init
  (all-the-icons-ivy-rich-mode 1))  ;; Enable icons in Ivy for richer buffer display

(use-package ivy-rich
  :after ivy
  :init
  (ivy-rich-mode 1)  ;; Enable Ivy-rich for improved display in Ivy prompts
  :custom
  (ivy-virtual-abbreviate 'full)  ;; Show full path in Ivy buffers
  (ivy-rich-switch-buffer-align-virtual-buffer t)  ;; Align virtual buffers (e.g., project-root buffers)
  (ivy-rich-path-style 'abbrev)  ;; Abbreviate file paths for better display
  :config
  ;; Set default transformers for ivy commands
  (setq ivy-rich-display-transformers-list
        '((ivy-switch-buffer
           :columns
           ((ivy-rich-switch-buffer-icon (:width 2))
            (ivy-rich-candidate (:width 30))
            (ivy-rich-switch-buffer-size (:width 7))
            (ivy-rich-switch-buffer-major-mode (:width 12 :face warning))
            (ivy-rich-switch-buffer-project (:width 15 :face success))
            (ivy-rich-switch-buffer-path (:width (lambda (x) (ivy-rich-switch-buffer-shorten-path x (ivy-rich-minibuffer-width 0.3)))))))))
)

;; (use-package posframe
;;   :ensure t)

;; (use-package ivy-posframe
;;   :ensure t
;;   :after ivy
;;   :config
;;   (setq ivy-posframe-parameters '((left . 0) (top . 0)))  ;; Center position
;;   (setq ivy-posframe-width 80)  ;; Adjust the width as needed
;;   (setq ivy-posframe-height 20)  ;; Adjust the height as needed
;;   (setq ivy-posframe-min-width 20)
  
;;   ;; Enable ivy-posframe
;;   (ivy-posframe-mode 1))

;; (setq ivy-display-function 'ivy-posframe-display)

(use-package lsp-mode
  :ensure t
  :defer t
  :commands (lsp lsp-deffered)
  :init
  (setq lsp-keymap-prefix "C-c L")
  :custom 
  (lsp-eldoc-render-all t)
  (lsp-idle-delay 0.6)
  (lsp-inlay-hint-enable nil)
  (setq lsp-auto-guess-root nil) 
  :config
  (add-hook 'lsp-mode-hook 'lsp-ui-mode
          'lsp-mode-hook 'lsp-enable-which-key-integration)
  (setq lsp-enable-which-key-integration t)
  (setq lsp-headerline-breadcrumb-enable t)
  (setq lsp-headerline-breadcrumb-segments '(path-up-to-project file symbols))
  (setq lsp-modeline-code-actions-enable t))

(with-eval-after-load 'lsp-mode
  ;; :global/:workspace/:file
  (setq lsp-modeline-diagnostics-scope :workspace))

(use-package lsp-ui
:ensure t
:commands lsp-ui-mode
:hook (lsp-mode . lsp-ui-mode)
:custom
(lsp-ui-peek-always-show nil)
(lsp-ui-sideline-show-hover nil)
;; (lsp-ui-doc-enable nil)
(lsp-ui-doc-position 'bottom)
)

(use-package lsp-ivy :commands lsp-ivy-workspace-symbol)

(use-package dap-mode
  :after lsp-mode
  :ensure t
  :defer t)

(use-package web-mode
  :ensure t
  :defer t
  :config
  (setq
   web-mode-markup-indent-offset 2
   web-mode-css-indent-offset 2
   web-mode-code-indent-offset 2
   web-mode-style-padding 2
   web-mode-script-padding 2
   web-mode-enable-auto-closing t
   web-mode-enable-auto-opening t
   web-mode-enable-auto-pairing t
   web-mode-enable-auto-indentation t)
  :mode
  (".html$" "*.php$" "*.tsx"))

(use-package emmet-mode
  :ensure t
  :defer t)

(use-package python-mode
  :hook (python-mode . lsp-deferred))

(use-package conda
  :init
  (setq conda-anaconda-home (expand-file-name "~/miniconda"))
  (setq conda-env-home-directory (expand-file-name "~/miniconda"))
  (setq python-shell-interpreter (expand-file-name "bin/python" conda-anaconda-home))
  (conda-env-initialize-interactive-shells)
  (conda-env-initialize-eshell)
  (conda-env-autoactivate-mode nil) ;; Disable global auto-activation
  (conda-mode-line-setup) ;; Update modeline when Conda env changes
  :hook 
  (python-mode . conda-env-autoactivate-mode)
  )

(use-package lsp-pyright
  :ensure t
  :defer t
  :hook (python-mode . (lambda ()
                         (setq indent-tabs-mode t) 
                         (setq tab-width 4)
                         (setq python-indent-offset 4)
                         (electric-indent-mode t)
                         (setq python-indent-guess-indent-offset-verbose nil)
                         (company-mode 1)
                         (require 'lsp-pyright)
                         (lsp))))

(defun open-python-right-side ()
  "Toggle a Python REPL in a vertical split on the right side."
  (interactive)
  (let ((python-buffer (get-buffer "*Python*"))
        (python-window (get-buffer-window "*Python*")))
    (if python-buffer
        (if python-window
            (progn
              (delete-window python-window)  ;; Close the Python window if open
              (other-window 1))              ;; Switch back to the original window
          (progn
            (split-window-right)            ;; Split window to the right
            (other-window 1)                ;; Switch to the new window
            (run-python)                    ;; Start Python REPL in the current window
            (when (get-buffer "*Python*")    ;; Switch to the Python buffer explicitly
              (switch-to-buffer "*Python*"))
            (other-window 1)))              ;; Switch back to the original window
      (progn
        (split-window-right)              ;; Split window to the right
        (other-window 1)                  ;; Switch to the new window
        (run-python)                      ;; Start Python REPL in the current window
        (when (get-buffer "*Python*")      ;; Switch to the Python buffer explicitly
          (switch-to-buffer "*Python*"))
        (other-window 1)))))              ;; Switch back to the original window


(use-package capf-autosuggest
  :ensure t
  :hook ((eshell-mode . capf-autosuggest-mode))
  :custom
  (capf-autosuggest-dwim-next-line nil))


;; (use-package pyvenv
;;   :ensure t
;;   :defer t)  

;; (defun pyvenv-autoload ()
;;   (require 'pyvenv)
;;   (require 'projectile)
;;   (interactive)
;;   "auto activate venv directory if exists"
;;   (f-traverse-upwards (lambda (path)
;; 			  (let ((venv-path (f-expand "env" path)))
;; 			    (when (f-exists? venv-path)
;; 			      (pyvenv-activate venv-path))))))
;; (add-hook 'python-mode 'pyvenv-autoload)

;; Enable rich annotations using the Marginalia package
(use-package marginalia
  :ensure t
  ;; Bind `marginalia-cycle' locally in the minibuffer.  To make the binding
  ;; available in the *Completions* buffer, add it to the
  ;; `completion-list-mode-map'.
  :bind (:map minibuffer-local-map
         ("M-A" . marginalia-cycle))
  :custom 
  (marginalia-annotators '(marginalia-annotators-heavy marginalia-annotators-light nil))
  ;; The :init section is always executed.
  :init

  ;; Marginalia must be actived in the :init section of use-package such that
  ;; the mode gets enabled right away. Note that this forces loading the
  ;; package.
  (marginalia-mode))

(global-set-key [escape] 'keyboard-escape-quit)

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
  :config
  (setq doom-modeline-height 35      ;; sets modeline height
        doom-modeline-bar-width 5    ;; sets right bar width
        doom-modeline-persp-name t   ;; adds perspective name to modeline
        doom-modeline-persp-icon t)) ;; adds folder icon next to persp name

;; Using garbage magic hack.
 (use-package gcmh
   :config
   (gcmh-mode 1))
;; Setting garbage collection threshold
(setq gc-cons-threshold 402653184
      gc-cons-percentage 0.6)

;; Profile emacs startup
(add-hook 'emacs-startup-hook
          (lambda ()
            (message "*** Emacs loaded in %s with %d garbage collections."
                     (format "%.2f seconds"
                             (float-time
                              (time-subtract after-init-time before-init-time)))
                     gcs-done)))

;; Silence compiler warnings as they can be pretty disruptive
(if (boundp 'comp-deferred-compilation)
    (setq comp-deferred-compilation nil)
    (setq native-comp-deferred-compilation nil))
;; In noninteractive sessions, prioritize non-byte-compiled source files to
;; prevent the use of stale byte-code. Otherwise, it saves us a little IO time
;; to skip the mtime checks on every *.elc file.
(setq load-prefer-newer noninteractive)

(setq org-agenda-files '("/mnt/Karna/Git/Project-K/Org/Tasks.org"))

(setq org-agenda-start-with-log-mode t
      org-log-done 'time
      org-log-into-drawer t)

(setq
   ;; org-fancy-priorities-list '("[A]" "[B]" "[C]")
   ;; org-fancy-priorities-list '("❗" "[B]" "[C]")
   org-fancy-priorities-list '("🟥" "🟧" "🟨")
   org-priority-faces
   '((?A :foreground "#ff6c6b" :weight bold)
     (?B :foreground "#98be65" :weight bold)
     (?C :foreground "#c678dd" :weight bold))
   org-agenda-block-separator 8411)

(setq org-agenda-custom-commands
      '(("v" "A better agenda view"
         ((tags "PRIORITY=\"A\""
                ((org-agenda-skip-function '(org-agenda-skip-entry-if 'todo 'done))
                 (org-agenda-overriding-header "High-priority unfinished tasks:")))
          (tags "PRIORITY=\"B\""
                ((org-agenda-skip-function '(org-agenda-skip-entry-if 'todo 'done))
                 (org-agenda-overriding-header "Medium-priority unfinished tasks:")))
          (tags "PRIORITY=\"C\""
                ((org-agenda-skip-function '(org-agenda-skip-entry-if 'todo 'done))
                 (org-agenda-overriding-header "Low-priority unfinished tasks:")))
          (tags "customtag"
                ((org-agenda-skip-function '(org-agenda-skip-entry-if 'todo 'done))
                 (org-agenda-overriding-header "Tasks marked with customtag:")))

          (agenda "")
          (alltodo "")))))

(use-package org-auto-tangle
  :defer t
  :hook (org-mode . org-auto-tangle-mode)
  :config
  (setq org-auto-tangle-default t))

(defun dt/insert-auto-tangle-tag ()
  "Insert auto-tangle tag in a literate config."
  (interactive)
  (org-end-of-line)
  (newline)
  (insert "#+auto_tangle: t")
  (evil-force-normal-state))

(add-hook 'org-mode-hook 'org-indent-mode)
(use-package org-bullets)
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))

(defun efs/org-mode-visual-fill ()
  (setq visual-fill-column-width 140
        visual-fill-column-center-text t)
  (visual-fill-column-mode 1))

(use-package visual-fill-column
  :hook (org-mode . efs/org-mode-visual-fill))

(eval-after-load 'org-indent '(diminish 'org-indent-mode))

(setq org-directory "/mnt/Karna/Git/Project-K/Org/"
        org-default-notes-file (expand-file-name "notes.org" org-directory)
        org-ellipsis " ▼ "
        org-superstar-headline-bullets-list '("◉" "●" "○" "◆" "●" "○" "◆")
        org-superstar-itembullet-alist '((?+ . ?➤) (?- . ?✦)) ; changes +/- symbols in item lists
        org-log-done 'time
        org-hide-emphasis-markers t
        ;; ex. of org-link-abbrev-alist in action
        ;; [[arch-wiki:Name_of_Page][Description]]
        org-link-abbrev-alist    ; This overwrites the default Doom org-link-abbrev-list
          '(("google" . "http://www.google.com/search?q=")
            ("arch-wiki" . "https://wiki.archlinux.org/index.php/")
            ("ddg" . "https://duckduckgo.com/?q=")
            ("wiki" . "https://en.wikipedia.org/wiki/"))
        org-table-convert-region-max-lines 20000
        org-todo-keywords
    '((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d!)")
      (sequence "BACKLOG(b)" "PLAN(p)" "READY(r)" "ACTIVE(a)" "REVIEW(v)" "WAIT(w@/!)" "HOLD(h)" "|" "COMPLETED(c)" "CANC(k@)")))

  (setq org-refile-targets
    '(("Archive.org" :maxlevel . 1)
      ("Tasks.org" :maxlevel . 1)))

;; Save Org buffers after refiling!
  (advice-add 'org-refile :after 'org-save-all-org-buffers)

  (setq org-tag-alist
    '((:startgroup)
       ; Put mutually exclusive tags here
       (:endgroup)
       ("@errand" . ?E)
       ("@home" . ?H)
       ("@work" . ?W)
       ("agenda" . ?a)
       ("planning" . ?p)
       ("publish" . ?P)
       ("batch" . ?b)
       ("note" . ?n)
       ("idea" . ?i)))

  ;; Configure custom agenda views
  (setq org-agenda-custom-commands
   '(("d" "Dashboard"
     ((agenda "" ((org-deadline-warning-days 7)))
      (todo "NEXT"
        ((org-agenda-overriding-header "Next Tasks")))
      (tags-todo "agenda/ACTIVE" ((org-agenda-overriding-header "Active Projects")))))

    ("n" "Next Tasks"
     ((todo "NEXT"
        ((org-agenda-overriding-header "Next Tasks")))))

    ("W" "Work Tasks" tags-todo "+work-email")

    ;; Low-effort next actions
    ("e" tags-todo "+TODO=\"NEXT\"+Effort<15&+Effort>0"
     ((org-agenda-overriding-header "Low Effort Tasks")
      (org-agenda-max-todos 20)
      (org-agenda-files org-agenda-files)))

    ("w" "Workflow Status"
     ((todo "WAIT"
            ((org-agenda-overriding-header "Waiting on External")
             (org-agenda-files org-agenda-files)))
      (todo "REVIEW"
            ((org-agenda-overriding-header "In Review")
             (org-agenda-files org-agenda-files)))
      (todo "PLAN"
            ((org-agenda-overriding-header "In Planning")
             (org-agenda-todo-list-sublevels nil)
             (org-agenda-files org-agenda-files)))
      (todo "BACKLOG"
            ((org-agenda-overriding-header "Project Backlog")
             (org-agenda-todo-list-sublevels nil)
             (org-agenda-files org-agenda-files)))
      (todo "READY"
            ((org-agenda-overriding-header "Ready for Work")
             (org-agenda-files org-agenda-files)))
      (todo "ACTIVE"
            ((org-agenda-overriding-header "Active Projects")
             (org-agenda-files org-agenda-files)))
      (todo "COMPLETED"
            ((org-agenda-overriding-header "Completed Projects")
             (org-agenda-files org-agenda-files)))
      (todo "CANC"
            ((org-agenda-overriding-header "Cancelled Projects")
             (org-agenda-files org-agenda-files)))))))

(defun dt/org-colors-doom-one ()
  "Enable Doom One colors for Org headers."
  (interactive)
  (dolist
      (face
       '((org-level-1 1.7 "#51afef" ultra-bold)
         (org-level-2 1.6 "#c678dd" extra-bold)
         (org-level-3 1.5 "#98be65" bold)
         (org-level-4 1.4 "#da8548" semi-bold)
         (org-level-5 1.3 "#5699af" normal)
         (org-level-6 1.2 "#a9a1e1" normal)
         (org-level-7 1.1 "#46d9ff" normal)
         (org-level-8 1.0 "#ff6c6b" normal)))
    (set-face-attribute (nth 0 face) nil :font "Ubuntu" :weight (nth 3 face) :height (nth 1 face) :foreground (nth 2 face)))
  (set-face-attribute 'org-table nil :font "JetBrainsMono" :weight 'normal :height 1.0 :foreground "#bfafdf"))


;; Load our desired dt/org-colors-* theme on startup
(dt/org-colors-doom-one)

  (custom-set-faces
   '(org-level-1 ((t (:inherit outline-1 :height 1.7))))
   '(org-level-2 ((t (:inherit outline-2 :height 1.6))))
   '(org-level-3 ((t (:inherit outline-3 :height 1.5))))
   '(org-level-4 ((t (:inherit outline-4 :height 1.4))))
   '(org-level-5 ((t (:inherit outline-5 :height 1.3))))
   '(org-level-6 ((t (:inherit outline-5 :height 1.2))))
   '(org-level-7 ((t (:inherit outline-5 :height 1.1)))))

(use-package org-roam
  :ensure t
  :init
  (setq org-roam-v2-ack t)
  :custom
  (org-roam-db-autosync-mode)
  (org-roam-completion-everywhere t)
;; (org-roam-dailies-capture-templates
;;     '(("d" "default" entry "* %<%I:%M %p>: %?"
;;        :if-new (file+head "%<%Y-%m-%d>.org" "#+title: %<%Y-%m-%d>\n"))))
  (org-roam-capture-templates
   '(("d" "default" plain "%?"
 :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n#+date: %U\n")
 :unnarrowed t)
   ("l" "programming language" plain
   "* Characteristics\n\n- Family: %?\n- Inspired by: \n\n* Reference:\n\n"
   :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n")
   :unnarrowed t)
   ("b" "book notes" plain
   (file "/mnt/Karna/Git/Project-K/Org/Templates/BooknoteTemplate.org")
   :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n")
   :unnarrowed t)
   ("p" "project" plain "* Goals\n\n%?\n\n* Tasks\n\n** TODO Add initial tasks\n\n* Dates\n\n"
   :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n#+filetags: Project")
   :unnarrowed t)))
  :config
  (org-roam-setup))

(with-eval-after-load 'org
  (setq org-roam-directory "/mnt/Karna/Git/Project-K/Org/Roam/"
        org-roam-graph-viewer "/usr/bin/zen-browser"))

(setq org-roam-dailies-directory "/mnt/Karna/Git/Project-K/Org/Journal/")

(setq org-journal-dir "/mnt/Karna/Git/Project-K/Org/Journal/"
      org-journal-date-prefix "* "
      org-journal-time-prefix "** "
      org-journal-date-format "%B %d, %Y (%A) "
      org-journal-file-format "%Y-%m-%d.org")

(setq org-roam-db-location "/mnt/Karna/Git/Project-K/Org/Roam/org-roam.db")

(require 'org-tempo)

(setq org-src-preserve-indentation t)
(use-package org-modern
  :ensure t)

(use-package toc-org
    :commands toc-org-enable
    :init (add-hook 'org-mode-hook 'toc-org-enable))

(use-package pdf-tools
  :defer t
  :commands (pdf-loader-install)
  :mode "\\.pdf\\'"
  :bind (:map pdf-view-mode-map
              ("j" . pdf-view-next-line-or-next-page)
              ("k" . pdf-view-previous-line-or-previous-page)
              ("C-=" . pdf-view-enlarge)
              ("C--" . pdf-view-shrink))
  :init (pdf-loader-install)
  :config (add-to-list 'revert-without-query ".pdf"))

(add-hook 'pdf-view-mode-hook #'(lambda () (interactive) (display-line-numbers-mode -1)
                                                         (blink-cursor-mode -1)
                                                         (doom-modeline-mode -1)))

(use-package perspective
  :ensure t
  :custom
  ;; NOTE! I have also set 'SCP =' to open the perspective menu.
  ;; I'm only setting the additional binding because setting it
  ;; helps suppress an annoying warning message.
  (persp-mode-prefix-key (kbd "C-c M-p"))
  :config
  (persp-mode 1)
  ;; Sets a file to write to when we save states

  (setq persp-state-default-file "~/.cache/emacs/sessions"))

;; This will group buffers by persp-name in ibuffer.
(add-hook 'ibuffer-hook
          (lambda ()
            (persp-ibuffer-set-filter-groups)
            (unless (eq ibuffer-sorting-mode 'alphabetic)
              (ibuffer-do-sort-by-alphabetic))))

;; Automatically save perspective states to file when Emacs exits.
(add-hook 'kill-emacs-hook #'persp-state-save)

(use-package projectile
  :config
  (projectile-mode 1)
  :custom ((projectile-completion-system 'ivy))
  :init
  ;; NOTE: Set this to the folder where you keep your Git repos!
  (when (file-directory-p "/mnt/Karna")
    (setq projectile-project-search-path '("/mnt/Karna/")))
  (setq projectile-switch-project-action #'projectile-dired))

(use-package counsel-projectile
  :config (counsel-projectile-mode))

(use-package rainbow-delimiters
  :hook ((emacs-lisp-mode . rainbow-delimiters-mode)
         (clojure-mode . rainbow-delimiters-mode)))

(use-package rainbow-mode
  :diminish
  :hook org-mode prog-mode)

(require 'recentf)

(setq recentf-exclude
      '("~/.cache/emacs/recentf"
        "/mnt/Karna/Git/Project-K/Org/Tasks.org"
        "~/.cache/emacs/treemacs-persist"))

(setq recentf-save-file (dir-concat user-cache-directory "recentf"))
(setq recentf-max-saved-items 200)
(setq recentf-auto-cleanup 300)

;; Dynamic Mode
;; (setq recentf-exclude
;;       (lambda (file)
;;         (or (string-match-p (regexp-quote (expand-file-name "~/.config/emacs/recentf")) file)
;;             (string-match-p (regexp-quote (expand-file-name "/mnt/Karna/Git/Project-K/Org/agenda.org")) file)
;;             (string-match-p (regexp-quote (expand-file-name "~/.config/emacs/.cache/treemacs-persist")) file))))


(recentf-mode 1)  ;; Ensure recentf mode is enabled

(setq long-line-threshold 100000) ;; Set to a higher limit

;; load dashboard instead of scratchpad at startup *INSTALL DASHBOARD*
(setq initial-buffer-choice (lambda () (get-buffer "*dashboard*")))
(delete-selection-mode 1)    ;; You can select text and delete it by typing.
(electric-indent-mode -1)    ;; Turn off the weird indenting that Emacs does by default.
(electric-pair-mode 1)       ;; Turns on automatic parens pairing
(setq electric-pair-pairs '(
			     (?\{ . ?\})
			     (?\( . ?\))
			     (?\[ . ?\])
			     (?\" . ?\")
			     ))
(setq org-edit-src-content-indentation 0)
;; The following prevents <> from auto-pairing when electric-pair-mode is on.
;; Otherwise, org-tempo is broken when you try to <s TAB...
(add-hook 'org-mode-hook (lambda ()
           (setq-local electric-pair-inhibit-predicate
                   `(lambda (c)
                  (if (char-equal c ?<) t (,electric-pair-inhibit-predicate c))))))
(global-auto-revert-mode t)  ;; Automatically show changes if the file has changed
;; Revert Dired and other buffers
(setq global-auto-revert-non-file-buffers t)
(global-display-line-numbers-mode 1) ;; Display line numbers
(global-visual-line-mode t)  ;; Enable truncated lines
(menu-bar-mode -1)           ;; Disable the menu bar 
(scroll-bar-mode -1)         ;; Disable the scroll bar
(setq inhibit-startup-screen t) ; Disable startup default startup screen
(fringe-mode -1) 
(defalias 'yes-or-no-p 'y-or-n-p) 
(tool-bar-mode -1)           ;; Disable the tool bar
(setq org-edit-src-content-indentation 0) ;; Set src block automatic indent to 0 instead of 2.
(setq use-file-dialog nil)   ;; No file dialog
(setq use-dialog-box nil)    ;; No dialog box
(setq pop-up-windows nil)    ;; No popup windows
(setq auto-save-interval 2400)
(setq auto-save-timeout 300)
(setq auto-save-list-file-prefix
      (dir-concat user-cache-directory "auto-save-list/.saves-"))
(setq pixel-scroll-precision-mode 1)
(setq locale-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(prefer-coding-system 'utf-8)
(setq ring-bell-function 'ignore)
(setq display-time-default-load-average nil)

;; Save minibuffer commands 
(setq history-length 1000)
(setq history-delete-duplicates t)
(setq savehist-save-minibuffer-history t)
(savehist-mode 1)
;; So I can always jump back to wear I left of yesterday
(add-to-list 'savehist-additional-variables 'global-mark-ring)
(setq savehist-file (dir-concat user-cache-directory "savehist"))

;; For lazy typists
(setq use-short-answers t)
;; Move the mouse away if the cursor gets close
;; (mouse-avoidance-mode 'animate)

;; highlight the current line, as in Matlab
;; (global-hl-line-mode)

;; FULLSCREEN
;;(global-set-key [f11] 'toggle-frame-fullscreen)


;; Byte-compile elisp files immediately after saving them if .elc exists:
(defun auto-byte-recompile ()
  "If the current buffer is in `emacs-lisp-mode' and there
  already exists an `.elc' file corresponding to the current
  buffer file, then recompile the file."
  (interactive)
  (when (and (eq major-mode 'emacs-lisp-mode)
             (not ;; (string= user-init-file (buffer-file-name))
              (string-match-p "init\\.el$" (buffer-file-name)))
             (file-exists-p (byte-compile-dest-file buffer-file-name)))
    (byte-recompile-file buffer-file-name)))
(add-hook 'after-save-hook 'auto-byte-recompile)
(add-hook 'kill-emacs-hook (lambda () (byte-recompile-file user-init-file)))
(add-hook 'after-save-hook 'executable-make-buffer-file-executable-if-script-p)

(setq tramp-persistency-file-name
        (dir-concat user-cache-directory "tramp"))

(setq lsp-session-file (dir-concat user-cache-directory "lsp-session"))
(setq dap-breakpoints-file (dir-concat user-cache-directory "dap-breakpoints"))
(setq projectile-known-projects-file "~/.cache/emacs/projectile-bookmarks.eld")

;; The eshell prompt
(setopt eshell-prompt-function 'fancy-shell)
(setopt eshell-prompt-regexp "^[^#$\n]* [$#] ")
(setopt eshell-highlight-prompt nil)

;; Disabling company mode in eshell, because it's annoying.
(setq company-global-modes '(not eshell-mode))

;; Adding a keybinding for 'pcomplete-list' on F9 key.
(add-hook 'eshell-mode-hook
          (lambda ()
            (define-key eshell-mode-map (kbd "<f9>") #'pcomplete-list)))

;; A function for easily creating multiple buffers of 'eshell'.
;; NOTE: `C-u M-x eshell` would also create new 'eshell' buffers.
(defun eshell-new (name)
  "Create new eshell buffer named NAME."
  (interactive "sName: ")
  (setq name (concat "$" name))
  (eshell)
  (rename-buffer name))

(use-package eshell-toggle
  :custom
  (eshell-toggle-size-fraction 3)
  (eshell-toggle-use-projectile-root t)
  (eshell-toggle-run-command nil)
  (eshell-toggle-init-function #'eshell-toggle-init-ansi-term))

  (use-package eshell-syntax-highlighting
    :after esh-mode
    :config
    (eshell-syntax-highlighting-global-mode +1))

  ;; eshell-syntax-highlighting -- adds fish/zsh-like syntax highlighting.
  ;; eshell-rc-script -- your profile for eshell; like a bashrc for eshell.
  ;; eshell-aliases-file -- sets an aliases file for the eshell.

  (setq eshell-rc-script (concat user-emacs-directory "eshell/profile")
        eshell-aliases-file (concat user-emacs-directory "eshell/aliases")
        eshell-history-size 5000
        eshell-buffer-maximum-lines 5000
        eshell-hist-ignoredups t
        eshell-scroll-to-bottom-on-input t
        eshell-destroy-buffer-when-process-dies t
        eshell-visual-commands'("bash" "zsh" "htop" "ssh" "top" "fish"))

(setq eshell-directory-name "~/.cache/emacs/eshell")
(setq eshell-last-dir-ring-file-name "~/.cache/emacs/eshell/eshell-last-dir")
(setq eshell-history-file-name "~/.cache/emacs/eshell/eshell-history")

(use-package vterm
:config
(setq shell-file-name "/bin/sh"
      vterm-max-scrollback 5000))

(use-package vterm-toggle
  :after vterm
  :config
  ;; When running programs in Vterm and in 'normal' mode, make sure that ESC
  ;; kills the program as it would in most standard terminal programs.
  (evil-define-key 'normal vterm-mode-map (kbd "<escape>") 'vterm--self-insert)
  (setq vterm-toggle-fullscreen-p nil)
  (setq vterm-toggle-scope 'project)
  (add-to-list 'display-buffer-alist
               '((lambda (buffer-or-name _)
                     (let ((buffer (get-buffer buffer-or-name)))
                       (with-current-buffer buffer
                         (or (equal major-mode 'vterm-mode)
                             (string-prefix-p vterm-buffer-name (buffer-name buffer))))))
                  (display-buffer-reuse-window display-buffer-at-bottom)
                  ;;(display-buffer-reuse-window display-buffer-in-direction)
                  ;;display-buffer-in-direction/direction/dedicated is added in emacs27
                  ;;(direction . bottom)
                  ;;(dedicated . t) ;dedicated is supported in emacs27
                  (reusable-frames . visible)
                  (window-height . 0.4))))

(use-package sudo-edit)

;; (add-to-list 'custom-theme-load-path "~/.config/emacs/themes/")

;; (use-package doom-themes
;;   :config
;;   (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
;;         doom-themes-enable-italic t) ; if nil, italics is universally disabled
;;   ;; Sets the default theme to load!!! 
;;   (load-theme 'doom-challenger-deep t)
;;   ;; Enable custom neotree theme (all-the-icons must be installed!)
;;   (doom-themes-neotree-config)
;;   ;; Corrects (and improves) org-mode's native fontification.
;;   (doom-themes-org-config))

;; (use-package battery
;;   :ensure nil
;;   :hook (after-init . display-battery-mode))

;; (use-package leuven-theme
;;   :ensure (:host github :repo "fniessen/emacs-leuven-theme")
;;   :custom-face
;;   (doom-modeline-buffer-file ((t (:inherit (doom-modeline font-lock-doc-face) :weight normal :slant normal))))
;;   (doom-modeline-buffer-path ((t (:inherit (doom-modeline font-lock-doc-face) :weight normal :slant normal))))
;;   (which-func ((t (:inherit (doom-modeline font-lock-doc-face) :weight normal :slant normal :foreground "gray29"))))
;;   (doom-modeline-buffer-major-mode ((t (:inherit (doom-modeline font-lock-doc-face) :weight normal :slant normal)))))



;; (use-package tao-theme
;;   :ensure t
;;   :custom
;;   (tao-theme-use-boxes t)
;;   (tao-theme-use-height nil)
;;   (tao-theme-use-sepia nil)
;;   :init
;;   (defvar after-load-theme-hook nil
;;     "Hook run after a color theme is loaded using `load-theme'.")

;;   (defadvice load-theme (after run-after-load-theme-hook activate)
;;     "Run `after-load-theme-hook'."
;;     (run-hooks 'after-load-theme-hook))

;;   (defun update-doom-modeline-battery-faces ()
;;   "Customize battery faces for tao-yin and tao-yang themes."
;;   (cond
;;    ((member 'tao-yin custom-enabled-themes)
;;     ;; Customizations for tao-yin theme
;;     (custom-set-faces
;;      '(doom-modeline-battery-warning ((t (:foreground "black" :background "orange"))))
;;      '(doom-modeline-battery-critical ((t (:foreground "black" :background "red"))))
;;      ))
;;    ((member 'tao-yang custom-enabled-themes)
;;     ;; Customizations for tao-yang theme
;;     (custom-set-faces
;;      '(doom-modeline-battery-warning ((t (:foreground "black" :background "orange"))))
;;      '(doom-modeline-battery-critical ((t (:foreground "black" :background "red"))))
;;      ))))

;;   (add-hook 'after-load-theme-hook 'update-doom-modeline-battery-faces))

(use-package ewal
  :init (setq ewal-use-built-in-always-p nil
              ewal-use-built-in-on-failure-p t
              ;; ewal-built-in-palette "sexy-material")
              ewal-built-in-palette "vscode")
)
(use-package ewal-doom-themes
  :init (progn
          (setq doom-theme-underline-parens t
                my:rice:font (font-spec
                              :family "JetbrainsMono Nerd Font"
                              :weight 'semi-bold
                              :size 12.0))
          (show-paren-mode +1)
          (global-hl-line-mode)
          (set-frame-font my:rice:font nil t)
          (add-to-list  'default-frame-alist
                        `(font . ,(font-xlfd-name my:rice:font))))
  :config (progn
            (load-theme 'ewal-doom-one t)
            (enable-theme 'ewal-doom-one)))
(use-package ewal-evil-cursors
  :after (ewal-doom-themes)
  :config (ewal-evil-cursors-get-colors
           :apply t :spaceline t))
(use-package spaceline
  :after (ewal-evil-cursors winum)
  :init (setq powerline-default-separator nil)
  :config (spaceline-doom-theme))

(set-face-attribute 'default nil
  :font "JetbrainsMono Nerd Font"
  :height 110
  :weight 'medium)
(set-face-attribute 'variable-pitch nil
  :font "JetbrainsMono Nerd Font"
  :height 120
  :weight 'medium)
(set-face-attribute 'fixed-pitch nil
  :font "JetBrainsMono Nerd Font"
  :height 110
  :weight 'medium)
;; Makes commented text and keywords italics.
;; This is working in emacsclient but not emacs.
;; Your font must have an italic face available.
(set-face-attribute 'font-lock-comment-face nil
  :slant 'italic)
(set-face-attribute 'font-lock-keyword-face nil
  :slant 'italic)

;; This sets the default font on all graphical frames created after restarting Emacs.
;; Does the same thing as 'set-face-attribute default' above, but emacsclient fonts
;; are not right unless I also add this method of setting the default font.
;; (add-to-list 'default-frame-alist '(font . "JetbrainsMono Nerd Font-12"))

;; Uncomment the following line if line spacing needs adjusting.
(setq-default line-spacing 0.12)

(use-package tldr)

(add-to-list 'default-frame-alist '(alpha-background . 97)) ; For all new frames henceforth
;; changes certain keywords to symbols, such as lamda!
(setq global-prettify-symbols-mode t)

(setq treesit-language-source-alist
      '((templ "https://github.com/vrischmann/tree-sitter-templ")
        (bash "https://github.com/tree-sitter/tree-sitter-bash")
        (cmake "https://github.com/uyha/tree-sitter-cmake")
        (css "https://github.com/tree-sitter/tree-sitter-css")
        (elisp "https://github.com/Wilfred/tree-sitter-elisp")
        (go "https://github.com/tree-sitter/tree-sitter-go")
        (gomod "https://github.com/camdencheek/tree-sitter-go-mod")
        (html "https://github.com/tree-sitter/tree-sitter-html")
        (javascript "https://github.com/tree-sitter/tree-sitter-javascript" "master" "src")
        (dockerfile "https://github.com/camdencheek/tree-sitter-dockerfile")
        (json "https://github.com/tree-sitter/tree-sitter-json")
        (make "https://github.com/alemuller/tree-sitter-make")
        (markdown "https://github.com/ikatyang/tree-sitter-markdown")
        (python "https://github.com/tree-sitter/tree-sitter-python")
        (toml "https://github.com/tree-sitter/tree-sitter-toml")
        (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")
        (typescript "https://github.com/tree-sitter/tree-sitter-typescript"
                    "master" "typescript/src")
        (yaml "https://github.com/ikatyang/tree-sitter-yaml")
        (haskell "https://github.com/tree-sitter/tree-sitter-haskell")
        (typst "https://github.com/uben0/tree-sitter-typst")
        (java "https://github.com/tree-sitter/tree-sitter-java")
        (ruby "https://github.com/tree-sitter/tree-sitter-ruby")
        (rust "https://github.com/tree-sitter/tree-sitter-rust")))

;; The =undo-fu-session= package saves and restores the undo states of buffers
;; across Emacs sessions.
(use-package undo-fu-session
  :ensure t
  :hook ((prog-mode conf-mode text-mode tex-mode) . undo-fu-session-mode)
  :config
  (setq undo-fu-session-directory
        (dir-concat user-cache-directory "undo-fu-session/")))

(use-package treemacs
  :ensure t
  :defer t
  :init
  (with-eval-after-load 'winum
    (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))
  :config
  (progn
    (setq treemacs-collapse-dirs                   (if treemacs-python-executable 3 0)
          treemacs-deferred-git-apply-delay        0.5
          treemacs-directory-name-transformer      #'identity
          treemacs-display-in-side-window          t
          treemacs-eldoc-display                   'simple
          treemacs-file-event-delay                2000
          treemacs-file-extension-regex            treemacs-last-period-regex-value
          treemacs-file-follow-delay               0.2
          treemacs-file-name-transformer           #'identity
          treemacs-follow-after-init               t
          treemacs-expand-after-init               t
          treemacs-find-workspace-method           'find-for-file-or-pick-first
          treemacs-git-command-pipe                ""
          treemacs-goto-tag-strategy               'refetch-index
          treemacs-header-scroll-indicators        '(nil . "^^^^^^")
          treemacs-hide-dot-git-directory          t
          treemacs-indentation                     2
          treemacs-indentation-string              " "
          treemacs-is-never-other-window           nil
          treemacs-max-git-entries                 5000
          treemacs-missing-project-action          'ask
          treemacs-move-files-by-mouse-dragging    t
          treemacs-move-forward-on-expand          nil
          treemacs-no-png-images                   nil
          treemacs-no-delete-other-windows         t
          treemacs-project-follow-cleanup          nil
          treemacs-persist-file                    (expand-file-name "~/.cache/emacs/treemacs-persist")
          treemacs-position                        'left
          treemacs-read-string-input               'from-child-frame
          treemacs-recenter-distance               0.1
          treemacs-recenter-after-file-follow      nil
          treemacs-recenter-after-tag-follow       nil
          treemacs-recenter-after-project-jump     'always
          treemacs-recenter-after-project-expand   'on-distance
          treemacs-litter-directories              '("/node_modules" "/.venv" "/.cask")
          treemacs-project-follow-into-home        nil
          treemacs-show-cursor                     nil
          treemacs-show-hidden-files               t
          treemacs-silent-filewatch                nil
          treemacs-silent-refresh                  nil
          treemacs-sorting                         'alphabetic-asc
          treemacs-select-when-already-in-treemacs 'move-back
          treemacs-space-between-root-nodes        t
          treemacs-tag-follow-cleanup              t
          treemacs-tag-follow-delay                1.5
          treemacs-text-scale                      nil
          treemacs-user-mode-line-format           nil
          treemacs-user-header-line-format         nil
          treemacs-wide-toggle-width               70
          treemacs-width                           30
          treemacs-width-increment                 1
          treemacs-width-is-initially-locked       t
          treemacs-workspace-switch-cleanup        nil)

    ;; The default width and height of the icons is 22 pixels. If you are
    ;; using a Hi-DPI display, uncomment this to double the icon size.
    ;;(treemacs-resize-icons 44)

    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode 'always)
    (when treemacs-python-executable
      (treemacs-git-commit-diff-mode t))

    (pcase (cons (not (null (executable-find "git")))
                 (not (null treemacs-python-executable)))
      (`(t . t)
       (treemacs-git-mode 'deferred))
      (`(t . _)
       (treemacs-git-mode 'simple)))

    (treemacs-hide-gitignored-files-mode nil))
  ;; :bind
  ;; (:map global-map
  ;;       ("M-0"       . treemacs-select-window)
  ;;       ("C-x t 1"   . treemacs-delete-other-windows)
  ;;       ("C-x t t"   . treemacs)
  ;;       ("C-x t d"   . treemacs-select-directory)
  ;;       ("C-x t B"   . treemacs-bookmark)
  ;;       ("C-x t C-t" . treemacs-find-file)
  ;;       ("C-x t M-t" . treemacs-find-tag))
  )


(use-package treemacs-evil
  :after (treemacs evil)
  :ensure t)

(use-package treemacs-icons-dired
  :after treemacs 
  :hook (dired-mode . treemacs-icons-dired-enable-once)
  :ensure t)

(use-package treemacs-projectile
  :after (treemacs projectile)
  :ensure t)

(use-package treemacs-magit
  :after (treemacs magit)
  :ensure t)


(use-package treemacs-persp ;;treemacs-perspective if you use perspective.el vs. persp-mode
  :after (treemacs persp-mode) ;;or perspective vs. persp-mode
  :ensure t
  :config (treemacs-set-scope-type 'Perspectives))

(with-eval-after-load 'treemacs
  (define-key treemacs-mode-map [mouse-1] #'treemacs-single-click-expand-action))

(use-package lsp-treemacs :commands lsp-treemacs-errors-list)

;;install vertico
(use-package vertico
  :init
  (vertico-mode)
;; Enable vertico using the vertico-flat-mode
  (require 'vertico-directory)
  (add-hook 'rfn-eshadow-update-overlay-hook #'vertico-directory-tidy)

  ;; Different scroll margin
  ;; (setq vertico-scroll-margin 0)

  ;; Show more candidates
  (setq vertico-count 20)

  ;; Grow and shrink the Vertico minibuffer
  (setq vertico-resize t)
  ;; Optionally enable cycling for `vertico-next' and `vertico-previous'.
  (setq vertico-cycle t))

(setq recentf-max-saved-items 50)  ;; Adjust as needed
(setq recentf-auto-cleanup 'never)  ;; Keep the history intact


(use-package consult)

(use-package consult-dir
 :ensure t
 :bind (("C-x C-d" . consult-dir)
 :map vertico-map
 ("C-x C-d" . consult-dir)
 ("C-x C-j" . consult.dir-jump-file)))

;; Optionally use the `orderless' completion style.
(use-package orderless
  :ensure t
  :custom
  ;; (orderless-style-dispatchers '(orderless-affix-dispatch))
  ;; (orderless-component-separator #'orderless-escapable-split-on-space)
  (completion-styles '(orderless flex))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion)))))

(use-package wakatime-mode
  :ensure t
  :config
  (global-wakatime-mode))

(use-package which-key
  :init
    (which-key-mode 1)
  :diminish
  :config
  (setq which-key-side-window-location 'bottom
	  which-key-sort-order #'which-key-key-order-alpha
	  which-key-allow-imprecise-window-fit nil
	  which-key-sort-uppercase-first nil
	  which-key-add-column-padding 1
	  which-key-max-display-columns nil
	  which-key-min-display-lines 6
	  which-key-side-window-slot -10
	  which-key-side-window-max-height 0.25
	  which-key-idle-delay 0.8
	  which-key-max-description-length 25
	  which-key-allow-imprecise-window-fit nil
	  which-key-separator " → " ))

(use-package yasnippet
:config
(yas-reload-all)
(add-hook 'prog-mode-hook 'yas-minor-mode)
(add-hook 'text-mode-hook 'yas-minor-mode))
