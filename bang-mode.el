;;; bang-mode.el --- Cambricon Bang (BANG) Major Mode

;; Copyright (C) 2021  Chihyang Hsin

;; Author: Chihang Hsin <chihyanghsin@gmail.com>
;; Keywords: c, languages

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Based on CUDA mode on EmacsWiki http://www.emacswiki.org/emacs/CudaMode and
;; Github @ https://github.com/chachi/cuda-mode

;;; Code:

(require 'cc-mode)
(require 'cc-menus)

;; These are only required at compile time to get the sources for the
;; language constants.  (The cc-fonts require and the font-lock
;; related constants could additionally be put inside an
;; (eval-after-load "font-lock" ...) but then some trickery is
;; necessary to get them compiled.)
(eval-when-compile
  (require 'cc-langs)
  (require 'cc-fonts))


(eval-and-compile
  ;; Make our mode known to the language constant system.  Use C
  ;; mode as the fallback for the constants we don't change here.
  ;; This needs to be done also at compile time since the language
  ;; constants are evaluated then.
  (c-add-language 'bang-mode 'c++-mode))

(c-lang-defconst c-primitive-type-kwds
  "Primitive type keywords.  As opposed to the other keyword lists, the
keywords listed here are fontified with the type face instead of the
keyword face.
If any of these also are on `c-type-list-kwds', `c-ref-list-kwds',
`c-colon-type-list-kwds', `c-paren-nontype-kwds', `c-paren-type-kwds',
`c-<>-type-kwds', or `c-<>-arglist-kwds' then the associated clauses
will be handled.
Do not try to modify this list for end user customizations; the
`*-font-lock-extra-types' variable, where `*' is the mode prefix, is
the appropriate place for that."
  bang
  (append
   '("int8_t" "uint8_t" "int16_t" "uint16_t" "int32_t" "uint32_t"
     "half" "float" "char" "int8" "int16" "bool")
   ;; Use append to not be destructive on the
   ;; return value below.
   (append
    (c-lang-const c-primitive-type-kwds)
    nil)))

(c-lang-defconst c-modifier-kwds
  bang
  (append
   (c-lang-const c-modifier-kwds)
   '("__nram__" "__wram__" "__mlu_shared__" "__ldram__" "__mlu_device__"
     "__mlu_func__" "__mlu_entry__" "__asm__")))

(c-lang-defconst c-other-op-syntax-tokens
  "List of the tokens made up of characters in the punctuation or
parenthesis syntax classes that have uses other than as expression
operators."
  bang
  (append '("#" "##"    ; Used by cpp.
        "::" "..." "<<<" ">>>")
      (c-lang-const c-other-op-syntax-tokens)))

(c-lang-defconst c-primary-expr-kwds
  "Keywords besides constants and operators that start primary expressions."
  bang
  '("taskDim" "taskDimX" "taskDimY" "taskDimZ"
    "taskId" "taskIdX" "taskIdY" "taskIdZ"))

(c-lang-defconst c-paren-nontype-kwds
  "Keywords that may be followed by a parenthesis expression that doesn't
contain type identifiers."
  bang
  nil
  (c c++)
  '(;; GCC extension.
    "__attribute__"
    ;; MSVC extension.
    "__declspec"))

(defconst bang-builtins
  '(;; scalar operation
    "abs"
    "ceil"
    "ceilf"
    "cosf"
    "floor"
    "floorf"
    "fabsf"
    "fmaxf"
    "fminf"
    "log2f"
    "max"
    "min"
    "powf"
    "round"
    "sinf"
    "sqrtf"
    "truncf"
    ;; scalar type convertion
    "__half2int_tz"
    "__half2int_oz"
    "__half2int_up"
    "__half2int_dn"
    "__half2int_rd"
    "__half2short_tz"
    "__half2short_oz"
    "__half2short_up"
    "__half2short_dn"
    "__half2short_rd"
    "__float2int_tz"
    "__float2int_oz"
    "__float2int_up"
    "__float2int_dn"
    "__float2int_rd"
    "__float2short_tz"
    "__float2short_oz"
    "__float2short_up"
    "__float2short_dn"
    "__float2short_rd"
    ;; scalar/stream atomic
    "__bang_atomic_add"
    "__bang_atomic_and"
    "__bang_atomic_cas"
    "__bang_atomic_dec"
    "__bang_atomic_exch"
    "__bang_atomic_inc"
    "__bang_atomic_max"
    "__bang_atomic_min"
    "__bang_atomic_or"
    "__bang_atomic_xor"
    ;; stream operation
    "__bang_active_abs"
    "__bang_active_cos"
    "__bang_active_exp"
    "__bang_active_exphp"
    "__bang_active_exp_less_0"
    "__bang_active_gelu"
    "__bang_active_gelup"
    "__bang_active_log"
    "__bang_active_loghp"
    "__bang_active_pow2"
    "__bang_active_recip"
    "__bang_active_recip_greater_1"
    "__bang_active_reciphp"
    "__bang_active_relu"
    "__bang_active_rsqrt"
    "__bang_active_rsqrthp"
    "__bang_active_sigmoid"
    "__bang_active_sign"
    "__bang_active_sin"
    "__bang_active_sqrt"
    "__bang_active_sqrthp"
    "__bang_active_tanh"
    "__bang_add"
    "__bang_add_const"
    "__bang_avgpool"
    "__bang_avgpool_bp"
    "__bang_collect"
    "__bang_collect_bitindex"
    "__bang_conv"
    "__bang_conv_partial"
    "__bang_count"
    "__bang_count_bitindex"
    "__bang_cycle_add"
    "__bang_cycle_mul"
    "__bang_cycle_sub"
    "__bang_div"
    "__bang_div"
    "__bang_bindfirst1"
    "__bang_bindlast1"
    "__bang_ge_const"
    "__bang_maskmove"
    "__bang_maskmove_bitindex"
    "__bang_maximum"
    "__bang_maxpool"
    "__bang_maxpool_bp"
    "__bang_maxpool_index"
    "__bang_minpool"
    "__bang_minpool_index"
    "__bang_mirror"
    "__bang_mlp"
    "__bang_mul"
    "__bang_mul_const"
    "__bang_mul_pad"
    "__bang_mul_reduce_sum"
    "__bang_rotate90"
    "__bang_rotate180"
    "__bang_rotate270"
    "__bang_select"
    "__bang_select_bitindex"
    "__bang_square"
    "__bang_sub"
    "__bang_sub_const"
    "__bang_subpool"
    "__bang_taylor3_sin"
    "__bang_taylor4_sin"
    "__bang_taylor3_cos"
    "__bang_taylor4_cos"
    "__bang_taylor3_tanh"
    "__bang_taylor4_tanh"
    "__bang_taylor3_sigmoid"
    "__bang_taylor4_sigmoid"
    "__bang_taylor3_softplus"
    "__bang_taylor4_softplus"
    "__bang_tiling_2d"
    "__bang_tiling_3d"
    "__bang_transpose"
    "__bang_unpool"
    "__bang_write_zero"
    "__bang_rand"
    "__bang_histogram"
    "__bang_reshape_filter"
    "__bang_reshape_nhwc2nchw"
    "__bang_reshape_nchw2nhwc"
    ;; stream comparison
    "__bang_cycle_eq"
    "__bang_cycle_ge"
    "__bang_cycle_gt"
    "__bang_cycle_le"
    "__bang_cycle_lt"
    "__bang_cycle_ne"
    "__bang_eq"
    "__bang_eq_bitindex"
    "__bang_ge"
    "__bang_ge_bitindex"
    "__bang_gt"
    "__bang_gt_bitindex"
    "__bang_le"
    "__bang_le_bitindex"
    "__bang_lt"
    "__bang_lt_bitindex"
    "__bang_ne"
    "__bang_ne_bitindex"
    ;; stream logic and bit operation
    "__bang_and"
    "__bang_band"
    "__bang_bnot"
    "__bang_bor"
    "__bang_bxor"
    "__bang_cycle_and"
    "__bang_cycle_band"
    "__bang_cycle_bor"
    "__bang_cycle_bxor"
    "__bang_cycle_maxequal"
    "__bang_cycle_minequal"
    "__bang_cycle_or"
    "__bang_cycle_xor"
    "__bang_max"
    "__bang_maxequal"
    "__bang_min"
    "__bang_minequal"
    "__bang_not"
    "__bang_or"
    "__bang_xor"
    ;; stream type conversion
    "__bang_int82half"
    "__bang_float2half_dn"
    "__bang_float2half_oz"
    "__bang_float2half_rd"
    "__bang_float2half_tz"
    "__bang_float2half_up"
    "__bang_float2int16_dn"
    "__bang_float2int16_oz"
    "__bang_float2int16_rd"
    "__bang_float2int16_tz"
    "__bang_float2int16_up"
    "__bang_float2int8_dn"
    "__bang_float2int8_oz"
    "__bang_float2int8_rd"
    "__bang_float2int8_tz"
    "__bang_float2int8_up"
    "__bang_half2float"
    "__bang_half2int16_dn"
    "__bang_half2int16_oz"
    "__bang_half2int16_rd"
    "__bang_half2int16_tz"
    "__bang_half2int16_up"
    "__bang_half2int8_dn"
    "__bang_half2int8_oz"
    "__bang_half2int8_rd"
    "__bang_half2int8_tz"
    "__bang_half2int8_up"
    "__bang_half2short_dn"
    "__bang_half2short_oz"
    "__bang_half2short_rd"
    "__bang_half2short_tz"
    "__bang_half2short_up"
    "__bang_half2uchar_dn"
    "__bang_int82half"
    "__bang_int162float"
    "__bang_int162half"
    "__bang_int82float"
    "__bang_short2half"
    "__bang_uchar2half"
    ;; memory management
    "__bang_lock"
    "__bang_unlock"
    "__memcpy"
    "__memcpy_async"
    "__memcpy_nram_to_nram"
    "__gdramset"
    "__ldramset"
    "__nramset"
    "__nramset_half"
    "__nramset_int"
    "__nramset_short"
    "__sramset"
    ;; sync
    "__sync_all"
    "__sync_all_ipu"
    "__sync_all_mpu"
    "__sync_cluster"
    "__sync_compute"
    "__sync_copy"
    ;; control flow
    "__abort"
    "__assert"
    "exit"
    "printf"
    ;; CASCCL
    "__bang_printf"
    "cnscclAllReduce"
    "cnscclBroadcast"
    "cnscclGather"
    "cnscclReduce"
    "cnscclReduceScatter"
    )
  "Names of built-in bang functions.")

(defcustom bang-font-lock-extra-types nil
  "*List of extra types to recognize in BANG mode.
Each list item should be a regexp matching a single identifier."
  :group 'bang-mode)

(defconst bang-font-lock-keywords-1
  (c-lang-const c-matchers-1 bang)
  "Minimal highlighting for BANG mode.")

(defconst bang-font-lock-keywords-2
  (c-lang-const c-matchers-2 bang)
  "Fast normal highlighting for BANG mode.")

(defconst bang-font-lock-keywords-3
  (c-lang-const c-matchers-3 bang)
  "Accurate normal highlighting for BANG mode.")

;;; here we `cc-imenu-c++-generic-expression' is used directly
(defvar cc-imenu-bang-generic-expression
  cc-imenu-c++-generic-expression
  "Imenu generic expression for BANG mode.  See `imenu-generic-expression'.")

(defvar bang-font-lock-keywords bang-font-lock-keywords-3
  "Default expressions to highlight in BANG mode.")

(defvar bang-mode-syntax-table
  (funcall (c-lang-const c-make-mode-syntax-table bang))
  "Syntax table used in bang-mode buffers.")

(c-define-abbrev-table 'bang-mode-abbrev-table
  '(("else" "else" c-electric-continued-statement 0)
    ("while" "while" c-electric-continued-statement 0)
    ("catch" "catch" c-electric-continued-statement 0))
  "Abbreviation table used in bang-mode buffers.")

(defvar bang-mode-map
  (let ((map (c-make-inherited-keymap)))
    ;; Add bindings which are only useful for BANG
    map)
  "Keymap used in bang-mode buffers.")

(easy-menu-define bang-menu bang-mode-map "BANG Mode Commands"
  ;; Can use `bang' as the language for `c-mode-menu'
  ;; since its definition covers any language.  In
  ;; this case the language is used to adapt to the
  ;; nonexistence of a cpp pass and thus removing some
  ;; irrelevant menu alternatives.
  (cons "BANG" (c-lang-const c-mode-menu bang)))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.mlu\\'" . bang-mode))

;;;###autoload
(define-derived-mode bang-mode prog-mode "Bang"
  "Major mode for editing cambricon BANG code.

Bang is a C++-like language create by Cambricon for mixed
native/MLU coding.

The hook `c-mode-common-hook' is run with no args at mode
initialization, then `bang-mode-hook'.

Key bindings:
\\{bang-mode-map}"
  :syntax-table bang-mode-syntax-table
  :after-hook (progn (c-make-noise-macro-regexps)
                     (c-make-macro-with-semi-re)
                     (c-update-modeline))
  (c-initialize-cc-mode t)
  (setq abbrev-mode t)
  (c-init-language-vars bang-mode)
  (c-common-init 'bang-mode)
  (easy-menu-add bang-menu)
  (cc-imenu-init cc-imenu-bang-generic-expression)
  (add-hook 'flymake-diagnostic-functions 'flymake-cc nil t)
  (c-run-mode-hooks 'c-mode-common-hook))

(provide 'bang-mode)
;;; bang-mode.el ends here
