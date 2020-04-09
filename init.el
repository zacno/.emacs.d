(package-initialize)
(add-to-list 'package-archives '("melpa" . "https://melpa.milkbox.net/packages/"))
;;(add-to-list 'package-archives '("gnu" . "https://elpa.gnu.org/packages/"))


(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )


;; Shall fix dead keys??
(require 'iso-transl)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load theme
(setq solarized-distinct-fringe-background t)
(load-theme 'solarized-dark t)
;; (load-theme 'solarized-light t)

;; Setup <f5> for swtiching between the themes
(defvar *theme-dark* 'solarized-dark)
(defvar *theme-light* 'solarized-light)
(defvar *current-theme* *theme-dark*)

;; disable other themes before loading new one
(defadvice load-theme (before theme-dont-propagate activate)
  "Disable theme before loading new one."
  (mapc #'disable-theme custom-enabled-themes))

(defun next-theme (theme)
    (progn
      (load-theme theme t))
  (setq *current-theme* theme))

(defun toggle-theme ()
  (interactive)
  (cond ((eq *current-theme* *theme-dark*) (next-theme *theme-light*))
        ((eq *current-theme* *theme-light*) (next-theme *theme-dark*))))

(global-set-key [f5] 'toggle-theme)
 
;;Preference settings for emacs
;;(setq column-number-mode t)
(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode)
(global-visual-line-mode)
(delete-selection-mode 1)
;; Turn the alarm bell into a visual flash
(setq visible-bell 1)
;; If no alarm shall be sounded or shown
;;(setq ring-bell-function 'ignore)

;; Highlight parentheses
(show-paren-mode 1)

;; Always center the line
;; keep the cursor centered to avoid sudden scroll jumps
;;(require 'centered-cursor-mode)

;; disable in terminal modes
;; http://stackoverflow.com/a/6849467/519736
;; also disable in Info mode, because it breaks going back with the backspace key
;; (define-global-minor-mode my-global-centered-cursor-mode centered-cursor-mode
;;   (lambda ()
;;     (when (not (memq major-mode
;;                      (list 'Info-mode 'term-mode 'eshell-mode 'shell-mode 'erc-mode)))
;;       (centered-cursor-mode))))
;; (my-global-centered-cursor-mode 1)

;; Crux have multiple QoL improvments

;; Setup for autocomplete
(ac-config-default)

;; Setting up spellcheck for emacs
(dolist (hook '(text-mode-hook))
  (add-hook hook (lambda () (flyspell-mode 1))))

;;(define-key flyspell-mode-map (kbd "C-;") #'flyspell-popup-correct)
;;(define-key flyspell-mode-map (kbd "<f8>") #'flyspell-popup-correct)
(add-hook 'flyspell-mode-hook #'flyspell-popup-auto-correct-mode)
(global-set-key (kbd "<f8>") 'ispell-word)
(defun flyspell-check-next-highlighted-word ()
  "Custom Function to spell check next highlighted word"
  (interactive)
  (flyspell-goto-next-error)
  (ispell-word))
(global-set-key (kbd "M-<f8>") 'flyspell-check-next-highlighted-word)
(global-set-key (kbd "<f9>") 'flyspell-prog-mode)

(when (executable-find "hunspell")
  (setq-default ispell-program-name "hunspell")
  (setq ispell-really-hunspell t))


(require 'langtool)
(setq langtool-language-tool-jar "/home/zacharias/Documents/Software/LanguageTool-4.7/languagetool-commandline.jar"
      langtool-mother-tongue "en-GB"
      langtool-disabled-rules '("WHITESPACE_RULE"
                                "EN_UNPAIRED_BRACKETS"
                                "COMMA_PARENTHESIS_WHITESPACE"
                                "EN_QUOTES"))
(global-set-key (kbd "<f2>") 'langtool-check)
(global-set-key (kbd "<f1>") 'langtool-check-done)
(global-set-key (kbd "<f3>") 'langtool-correct-buffer)
(global-set-key (kbd "<f4>") 'langtool-show-message-at-point)

;; Setup for Auctex
(setq TeX-auto-save t)
(setq TeX-parse-self t)
(setq-default TeX-master nil)

(add-hook 'LaTeX-mode-hook 'visual-line-mode)
(add-hook 'LaTeX-mode-hook 'flyspell-mode)
(add-hook 'LaTeX-mode-hook 'LaTeX-math-mode)

(add-hook 'LaTeX-mode-hook 'turn-on-reftex)
(setq reftex-plug-into-AUCTeX t)

(setq TeX-PDF-mode t)

;; Set up for C-a to go to first non whitespace, as M-m does
;; and behave normally if pressed agai
(defun smarter-move-beginning-of-line (arg)
  "Move point back to indentation of beginning of line.

Move point to the first non-whitespace character on this line.
If point is already there, move to the beginning of the line.
Effectively toggle between the first non-whitespace character and
the beginning of the line.

If ARG is not nil or 1, move forward ARG - 1 lines first.  If
point reaches the beginning or end of the buffer, stop there."
  (interactive "^p")
  (setq arg (or arg 1))

  ;; Move lines first
  (when (/= arg 1)
    (let ((line-move-visual nil))
      (forward-line (1- arg))))

  (let ((orig-point (point)))
    (back-to-indentation)
    (when (= orig-point (point))
      (move-beginning-of-line 1))))

;; remap C-a to `smarter-move-beginning-of-line'
(global-set-key [remap move-beginning-of-line]
                'smarter-move-beginning-of-line)

(global-set-key (kbd "C-a") 'smarter-move-beginning-of-line) ;

;; Setup a tabs setup
(require 'centaur-tabs)
(centaur-tabs-mode t)
(global-set-key (kbd "C-<prior>")  'centaur-tabs-backward)
(global-set-key (kbd "C-<next>") 'centaur-tabs-forward)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Standard Jedi.el setting
(add-hook 'python-mode-hook 'jedi:setup)
(setq jedi:complete-on-dot t)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; C/C++ autocomplete
(add-hook 'c++-mode-hook 'irony-mode)
(add-hook 'c-mode-hook 'irony-mode)
(add-hook 'objc-mode-hook 'irony-mode)


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (irony pandoc-mode popup-complete flyspell-popup centered-cursor-mode ein jupyter latex-preview-pane crux highlight-parentheses centaur-tabs langtool evil auctex yasnippet solarized-theme s pyvenv markdown-mode jedi-direx highlight-indentation find-file-in-project company)))
 '(show-paren-mode t))
