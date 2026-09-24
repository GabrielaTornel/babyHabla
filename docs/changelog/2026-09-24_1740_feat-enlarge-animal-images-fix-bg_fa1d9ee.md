---
title: "Nuevos minijuegos: dibujo libre y trazado de caminos"
date: 2026-09-24
branch: feat/enlarge-animal-images-fix-bg
sha: fa1d9ee
tags:
  - changelog
  - mini-games
  - feat
---

# Nuevos minijuegos: dibujo libre y trazado de caminos

## Resumen
Agrega dos minijuegos a tinytalk (Flutter): "Dibuja Libre" (canvas libre con pinceles/colores/tamaños) y "Sigue el Camino" (trazar curva con dedo entre dos familiares). Ambos siguen patrón Riverpod (state+notifier+provider) y se integran a router y catálogo de minijuegos existentes.

## Archivos modificados
| Archivo | Tipo de cambio | Descripción breve |
|---------|----------------|-------------------|
| `tinytalk/lib/app/constants/mini_game_data.dart` | feat | Registra entradas `trace_path` y `free_draw` en catálogo |
| `tinytalk/lib/app/localization/app_language.dart` | feat | Strings ES/EN: `followThePathTo`, `freeDrawHint` |
| `tinytalk/lib/app/router/app_router.dart` | feat | Rutas para `TracePathScreen`, `FreeDrawScreen` |
| `tinytalk/lib/features/mini_games/models/free_draw.dart` | feat | `BrushType`, `BrushSize`, `DrawStroke`, `FreeDrawPalette` |
| `tinytalk/lib/features/mini_games/models/trace_path.dart` | feat | `TracePathShape` (curvas normalizadas, smooth-step), `TracePathRound` |
| `tinytalk/lib/features/mini_games/presentation/free_draw/free_draw_screen.dart` | feat | Pantalla canvas, paleta color/pincel/tamaño, panel colapsable |
| `tinytalk/lib/features/mini_games/presentation/free_draw/widgets/draw_painter.dart` | feat | `CustomPainter` para trazos por tipo de pincel |
| `tinytalk/lib/features/mini_games/presentation/trace_path/trace_path_screen.dart` | feat | Pantalla trazado, detección de progreso por gesto, sparkles, celebración |
| `tinytalk/lib/features/mini_games/presentation/trace_path/widgets/path_painter.dart` | feat | `CustomPainter` guía punteada + relleno dorado de progreso |
| `tinytalk/lib/features/mini_games/providers/free_draw_provider.dart` | feat | `FreeDrawNotifier`/`FreeDrawState` (Riverpod) |
| `tinytalk/lib/features/mini_games/providers/trace_path_provider.dart` | feat | `TracePathNotifier`/`TracePathState`, generación de rondas por familia |
| `.vscode/launch.json` | chore | Config de lanzamiento Dart para tinytalk |
| `.vscode/settings.json` | chore | Config Java nullAnalysis (nuevo archivo) |
| `talos/metrics/timing.jsonl`, `tinytalk/talos/metrics/timing.jsonl` | chore | Telemetría de sesión Talos (auto-generado) |

## Impacto funcional
Niño puede: (1) dibujar libre con dedo eligiendo color/pincel(lápiz,pincel,acuarela,marcador)/tamaño; (2) seguir con dedo un camino curvo desde palabra "bebé" hasta otro familiar, con feedback sonoro (audio/TTS) y celebración al completar. Ambos aparecen en catálogo de minijuegos.

## Impacto técnico
- Stack: Flutter + Riverpod (Notifier/AsyncNotifier), go_router. Patrón: feature-first (models/providers/presentation) igual al resto de `mini_games`.
- `TracePathNotifier` depende de `wordsProvider` (categoría `family`), filtra `family_baby` como punto inicio fijo.
- `trace_path_screen.dart` deja 2 `debugPrint` de depuración activos en `_handleDrag` (líneas con touch/screen/progress y bestT) — código no limpio para prod.
- Sin cambios en API/DB. Archivos `.vscode/` y `timing.jsonl` son ruido de tooling/telemetría, no funcionalidad.

## Riesgos
- `debugPrint` en `trace_path_screen.dart` corre en cada `onPanUpdate` — ruido en consola release/logs, revisar antes de merge.
- `_handleDrag` con `_sampleSteps=120` recalculado en cada frame de arrastre — verificar performance en dispositivos gama baja.
- `.vscode/settings.json` y `launch.json` son config local de entorno, confirmar si deben versionarse en repo compartido.

## Pruebas sugeridas
- [ ] Unit test `TracePathShape.positionAt` en límites t=0, t=1, y con 2 waypoints
- [ ] Unit test `TracePathNotifier.onPathCompleted` evita repetir mismo índice cuando `rounds.length > 1`
- [ ] Widget test `FreeDrawNotifier.extendStroke` con `strokes` vacío (no debe crashear)
- [ ] Caso edge: completar camino y verificar fallback TTS cuando `audioServiceProvider.playAsset` retorna false
- [ ] Verificar `debugPrint` removido o gateado antes de release

## Referencias
[[02-Arquitectura/Visión General]]
[[03-Implementación/Mini Juegos]]

---
*Generado automáticamente · 2026-09-24 17:40*