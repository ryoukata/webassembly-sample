(module
  ;; JSのインクリメント関数
  (import "js" "increment" (func $js_increment (result i32)))
  ;; JSのデクリメント関数
  (import "js" "decrement" (func $js_decrement (result i32)))

  ;; ４つの関数を持つテーブルをエクスポート
  (table $tbl (export "tbl") 4 anyfunc)

  (global $i (mut i32) (i32.const 0))
  (func $increment (export "increment") (result i32)
    (global.set $i (i32.add (global.get $i) (i32.const 1))) ;; $i++
    global.get $i
  )

  (func $decrement (export "decrement") (result i32)
    (global.set $i (i32.sub (global.get $i) (i32.const 1))) ;; $i--
    global.get $i
  )

  ;; テーブルに関数を追加
  (elem (i32.const 0) $js_increment $js_decrement $increment $decrement)
)