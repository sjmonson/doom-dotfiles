;;; ~/.doom.d/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here
(add-hook! 'sql-interactive-mode-hook
           (lambda ()
             (toggle-truncate-lines t)))

(after! tide
  (defun setup-tide-mode ()
    (interactive)
    (tide-setup)
    (flycheck-mode +1)
    (setq flycheck-check-syntax-automatically '(save mode-enabled))
    (eldoc-mode +1)
    (tide-hl-identifier-mode +1)
    ;; company is an optional dependency. You have to
    ;; install it separately via package-install
    ;; `M-x package-install [ret] company`
    (company-mode +1))

  ;; aligns annotation to the right hand side
  (setq company-tooltip-align-annotations t)
)
;; formats the buffer before saving
(add-hook! 'before-save-hook 'tide-format-before-save)

(add-hook! 'typescript-mode-hook #'setup-tide-mode)

;; Stops evil-snipe from overiding keybinds
(after! evil-snipe (evil-snipe-override-mode -1))

(after! evil-maps
  (define-key evil-motion-state-map "j" 'evil-next-line)
  (define-key evil-motion-state-map "k" 'evil-previous-line)
  (define-key evil-motion-state-map "l" 'evil-backward-char)
  (define-key evil-motion-state-map ";" 'evil-forward-char))

(after! sql
  (setq sql-mysql-login-params
      '((user :default "km_monsonsamuel")
        (database :default "km_monsonsamuel")
        (server :default "cs100.seattleu.edu")
        (password :default ""))))

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
    (setq org-latex-pdf-process
          '("pdflatex -interaction nonstopmode -output-directory %o %f"
            "bibtex %b"
            "pdflatex -interaction nonstopmode -output-directory %o %f"
            "pdflatex -interaction nonstopmode -output-directory %o %f"))
    (setq org-latex-with-hyperref-template nil) ;; stop org adding hypersetup{author..} to latex export
    ;; (setq org-latex-prefer-user-labels t)

    ;; deleted unwanted file extensions after latexMK
    (setq org-latex-logfiles-extensions
          (quote ("lof" "lot" "tex~" "aux" "idx" "log" "out" "toc" "nav" "snm" "vrb" "dvi" "fdb_latexmk" "blg" "brf" "fls" "entoc" "ps" "spl" "bbl" "xmpi" "run.xml" "bcf" "acn" "acr" "alg" "glg" "gls" "ist")))

    (unless (boundp 'org-latex-classes)
      (setq org-latex-classes nil))))
