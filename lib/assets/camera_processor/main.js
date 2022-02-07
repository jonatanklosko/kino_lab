const MAX_UNPROCESSED_FRAMES = 4;
const DATA_URL_PREFIX = "data:image/jpeg;base64,";

export function init(ctx, info) {
  ctx.importCSS("./main.css");

  const state = {
    unprocessed: 0,
    tickTimeout: null,
  };

  ctx.root.innerHTML = `
    <div id="clients" class="clients">
      <div class="client">
        <div class="frame-container">
          <video id="self-video" playsinline autoplay muted></video>
        </div>
        <div class="frame-container">
          <img id="self-processed" />
        </div>
      </div>
    </div>
  `;

  const videoEl = ctx.root.querySelector("#self-video");
  const imgEl = ctx.root.querySelector("#self-processed");
  const clientsEl = ctx.root.querySelector("#clients");

  function addClient(clientId) {
    clientsEl.insertAdjacentHTML("beforeend", `
      <div class="client" data-client-id="${clientId}">
        <div class="frame-container">
          <img data-original />
        </div>
        <div class="frame-container">
          <img data-processed />
        </div>
      </div>
    `);
  }

  info.clients.forEach(addClient);

  const constraints = {
    audio: false,
    video: { facingMode: "user" }
  };

  navigator.mediaDevices.getUserMedia(constraints)
    .then((stream) => {
      videoEl.srcObject = stream;
    });

  videoEl.addEventListener("canplay", (event) => {
    tick();
  });

  ctx.handleEvent("client_join", ({ client_id }) => {
    if (client_id !== info.client_id) {
      addClient(client_id);
    }
  });

  ctx.handleEvent("frame", ([{ client_id, original_size }, buffer]) => {
    const originalBuffer = buffer.slice(0, original_size)
    const processedBuffer = buffer.slice(original_size)

    if (client_id === info.client_id) {
      imgEl.src = DATA_URL_PREFIX + bufferToBase64(processedBuffer);

      state.unprocessed--;

      if (state.tickTimeout === null) {
        tick();
      }
    } else {
      const clientEl = clientsEl.querySelector(`[data-client-id="${client_id}"]`);
      clientEl.querySelector("[data-original]").src = DATA_URL_PREFIX + bufferToBase64(originalBuffer);
      clientEl.querySelector("[data-processed]").src = DATA_URL_PREFIX + bufferToBase64(processedBuffer);
    }
  });

  function tick() {
    if (state.unprocessed < MAX_UNPROCESSED_FRAMES) {
      state.tickTimeout = setTimeout(tick, 1000 / info.max_fps);
      sendFrame();
      state.unprocessed++;
    } else {
      state.tickTimeout = null;
    }
  }

  function sendFrame() {
    const canvas = document.createElement('canvas');
    canvas.width = videoEl.videoWidth;
    canvas.height = videoEl.videoHeight;
    canvas.getContext('2d').drawImage(videoEl, 0, 0);
    const dataUrl = canvas.toDataURL('image/jpeg', info.quality / 100);
    const data = dataUrl.slice(DATA_URL_PREFIX.length);

    const buffer = base64ToBuffer(data);

    ctx.pushEvent("frame", [{ client_id: info.client_id }, buffer]);
  }
}

function base64ToBuffer(base64) {
  const binaryString = atob(base64);
  const length = binaryString.length;
  const bytes = new Uint8Array(length);

  for (let i = 0; i < length; i++) {
    bytes[i] = binaryString.charCodeAt(i);
  }

  return bytes.buffer;
}

function bufferToBase64(buffer) {
  let binaryString = "";
  const bytes = new Uint8Array(buffer);
  const length = bytes.byteLength;

  for (let i = 0; i < length; i++) {
    binaryString += String.fromCharCode(bytes[i]);
  }

  return btoa(binaryString);
}
