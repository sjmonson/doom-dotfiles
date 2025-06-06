;;; ~/.doom.d/config.el -*- lexical-binding: t; -*-

;; Removes evil-snipe repeat keys such as ;
(setq evil-snipe-override-evil-repeat-keys nil)
;; Stops evil-snipe from overiding keybinds
;(after! evil-snipe (evil-snipe-override-mode -1))

;; Place your private configuration here
;;(add-hook! 'sql-interactive-mode-hook
;;           (lambda ()
;;             (toggle-truncate-lines t)))

(after! lsp
  (setq lsp-ui-sideline-show-code-actions nil)
)

;; Cache passwords forever
(setq password-cache-expiry nil)

; Adapted from https://www.reddit.com/r/emacs/comments/o49v2w/automatically_switch_emacs_theme_when_changing/?rdt=59586
(defun mf/set-theme-from-dbus-value (value)
  "Set the appropiate theme according to the color-scheme setting value."
  (message "value is %s" value)
    (if (equal value '1)
        (progn (message "Switch to dark theme")
               (load-theme 'doom-one))
      (progn (message "Switch to light theme")
             (load-theme 'doom-one-light))))

(defun mf/color-scheme-changed (path var value)
  "DBus handler to detect when the color-scheme has changed."
  (when (and (string-equal path "org.freedesktop.appearance")
             (string-equal var "color-scheme"))
    (mf/set-theme-from-dbus-value (car value))
    ))
(use-package! dbus
  :config
  ;; Register for future changes
  (dbus-register-signal
     :session "org.freedesktop.portal.Desktop"
     "/org/freedesktop/portal/desktop" "org.freedesktop.portal.Settings"
     "SettingChanged"
     #'mf/color-scheme-changed)

  ;; Request the current color-scheme
  (dbus-call-method-asynchronously
   :session "org.freedesktop.portal.Desktop"
   "/org/freedesktop/portal/desktop" "org.freedesktop.portal.Settings"
   "Read"
   (lambda (value) (mf/set-theme-from-dbus-value (caar value)))
   "org.freedesktop.appearance"
   "color-scheme"
   ))

(after! evil-maps
  (define-key evil-motion-state-map "j" 'evil-next-line)
  (define-key evil-motion-state-map "k" 'evil-previous-line)
  (define-key evil-motion-state-map "l" 'evil-backward-char)
  (define-key evil-motion-state-map ";" 'evil-forward-char))

;;(after! sql
;;  (setq sql-mysql-login-params
;;      '((user :default "km_monsonsamuel")
;;        (database :default "km_monsonsamuel")
;;        (server :default "cs100.seattleu.edu")
;;        (password :default ""))))

(after! org
  (use-package! ox-extra
    :config
    (ox-extras-activate '(latex-header-blocks ignore-headlines))))

(after! org
  ;; Import ox-latex to get org-latex-classes and other funcitonality
  ;; for exporting to LaTeX from org
  (use-package! ox-latex
    :init
    ;; code here will run immediately
    :config
    ;; code here will run after the package is loaded
    ;;(setq org-latex-pdf-process '("xelatex -interaction nonstopmode -output-directory %o %f"))
    ;;(setq org-latex-pdf-process '("PDFLATEX=\"xelatex\" texi2dvi --shell-escape --pdf %f"))
    (setq org-latex-pdf-process '("latexmk -shell-escape -xelatex %f"))
    (setq org-latex-with-hyperref-template nil) ;; stop org adding hypersetup{author..} to latex export
    ;; (setq org-latex-prefer-user-labels t)

    ;; deleted unwanted file extensions after latexMK
    (setq org-latex-logfiles-extensions
          (quote ("lof" "lot" "tex~" "aux" "idx" "log" "out" "toc" "nav" "snm" "vrb" "dvi"
                   "fdb_latexmk" "blg" "brf" "fls" "entoc" "ps" "spl" "bbl" "xmpi" "run.xml"
                   "bcf" "acn" "acr" "alg" "glg" "gls" "ist" "xdv")))

    (unless (boundp 'org-latex-classes)
      (setq org-latex-classes nil))))

;; accept completion from copilot and fallback to company
(use-package! copilot
  :hook (prog-mode . copilot-mode)
  :bind (:map copilot-completion-map
              ("C-e" . 'copilot-accept-completion)
              ("C-e" . 'copilot-accept-completion)
              ("C-TAB" . 'copilot-accept-completion-by-word)
              ("C-<tab>" . 'copilot-accept-completion-by-word)))

(use-package! gptel
  :config
  (setq gptel-backend (gptel-make-gh-copilot "Copilot"))
  (map! :leader
        :prefix-map ("e" . "GPTel")
        :desc "GPTel menu" "SPC" #'gptel-menu
        :desc "GPTel" "b" #'gptel
        :desc "GPTel rewrite" "r" #'gptel-rewrite
        :desc "GPTel send" "s" #'gptel-send
        :desc "GPTel abort" "a" #'gptel-abort
        :desc "GPTel toggle mode" "m" #'gptel-mode
        :desc "Next response" "n" #'gptel-next
        :desc "Previous response" "p" #'gptel-previous))
