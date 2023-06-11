(module
  ;; インポートするJS関数は位置と長さを受け取る
  (import "env" "str_pos_len" (func $str_pos_len (param i32 i32)))
  ;; null終端文字列を取得する関数
  (import "env" "null_str" (func $null_str (param i32)))
  ;; 長さを表すプレフィックスを持つ文字列を取得する関数
  (import "env" "len_prefix" (func $len_prefix (param i32)))
  (import "env" "buffer" (memory 1))

  ;; null終端文字列で使用
  ;; dataキーワードでメモリに文字列を設定するときは、他の文字列とメモリの開始位置が被らないこと
  ;; \00は\がWATのエスケープ文字であり、この後の２つの16進数を指定すると指定した値で数値バイトを定義することになる
  ;; つまり0の値を持つシングルバイトを表すnull終端となる
  (data (i32.const 0) "null-terminating string\00")
  (data (i32.const 128) "another null-terminating string\00")

  ;; 30文字の文字列
  (data (i32.const 256) "Know the length of this string")
  ;; 35文字の文字列
  (data (i32.const 384) "Also know the length of this string")

  ;; 文字列長のプレフィックスを持つ文字列
  ;; 長さは10進数で22, 16進数で16
  (data (i32.const 512) "\16length-prefixed string")
  ;; 長さは10進数で30 16進数で1e
  (data (i32.const 640) "\1eanother length-prefixed string")

  (func (export "main")
    ;; null終端文字列の取得
    (call $null_str (i32.const 0))
    (call $null_str (i32.const 128))

    ;; 1つ目の文字列の長さは30文字
    (call $str_pos_len (i32.const 256) (i32.const 30))
    ;; 2つ目の文字列の長さは35文字
    (call $str_pos_len (i32.const 384) (i32.const 35))

    ;; 長さを表すプレフィックスを持つ文字列を取得
    (call $len_prefix (i32.const 512))
    (call $len_prefix (i32.const 640))
  )
)