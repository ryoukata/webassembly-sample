const colors = require('colors');
const fs = require('fs');
const bytes = fs.readFileSync(__dirname + '/store_data.wasm');

// 64Kのメモリブロックを確保
const memory = new WebAssembly.Memory({ initial: 1});
// メモリバッファの32ビットデータビュー
const mem_i32 = new Uint32Array(memory.buffer);

const data_addr = 32;   // データの１バイト目のアドレス

// データの先頭を表す32ビットインデックス
const data_i32_index = data_addr / 4;
const data_count = 16;    // 設定する３２ビット整数の個数

// WASMがJSからインポートするオブジェクト
const importObject = {
  env: {
    mem: memory,
    data_addr: data_addr,
    data_count: data_count
  }
};

(async () => {
  let obj = await WebAssembly.instantiate(new Uint8Array(bytes), importObject);

  for (let i = 0; i < data_i32_index + data_count + 4; i++) {
    let data = mem_i32[i];
    if (data != 0) {
      console.log(`data[${i}]=${data}`.red.bold);
    } else {
      console.log(`data[${i}]=${data}`);
    }
  }
})();