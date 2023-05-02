(module
  (import "env" "log" (func $log (param i32 i32)))

  (func $loop_test (export "loop_test") (param $n i32)
    (result i32)

    (local $i i32)
    (local $factorial i32)

    (local.set $factorial (i32.const 1))

    (loop $continue (block $break;; $continue ループと$breakブロック
      (local.set $i  ;; $i++
        (i32.add (local.get $i) (i32.const 1))
      )
      
      ;; $iの階乗の値
      (local.set $factorial  ;; $factorial = $i * $factorial
        (i32.mul (local.get $i) (local.get $factorial))
      )

      ;; $logを呼び出し、パラメータ$iと$factiorialを渡す
      (call $log (local.get $i) (local.get $factorial))

      (br_if $break
        ;; $i==$nの場合はループを抜ける
        (i32.eq (local.get $i) (local.get $n))
      )
      br $continue  ;; ループの先頭に分岐
    ))

    ;; $factorialを呼び出し元のJavascriptに返す
    local.get $factorial
  )
)