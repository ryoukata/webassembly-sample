(module
  ;; JavaScript関数の外部からの呼び出し
  (import "js" "external_call" (func $external_call (result i32)))
  ;; 内部関数のためのグローバル変数
  (global $i (mut i32) (i32.const 0))

  (func $internal_call (result i32) ;; i32を呼び出し元の関数に返す
    global.get $i
    i32.const 1
    i32.add
    global.set $i ;; 最初の４行は$iをインクリメントするコード

    global.get $i ;; $iを呼び出し元の関数に返す
  )

  ;; JavaScriptにエクスポートされる wasm_call 関数
  (func (export "wasm_call")
    (loop $again              ;; $againループ
      call $internal_call     ;; WASMの$internal_call 関数を呼ぶ
      i32.const 4_000_000
      i32.le_u                ;; $iの値は4,000,000以下か判定
      br_if $again            ;; 上記の判定がtrueであればループの先頭へ移動してループを継続
    ) 
  )

  ;; 外部JS関数に対する400万回の呼び出し
  (func (export "js_call")
    (loop $again
      ;; インポートした$external_call関数を呼ぶ
      (call $external_call)
      i32.const 4_000_000
      i32.le_u      ;; $external_callから返された値は400万以下か判定
      br_if $again  ;; 上記判定がtrueであればループを継続
    )
  )
)   ;; モジュールの終了