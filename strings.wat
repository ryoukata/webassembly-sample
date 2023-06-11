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
    ;; (call $null_str (i32.const 0))
    ;; (call $null_str (i32.const 128))

    ;; 1つ目の文字列の長さは30文字
    (call $str_pos_len (i32.const 256) (i32.const 30))
    ;; 2つ目の文字列の長さは35文字
    (call $str_pos_len (i32.const 384) (i32.const 35))

    (call $string_copy (i32.const 256) (i32.const 384) (i32.const 30))

    (call $str_pos_len (i32.const 384) (i32.const 35))
    ;; 2つ目の文字列の長さは35文字
    (call $str_pos_len (i32.const 384) (i32.const 30))

    ;; 長さを表すプレフィックスを持つ文字列を取得
    ;; (call $len_prefix (i32.const 512))
    ;; (call $len_prefix (i32.const 640))
  )

  ;; 文字列のコピー関数
  ;; １バイトずつのコピーのため速度効率が悪い
  (func $byte_copy
    (param $source i32) (param $dest i32) (param $len i32)
    (local $last_source_byte i32)

    local.get $source
    local.get $len
    i32.add   ;; $source + $len

    local.set $last_source_byte     ;; $last_source_byte = $source + $len

    (loop $copy_loop (block $break
      ;; $destをi32.store8呼び出しで使うためにスタックにプッシュ
      local.get $dest
      ;; soruceから1バイトを読み取る
      (i32.load8_u (local.get $source))
      ;; $destに１バイトを格納
      i32.store8

      local.get $dest
      i32.const 1
      i32.add
      local.set $dest   ;; $dest = $dest + 1

      local.get $source
      i32.const 1
      i32.add
      local.tee $source     ;; $source = $source + 1

      local.get $last_source_byte
      i32.eq
      br_if $break
      br $copy_loop
    ))
  )

  ;; 8バイトずつコピーする関数
  ;; ただし文字数が必ずしも8の倍数とは限らないため、8の倍数でない最後の文字については１バイトずつ読み取る
  (func $byte_copy_i64
    (param $source i32) (param $dest i32) (param $len i32)
    (local $last_source_byte i32)

    local.get $source
    local.get $len
    i32.add

    local.set $last_source_byte

    (loop $copy_loop (block $break
      (i64.store (local.get $dest) (i64.load (local.get $source)))

      local.get $dest
      i32.const 8
      i32.add
      local.set $dest   ;; $dest = $dest + 8

      local.get $source
      i32.const 8
      i32.add
      local.tee $source   ;; $source = $source + 8

      local.get $last_source_byte
      i32.ge_u
      br_if $break
      br $copy_loop
    ))
  )

  ;; $byte_copy_i64関数で８バイトずつデータをコピーした後
  ;; $byte_copy関数で残りのデータを１バイトずつコピーする関数
  (func $string_copy
    (param $source i32) (param $dest i32) (param $len i32)
    (local $start_source_byte i32)
    (local $start_dest_byte i32)
    (local $singles i32)
    (local $len_less_singles i32)

    local.get $len
    local.set $len_less_singles   ;; 64ビットコピーでコピーできるバイト数

    local.get $len
    i32.const 7   ;; 7 = 2進数の0111
    i32.add
    local.tee $singles    ;; $singlesは$lenの最後の3ビット

    if    ;; $lenの最後の3ビットが000ではない場合
      local.get $len
      local.get $singles
      i32.sub
      ;; $len_less_singles = $len - $singles
      local.tee $len_less_singles

      local.get $source
      i32.add
      ;; $start_source_byte = $source + $len_less_singles
      local.set $start_source_byte

      local.get $len_less_singles
      local.get $dest
      i32.add
      ;; $start_dest_byte = $dest + $len_less_singles
      local.set $start_dest_byte

      (call $byte_copy (local.get $start_source_byte)
        (local.get $start_dest_byte) (local.get $singles))
    end

    local.get $len
    i32.const 0xff_ff_ff_f8   ;; 最後の３ビット以外は全て１
    i32.and     ;; $lenの最後の3ビットを0に設定
    local.set $len
    (call $byte_copy_i64
      (local.get $source) (local.get $dest) (local.get $len))
  )
)