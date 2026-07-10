# CLAUDE.md

Contexto del proyecto para Claude Code (y para retomar el trabajo tras un
formateo de PC). Para el roadmap detallado ver [PENDIENTES.md](PENDIENTES.md).

---

## Qué es

Motor de **novela visual** estilo anime / Danganronpa / Ace Attorney hecho en
**Godot 4.6** (GDScript). Arquitectura modular basada en escenas + señales +
autoloads. Los diálogos se definen en JSON con **IDs de texto únicos** (no
índices) y navegación por el campo `next`.

- Repo: https://github.com/alainquirozdiaz/visual-novel
- Escena principal (arranque): `res://scenes/MainMenu.tscn`
- Resolución base: 1280×720, stretch `canvas_items`.

## Cómo ejecutar

Abrir el proyecto en Godot 4.6 y pulsar Play (F5). Arranca en el menú de inicio.
No hay build/CLI: es un proyecto de editor. (No hay binario de Godot en PATH en
esta máquina, así que la validación se hace abriendo el editor.)

---

## Arquitectura

### Autoloads
- **`SaveManager`** (`scripts/SaveManager.gd`) — guardado/carga. Ver abajo.

### Escenas clave (`scenes/`)
| Escena | Rol |
|---|---|
| `MainMenu.tscn` | Menú de inicio: Inicio / Cargar / Créditos. Overlay de créditos a pantalla completa. |
| `Main.tscn` | Escena de juego. Orquesta fondo, sprites, diálogo, guardado. |
| `UILayer.tscn` | `CanvasLayer` (layer 1) con toda la UI in-game. Script `UIManager.gd`. |
| `DialogueBox.tscn` | **Cuadro de diálogo único** con placa de nombre y botón "Next" integrado. |
| `DecisionMenu.tscn` | Menú de decisiones (overlay atenuado + panel + botones dinámicos). |
| `SystemMenu.tscn` | Menú in-game (☰): Continuar / Guardar / Cargar / Ir al menú principal. |
| `SaveSlotPanel.tscn` | Selector de ranuras reutilizable (guardar/cargar/eliminar). |
| `CharacterSprite.tscn` | `TextureRect` reutilizable (SpriteLeft/SpriteRight). |
| `EndScreen.tscn` | Pantalla de cierre al terminar los diálogos. |

### Scripts (`scripts/`)
- `Main.gd` — orquestador; conecta señales, aplica fondo/sprites, captura y
  restaura el estado de guardado, autoguarda en cada línea/decisión.
- `DialogueManager.gd` — carga el JSON a un `Dictionary` por ID; `start(id)` /
  `next()`; emite `line_displayed`, `decision_triggered`, `dialogue_ended`.
- `UIManager.gd` — muestra el cuadro correcto y lo **tiñe con el color del
  personaje**; reenvía `option_selected`.
- `TypewriterManager.gd` — efecto máquina de escribir con `skip()`.
- `DecisionManager.gd` — genera botones de decisión y anima su aparición.
- `CharacterAnimator.gd` — flotación vertical continua (onda seno) del que habla,
  slide-in en la primera aparición, atenuado del inactivo.
- `SaveManager.gd` — autoload de guardado.
- `SaveSlotPanel.gd` / `SystemMenu.gd` — UI de guardado/menú de sistema.
- `MainMenu.gd` / `EndScreen.gd` — menús.

### Convenciones importantes
- **Orden de CanvasLayer**: fondo/sprites (Node2D) < UILayer (1) < EndScreen (5)
  < TransitionLayer (10, FadeOverlay negro).
- `CanvasLayer` NO hereda `CanvasItem` → **no tiene `modulate`**. Para fundidos en
  una capa se usa un `ColorRect` (p. ej. `FadeRect` en EndScreen).
- El shader `shaders/blur.gdshader` es `canvas_item`; **no usar `return` en
  `fragment()`** (usar `if/else`).
- `CharacterAnimator` usa claves de tween namespaced (`float_`, `modulate_`,
  `slide_`) para que no se cancelen entre sí. Flotación solo en eje Y; slide en X.
- **Tema visual compartido**: `themes/ui_theme.tres` (botones y paneles). Cambiar
  el acento violeta ahí afecta a todos los menús.
- **Placeholders de editor**: `Main.tscn` asigna fondo/sprites y hace visible el
  cuadro para editar cómodamente; en runtime `Main._ready()` los oculta y el
  código los gestiona (no tocar esa lógica al ajustar layout).

---

## Sistema de guardado

- Autoload `SaveManager`. Archivos en `user://saves/*.save` (JSON).
  - Windows: `C:\Users\<user>\AppData\Roaming\Godot\app_userdata\Visual Novel\saves\`
- Ranuras: `slot_1`…`slot_6` (manuales) + `autosave` (automático).
- **Autoguardado** en cada línea y cada decisión (`Main._collect_state()`).
- **Guardado/carga manual** desde el menú in-game (☰) y **cargar** también desde
  el menú de inicio (`▣ Cargar`).
- **Eliminar** ranura con `ConfirmationDialog` (botón 🗑 por ranura ocupada).
- `SaveManager.pending_state` transporta el estado entre escenas (menú → juego).
- Estado guardado: `current_id`, `background`, sprites (ruta + visibilidad),
  `label` legible y `saved_at`.

---

## Formato del JSON de diálogo (`dialogues/dialogue.json`)

```json
[
  { "id": "start", "speaker": "narrator", "text": "...",
    "background": "res://backgrounds/classroom.svg", "next": "intro_1" },
  { "id": "intro_1", "speaker": "left", "name": "Aiko", "text": "...",
    "sprite_left": "res://sprites/Kat1.png", "next": "intro_2" },
  { "id": "choice_1", "type": "decision",
    "options": [ { "text": "...", "next": "path_a" } ] }
]
```
- `speaker`: `left` | `right` | `narrator`.
- `type: "decision"` → menú de opciones en vez de línea.
- Color por personaje: mapa en `UIManager.gd` (Aiko=rosa, Riku=azul) o campo
  opcional `"color": "#rrggbb"` por línea.

---

## Estado actual (implementado)

Motor de diálogos JSON, typewriter + skip, decisiones dinámicas, narrador,
cuadro único con color por personaje y botón Next integrado, flotación sutil de
sprites, slide-in, intro con blur+fade, EndScreen, menú de inicio con tema,
créditos, **guardado auto + manual (6 ranuras) + cargar + eliminar con
confirmación**, volver al menú principal jugando, placeholders de editor.

## Pendiente (resumen — detalle en PENDIENTES.md)

Prioridad alta y ausencias más notorias en una VN:
1. **Audio**: `AudioManager` (BGM por escena + SFX: typewriter, click).
2. **Menú de ajustes** con persistencia (`user://settings.cfg`): velocidad de
   texto, volumen, pantalla completa.
3. **Modo Auto / Skip** y **Backlog** (historial de diálogos).
4. **Flags / variables narrativas** para decisiones con consecuencias.
5. Expresiones de personaje, transiciones entre fondos, RichTextLabel (BBCode),
   múltiples capítulos, galería de CGs, i18n, controles de teclado/gamepad.

> Sugerencia de siguiente feature: **AudioManager** (mayor impacto/esfuerzo).

---

## Notas para retomar tras formatear

- Todo lo versionado está en el repo (`git clone`). **NO** están en git (y se
  perderían): `.claude/` (settings locales) y los archivos de guardado en
  `user://` (AppData) — son datos de partida, no del proyecto.
- Instalar **Godot 4.6**, clonar el repo, abrir `project.godot`. Godot regenera
  `.godot/` y los `.import` (ignorados) al abrir.
