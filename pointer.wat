(module
  (memory 1)
  (global $pointer i32 (i32.const 128))

  (func $init
    (i32.store
      (global.get $pointer)   ;; $pointerの位置に格納
      (i32.const 99)          ;; 格納する値
    )
  )

  (func (export "get_ptr") (result i32)
    (i32.load (global.get $pointer))    ;; $pointerの位置にある値を返す
  )

  (start $init)
)