const fs = require('fs');
const export_bytes = fs.readFileSync(__dirname + '/table_export.wasm');
const test_bytes = fs.readFileSync(__dirname + '/table_test.wasm');

let i = 0;
let increment = () => {
  i++;
  return i;
}

let decrement = () => {
  i--;
  return i;
}

const importObject = {
  js: {
    // tblの初期値はnullで、2つ目のWASMモジュールのために設定される
    tbl: null,
    // JSのインクリメント関数
    increment: increment,
    // JSのデクリメント関数
    decrement: decrement,
    // 初期値はnullで、２つ目のモジュールで作成された関数が定義される
    wasm_increment: null,
    // 初期値はnullで、２つ目のモジュールで作成された関数が定義される
    wasm_decrement: null
  }
};

(async () => {
  // 関数テーブルを使うモジュールをインスタンス化
  let table_exp_obj =
    await WebAssembly.instantiate(new Uint8Array(export_bytes), importObject);

  // エクスポートされたテーブルをtbl変数に割り当てる
  importObject.js.tbl = table_exp_obj.instance.exports.tbl;

  importObject.js.wasm_increment = table_exp_obj.instance.exports.increment;
  importObject.js.wasm_decrement = table_exp_obj.instance.exports.decrement;
  let obj = 
    await WebAssembly.instantiate(new Uint8Array(test_bytes), importObject);

  // 分割代入を使ってexportsからjs関数を作成
  ({js_table_test,
    js_import_test,
    wasm_table_test,
    wasm_import_test} = obj.instance.exports);

  i = 0;  // iを再度０に初期化
  let start = Date.now();   // 開始タイムスタンプ取得
  // JSのテーブル呼び出しをテストする関数の実行
  js_table_test();
  let time = Date.now() - start;  // かかった時間を計算
  console.log('js_table_test time= ' + time);

  i = 0;  // iを再度０に初期化
  start = Date.now();   // 開始タイムスタンプ取得
  // JSの直接のインポート呼び出しをテストする関数の実行
  js_import_test();
  time = Date.now() - start;  // かかった時間を計算
  console.log('js_import_test time= ' + time);

  i = 0;  // iを再度０に初期化
  start = Date.now();   // 開始タイムスタンプ取得
  // WASMのテーブル呼び出しをテストする関数の実行
  wasm_table_test();
  time = Date.now() - start;  // かかった時間を計算
  console.log('wasm_table_test time= ' + time);

  i = 0;  // iを再度０に初期化
  start = Date.now();   // 開始タイムスタンプ取得
  // WASMの直接のインポート呼び出しをテストする関数の実行
  wasm_import_test();
  time = Date.now() - start;  // かかった時間を計算
  console.log('wasm_import_test time= ' + time);
})();