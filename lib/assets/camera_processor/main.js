const MAX_UNPROCESSED_FRAMES = 4;
const DATA_URL_PREFIX = "data:image/png;base64,";

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

  ctx.handleEvent("frame", ({ client_id, original, processed }) => {
    if (client_id === info.client_id) {
      imgEl.src = DATA_URL_PREFIX + processed;

      state.unprocessed--;

      if (state.tickTimeout === null) {
        tick();
      }
    } else {
      const clientEl = clientsEl.querySelector(`[data-client-id="${client_id}"]`);
      clientEl.querySelector("[data-original]").src = DATA_URL_PREFIX + original;
      clientEl.querySelector("[data-processed]").src = DATA_URL_PREFIX + processed;
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
    const dataUrl = canvas.toDataURL('image/png');
    const data = dataUrl.slice(DATA_URL_PREFIX.length);

    ctx.pushEvent("frame", { data, client_id: info.client_id });
  }
}
