const colors = require('colors');
const fs = require('fs');
const bytes = fs.readFileSync(__dirname + '/data_structures.wasm');

// 64KBのメモリーブロックを確保
const memory = new WebAssembly.Memory({ initial: 1 });
// メモリーバッファの32ビットビュー
const mem_i32 = new Uint32Array(memory.buffer);

const obj_base_addr = 0;  // データの１バイト目のアドレス
const obj_count = 32;     // 構造体の個数
const obj_stride = 16;    // 16バイトのストライド

// 構造体の属性のオフセット
const x_offset = 0;
const y_offset = 4;
const radius_offset = 8;
const collision_offset = 12;

// 32ビット整数のインデックス
const obj_i32_base_index = obj_base_addr / 4;
// 32ビットのストライド
const obj_i32_stride = obj_stride / 4;

// 32ビット整数配列内のオフセット
const x_offset_i32 = x_offset / 4;
const y_offset_i32 = y_offset / 4;
const radius_offset_i32 = radius_offset / 4;
const collision_offset_i32 = collision_offset / 4;

// WebAssemblyがJSからインポートするオブジェクト
const importObject = {
  env: {
    mem: memory,
    obj_base_addr: obj_base_addr,
    obj_count: obj_count,
    obj_stride: obj_stride,
    x_offset: x_offset,
    y_offset: y_offset,
    radius_offset: radius_offset,
    collision_offset: collision_offset,
  }
};

// ランダムなx座標、y座標、半径で円を初期化
for (let i = 0; i < obj_count; i++) {
  let index = obj_i32_stride * i + obj_i32_base_index;
  let x = Math.floor(Math.random() * 100);
  let y = Math.floor(Math.random() * 100);
  let r = Math.floor(Math.random() * 10);

  mem_i32[index + x_offset_i32] = x;
  mem_i32[index + y_offset_i32] = y;
  mem_i32[index + radius_offset_i32] = r;
}

// WebAssemblyをインスタンス化し、円の衝突を調べる
(async () => {
  let obj = await WebAssembly.instantiate(new Uint8Array(bytes), importObject);

  for (let i = 0; i < obj_count; i++) {
    let index = obj_i32_stride * i + obj_i32_base_index;

    let x = mem_i32[index + x_offset_i32].toString().padStart(2, ' ');
    let y = mem_i32[index + y_offset_i32].toString().padStart(2, ' ');
    let r = mem_i32[index + radius_offset_i32].toString().padStart(2, ' ');
    let i_str = i.toString().padStart(2, '0');
    let c = !!mem_i32[index + collision_offset_i32];

    if (c) {
      console.log(
        `obj[${i_str}] x=${x} y=${y} r=${r} collision=${c}`.red.bold
      );
    } else {
      console.log(
        `obj[${i_str}] x=${x} y=${y} r=${r} collision=${c}`.green
      );
    }
  }
})();