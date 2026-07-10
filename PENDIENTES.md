# Pendientes / Roadmap

Funcionalidades **no implementadas aún** ordenadas por prioridad para una novela visual completa.
Cada sección incluye la arquitectura recomendada para Godot 4.

---

## 🔴 Alta prioridad (core gameplay)

### 1. Sistema de guardado y carga ✅ (implementado)
Ya disponible (ver sección "Implementado"). Pendiente opcional:
- Guardar también flags/variables narrativas (punto 2) dentro del estado.
- Miniatura/captura por ranura.
- Confirmación al sobrescribir una ranura ocupada.

---

### 2. Sistema de flags / variables narrativas
**Por qué falta:** necesario para decisiones con consecuencias a largo plazo.

**Qué implementar:**
- Diccionario global `GameState.flags: Dictionary` (autoload)
- En el JSON, soporte para:
  ```json
  { "id": "...", "set_flag": "met_riku", "require_flag": "went_left" }
  ```
- `DialogueManager` verifica flags antes de mostrar/saltar un nodo

**Archivos a crear:** `scripts/GameState.gd` (autoload)

---

### 3. Múltiples archivos JSON (capítulos)
**Por qué falta:** actualmente solo se carga `dialogue.json`.

**Qué implementar:**
- Array de rutas en `DialogueManager.load_chapter(chapter_index)`
- Manifiesto: `dialogues/chapters.json`:
  ```json
  ["dialogues/ch01.json", "dialogues/ch02.json"]
  ```
- Señal `chapter_ended` para transicionar entre capítulos

**Archivos a modificar:** `scripts/DialogueManager.gd`

---

### 4. Música de fondo (BGM)
**Por qué falta:** no hay ningún nodo de audio en la escena.

**Qué implementar:**
- `AudioManager.gd` (autoload) con `AudioStreamPlayer` para BGM y SFX
- En el JSON: `"bgm": "res://audio/theme.ogg"` y `"sfx": "res://audio/click.ogg"`
- Fade entre temas (`tween` en `volume_db`)
- Soporte para `.ogg` y `.mp3`

**Archivos a crear:** `scripts/AudioManager.gd`  
**Carpeta de audio:** `audio/bgm/`, `audio/sfx/`

---

### 5. Efectos de sonido (SFX)
Ligado al punto anterior. Incluye:
- Sonido de typewriter (tick por letra)
- Sonido de decisión seleccionada
- Sonido de avanzar diálogo

---

## 🟡 Media prioridad (experiencia narrativa)

### 6. Sistema de relaciones / afinidad
**Qué implementar:**
- `GameState.relations: Dictionary = { "riku": 0 }` (valor -100 a 100)
- En JSON: `"relation_change": { "riku": +10 }`
- Influye en qué opciones están disponibles (`require_relation`)

---

### 7. Transiciones de escena animadas
**Por qué falta:** actualmente `change_scene_to_file()` es instantáneo dentro de Main (entre IDs no hay transición).

**Qué implementar:**
- `TransitionManager.gd` — fade/dissolve/wipe entre fondos
- En JSON: `"transition": "fade"` o `"transition": "dissolve"`
- Tipos: negro, blanco, pixelate (shader), slide

---

### 8. Expresiones adicionales de sprites
**Por qué falta:** solo existe `_normal` para cada personaje.

**Qué implementar:**
- Archivos: `aiko_happy.svg`, `aiko_sad.svg`, `aiko_surprised.svg`, etc.
- En JSON: `"sprite_left": "res://sprites/aiko_happy.svg"`
- `CharacterAnimator.flash_expression(sprite, duration)` — parpadeo suave al cambiar

---

### 9. Typewriter — soporte para texto enriquecido
**Por qué falta:** el `DialogueLabel` actual es un `Label` normal sin BBCode.

**Qué implementar:**
- Cambiar `Label` → `RichTextLabel` con `bbcode_enabled = true`
- Soporte para `[color=red]texto[/color]`, `[b]`, `[i]`, `[shake]`
- Adaptar `TypewriterManager` para usar `visible_characters` en lugar de `.substr()`
  ```gdscript
  label.visible_characters = _char_index  # más eficiente con RichTextLabel
  ```

**Archivos a modificar:** `scenes/DialogueBox.tscn`, `scenes/NarrativeBox.tscn`, `scripts/TypewriterManager.gd`

---

## 🟢 Baja prioridad (contenido extra)

### 10. Galería de CGs (Computer Graphics)
- `scenes/Gallery.tscn` — grilla de ilustraciones desbloqueables
- `GameState.unlocked_cgs: Array` guardado en save
- Accesible desde el menú principal

### 11. Sistema estilo Ace Attorney
- Nodo `EvidenceManager.gd`
- `scenes/EvidencePopup.tscn` — presentar prueba con animación
- JSON: `"type": "present_evidence"`, `"evidence_id": "note_01"`

### 12. Sistema estilo Danganronpa
- `scenes/TrialScene.tscn` — minijuego de juicio
- Truth bullets / Non-Stop Debate
- Requiere un sistema de escenas separado del diálogo lineal

### 13. Selector de capítulos
- `scenes/ChapterSelect.tscn`
- Solo disponible si el capítulo fue desbloqueado (flag en SaveManager)

### 14. Modo de texto automático (Auto)
- Botón "Auto" en UI que avanza sin input del jugador
- Timer configurable (`auto_speed` en settings)

### 15. Log de diálogos (Backlog)
- `scenes/BacklogPanel.tscn` — scroll de los últimos ~50 diálogos
- Guardar historial en array durante la sesión
- Acceso con botón "Log" en UILayer

---

## 🔧 Mejoras técnicas pendientes

| Problema | Solución recomendada |
|---|---|
| `CharacterAnimator` accede a nodos por nombre (`get_parent().get_node(...)`) — frágil | Usar `@export var sprite_left: TextureRect` y asignarlo desde el editor |
| El pivot_offset se calcula en `_ready()` pero `size` puede ser 0 si el layout no está listo | Calcularlo en `_notification(NOTIFICATION_RESIZED)` o diferir con `call_deferred` |
| `TypewriterManager` usa `.substr()` en cada tick — O(n) por carácter | Cambiar a `RichTextLabel.visible_characters` que es O(1) |
| El blur shader afecta solo al Background TextureRect, no a los sprites | Mover el efecto a un `CanvasLayer` con `SubViewport` para capturar toda la escena |
| No existe manejo de errores si un `"next"` ID no existe en el JSON | `DialogueManager` debería mostrar un warning en pantalla, no solo en consola |
| No hay soporte para `"type": "jump"` condicional en JSON | Agregar `"condition": "flag_name"` y `"else_next": "other_id"` |

---

## 📁 Estructura de carpetas pendiente de crear

```
audio/
├── bgm/          ← música de fondo (.ogg)
└── sfx/          ← efectos de sonido (.ogg)

sprites/
├── aiko_happy.svg
├── aiko_sad.svg
├── aiko_surprised.svg
├── riku_happy.svg
└── riku_serious.svg

backgrounds/
├── classroom_night.svg
├── hallway.svg
└── rooftop.svg

dialogues/
├── chapters.json   ← manifiesto de capítulos
├── ch01.json
└── ch02.json
```

---

## ✅ Implementado actualmente

- [x] Motor de diálogos JSON con IDs únicos
- [x] Efecto typewriter con skip
- [x] Sistema de decisiones con botones dinámicos
- [x] Narrador sin sprite (`"speaker": "narrator"`)
- [x] Sprites animados (modulate + scale con Tween)
- [x] Slide-in al primer aparición de personaje
- [x] Blur + fade de intro al iniciar historia
- [x] Menú principal con Inicio y Créditos
- [x] Pantalla de cierre (EndScreen) con "Volver al Menú"
- [x] Arquitectura modular en sub-escenas
- [x] Sprites SVG de demo (Aiko y Riku)
- [x] Fondo SVG de demo (salón de clases)
- [x] Capas de UI correctas (layer 1 / 5 / 10)
- [x] Fade entre menú y escena de historia
- [x] Tema visual compartido (`themes/ui_theme.tres`)
- [x] Cuadro de diálogo único con color por personaje y botón "Next" integrado
- [x] **Guardado automático** (ranura `autosave`) en cada línea/decisión
- [x] **Guardado manual** en 6 ranuras desde el menú in-game
- [x] **Cargar** partida desde el menú in-game o desde el menú de inicio
- [x] **Volver al menú principal** durante la partida
- [x] `SaveManager` autoload (`user://saves/*.save`)
