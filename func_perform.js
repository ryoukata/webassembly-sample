const fs = require('fs');
const bytes = fs.readFileSync(__dirname + '/func_perform.wasm');

let i = 0;
let importObject = {
  js: {
    external_call: function() {  // インポートされるJS関数
      i++;
      return i;   // 変数iをインクリメントして返す
    }
  }
};

(async () => {
  const obj = await WebAssembly.instantiate(new Uint8Array(bytes),
                                            importObject);
  // obj.instance.exportからのwasm_callとjs_callの分割代入
  ({wasm_call, js_call} = obj.instance.exports);

  let start = Date.now();
  // WebAssemblyモジュールからwasm_callを呼ぶ
  wasm_call();
  let time = Date.now() - start;
  console.log('wasm_call time=' + time);    // 実行時間（ms）

  start = Date.now();
  // WebAssemblyモジュールからjs_callを呼ぶ
  js_call();
  time = Date.now() - start;
  console.log('js_call time=' + time);    // 実行時間（ms）
})();