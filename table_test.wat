(module
  (import "js" "tbl" (table $tbl 4 anyfunc))
  ;; インクリメント関数のインポート（テーブルにあるJS用の関数と比較のため）
  (import "js" "increment" (func $increment (result i32)))
  ;; デクリメント関数をインポート（テーブルにあるJS用の関数と比較のため）
  (import "js" "decrement" (func $decrement (result i32)))

  ;; wasm_increment関数をインポート
  (import "js" "wasm_increment" (func $wasm_increment (result i32)))
  ;; wasm_decrement関数をインポート
  (import "js" "wasm_decrement" (func $wasm_decrement (result i32)))

  ;; テーブル関数の型定義は全てi32であり、パラメータはない
  (type $returns_i32 (func (result i32)))

  ;; JSのインクリメント関数のテーブルインデックス
  (global $inc_ptr i32 (i32.const 0))
  ;; JSのデクリメント関数のテーブルインデックス
  (global $dec_ptr i32 (i32.const 1))

  ;; WASMのインクリメント関数のインデックス
  (global $wasm_inc_ptr i32 (i32.const 2))
  ;; WASMのデクリメント関数のインデックス
  (global $wasm_dec_ptr i32 (i32.const 3))

  ;; js関数の間接的な呼び出しパフォーマンスをテスト
  (func (export "js_table_test")
    (loop $inc_cycle
      ;; JSのインクリメント関数を間接的に呼び出す
      (call_indirect (type $returns_i32) (global.get $inc_ptr))
      i32.const 4_000_000
      i32.le_u        ;; $inc_ptrから返された値は4,000,000以下か判定
      br_if $inc_cycle    ;; 上記判定がtrueであればループを繰り返す
    )

    (loop $dec_cycle
      ;; JSのデクリメント関数を間接的に呼び出す
      (call_indirect (type $returns_i32) (global.get $dec_ptr))
      i32.const 4_000_000
      i32.le_u        ;; dec_ptrから返された値は4,000,000以下か判定
      br_if $dec_cycle    ;; 上記判定がtrueであればループを繰り返す
    )
  )

  ;; JS関数の直接の呼び出しのパフォーマンスをテスト
  (func (export "js_import_test")
    (loop $inc_cycle
      ;; JSのインクリメント関数を直接呼ぶ
      call $increment
      i32.const 4_000_000
      i32.le_u        ;; incrementから返された値は4,000,000以下か判定
      br_if $inc_cycle    ;; 上記判定がtrueであればループを繰り返す
    )

    (loop $dec_cycle
      ;; JSのデクリメント関数を直接呼ぶ
      call $decrement
      i32.const 4_000_000
      i32.le_u        ;; decrementから返された値は4,000,000以下か判定
      br_if $dec_cycle    ;; 上記判定がtrueであればループを繰り返す
    )
  )

  ;; WASM関数の間接的な呼び出しパフォーマンスをテスト
  (func (export "wasm_table_test")
    (loop $inc_cycle
      ;; WASMのインクリメント関数を間接的に呼び出す
      (call_indirect (type $returns_i32) (global.get $wasm_inc_ptr))
      i32.const 4_000_000
      i32.le_u        ;; $wasm_inc_ptrから返された値は4,000,000以下か判定
      br_if $inc_cycle    ;; 上記判定がtrueであればループを繰り返す
    )

    (loop $dec_cycle
      ;; WASMのデクリメント関数を間接的に呼び出す
      (call_indirect (type $returns_i32) (global.get $wasm_dec_ptr))
      i32.const 4_000_000
      i32.le_u        ;; wasm_dec_ptrから返された値は4,000,000以下か判定
      br_if $dec_cycle    ;; 上記判定がtrueであればループを繰り返す
    )
  )

  ;; WASM関数の直接の呼び出しのパフォーマンスをテスト
  (func (export "wasm_import_test")
    (loop $inc_cycle
      ;; WASMのインクリメント関数を直接呼ぶ
      call $wasm_increment
      i32.const 4_000_000
      i32.le_u        ;; wasm_incrementから返された値は4,000,000以下か判定
      br_if $inc_cycle    ;; 上記判定がtrueであればループを繰り返す
    )

    (loop $dec_cycle
      ;; WASMのデクリメント関数を直接呼ぶ
      call $wasm_decrement
      i32.const 4_000_000
      i32.le_u        ;; wasm_decrementから返された値は4,000,000以下か判定
      br_if $dec_cycle    ;; 上記判定がtrueであればループを繰り返す
    )
  )
)
