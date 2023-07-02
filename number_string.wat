(module
  (import "env" "print_string" (func $print_string (param i32 i32)))
  (import "env" "buffer" (memory 1))

  (data (i32.const 128) "0123456789ABCDEF")   ;; $digits

  (data (i32.const 256) "               0")   ;; $dec_string
  (global $dec_string_len i32 (i32.const 16))

  (global $hex_string_len i32 (i32.const 16))   ;; 16進数文字の個数 
  (data (i32.const 384) "             0x0")     ;; 16進数文字列データ

  (global $bin_string_len i32 (i32.const 40))
  (data (i32.const 512)
    " 0000 0000 0000 0000 0000 0000 0000 0000") ;; $bin_string
  
  (func $set_bin_string (param $num i32) (param $string_len i32)
    (local $index i32)
    (local $loops_remaining i32)
    (local $nibble_bits i32)

    global.get $bin_string_len
    local.set $index

    i32.const 8     ;; 32ビットの二ブルは8つ（32/4 = 8）
    local.set $loops_remaining  ;; 外側のループで二ブルを区切る

    ;; スペースを追加するための外側のループ
    (loop $bin_loop (block $outer_break
      local.get $index
      i32.eqz
      br_if $outer_break    ;; $indexが0になったらループを停止

      i32.const 4
      local.set $nibble_bits    ;; 各二ブルの4ビット

      ;; 各桁を処理するための内側のループ
      (loop $nibble_loop (block $nibble_break
        local.get $index
        i32.const 1
        i32.sub
        local.set $index    ;; $indexをデクリメント

        local.get $num
        i32.const 1
        i32.and     ;; 最後のビットが１の場合は1, それ以外は0
        if          ;; 最後のビットが１の場合
          local.get $index
          i32.const 49      ;; ASCIIの'1'は49
          i32.store8 offset=512   ;; 512 + $indexに'1'を格納
        else        ;; 最後のビットが０だった場合に実行
          local.get $index
          i32.const 48    ;; ASCIIの'0'は48
          i32.store8 offset=512   ;; 512 + $indexに'0'を格納
        end

        local.get $num
        i32.const 1
        i32.shr_u     ;; $numを右に１ビットシフト
        local.set $num  ;; $numの最後のビットをシフトオフ

        local.get $nibble_bits
        i32.const 1
        i32.sub
        local.tee $nibble_bits    ;; $nibble_bitsをデクリメント
        i32.eqz                   ;; $nibble_bit == 0
        br_if $nibble_break      ;; $nibble_bits == 0でループを抜ける
      ))

      local.get $index
      i32.const 1
      i32.sub
      local.tee $index    ;; $indexをデクリメント
      i32.const 32        ;; ASCIIのスペース文字
      i32.store8 offset=512   ;; スペースを512 + $indexに格納
      br $bin_loop
    ))
  )

  (func $set_hex_string (param $num i32) (param $string_len i32)
    (local $index i32)
    (local $digit_char i32)
    (local $digit_val i32)
    (local $x_pos i32)

    global.get $hex_string_len
    local.set $index    ;; $indexに16進数文字の個数を格納

    (loop $digit_loop (block $break
      local.get $index
      i32.eqz
      br_if $break

      local.get $num
      i32.const 0xf   ;; 最後の4ビットが1
      i32.and         ;; 最後の4ビット以外をマスク

      local.set $digit_val    ;; その桁の値は最後4ビットに含まれている
      local.get $num
      i32.eqz
      if    ;; $num == 0の場合
        local.get $x_pos
        i32.eqz
        if
          local.get $index
          local.set $x_pos   ;; 16進数の0xプレフィックスでのxの位置
        else
          i32.const 32    ;; 32はASCIIのスペース文字
          local.set $digit_char
        end
      else
        ;; 128 + $digit_valから文字列を読み込む
        (i32.load8_u offset=128 (local.get $digit_val))
        local.set $digit_char
      end

      local.get $index
      i32.const 1
      i32.sub
      local.tee $index    ;; $index = $index - 1
      local.get $digit_char

      ;; $digit_charの文字を384+$indexの位置に格納
      i32.store8 offset=384
      local.get $num
      i32.const 4
      i32.shr_u   ;; $numの16進数を1桁シフト
      local.set $num

      br $digit_loop
    ))

    local.get $x_pos
    i32.const 1
    i32.sub

    i32.const 120 ;; ascii x
    i32.store8 offset=384   ;; xを文字列に格納

    local.get $x_pos
    i32.const 2
    i32.sub

    i32.const 48  ;; ascii '0'
    i32.store8 offset=384   ;; '0x'を文字列の先頭に格納
  )

  (func $set_dec_string (param $num i32) (param $string_len i32)
    (local $index i32)
    (local $digits_char i32)
    (local $digits_val i32)

    local.get $string_len
    local.set $index    ;; $indexに文字列の長さを格納

    local.get $num
    i32.eqz     ;; $numは0に等しいか
    if
      local.get $index
      i32.const 1
      i32.sub
      local.set $index    ;; $index--

      ;; ASCIIの'0'をメモリ位置256 + indexに格納
      (i32.store8 offset=256 (local.get $index) (i32.const 48))
    end

    ;; ループを使って数値を文字列に変換
    (loop $digit_loop (block $break
      ;; $indexが文字列の終わりを指すようにし、0をデクリメント
      local.get $index
      i32.eqz     ;; $indexは0か？
      br_if $break

      local.get $num
      i32.const 10
      i32.rem_u   ;; 0-9の数字は10で割った余り

      local.set $digits_val   ;; 10で割った余りを格納
      local.get $num
      i32.eqz   ;; $numが0稼働かをチェック
      if
        i32.const 32    ;; 32はASCIIのスペース文字
        local.set $digits_char  ;; $numが0の場合は左側をスペースでパディング
      else
        (i32.load8_u offset=128 (local.get $digits_val))
        local.set $digits_char  ;; $digits_charにASCII数字を格納
      end

      local.get $index
      i32.const 1
      i32.sub
      local.set $index
      ;; ASCII数字を256 + $indexに格納
      (i32.store8 offset=256 (local.get $index) (local.get $digits_char))

      local.get $num
      i32.const 10
      i32.div_u
      local.set $num    ;; 10進数の最後の桁を削除し、10で割る

      br $digit_loop
    ))
  )

  (func (export "to_string") (param $num i32)
    (call $set_dec_string
      (local.get $num) (global.get $dec_string_len))
    (call $print_string
      (i32.const 256) (global.get $dec_string_len))

    (call $set_hex_string
      (local.get $num) (global.get $hex_string_len))
    (call $print_string
      (i32.const 384) (global.get $hex_string_len))

    (call $set_bin_string
      (local.get $num) (global.get $bin_string_len))
    (call $print_string
      (i32.const 512) (global.get $bin_string_len))
  )
)