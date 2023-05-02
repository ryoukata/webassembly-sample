(module
  ;; １行のコメント
  (;
  複数行にわたるコメント
  ;)

  ;; 組み込み環境からインポートしたオブジェクトenvが利用できることと、
  ;; このオブジェクトがprint_string関数を持っていることをWebAssemblyに伝える
  (import "env" "print_string" (func $print_string (param i32)))
  ;; envオブジェクトからメモリバッファのインポートし、名前がbufferであることをWebAssemblyに伝える
  ;; (memory 1)はバッファが１ページの線形メモリを表し、ページは線形メモリに一度に割り当て可能なメモリブロックの最小単位
  ;; WebAssemblyの１ページあたりのサイズは64KBで、このモジュールに必要な量よりも大きいため、１ページで十分と判断
  (import "env" "buffer" (memory 1))

  ;; グローバル変数の宣言
  ;; JSのインポートオブジェクトからインポートした数値で、JSのenvという変数にマッピングされる
  ;; $start_stringは線形メモリでの文字列の開始位置になる値で、最大65,535までの値であれば線形メモリページのどの位置でもOK
  ;; 0を渡した場合は文字データの格納に64KB全体を使用可能
  (global $start_string (import "env" "start_string") i32)
  ;; 文字列の長さを表す。ここでは12文字
  (global $string_len i32 (i32.const 12))

  ;; データ式を使って線形メモリ内の文字列を定義
  ;; このモジュールがデータを書き込むメモリ位置を１つのパラメータに渡している
  (data (global.get $start_string) "hello world!")

  ;; helloworld関数を定義し、モジュールに追加
  (func (export "helloworld")
    ;; インポートした$print_string関数を呼び出し、グローバル変数として定義した文字列の長さを渡すだけ
    (call $print_string (global.get $string_len))
  )
)