# ChitraDev

ChitraDev is a local-first FastAPI image generation app for Stable Diffusion 1.5. It can generate images from prompts alone, or use one or two FaceID reference photos through IP-Adapter FaceID identity guidance. Generated PNGs, ZIP downloads, reference photos, and model cache stay on your own machine.

ChitraDev is built to avoid hosted image-generation limits. There are no subscription quotas, remote credits, or repo-imposed creative category blocks in the app itself. Practical output is controlled by your local hardware, selected model behavior, environment settings, and the laws or consent requirements that apply to your use.

## What ChitraDev Does

- Prompt-only image generation with Stable Diffusion 1.5.
- Optional single-person FaceID generation with one reference image.
- Optional two-person FaceID generation with separate Person 1 and Person 2 reference images.
- Left/right person placement controls for cleaner two-person identity separation.
- Previewable PNG outputs with direct image downloads and a ZIP download.
- Separate batch creator page for long prompt-only runs.
- Local FastAPI browser UI at `http://127.0.0.1:8000`.
- Public website lives in the separate `ChitraDevWeb` repository.

## System Requirements

Recommended local setup:

| Requirement | Recommended | Notes |
| --- | --- | --- |
| OS | Windows 10/11 | PowerShell scripts are included. Linux/macOS can adapt the same Python commands manually. |
| Python | 3.11 | The setup script creates a `.venv` using Python 3.11. |
| GPU | NVIDIA CUDA GPU | Defaults are tuned for a 4 GB GPU at `512x512`, `20` steps, and `1` image. |
| CPU-only | Supported, but slow | CPU generation can work, but expect long generation times. |
| Disk | Several GB free | Stable Diffusion, IP-Adapter, and InsightFace assets cache in `.cache/`. |
| RAM | 16 GB recommended | More memory helps model loading and larger batches. |
| Node.js | 20 or newer | Needed only for the public website in `frontend/`. |
| Git | Latest stable | Needed to clone the repo and publish the website. |
| Network | Required on first model load | Use `LOCAL_FILES_ONLY=true` after assets are already cached locally. |

## Quick Local Start

1. Clone ChitraDev and open the folder:

```powershell
git clone https://github.com/yuvrajraina/ChitraDev.git
cd ChitraDev
```

2. Optional: create `.env` from `.env.example` if you want custom local paths, default generation settings, or higher hardware caps:

```powershell
Copy-Item .env.example .env
```

3. Run the setup script:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\setup.ps1
```

4. Activate the environment:

```powershell
.\.venv\Scripts\Activate.ps1
```

5. Optional but recommended: preload the model stack before opening the UI:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\preload_models.ps1
```

6. Start ChitraDev:

```powershell
python -m uvicorn app.main:app --host 127.0.0.1 --port 8000
```

7. Open the local app:

```text
http://127.0.0.1:8000
```

If you see a `torchvision::nms does not exist` error, rerun the setup script. It force-reinstalls a matching CUDA build of `torch`, `torchvision`, and `torchaudio`.

## How to Generate Images Locally

Prompt-only generation:

1. Open `http://127.0.0.1:8000`.
2. Leave both face upload fields empty.
3. Put the full subject, style, environment, lighting, and composition in the main prompt.
4. Click `Generate images`.

Single-person FaceID generation:

1. Upload a clear front-facing image in `Person 1 face image`.
2. Add the overall scene in `Prompt`.
3. Optionally describe clothing, pose, or action in `Person 1 role and action`.
4. Click `Generate images`.

Two-person FaceID generation:

1. Upload `Person 1 face image` and `Person 2 face image`.
2. Describe the overall scene in `Prompt`.
3. Add separate role/action text for each person if needed.
4. Use `Interaction or relationship` to describe what they are doing together.
5. Keep Person 1 and Person 2 on opposite sides in advanced settings.
6. Click `Generate images`.

Outputs are written to the ignored `outputs/` folder and can be downloaded from the browser UI.

Batch generation:

1. Open `http://127.0.0.1:8000/batch`.
2. Paste one prompt that should be reused.
3. Set total outputs, chunk size, dimensions, steps, guidance, negative prompt, and optional start seed.
4. Click `Start batch`.

Batch jobs run in the background while the server stays open. Each job writes PNGs, `batch-prompt.txt`, and `batch-results.zip` into an ignored `outputs/batch-.../` folder.

## Generation Limits And Controls

ChitraDev does not add hosted image-generation limits, remote credits, subscription gates, or repo-level prompt category restrictions. It is meant to run locally, so you control the model, cache, outputs, and environment configuration.

There are still local safety rails for stability and hardware fit. These are configurable in `.env`:

| Variable | Default | Purpose |
| --- | ---: | --- |
| `DEFAULT_WIDTH` | `512` | Default image width. Must be a multiple of 64. |
| `DEFAULT_HEIGHT` | `512` | Default image height. Must be a multiple of 64. |
| `DEFAULT_STEPS` | `20` | Default diffusion steps. |
| `DEFAULT_NUM_IMAGES` | `1` | Default images per request. |
| `MAX_WIDTH` | `768` | Maximum request width. Raise only if your GPU can handle it. |
| `MAX_HEIGHT` | `768` | Maximum request height. Raise only if your GPU can handle it. |
| `MAX_STEPS` | `50` | Maximum diffusion steps per request. |
| `MAX_NUM_IMAGES` | `4` | Maximum images per request. |
| `MAX_GUIDANCE_SCALE` | `20` | Maximum classifier-free guidance scale. |
| `DEFAULT_BATCH_TOTAL_IMAGES` | `100` | Default total outputs in the batch creator. |
| `MAX_BATCH_TOTAL_IMAGES` | `500` | Maximum outputs allowed for one batch job. |
| `DEFAULT_BATCH_CHUNK_SIZE` | `1` | Default images generated per batch chunk. |
| `MAX_BATCH_CHUNK_SIZE` | `4` | Maximum images generated per batch chunk. |
| `MAX_FACE_IMAGE_MB` | `10` | Maximum uploaded reference image size. |

If you hit GPU memory issues, lower the image size, step count, or output count.

## Configuration

Create `.env` from `.env.example` when you want to customize ChitraDev:

```powershell
Copy-Item .env.example .env
```

Important settings:

- `HOST` and `PORT` control the local FastAPI address.
- `OUTPUT_DIR` controls where generated PNGs and ZIPs are written.
- `CACHE_DIR` controls where model assets are cached.
- `SD_BASE_MODEL` controls the Stable Diffusion model source.
- `IP_ADAPTER_SOURCE` and `IP_ADAPTER_WEIGHT` control FaceID adapter assets.
- `HF_TOKEN` can be used for gated Hugging Face assets.
- `LOCAL_FILES_ONLY=true` keeps model loading offline after assets are cached.
- `DEFAULT_NEGATIVE_PROMPT` sets the default negative prompt in the UI.

## Health Check

```powershell
curl http://127.0.0.1:8000/health
```

The response reports whether the service is alive and whether the model runtime has loaded.

## Tests

The included tests cover settings loading, output saving and ZIP creation, prompt composition, and the web API with a stubbed inference service.

```powershell
python -m unittest discover -s tests -v
```

## Host The Website On Netlify

The ChitraDev app repo is the local FastAPI generator. Host only the separate website repo, `https://github.com/yuvrajraina/ChitraDevWeb`, on Netlify.

The frontend includes `netlify.toml` with the expected Vite settings:

```text
Build command: npm run build
Publish directory: dist
Node version: 20
```

After Netlify gives you a live URL, update the frontend SEO URL values if needed:

- `frontend/src/config/site.ts`
- `frontend/index.html`
- `frontend/public/robots.txt`
- `frontend/public/sitemap.xml`
