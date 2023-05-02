const fs = require('fs');

const bytes = fs.readFileSync(__dirname + '/hello.wasm');

// 関数は後で定義(最終的にはWebAssemblyモジュールによってエクスポートされるhelloworld関数を指す)
let hello_world = null;

// 線形メモリでの文字列位置
// 線形メモリ配列での文字列開始位置を表す
let start_string_index = 100;

// 線形メモリ
// WebAssemblyインスタンスがアクセスする線形メモリであるバッファを表す
// オブジェクトに渡される数字は確保するページの数
// この数字は最大２GBまで確保できるが、大きすぎるとWebブラウザが要求を満たすような連続メモリを見つけられない場合にエラーになるかもしれない
let memory = new WebAssembly.Memory({initial: 1});

// WebAssemblyモジュールをインスタンス化するときに渡すもの
let importObject = {
  env: {  // オブジェクト名はWebAssemblyのインポート宣言内の名前と一致してればなんでもOK
    buffer: memory,
    start_string: start_string_index,
    print_string: function(str_len) { // WebAssemblyモジュールによって呼ばれる関数
      const bytes = new Uint8Array(memory.buffer,
                                    start_string_index,
                                    str_len);
      const log_string = new TextDecoder('utf8').decode(bytes);
      console.log(log_string);
    }
  }
};

// 非同期でインスタンス化
(async () => {
  let obj = await WebAssembly.instantiate(new Uint8Array(bytes), importObject);
  ({helloworld: hello_world} = obj.instance.exports);
  hello_world();  // WebAssemblyのhelloworld関数を呼ぶ
})(); // 即時に関数を実行