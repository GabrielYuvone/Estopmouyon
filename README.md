# ESTOPMOUYON — PWA Installation Guide

**ESTOPMOUYON** es una Progressive Web App (PWA) para crear animaciones stop motion cuadro a cuadro con la cámara del navegador. Funciona en cualquier dispositivo moderno (Android, iOS, Windows, Mac, Linux) y **se puede instalar como una app nativa** desde el navegador.

---

## 📁 Archivos incluidos

```
pwa/
├── index.html              # La app completa (con ambos logos embebidos en base64)
├── manifest.json           # Manifest de la PWA (nombre, íconos, colores)
├── sw.js                   # Service Worker para offline
├── icon-192.png            # Ícono 192×192 (Chrome / Android)
├── icon-512.png            # Ícono 512×512 (Chrome / Android)
├── icon-maskable-512.png   # Ícono maskable (para Android adaptive icons)
├── apple-touch-icon.png    # Ícono para iOS (180×180)
├── favicon-32.png          # Favicon del navegador
├── _headers                # Config para Cloudflare Pages
├── _redirects              # Config para GitHub Pages / Cloudflare
└── .nojekyll               # Desactiva Jekyll en GitHub Pages
```

---

## 🚀 Deployment en Cloudflare Pages

### Opción A — Drag & drop (lo más simple)

1. Andá a https://dash.cloudflare.com → **Workers & Pages** → **Create application** → **Pages** → **Upload assets**
2. Nombrá el proyecto (ej: `estopmouyon`)
3. Arrastrá **todo el contenido** de la carpeta `pwa/` (no la carpeta misma, los archivos sueltos)
4. Click **Deploy**
5. Te dan una URL tipo `https://estopmouyon.pages.dev` — listo para instalar

### Opción B — Con Git (recomendado para actualizar)

1. Subí los archivos a un repo de GitHub (ej: `usuario/estopmouyon`)
2. En Cloudflare Pages → **Create application** → **Pages** → **Connect to Git**
3. Elegí el repo
4. En **Build output directory** dejá `/` (vacío o la raíz)
5. **Deploy** — cada vez que hagas `git push`, se actualiza solo

---

## 🚀 Deployment en GitHub Pages

1. Creá un repo público (ej: `usuario/estopmouyon`)
2. Subí los archivos de la carpeta `pwa/` a la rama `main` (o `gh-pages`)
3. Andá a **Settings → Pages → Build and deployment → Source: Deploy from a branch**
4. Elegí la rama `main` y carpeta `/root`
5. Guardá. En 1-2 minutos tenés la URL: `https://usuario.github.io/estopmouyon/`

> **Nota sobre GitHub Pages:** El archivo `_headers` no funciona en GitHub Pages (sí funciona en Cloudflare). El `_redirects` sí funciona. Aún así la PWA funciona correctamente en GitHub Pages, solo que sin los headers de cacheo fino.

---

## 📲 Cómo instalar la PWA

### Android (Chrome / Edge / Brave)

1. Abrí la URL de la app en el navegador
2. Esperá 3-5 segundos a que cargue la cámara (concede el permiso)
3. Aparece un banner abajo: **"Instalar ESTOPMOUYON"** → tap **Instalar**
4. Si no aparece el banner: tap el menú ⋮ → **Agregar a pantalla de inicio**
5. Aparece un ícono en la home screen del celu → listo, ábrelo como una app

### iOS (Safari — iPhone / iPad)

1. Abrí la URL en Safari (NO funciona desde Chrome de iOS)
2. Tap el botón **Compartir** (cuadrado con flecha arriba)
3. Tap **Agregar a pantalla de inicio**
4. Confirmá el nombre "ESTOPMOUYON" → tap **Agregar**
5. Aparece el ícono en la home → abrila como una app nativa

### Desktop (Chrome / Edge)

1. Abrí la URL en el navegador
2. Aparece un ícono **⊕ Instalar** en la barra de direcciones (a la derecha)
3. Click → **Instalar**
4. Se abre en su propia ventana sin barra de navegador
5. Queda accesible desde el menú inicio / dock

---

## ✅ Checklist post-deploy

Después de subir los archivos, verificá:

- [ ] Abrí la URL y la app carga (logo Escuela + logo ESTOPMOUYON visibles arriba)
- [ ] El navegador pide permiso de cámara — aceptalo
- [ ] En Chrome desktop: aparece el ícono ⊕ Instalar en la barra de direcciones
- [ ] En Chrome Android: aparece el banner "Instalar ESTOPMOUYON" o el menú tiene "Agregar a pantalla de inicio"
- [ ] En Safari iOS: Compartir → Agregar a pantalla de inicio funciona
- [ ] Después de instalar, abrí la app sin internet — debería seguir funcionando (offline)
- [ ] Verificá en DevTools → Application → Service Workers: el SW aparece como "activated and is running"

---

## 🔧 Solución de problemas

### "No aparece el prompt para instalar"

Causas posibles:
- **No estás en HTTPS** — solo localhost y HTTPS permiten SW
- **Abriste con `file://`** — el SW no se registra desde file://
- **Ya está instalada** — desinstalala primero
- **Poco tiempo de uso** — Chrome requiere que el usuario interactúe con la app unos segundos antes de mostrar el prompt

### "La cámara no funciona"

- Verificá que estás en HTTPS o localhost (no file://)
- En iOS Safari, asegurate de haber **agregado a pantalla de inicio** Y abierto desde ahí (no desde Safari)
- Revisá los permisos del navegador: el ícono de candado/cámara en la barra debe tener "Allow"

### "No funciona offline después de instalar"

- Abrí DevTools → Application → Service Workers. Si dice "trying to install" o "waiting", hacé click en **skipWaiting**
- Si dice error, revisá la consola. Probablemente algún CDN no se pudo cachear (la app igual funciona, solo que sin librerías externas si las necesitás offline)
- Forzá refresh: Ctrl+Shift+R (desktop) o borrar cache del navegador

### "Se ve mal en iPhone después de instalar"

iOS tiene un modo "PWA" limitado. Algunas cosas que funcionan distinto:
- El storage es de ~50 MB (no de varios GB como Android)
- La cámara SÍ funciona desde la PWA en iOS 16.4+
- La exportación a MP4 funciona vía WebCodecs en iOS 16.4+

---

## 🛠️ Estructura técnica

- **HTML**: 1 archivo con todo el código de la app + 2 logos embebidos como base64
- **Manifest**: `manifest.json` con nombre, íconos (3 tamaños), colores, display standalone
- **Service Worker**: `sw.js` con estrategia **stale-while-revalidate** + pre-cache de CDNs
- **Storage**: IndexedDB del navegador (sin servidores, sin backend)
- **Cámara**: getUserMedia API
- **Exportación**: WebCodecs (MP4 H.264), gif.js (GIF), MediaRecorder (WebM fallback)

---

## ❓ Preguntas frecuentes

### ¿Los usuarios pueden compartir la URL y todos instalan?

Sí. Pasás la URL de Cloudflare/GitHub Pages por WhatsApp, mail, redes sociales y cualquiera puede instalarla en su dispositivo.

### ¿Necesitan internet cada vez que abren la app?

Solo la **primera vez**. Después de la primera carga, el SW cachea todo y la app abre instantáneamente sin internet.

### ¿Las fotos se suben a algún servidor?

**No.** Todo es 100% local. La app no tiene backend. Las fotos se guardan en el almacenamiento del navegador del usuario.

### ¿Puedo actualizar la app después de publicada?

Sí. Subís los archivos nuevos al repositorio (o los volvés a arrastrar a Cloudflare). En la próxima apertura de la app, el SW detecta la nueva versión y se actualiza automáticamente.

### ¿Funciona en modo incógnito / privada?

Parcialmente. El SW no se registra en modo incógnito (limitación de los navegadores). La app carga pero no es instalable offline.

---

## 📜 Licencia

Libre uso. Distribuí y modificá como quieras.
