(require 'package)
(add-to-list 'package-archives '("gnu"   . "https://elpa.gnu.org/packages/") t)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(eval-and-compile
  (setq use-package-always-ensure t
        use-package-expand-minimally t))


(load-file "~/.emacs.d/custom.el")







(use-package better-defaults)


(use-package helm
  ;; 等价于 (bind-key "M-x" #'helm-M-x)
  :bind (("M-x" . helm-M-x)
         ("C-x C-f" . helm-find-files))
  :config
  ;; 全局启用 Helm minor mode
  (helm-mode 1))

(use-package helm-xref)

(use-package flycheck
  :init ;; 在 (require) 之前需要执行的
  (setq flycheck-emacs-lisp-load-path 'inherit)
  :config
  (global-flycheck-mode))

;; ~/.emacs.d/init.el
(use-package projectile
  :config
  ;; 把它的缓存挪到 ~/.emacs.d/.cache/ 文件夹下，让 gitignore 好做
  (setq projectile-cache-file (expand-file-name ".cache/projectile.cache" user-emacs-directory))
  ;; 全局 enable 这个 minor mode
  (projectile-mode 1)
  ;; 定义和它有关的功能的 leader key
  (define-key projectile-mode-map (kbd "C-c C-p") 'projectile-command-map))

(use-package helm-projectile
  :if (functionp 'helm) ;; 如果使用了 helm 的话，让 projectile 的选项菜单使用 Helm 呈现
  :config
  (helm-projectile-on))

;; ~/.emacs.d/init.el
(use-package magit)

(use-package company)

(use-package lsp-mode
  ;; 延时加载：仅当 (lsp) 函数被调用时再 (require)
  :commands (lsp)
  ;; 在哪些语言 major mode 下启用 LSP
  :hook (((ruby-mode
           php-mode
           typescript-mode
	   c-mode
	   c++-mode
	   rustic-mode
           glsl-mode
           html-mode
           css-mode
           verilog-mode
           ;; ......
           ) . lsp))
  :init ;; 在 (reuqire) 之前执行
  (setq lsp-auto-configure t ;; 尝试自动配置自己
        lsp-auto-guess-root t ;; 尝试自动猜测项目根文件夹
        lsp-idle-delay 0.500 ;; 多少时间idle后向服务器刷新信息
        lsp-session-file "~/.emacs.d/.cache/lsp-sessions") ;; 给缓存文件换一个位置
  )

;; 内容呈现
(use-package lsp-ui
  ;; 仅在某软件包被加载后再加载
  :after (lsp-mode)
  ;; 延时加载
  :commands (lsp-ui-mode)
  :bind
  (:map lsp-ui-mode-map
        ;; 查询符号定义：使用 LSP 来查询。通常是 M-.
        ([remap xref-find-references] . lsp-ui-peek-find-references)
        ;; 查询符号引用：使用 LSP 来查询。通常是 M-?
        ([remap xref-find-definitions] . lsp-ui-peek-find-definitions)
        ;; 该文件里的符号列表：类、方法、变量等。前提是语言服务支持本功能。
        ("C-c u" . lsp-ui-imenu))
  ;; 当 lsp 被激活时自动激活 lsp-ui
  :hook (lsp-mode . lsp-ui-mode)
  :init
  ;; lsp-ui 有相当细致的功能开关。具体参考：
  ;; https://github.com/emacs-lsp/lsp-mode/blob/master/docs/tutorials/how-to-turn-off.md
  (setq lsp-enable-symbol-highlighting t
        lsp-ui-doc-enable t
        lsp-lens-enable t))

(use-package helm-ag)

(use-package ctrlf
  :config
  (ctrlf-mode t))
;; 此时 C-s 已经被替换成 ctrlf 版本的了

(use-package helm-swoop
  ;; 更多关于它的配置方法: https://github.com/ShingoFukuyama/helm-swoop
  ;; 以下我的配置仅供参考
  :bind
  (("M-i" . helm-swoop)
   ("M-I" . helm-swoop-back-to-last-point)
   ("C-c M-i" . helm-multi-swoop)
   ("C-x M-i" . helm-multi-swoop-all)
   :map isearch-mode-map
   ("M-i" . helm-swoop-from-isearch)
   :map helm-swoop-map
   ("M-i" . helm-multi-swoop-all-from-helm-swoop)
   ("M-m" . helm-multi-swoop-current-mode-from-helm-swoop))
  :config
  ;; 它像 helm-ag 一样，可以直接修改搜索结果 buffer 里的内容并 apply
  (setq helm-multi-swoop-edit-save t)
  ;; 如何给它新开分割窗口
  ;; If this value is t, split window inside the current window
  (setq helm-swoop-split-with-multiple-windows t))


(use-package avy
  :bind (("C-'" . avy-goto-char-timer) ;; Control + 单引号
         ;; 复用上一次搜索
         ("C-c C-j" . avy-resume))
  :config
  (setq avy-background t ;; 打关键字时给匹配结果加一个灰背景，更醒目
        avy-all-windows t ;; 搜索所有 window，即所有「可视范围」
        avy-timeout-seconds 0.6)) ;; 「关键字输入完毕」信号的触发时间

(use-package anzu)
;; 我都是手动调用它的，因为使用场景不多，但又不能没有……
;; M-x anzu-query-replace-regexp

(use-package multiple-cursors
  :bind (("C-S-c" . mc/edit-lines) ;; 每行一个光标
         ("C->" . mc/mark-next-like-this-symbol) ;; 全选光标所在单词并在下一个单词增加一个光标。通常用来启动一个流程
         ("C-M->" . mc/skip-to-next-like-this) ;; 跳过当前单词并跳到下一个单词，和上面在同一个流程里。
         ("C-<" . mc/mark-previous-like-this-symbol) ;; 同样是开启一个多光标流程，但是是「向上找」而不是向下找。
         ("C-M-<" . mc/skip-to-previous-like-this) ;; 跳过当前单词并跳到上一个单词，和上面在同一个流程里。
         ("C-c C->" . mc/mark-all-symbols-like-this))) ;; 直接多选本 buffer 所有这个单词


(use-package rustic)
(use-package treemacs
  :bind ("C-c C-t" . treemacs))

(use-package undo-tree
  :config
  (setq undo-tree-auto-save-history nil))

  

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))


(use-package yasnippet
  :config
  (yas-global-mode 1))


(use-package wgsl-mode)
(use-package glsl-mode)

(use-package mwim
  :ensure t
  :bind
  ("C-a" . mwim-beginning-of-code-or-line)
  ("C-e" . mwim-end-of-code-or-line))


(use-package company
  :config
  (global-company-mode))



(delete-selection-mode t)
(column-number-mode t)
(global-undo-tree-mode)
(global-auto-revert-mode t)

(setq warning-minimum-level :emergency)


(setq gc-cons-threshold (* 100 1024 1024)
      read-process-output-max (* 1024 1024)
      treemacs-space-between-root-nodes nil
      company-idle-delay 0.0
      company-minimum-prefix-length 1
      lsp-idle-delay 0.1)  ;; clangd is fast
