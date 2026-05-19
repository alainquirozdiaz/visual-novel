# Visual Novel Engine — Godot 4.4

Motor base para novelas visuales estilo **anime / Danganronpa / Ace Attorney**, construido en Godot 4.4.1 con arquitectura modular y diálogos en JSON.

---

## Características

| Feature | Descripción |
|---|---|
| Diálogos JSON | Navegación por IDs únicos, sin índices |
| Sistema de decisiones | Botones dinámicos, múltiples rutas |
| Narrador | Caja sin sprite (`"speaker": "narrator"`) |
| Efecto typewriter | Texto letra a letra, velocidad configurable |
| Sprites animados | Resaltado del personaje activo con Tween |
| UI modular | CanvasLayer, cajas independientes por speaker |
| Cambio dinámico | Fondos y sprites cambiables desde el JSON |

---

## Estructura del proyecto

```
res://
├── scenes/
│   └── Main.tscn              # Escena principal
│
├── scripts/
│   ├── Main.gd                # Orquestador — conecta todos los sistemas
│   ├── DialogueManager.gd     # Carga JSON, navega por IDs
│   ├── UIManager.gd           # Muestra cajas correctas, reenvía señales
│   ├── TypewriterManager.gd   # Efecto letra a letra
│   ├── CharacterAnimator.gd   # Resalta / oscurece sprites activos
│   └── DecisionManager.gd     # Botones dinámicos de elección
│
├── dialogues/
│   └── dialogue.json          # Diálogos de ejemplo con bifurcaciones
│
├── sprites/                   # Sprites de personajes (.png / .webp)
├── backgrounds/               # Fondos de escena (.png / .webp)
└── audio/                     # Música y SFX (.ogg / .mp3)
```

---

## Formato del JSON de diálogos

### Línea de diálogo

```json
{
  "id": "mi_id_unico",
  "speaker": "left",
  "name": "Nombre del personaje",
  "text": "Texto que aparece en pantalla.",
  "next": "id_siguiente",

  "background":  "res://backgrounds/sala.png",
  "sprite_left":  "res://sprites/aiko_normal.png",
  "sprite_right": "res://sprites/riku_normal.png"
}
```

**Valores de `speaker`:**
- `"left"` → caja izquierda con nombre
- `"right"` → caja derecha con nombre
- `"narrator"` → caja central sin nombre ni sprite

Poner `"sprite_left": "none"` oculta el sprite izquierdo.  
Los campos `background`, `sprite_left` y `sprite_right` son **opcionales** — solo se aplican cuando aparecen.

### Decisión

```json
{
  "id": "eleccion_1",
  "type": "decision",
  "options": [
    { "text": "Opción A", "next": "ruta_a" },
    { "text": "Opción B", "next": "ruta_b" }
  ]
}
```

### Fin del diálogo

Dejar `"next": ""` (o no incluir la clave) termina la historia.

---

## Flujo de ejecución

```
Main._ready()
  └─ DialogueManager.load_dialogue()
  └─ DialogueManager.start("start")
       └─ line_displayed → UIManager.show_dialogue()
                        → TypewriterManager.type_text()
                        → CharacterAnimator.highlight()
       └─ decision_triggered → UIManager.show_decisions()
                             → DecisionManager (botones dinámicos)
                             → option_selected → DialogueManager.start(next_id)
```

---

## Cómo usar

1. Abre el proyecto en **Godot 4.4.1** (`project.godot`).
2. Coloca sprites en `res://sprites/` y fondos en `res://backgrounds/`.
3. Edita `dialogues/dialogue.json` con tu historia.
4. Presiona **F5** para ejecutar.

**Tecla / botón Next:**  
- Primera pulsación mientras escribe → **salta** el typewriter.  
- Pulsación cuando terminó → **avanza** al siguiente nodo.

---

## Extensión planificada

El motor está diseñado para agregar después:
- Música y SFX
- Sistema de guardado / carga
- Flags y variables narrativas
- Múltiples archivos JSON (capítulos)
- Transiciones de escena
- Sistema de relaciones
- CGs y escenas cinemáticas
- Modo Danganronpa (juicio / minijuegos)
- Modo Ace Attorney (objeción / pruebas)

---

## Requisitos

- Godot Engine **4.4.1** o superior
- No requiere plugins adicionales

---

## Licencia

MIT — libre para uso personal y comercial.
