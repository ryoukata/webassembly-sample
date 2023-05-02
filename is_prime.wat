(module
  ;; モジュールの先頭に$even_check関数を追加
  ;; 偶数かどうかを判定するモジュール
  (func $even_check (param $n i32) (result i32)
    local.get $n
    i32.const 2
    i32.rem_u ;; 2で割った余りを使う場合
    i32.const 0 ;; 偶数の余りは0になる
    i32.eq      ;; $n % 2 == 0
  )

  ;; $even_check関数の後に$eq_2関数を追加
  ;; 引数の数字が2であるかを判定
  (func $eq_2 (param $n i32) (result i32)
    local.get $n
    i32.const 2
    i32.eq    ;; $n == 2の場合は1を返す
  )

  ;; $eq_2関数の後に$multiple_check関数を追加
  ;; １つめの引数の数字が２つ目の引数の数字の倍数かどうかを判定
  (func $multiple_check (param $n i32) (param $m i32) (result i32)
    local.get $n
    local.get $m
    i32.rem_u   ;; $n % $m の余り
    i32.const 0 ;; その余りが0かどうかを確認
    i32.eq      ;; 上記から$n が$mの倍数かどうかがわかる
  )

  ;; 引数の数が素数であるかどうかを判定するモジュール
  (func $is_prime (export "is_prime") (param $n i32) (result i32)
    (local $i i32)
    (if (i32.eq (local.get $n) (i32.const 1))
      (then
        i32.const 0   ;; 1は素数ではない
        return
      )
    )
    ;; $nが2かどうか
    (if (call $eq_2 (local.get $n))
      (then
        i32.const 1   ;; ２は素数
        return
      )
    )

    (block $not_prime
      (call $even_check (local.get $n))
      br_if $not_prime      ;; (2以外の)偶数は素数ではない

      (local.set $i (i32.const 1))

      (loop $prime_test_loop

        ;; nを奇数で割るためにiを奇数にインクリメント
        (local.tee $i
          (i32.add (local.get $i) (i32.const 2)))   ;; $i += 2

        local.get $n      ;; stack = [$n, $i]

        i32.ge_u          ;; $i >= $n (nよりもiが大きいため、これ以上割ることができず、結果としてnと１でしか割れないことが判明)
        if                ;; $i >= $n の場合、$nは素数
          i32.const 1
          return
        end

        (call $multiple_check (local.get $n) (local.get $i))

        br_if $not_prime    ;; $nが$iの倍数の場合は素数ではない（1とn以外に約数が存在することがわかったため）
        br $prime_test_loop   ;; ループの先頭にもどる（nがiよりも大きくかつまだiでnを割れるため、ループで引き続き割る）
      )   ;; $prime_test_loop　ループの終わり
    )   ;; $not_primeブロックの終わり
    i32.const 0       ;; falseを返す
  )
)   ;; モジュールの終わり