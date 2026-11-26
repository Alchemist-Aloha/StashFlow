// Compiles a dart2wasm-generated main module from `source` which can then
// be instantiated via the `instantiate` method.
//
// `source` needs to be a `Response` object (or promise thereof) e.g. created
// via the `fetch()` JS API.
export async function compileStreaming(source) {
  const builtins = {builtins: ['js-string'], importedStringConstants: ''};
  return new CompiledApp(
      await _compileStreaming(source, builtins), builtins);
}

// Compiles a dart2wasm-generated wasm module from `bytes` which is then
// instantiable via the `instantiate` method.
export async function compile(bytes) {
  const builtins = {builtins: ['js-string'], importedStringConstants: ''};
  return new CompiledApp(await WebAssembly.compile(bytes, builtins), builtins);
}

let _isCompileStreamingSupported;
async function _compileStreaming(source, builtins) {
  _isCompileStreamingSupported ??= WebAssembly.compileStreaming(
    new Response(
      new Uint8Array([0,97,115,109,1,0,0,0,1,4,1,96,0,0,2,23,1,14,119,97,115,109,58,106,115,45,115,116,114,105,110,103,4,99,97,115,116,0,0]),
      {headers: {'Content-Type': 'application/wasm'}},
    ),
    builtins,
  ).then(() => false, (e) => e instanceof WebAssembly.CompileError);
  if (await _isCompileStreamingSupported) {
    return WebAssembly.compileStreaming(source, builtins);
  }
  return WebAssembly.compile(await (await source).arrayBuffer(), builtins);
}

class CompiledApp {
  constructor(module, builtins) {
    this.module = module;
    this.builtins = builtins;
  }

  // The second argument is an options object containing:
  // `loadDeferredModules` is a JS function that takes an array of module names
  //   matching wasm files produced by the dart2wasm compiler. It also takes a
  //   callback that should be invoked for each loaded module with 2 arguments:
  //   (1) the module name, (2) the loaded module in a format supported by
  //   `WebAssembly.compile` or `WebAssembly.compileStreaming`. The callback
  //   returns a Promise that resolves when the module is instantiated.
  //   loadDeferredModules should return a Promise that resolves when all the
  //   modules have been loaded and the callback promises have resolved.
  // `loadDeferredId` is a JS function that takes load ID produced by the
  //   compiler when the `use-load-ids` option is passed. Each load ID maps to
  //   one or more wasm files as specified in the emitted JSON file. It also
  //   takes a callback that should be invoked for each loaded module with 2
  //   arguments: (1) the module name, (2) the loaded module in a format
  //   supported by `WebAssembly.compile` or `WebAssembly.compileStreaming`.
  //   The callback returns a Promise that resolves when the module is
  //   instantiated.
  //   loadDeferredId should return a Promise that resolves when all the
  //   modules have been loaded and the callback promises have resolved.
  async instantiate(additionalImports, {loadDeferredModules, loadDeferredId} = {}) {
    let dartInstance;

    // Prints to the console
    function printToConsole(value) {
      if (typeof dartPrint == "function") {
        dartPrint(value);
        return;
      }
      if (typeof console == "object" && typeof console.log != "undefined") {
        console.log(value);
        return;
      }
      if (typeof print == "function") {
        print(value);
        return;
      }

      throw "Unable to print message: " + value;
    }

    // A special symbol attached to functions that wrap Dart functions.
    const jsWrappedDartFunctionSymbol = Symbol("JSWrappedDartFunction");

    function finalizeWrapper(dartFunction, wrapped) {
      wrapped.dartFunction = dartFunction;
      wrapped[jsWrappedDartFunctionSymbol] = true;
      return wrapped;
    }

    // Imports
    const dart2wasm = {
            AB: b => !!b,
      AC: Function.prototype.call.bind(DataView.prototype.setInt16),
      AD: x0 => x0.height,
      AE: x0 => x0.computedStyleMap(),
      AF: x0 => x0.clientX,
      AG: x0 => x0.openCursor(),
      AH: () => globalThis.Symbol,
      AI: x0 => x0.value,
      AJ: x0 => x0.value,
      AK: x0 => x0.message,
      AL: x0 => x0.createRange(),
      AM: x0 => x0.tracks,
      AN: x0 => x0.vendor,
      AO: (x0,x1,x2) => x0.setItem(x1,x2),
      AP: x0 => x0.getReader(),
      B: s => printToConsole(s),
      BB: () => globalThis.document,
      BC: Function.prototype.call.bind(DataView.prototype.setUint16),
      BD: x0 => x0.width,
      BE: (x0,x1) => x0.get(x1),
      BF: x0 => x0.changedTouches,
      BG: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      BH: (x0,x1) => new Intl.Segmenter(x0,x1),
      BI: x0 => x0.selectionDirection,
      BJ: x0 => x0.done,
      BK: x0 => x0.error,
      BL: (x0,x1) => x0.selectNode(x1),
      BM: () => globalThis.window.ImageDecoder,
      BN: (x0,x1,x2) => x0.insertBefore(x1,x2),
      BO: x0 => x0.baseURI,
      BP: x0 => x0.value,
      C: Function.prototype.call.bind(Number.prototype.toString),
      CB: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      CC: Function.prototype.call.bind(DataView.prototype.setUint8),
      CD: x0 => x0.screen,
      CE: (o, p) => p in o,
      CF: x0 => x0.key,
      CG: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      CH: x0 => x0.Segmenter,
      CI: x0 => x0.selectionStart,
      CJ: x0 => x0.cancel(),
      CK: x0 => x0.playbackRate,
      CL: x0 => x0.getSelection(),
      CM: x0 => ({type: x0}),
      CN: x0 => x0.id,
      CO: x0 => x0.document,
      CP: x0 => x0.done,
      D: Function.prototype.call.bind(BigInt.prototype.toString),
      DB: (x0,x1) => x0.focus(x1),
      DC: Function.prototype.call.bind(DataView.prototype.setInt8),
      DD: o => {
        if (o === null || o === undefined) return 0;
        if (typeof(o) === 'string') return 1;
        return 2;
      },
      DE: (x0,x1) => { x0.textContent = x1 },
      DF: x0 => x0.identifier,
      DG: (x0,x1) => { x0.onerror = x1 },
      DH: x0 => x0.buffer,
      DI: x0 => x0.selectionEnd,
      DJ: x0 => x0.body,
      DK: x0 => x0.volume,
      DL: x0 => x0.removeAllRanges(),
      DM: (x0,x1) => new Blob(x0,x1),
      DN: x0 => x0.offsetHeight,
      DO: (x0,x1) => x0.getRandomValues(x1),
      DP: x0 => x0.read(),
      E: (exn) => {
        let stackString = exn.toString();
        let frames = stackString.split('\n');
        let drop = 4;
        if (frames[0].startsWith('Error')) {
            drop += 1;
        }
        return frames.slice(drop).join('\n');
      },
      EB: () => ({}),
      EC: Function.prototype.call.bind(DataView.prototype.getInt8),
      ED: x0 => x0.tabIndex,
      EE: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      EF: x0 => x0.touches,
      EG: x0 => x0.error,
      EH: x0 => x0.wasmMemory,
      EI: (x0,x1) => { x0.name = x1 },
      EJ: x0 => x0.headers,
      EK: (x0,x1) => x0.end(x1),
      EL: (x0,x1) => x0.addRange(x1),
      EM: x0 => globalThis.createImageBitmap(x0),
      EN: x0 => x0.offsetWidth,
      EO: (x0,x1,x2,x3) => x0.encrypt(x1,x2,x3),
      EP: x0 => x0.body,
      F: () => new Error().stack,
      FB: (o, p, v) => o[p] = v,
      FC: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Int8Array) return 1;
        return 2;
      },
      FD: (x0,x1) => x0.contains(x1),
      FE: x0 => x0.matches,
      FF: x0 => x0.pressure,
      FG: (x0,x1) => { x0.onsuccess = x1 },
      FH: () => globalThis.window._flutter_skwasmInstance,
      FI: (x0,x1) => { x0.placeholder = x1 },
      FJ: x0 => x0.signal,
      FK: x0 => x0.length,
      FL: () => globalThis.window,
      FM: (x0,x1) => new OffscreenCanvas(x0,x1),
      FN: x0 => x0.stopPropagation(),
      FO: x0 => x0.sessionStorage,
      FP: (x0,x1) => new OffscreenCanvas(x0,x1),
      G: s => JSON.stringify(s),
      GB: () => [],
      GC: (o, start, length) => new Float64Array(o.buffer, o.byteOffset + start, length),
      GD: x0 => x0.activeElement,
      GE: (x0,x1) => x0.matchMedia(x1),
      GF: x0 => x0.tiltY,
      GG: x0 => x0.continue(),
      GH: () => new TextDecoder(),
      GI: (x0,x1) => { x0.autocomplete = x1 },
      GJ: () => {
        return typeof process != "undefined" &&
               Object.prototype.toString.call(process) == "[object process]" &&
               process.platform == "win32"
      },
      GK: x0 => x0.buffered,
      GL: (x0,x1) => { x0.innerText = x1 },
      GM: (x0,x1) => x0.getContext(x1),
      GN: x0 => x0.disabled,
      GO: x0 => x0.subtle,
      GP: x0 => x0.assetBase,
      H: Function.prototype.call.bind(Number.prototype.toString),
      HB: (a, i) => a.push(i),
      HC: (o, start, length) => new Float32Array(o.buffer, o.byteOffset + start, length),
      HD: x0 => x0.parentNode,
      HE: x0 => x0.matches,
      HF: x0 => x0.tiltX,
      HG: x0 => x0.result,
      HH: (map, o, v) => map.set(o, v),
      HI: (x0,x1) => { x0.type = x1 },
      HJ: () => {
        // On browsers return `globalThis.location.href`
        if (globalThis.location != null) {
          return globalThis.location.href;
        }
        return null;
      },
      HK: x0 => x0.duration,
      HL: x0 => x0.offsetY,
      HM: (x0,x1,x2,x3) => x0.drawImage(x1,x2,x3),
      HN: (x0,x1) => { x0.min = x1 },
      HO: (x0,x1,x2,x3,x4,x5,x6,x7) => x0.unwrapKey(x1,x2,x3,x4,x5,x6,x7),
      HP: x0 => x0.loader,
      I: Function.prototype.call.bind(String.prototype.indexOf),
      IB: x0 => new Int8Array(x0),
      IC: (o, start, length) => new Uint32Array(o.buffer, o.byteOffset + start, length),
      ID: x0 => x0.tagName,
      IE: o => typeof o === 'function' && o[jsWrappedDartFunctionSymbol] === true,
      IF: x0 => x0.pointerType,
      IG: x0 => x0.target,
      IH: (map, o) => map.get(o),
      II: (x0,x1) => { x0.name = x1 },
      IJ: x0 => new WeakRef(x0),
      IK: () => new Hls(),
      IL: x0 => x0.offsetX,
      IM: (x0,x1,x2,x3,x4) => x0.getImageData(x1,x2,x3,x4),
      IN: (x0,x1) => { x0.max = x1 },
      IO: (x0,x1,x2,x3,x4,x5) => x0.importKey(x1,x2,x3,x4,x5),
      IP: () => globalThis._flutter,
      J: (s, p, i) => s.lastIndexOf(p, i),
      JB: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI8ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      JC: (o, start, length) => new Int32Array(o.buffer, o.byteOffset + start, length),
      JD: x0 => x0.target,
      JE: f => f.dartFunction,
      JF: x0 => x0.pointerId,
      JG: (x0,x1) => x0.getAllKeys(x1),
      JH: () => new WeakMap(),
      JI: (x0,x1) => { x0.placeholder = x1 },
      JJ: x0 => x0.deref(),
      JK: (x0,x1) => x0.loadSource(x1),
      JL: x0 => x0.button,
      JM: x0 => x0.close(),
      JN: (x0,x1) => { x0.disabled = x1 },
      JO: (x0,x1,x2,x3) => x0.generateKey(x1,x2,x3),
      K: o => o,
      KB: x0 => new Uint8Array(x0),
      KC: (o, start, length) => new Uint16Array(o.buffer, o.byteOffset + start, length),
      KD: x0 => x0.clientY,
      KE: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      KF: x0 => x0.getCoalescedEvents(),
      KG: x0 => x0.key,
      KH: Function.prototype.call.bind(DataView.prototype.getBigInt64),
      KI: (x0,x1) => { x0.scrollTop = x1 },
      KJ: () => globalThis.WeakRef,
      KK: (x0,x1) => x0.attachMedia(x1),
      KL: x0 => x0.classList,
      KM: x0 => x0.data,
      KN: (x0,x1) => { x0.scrollLeft = x1 },
      KO: (x0,x1,x2,x3,x4) => x0.wrapKey(x1,x2,x3,x4),
      L: o => {
        if (o === undefined || o === null) return 0;
        if (typeof o === 'number') return 1;
        return 2;
      },
      LB: x0 => new Uint8ClampedArray(x0),
      LC: (o, start, length) => new Int16Array(o.buffer, o.byteOffset + start, length),
      LD: x0 => x0.clientX,
      LE: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1) { return wasmFunction(f,arguments.length,x0,x1) }),
      LF: s => s.trimLeft(),
      LG: (o, t) => typeof o === t,
      LH: Function.prototype.call.bind(DataView.prototype.setBigInt64),
      LI: (x0,x1,x2) => x0.setSelectionRange(x1,x2),
      LJ: () => new XMLHttpRequest(),
      LK: x0 => x0.message,
      LL: (x0,x1) => { x0.height = x1 },
      LM: x0 => x0.height,
      LN: (x0,x1) => { x0.spellcheck = x1 },
      LO: (x0,x1,x2) => x0.exportKey(x1,x2),
      M: x0 => x0.index,
      MB: x0 => new Int16Array(x0),
      MC: (o, start, length) => new Uint8ClampedArray(o.buffer, o.byteOffset + start, length),
      MD: (x0,x1,x2) => x0.addEventListener(x1,x2),
      ME: (p, s, f) => p.then(s, (e) => f(e, e === undefined)),
      MF: s => s.toUpperCase(),
      MG: x0 => x0.close(),
      MH: (o, start, length) => new BigInt64Array(o.buffer, o.byteOffset + start, length),
      MI: (x0,x1,x2) => x0.setSelectionRange(x1,x2),
      MJ: (x0,x1,x2) => x0.open(x1,x2),
      MK: (x0,x1) => { x0.src = x1 },
      ML: (x0,x1) => { x0.width = x1 },
      MM: x0 => x0.width,
      MN: (x0,x1) => { x0.disabled = x1 },
      MO: x0 => x0.crypto,
      N: o => String(o),
      NB: x0 => new Uint16Array(x0),
      NC: (o, start, length) => new Uint8Array(o.buffer, o.byteOffset + start, length),
      ND: (x0,x1,x2) => x0.setAttribute(x1,x2),
      NE: (o, i) => o[i],
      NF: x0 => x0.pop(),
      NG: x0 => x0.clear(),
      NH: (a, i) => a.splice(i, 1),
      NI: s => {
        if (/[[\]{}()*+?.\\^$|]/.test(s)) {
            s = s.replace(/[[\]{}()*+?.\\^$|]/g, '\\$&');
        }
        return s;
      },
      NJ: (x0,x1) => x0.send(x1),
      NK: (x0,x1) => x0.canPlayType(x1),
      NL: x0 => x0.style,
      NM: x0 => x0.abort(),
      NN: (x0,x1,x2,x3,x4,x5,x6,x7,x8,x9) => x0.drawImage(x1,x2,x3,x4,x5,x6,x7,x8,x9),
      NO: x0 => x0.isSecureContext,
      O: o => o === undefined,
      OB: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI16ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      OC: (o, start, length) => new Int8Array(o.buffer, o.byteOffset + start, length),
      OD: (x0,x1) => x0.closest(x1),
      OE: o => o.length,
      OF: x0 => x0.flags,
      OG: (x0,x1) => x0.delete(x1),
      OH: a => a.pop(),
      OI: x0 => x0.keyCode,
      OJ: x0 => x0.send(),
      OK: () => globalThis.Hls.isSupported(),
      OL: x0 => x0.sheet,
      OM: (x0,x1) => { x0.playbackRate = x1 },
      ON: (x0,x1) => x0.getContext(x1),
      OO: (x0,x1,x2,x3) => x0.decrypt(x1,x2,x3),
      P: (x0,x1) => x0.exec(x1),
      PB: x0 => new Int32Array(x0),
      PC: (x0,x1) => x0.querySelector(x1),
      PD: (ms, c) =>
      setTimeout(() => dartInstance.exports.$invokeCallback(c),ms),
      PE: o => {
        if (o === undefined) return 1;
        var type = typeof o;
        if (type === 'boolean') return 2;
        if (type === 'number') return 3;
        if (type === 'string') return 4;
        if (o instanceof Array) return 5;
        if (ArrayBuffer.isView(o)) {
          if (o instanceof Int8Array) return 6;
          if (o instanceof Uint8Array) return 7;
          if (o instanceof Uint8ClampedArray) return 8;
          if (o instanceof Int16Array) return 9;
          if (o instanceof Uint16Array) return 10;
          if (o instanceof Int32Array) return 11;
          if (o instanceof Uint32Array) return 12;
          if (o instanceof Float32Array) return 13;
          if (o instanceof Float64Array) return 14;
          if (o instanceof DataView) return 15;
        }
        if (o instanceof ArrayBuffer) return 16;
        // Feature check for `SharedArrayBuffer` before doing a type-check.
        if (globalThis.SharedArrayBuffer !== undefined &&
            o instanceof SharedArrayBuffer) {
            return 17;
        }
        if (o instanceof Promise) return 18;
        return 19;
      },
      PF: (a, s) => a.join(s),
      PG: (x0,x1,x2) => x0.put(x1,x2),
      PH: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmF32ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      PI: (x0,x1) => x0.scrollIntoView(x1),
      PJ: x0 => x0.abort(),
      PK: x0 => x0.userAgent,
      PL: x0 => x0.head,
      PM: x0 => new Blob(x0),
      PN: (x0,x1) => { x0.height = x1 },
      PO: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      Q: (x0,x1) => { x0.lastIndex = x1 },
      QB: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI32ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      QC: (x0,x1) => x0.item(x1),
      QD: (handle) => clearTimeout(handle),
      QE: x0 => x0.language,
      QF: (x0,x1) => x0.error(x1),
      QG: (x0,x1) => x0.createObjectStore(x1),
      QH: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmF64ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      QI: x0 => x0.multiViewEnabled,
      QJ: x0 => x0.readyState,
      QK: x0 => x0.navigator,
      QL: () => globalThis.document,
      QM: x0 => ({type: x0}),
      QN: (x0,x1) => { x0.width = x1 },
      QO: (x0,x1,x2) => x0.addEventListener(x1,x2),
      R: o => o,
      RB: x0 => new Uint32Array(x0),
      RC: x0 => x0.length,
      RD: x0 => x0.maxTouchPoints,
      RE: (x0,x1,x2,x3) => x0.register(x1,x2,x3),
      RF: () => globalThis.console,
      RG: x0 => x0.version,
      RH: x0 => x0.debugSkipFontRetryDelay,
      RI: (x0,x1) => x0.replaceWith(x1),
      RJ: x0 => x0.total,
      RK: (x0,x1) => { x0.innerHTML = x1 },
      RL: x0 => x0.exitFullscreen(),
      RM: (x0,x1) => new Blob(x0,x1),
      RN: (x0,x1) => x0.transferFromImageBitmap(x1),
      RO: x0 => x0.message,
      S: (s, m) => {
        try {
          return new RegExp(s, m);
        } catch (e) {
          return String(e);
        }
      },
      SB: x0 => new Float32Array(x0),
      SC: (x0,x1) => x0.querySelectorAll(x1),
      SD: x0 => x0.platform,
      SE: () => globalThis.window.FinalizationRegistry,
      SF: s => s.trimRight(),
      SG: x0 => x0.objectStoreNames,
      SH: x0 => x0.status,
      SI: (x0,x1) => { x0.className = x1 },
      SJ: x0 => x0.loaded,
      SK: x0 => x0.currentTime,
      SL: x0 => x0.requestFullscreen(),
      SM: (x0,x1) => x0.appendChild(x1),
      SN: x0 => x0.rasterEndMilliseconds,
      SO: x0 => x0.lastModified,
      T: o => o instanceof RegExp,
      TB: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmF32ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      TC: (x0,x1) => x0.getAttribute(x1),
      TD: s => new Date(s * 1000).getTimezoneOffset() * 60,
      TE: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      TF: x0 => x0.blur(),
      TG: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      TH: (x0,x1,x2) => x0.set(x1,x2),
      TI: (x0,x1) => { x0.tabIndex = x1 },
      TJ: x0 => x0.upload,
      TK: (o, p, v) => o[p] = v,
      TL: x0 => x0.documentElement,
      TM: x0 => globalThis.URL.revokeObjectURL(x0),
      TN: x0 => x0.rasterStartMilliseconds,
      TO: x0 => x0.size,
      U: (string, times) => string.repeat(times),
      UB: x0 => new Float64Array(x0),
      UC: x0 => x0.remove(),
      UD: Date.now,
      UE: x0 => new window.FinalizationRegistry(x0),
      UF: x0 => x0.button,
      UG: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      UH: x0 => x0.arrayBuffer(),
      UI: (x0,x1) => { x0.action = x1 },
      UJ: x0 => x0.responseURL,
      UK: (x0,x1) => { x0.border = x1 },
      UL: x0 => x0.paused,
      UM: x0 => x0.click(),
      UN: x0 => x0.imageBitmaps,
      UO: x0 => x0.name,
      V: o => o,
      VB: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmF64ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      VC: (x0,x1) => x0.appendChild(x1),
      VD: (x0,x1) => x0.contains(x1),
      VE: (x0,x1) => x0.unregister(x1),
      VF: (x0,x1) => x0.prepend(x1),
      VG: (x0,x1) => { x0.onupgradeneeded = x1 },
      VH: (x0,x1) => x0.fetch(x1),
      VI: (x0,x1) => { x0.method = x1 },
      VJ: x0 => x0.statusText,
      VK: (x0,x1) => { x0.height = x1 },
      VL: x0 => x0.naturalHeight,
      VM: x0 => x0.body,
      VN: x0 => x0.canvasKitMaximumSurfaces,
      VO: x0 => x0.type,
      W: o => {
        if (o === undefined || o === null) return 0;
        if (typeof o === 'boolean') return 1;
        return 2;
      },
      WB: x0 => new ArrayBuffer(x0),
      WC: (x0,x1) => x0.append(x1),
      WD: (decoder, codeUnits) => decoder.decode(codeUnits),
      WE: x0 => x0.preventDefault(),
      WF: x0 => x0.parentElement,
      WG: x0 => x0.indexedDB,
      WH: x0 => x0.fontFallbackBaseUrl,
      WI: (x0,x1) => { x0.noValidate = x1 },
      WJ: x0 => x0.getAllResponseHeaders(),
      WK: (x0,x1) => { x0.width = x1 },
      WL: x0 => x0.naturalWidth,
      WM: (x0,x1) => { x0.download = x1 },
      WN: x0 => x0.nextSibling,
      WO: (x0,x1) => x0.item(x1),
      X: x0 => x0.dotAll,
      XB: (x0,x1,x2) => new Uint8Array(x0,x1,x2),
      XC: (x0,x1,x2,x3) => x0.setProperty(x1,x2,x3),
      XD: () => new TextDecoder("utf-8", {fatal: true}),
      XE: x0 => x0.parent,
      XF: x0 => x0.innerHeight,
      XG: x0 => x0.self,
      XH: (handle) => clearInterval(handle),
      XI: x0 => x0.click(),
      XJ: x0 => x0.status,
      XK: x0 => x0.style,
      XL: (x0,x1) => { x0.pointerEvents = x1 },
      XM: (x0,x1) => { x0.href = x1 },
      XN: (x0,x1) => x0.debug(x1),
      XO: x0 => x0.length,
      Y: x0 => x0.unicode,
      YB: (x0,x1,x2) => new DataView(x0,x1,x2),
      YC: x0 => x0.style,
      YD: () => new TextDecoder("utf-8", {fatal: false}),
      YE: x0 => x0.timeStamp,
      YF: x0 => x0.innerWidth,
      YG: () => globalThis.window,
      YH: (ms, c) =>
      setInterval(() => dartInstance.exports.$invokeCallback(c), ms),
      YI: (x0,x1) => x0.getElementsByClassName(x1),
      YJ: x0 => x0.response,
      YK: (x0,x1) => { x0.muted = x1 },
      YL: (x0,x1) => { x0.src = x1 },
      YM: x0 => globalThis.URL.createObjectURL(x0),
      YN: x0 => x0.hostElement,
      YO: x0 => x0.files,
      Z: x0 => x0.ignoreCase,
      ZB: (o, p) => o[p],
      ZC: x0 => x0.debugShowSemanticsNodes,
      ZD: (a, i, v) => a[i] = v,
      ZE: (x0,x1) => x0.hasAttribute(x1),
      ZF: x0 => x0.height,
      ZG: (x0,x1) => x0.getRandomValues(x1),
      ZH: () => Date.now(),
      ZI: (x0,x1) => x0.dispatchEvent(x1),
      ZJ: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
      ZK: (x0,x1) => { x0.controls = x1 },
      ZL: x0 => x0.src,
      ZM: (o, p) => p in o,
      ZN: x0 => x0.location,
      ZO: (x0,x1) => { x0.multiple = x1 },
      a: x0 => x0.multiline,
      aB: (o) => new DataView(o.buffer, o.byteOffset, o.byteLength),
      aC: (x0,x1) => x0.warn(x1),
      aD: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI8ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      aE: x0 => x0.type,
      aF: x0 => x0.width,
      aG: () => globalThis.crypto,
      aH: (x0,x1,x2,x3) => x0.pushState(x1,x2,x3),
      aI: (x0,x1) => x0.createEvent(x1),
      aJ: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      aK: x0 => x0.text,
      aL: x0 => x0.close(),
      aM: x0 => x0.groups,
      aN: (x0,x1) => x0.getModifierState(x1),
      aO: (x0,x1) => { x0.accept = x1 },
      b: (exn) => {
        if (exn instanceof Error) {
          return exn.stack;
        } else {
          return null;
        }
      },
      bB: Function.prototype.call.bind(Object.getOwnPropertyDescriptor(DataView.prototype, 'byteLength').get),
      bC: x0 => x0.console,
      bD: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI16ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      bE: (x0,x1) => x0.getModifierState(x1),
      bF: x0 => x0.clientHeight,
      bG: l => new DataView(new ArrayBuffer(l)),
      bH: x0 => x0.history,
      bI: (x0,x1,x2,x3) => x0.initEvent(x1,x2,x3),
      bJ: (x0,x1,x2,x3) => x0.removeEventListener(x1,x2,x3),
      bK: (x0,x1) => x0[x1],
      bL: x0 => x0.height,
      bM: x0 => x0.decode(),
      bN: x0 => x0.metaKey,
      bO: (x0,x1) => { x0.type = x1 },
      c: (c) =>
      queueMicrotask(() => dartInstance.exports.$invokeCallback(c)),
      cB: o => o.byteOffset,
      cC: () => globalThis.window,
      cD: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI32ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      cE: x0 => x0.buttons,
      cF: x0 => x0.clientWidth,
      cG: () => typeof dartUseDateNowForTicks !== "undefined",
      cH: x0 => x0.search,
      cI: x0 => x0.readText(),
      cJ: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      cK: x0 => x0.length,
      cL: x0 => x0.width,
      cM: (x0,x1,x2,x3) => x0.open(x1,x2,x3),
      cN: x0 => x0.altKey,
      cO: (x0,x1) => x0.querySelector(x1),
      d: (x0,x1) => x0.didCreateEngineInitializer(x1),
      dB: o => o.buffer,
      dC: (o, c) => o instanceof c,
      dD: (s) => +s,
      dE: x0 => x0.ctrlKey,
      dF: x0 => x0.isConnected,
      dG: () => Date.now(),
      dH: x0 => x0.location,
      dI: x0 => x0.clipboard,
      dJ: x0 => x0.withCredentials,
      dK: x0 => x0.activeCues,
      dL: (x0,x1,x2,x3,x4,x5) => x0.createImageBitmap(x1,x2,x3,x4,x5),
      dM: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      dN: x0 => x0.ctrlKey,
      dO: (x0,x1) => ({src: x0,sizes: x1}),
      e: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      eB: Function.prototype.call.bind(DataView.prototype.getUint8),
      eC: (x0,x1) => x0[x1],
      eD: s => {
        if (!/^\s*[+-]?(?:Infinity|NaN|(?:\.\d+|\d+(?:\.\d*)?)(?:[eE][+-]?\d+)?)\s*$/.test(s)) {
          return NaN;
        }
        return parseFloat(s);
      },
      eE: x0 => x0.getBoundingClientRect(),
      eF: x0 => x0.head,
      eG: () => 1000 * performance.now(),
      eH: x0 => x0.pathname,
      eI: (x0,x1) => x0.writeText(x1),
      eJ: (x0,x1) => { x0.timeout = x1 },
      eK: (x0,x1) => { x0.mode = x1 },
      eL: (x0,x1,x2) => x0.createImageBitmap(x1,x2),
      eM: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      eN: x0 => x0.isComposing,
      eO: (x0,x1,x2,x3) => ({title: x0,artist: x1,album: x2,artwork: x3}),
      f: (wasmFunction,f) => finalizeWrapper(f, function() { return wasmFunction(f,arguments.length) }),
      fB: (b, o) => new DataView(b, o),
      fC: x0 => x0.length,
      fD: s => s.trim(),
      fE: x0 => x0.y,
      fF: (x0,x1) => { x0.content = x1 },
      fG: (x0,x1) => x0.requestAnimationFrame(x1),
      fH: (x0,x1,x2,x3) => x0.replaceState(x1,x2,x3),
      fI: x0 => x0.unlock(),
      fJ: (x0,x1,x2) => x0.setRequestHeader(x1,x2),
      fK: x0 => x0.track,
      fL: (x0,x1) => x0.createImageBitmap(x1),
      fM: x0 => x0.send(),
      fN: x0 => x0.code,
      fO: x0 => new MediaMetadata(x0),
      g: (x0,x1) => ({initializeEngine: x0,autoStart: x1}),
      gB: (b, o, l) => new DataView(b, o, l),
      gC: (string, token) => string.split(token),
      gD: x0 => x0.classList,
      gE: x0 => x0.x,
      gF: (x0,x1) => { x0.name = x1 },
      gG: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      gH: x0 => x0.state,
      gI: (x0,x1) => x0.lock(x1),
      gJ: (x0,x1) => { x0.withCredentials = x1 },
      gK: (x0,x1) => { x0.srclang = x1 },
      gL: x0 => new Blob(x0),
      gM: x0 => x0.status,
      gN: x0 => x0.repeat,
      gO: (x0,x1) => { x0.metadata = x1 },
      h: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1) { return wasmFunction(f,arguments.length,x0,x1) }),
      hB: Function.prototype.call.bind(DataView.prototype.getFloat64),
      hC: o => o instanceof Array,
      hD: x0 => x0.relatedTarget,
      hE: x0 => x0.top,
      hF: (x0,x1) => x0.removeChild(x1),
      hG: x0 => x0.now(),
      hH: x0 => x0.hash,
      hI: x0 => x0.orientation,
      hJ: (x0,x1) => { x0.responseType = x1 },
      hK: (x0,x1) => { x0.label = x1 },
      hL: x0 => x0.close(),
      hM: x0 => x0.response,
      hN: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      hO: x0 => x0.mediaSession,
      i: x0 => new Promise(x0),
      iB: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Float64Array) return 1;
        return 2;
      },
      iC: (a, i) => a[i],
      iD: x0 => x0.hasFocus(),
      iE: x0 => x0.left,
      iF: x0 => x0.firstChild,
      iG: x0 => x0.performance,
      iH: x0 => x0.state,
      iI: (x0,x1) => x0.querySelector(x1),
      iJ: o => o.byteLength,
      iK: (x0,x1) => { x0.kind = x1 },
      iL: x0 => x0.naturalHeight,
      iM: (x0,x1,x2) => x0.setRequestHeader(x1,x2),
      iN: x0 => globalThis.Wakelock.toggle(x0),
      iO: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      j: (x0,x1,x2) => x0.call(x1,x2),
      jB: Function.prototype.call.bind(DataView.prototype.setFloat64),
      jC: a => a.length,
      jD: x0 => x0.shiftKey,
      jE: x0 => x0.scrollTop,
      jF: x0 => x0.viewConstraints,
      jG: x0 => new Uint8Array(x0),
      jH: (x0,x1) => x0.go(x1),
      jI: (x0,x1) => { x0.title = x1 },
      jJ: (x0,x1,x2) => x0.register(x1,x2),
      jK: (x0,x1) => { x0.src = x1 },
      jL: x0 => x0.naturalWidth,
      jM: (x0,x1) => { x0.responseType = x1 },
      jN: x0 => x0.id,
      jO: (x0,x1,x2) => x0.setActionHandler(x1,x2),
      k: (constructor, args) => {
        const factoryFunction = constructor.bind.apply(
            constructor, [null, ...args]);
        return new factoryFunction();
      },
      kB: (t, s) => t.set(s),
      kC: (x0,x1) => x0.test(x1),
      kD: x0 => x0.body,
      kE: x0 => x0.offsetTop,
      kF: x0 => x0.hostElement,
      kG: (x0,x1,x2) => x0.slice(x1,x2),
      kH: (x0,x1) => x0.querySelectorAll(x1),
      kI: (x0,x1) => x0.vibrate(x1),
      kJ: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      kK: (x0,x1) => x0.querySelector(x1),
      kL: (x0,x1) => { x0.src = x1 },
      kM: () => new XMLHttpRequest(),
      kN: (x0,x1) => { x0.id = x1 },
      kO: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      l: x0 => new Array(x0),
      lB: Function.prototype.call.bind(DataView.prototype.setFloat32),
      lC: x0 => x0.userAgent,
      lD: x0 => x0.visibilityState,
      lE: x0 => x0.scrollLeft,
      lF: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      lG: (x0,x1) => x0.decode(x1),
      lH: (d, digits) => d.toFixed(digits),
      lI: x0 => x0.content,
      lJ: x0 => new FinalizationRegistry(x0),
      lK: x0 => x0.remove(),
      lL: x0 => x0.displayHeight,
      lM: x0 => x0.requestFullscreen(),
      lN: (x0,x1) => x0.canShare(x1),
      lO: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      m: o => [o],
      mB: Function.prototype.call.bind(DataView.prototype.getFloat32),
      mC: x0 => x0.navigator,
      mD: (x0,x1,x2) => x0.removeEventListener(x1,x2),
      mE: x0 => x0.offsetLeft,
      mF: x0 => ({runApp: x0}),
      mG: (x0,x1) => x0.adoptText(x1),
      mH: x0 => x0.maxHeight,
      mI: x0 => x0.document,
      mJ: () => globalThis.FinalizationRegistry,
      mK: (x0,x1) => { x0.volume = x1 },
      mL: x0 => x0.displayWidth,
      mM: x0 => x0.documentElement,
      mN: (x0,x1) => x0.share(x1),
      mO: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      n: (o0, o1) => [o0, o1],
      nB: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Float32Array) return 1;
        return 2;
      },
      nC: Function.prototype.call.bind(String.prototype.toLowerCase),
      nD: x0 => x0.disconnect(),
      nE: x0 => x0.offsetParent,
      nF: (x0,x1,x2) => x0.open(x1,x2),
      nG: x0 => x0.first(),
      nH: x0 => x0.maxWidth,
      nI: (a, s, e) => a.slice(s, e),
      nJ: x0 => x0.videoHeight,
      nK: x0 => x0.muted,
      nL: x0 => x0.duration,
      nM: () => globalThis.document,
      nN: (x0,x1,x2,x3) => x0.open(x1,x2,x3),
      nO: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      o: (o0, o1, o2) => [o0, o1, o2],
      oB: Function.prototype.call.bind(DataView.prototype.getUint32),
      oC: Object.is,
      oD: x0 => new Intl.Locale(x0),
      oE: x0 => x0.offsetY,
      oF: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      oG: x0 => x0.next(),
      oH: x0 => x0.minHeight,
      oI: () => new AbortController(),
      oJ: x0 => x0.videoWidth,
      oK: x0 => x0.play(),
      oL: (x0,x1) => ({frameIndex: x0,completeFramesOnly: x1}),
      oM: x0 => x0.exitFullscreen(),
      oN: (o, a) => o + a,
      oO: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      p: (o0, o1, o2, o3) => [o0, o1, o2, o3],
      pB: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Uint32Array) return 1;
        return 2;
      },
      pC: x0 => x0.vendor,
      pD: x0 => x0.region,
      pE: x0 => x0.offsetX,
      pF: (x0,x1) => x0.contains(x1),
      pG: x0 => x0.current(),
      pH: x0 => x0.minWidth,
      pI: (x0,x1,x2,x3,x4,x5) => ({method: x0,headers: x1,body: x2,credentials: x3,redirect: x4,signal: x5}),
      pJ: (x0,x1,x2) => x0.setAttribute(x1,x2),
      pK: x0 => x0.load(),
      pL: (x0,x1) => x0.decode(x1),
      pM: x0 => x0.fullscreenElement,
      pN: x0 => x0.children,
      pO: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      q: (x0,x1,x2) => { x0[x1] = x2 },
      qB: Function.prototype.call.bind(DataView.prototype.getInt32),
      qC: (x0,x1) => x0.createTextNode(x1),
      qD: x0 => x0.script,
      qE: (o, p, r) => o.replace(p, () => r),
      qF: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      qG: (x0,x1) => new Intl.v8BreakIterator(x0,x1),
      qH: (x0,x1) => x0.removeProperty(x1),
      qI: (x0,x1) => globalThis.fetch(x0,x1),
      qJ: x0 => x0.pause(),
      qK: (o, p) => delete o[p],
      qL: x0 => x0.image,
      qM: (x0,x1) => x0.deleteDatabase(x1),
      qN: (x0,x1) => { x0.display = x1 },
      qO: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      r: (o, p) => o[p],
      rB: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Int32Array) return 1;
        return 2;
      },
      rC: (x0,x1) => { x0.id = x1 },
      rD: x0 => x0.language,
      rE: (o, p, r) => o.replaceAll(p, () => r),
      rF: (x0,x1) => x0.get(x1),
      rG: x0 => x0.v8BreakIterator,
      rH: (x0,x1) => x0.add(x1),
      rI: (x0,x1) => x0.get(x1),
      rJ: (x0,x1) => x0.append(x1),
      rK: (x0,x1) => { x0.currentTime = x1 },
      rL: x0 => x0.close(),
      rM: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      rN: x0 => ({files: x0}),
      rO: (x0,x1,x2) => ({duration: x0,playbackRate: x1,position: x2}),
      s: () => globalThis,
      sB: o => o instanceof Uint16Array,
      sC: (x0,x1) => { x0.nonce = x1 },
      sD: x0 => x0.languages,
      sE: x0 => x0.deltaMode,
      sF: o => {
        const proto = Object.getPrototypeOf(o);
        return proto === Object.prototype || proto === null;
      },
      sG: () => globalThis.Intl,
      sH: x0 => x0.data,
      sI: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1,x2) { return wasmFunction(f,arguments.length,x0,x1,x2) }),
      sJ: (x0,x1) => x0.append(x1),
      sK: (a, l) => a.length = l,
      sL: (x0,x1,x2,x3,x4) => ({type: x0,data: x1,premultiplyAlpha: x2,colorSpaceConversion: x3,preferAnimation: x4}),
      sM: (x0,x1) => x0.deleteObjectStore(x1),
      sN: () => ({}),
      sO: (x0,x1) => x0.setPositionState(x1),
      t: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      tB: Function.prototype.call.bind(DataView.prototype.getUint16),
      tC: x0 => x0.nonce,
      tD: (x0,x1) => x0.observe(x1),
      tE: x0 => x0.deltaY,
      tF: o => Object.keys(o),
      tG: (x0,x1) => x0.segment(x1),
      tH: (x0,x1) => x0.removeAttribute(x1),
      tI: (x0,x1) => x0.forEach(x1),
      tJ: (x0,x1) => x0.createElement(x1),
      tK: (x0,x1) => x0.createElement(x1),
      tL: x0 => new window.ImageDecoder(x0),
      tM: x0 => x0.length,
      tN: (x0,x1,x2) => new File(x0,x1,x2),
      tO: x0 => x0.seekTime,
      u: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      uB: o => o instanceof Int16Array,
      uC: () => globalThis.window.flutterConfiguration,
      uD: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1) { return wasmFunction(f,arguments.length,x0,x1) }),
      uE: x0 => x0.deltaX,
      uF: (o, offsetInBytes, lengthInBytes) => {
        var dst = new ArrayBuffer(lengthInBytes);
        new Uint8Array(dst).set(new Uint8Array(o, offsetInBytes, lengthInBytes));
        return new DataView(dst);
      },
      uG: x0 => x0.index,
      uH: (x0,x1) => { x0.value = x1 },
      uI: x0 => x0.name,
      uJ: x0 => x0.head,
      uK: (x0,x1) => x0.append(x1),
      uL: x0 => x0.name,
      uM: x0 => x0.name,
      uN: (x0,x1) => { x0.type = x1 },
      uO: (x0,x1) => { x0.playbackState = x1 },
      v: (x0,x1) => ({addView: x0,removeView: x1}),
      vB: Function.prototype.call.bind(DataView.prototype.getInt16),
      vC: (x0,x1) => x0.attachShadow(x1),
      vD: x0 => new ResizeObserver(x0),
      vE: x0 => x0.wheelDeltaY,
      vF: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof ArrayBuffer) return 1;
        if (globalThis.SharedArrayBuffer !== undefined &&
            o instanceof SharedArrayBuffer) {
          return 2;
        }
        return 3;
      },
      vG: x0 => x0.next(),
      vH: (x0,x1) => { x0.value = x1 },
      vI: x0 => x0.statusText,
      vJ: () => globalThis.document,
      vK: (x0,x1,x2) => x0.insertRule(x1,x2),
      vL: x0 => x0.repetitionCount,
      vM: () => new FileReader(),
      vN: (x0,x1) => x0.getItem(x1),
      vO: x0 => x0.extraAssets,
      w: (l, r) => l === r,
      wB: o => o instanceof Uint8ClampedArray,
      wC: (x0,x1) => x0.createElement(x1),
      wD: (x0,x1) => x0.getPropertyValue(x1),
      wE: x0 => x0.wheelDeltaX,
      wF: (x0,x1,x2) => x0.transaction(x1,x2),
      wG: x0 => x0.value,
      wH: x0 => x0.value,
      wI: x0 => x0.url,
      wJ: (x0,x1) => { x0.src = x1 },
      wK: (x0,x1) => x0.add(x1),
      wL: x0 => x0.frameCount,
      wM: (x0,x1) => x0.readAsArrayBuffer(x1),
      wN: x0 => x0.localStorage,
      wO: x0 => x0.fontManifest,
      x: x0 => x0.random(),
      xB: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Uint8Array) return 1;
        return 2;
      },
      xC: x0 => x0.scale,
      xD: x0 => globalThis.parseFloat(x0),
      xE: x0 => x0.bottom,
      xF: (x0,x1) => x0.objectStore(x1),
      xG: x0 => x0.done,
      xH: x0 => x0.selectionDirection,
      xI: x0 => x0.status,
      xJ: (x0,x1) => { x0.type = x1 },
      xK: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      xL: x0 => x0.selectedTrack,
      xM: x0 => x0.result,
      xN: (x0,x1) => x0.key(x1),
      xO: x0 => x0.assetManifest,
      y: () => globalThis.Math,
      yB: Function.prototype.call.bind(DataView.prototype.setInt32),
      yC: x0 => x0.visualViewport,
      yD: (x0,x1) => x0.getComputedStyle(x1),
      yE: x0 => x0.right,
      yF: (x0,x1) => x0.getAll(x1),
      yG: (o, m, a) => o[m].apply(o, a),
      yH: x0 => x0.selectionStart,
      yI: x0 => x0.getReader(),
      yJ: (x0,x1) => { x0.charset = x1 },
      yK: (x0,x1,x2) => x0.addEventListener(x1,x2),
      yL: x0 => x0.completed,
      yM: (x0,x1,x2,x3) => x0.open(x1,x2,x3),
      yN: x0 => x0.length,
      yO: x0 => x0.buildConfig,
      z: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
      zB: Function.prototype.call.bind(DataView.prototype.setUint32),
      zC: x0 => x0.devicePixelRatio,
      zD: x0 => x0.documentElement,
      zE: x0 => x0.clientY,
      zF: x0 => x0.value,
      zG: x0 => x0.iterator,
      zH: x0 => x0.selectionEnd,
      zI: x0 => x0.read(),
      zJ: (x0,x1) => { x0.async = x1 },
      zK: x0 => x0.preventDefault(),
      zL: x0 => x0.ready,
      zM: x0 => x0.type,
      zN: (x0,x1) => x0.removeItem(x1),
      zO: x0 => x0.length,

    };

    const baseImports = {
      _: dart2wasm,
      Math: Math,
      Date: Date,
      Object: Object,
      Array: Array,
      Reflect: Reflect,
      WebAssembly: {
        JSTag: WebAssembly.JSTag,
      },
      "": new Proxy({}, { get(_, prop) { return prop; } }),

    };

    

    dartInstance = await WebAssembly.instantiate(this.module, {
      ...baseImports,
      ...additionalImports,
      
    });

    return new InstantiatedApp(this, dartInstance);
  }
}

class InstantiatedApp {
  constructor(compiledApp, instantiatedModule) {
    this.compiledApp = compiledApp;
    this.instantiatedModule = instantiatedModule;
  }

  // Call the main function with the given arguments.
  invokeMain(...args) {
    this.instantiatedModule.exports.$invokeMain(args);
  }
}
