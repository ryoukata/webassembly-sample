const fs = require('fs');

// wasmファイルの読み込み
const bytes = fs.readFileSync(__dirname + '/AddInt.wasm');

// wasmモジュール内で使用する変数の設定
const value_1 = parseInt(process.argv[2]);
const value_2 = parseInt(process.argv[3]);

// wasmモジュールの呼び出し
WebAssembly.instantiate(new Uint8Array(bytes))
.then(obj => {
  let add_value = obj.instance.exports.AddInt(value_1, value_2);
  console.log(`${value_1} + ${value_2} = ${add_value}`);
})