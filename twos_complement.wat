(module
  (func $twos_complement (export "twos_complement")
    (param $number i32)
    (result i32)
    local.get $number
    i32.const 0xffffffff    ;; 全てビットが1のマスク
    i32.xor                 ;; 全てのビットを反転させる
    i32.const 1
    i32.add                 ;; ２の補数のためにビットフリップの数に１を足す
  )
)