---
title: "Mini-juego colorear dibujos con línea sobre color"
date: 2026-09-24
branch: feat/enlarge-animal-images-fix-bg
sha: faacd45
tags:
  - changelog
  - mini-games
  - feat
---

# Mini-juego "Colorea" (coloring book) con blend multiply

## Resumen
Se añade nuevo mini-juego "Colorea" a TinyTalk: galería de dibujos en blanco y negro (Olaf, Elsa) que el niño pinta con el dedo, renderizando el line-art encima de los trazos vía `BlendMode.multiply`. Se refactoriza el panel de colores/pinceles del free-draw a un widget compartido (`DrawingPalette`, `GlassButton`, `PanelReopenButton`) para reutilizarlo en ambos canvas.

## Archivos modificados
| Archivo | Tipo de cambio | Descripción breve |
|---------|----------------|-------------------|
| `tinytalk/lib/features/mini_games/models/coloring_page.dart` | feat | Modelo `ColoringPage` + catálogo estático (Olaf, Elsa) |
| `tinytalk/lib/features/mini_games/presentation/coloring_book/coloring_gallery_screen.dart` | feat | Grid de selección de dibujo a colorear |
| `tinytalk/lib/features/mini_games/presentation/coloring_book/coloring_canvas_screen.dart` | feat | Pantalla de canvas: carga imagen como `ui.Image`, gestiona trazos vía `freeDrawProvider` con `ProviderScope` override para estado aislado por página |
| `tinytalk/lib/features/mini_games/presentation/coloring_book/widgets/coloring_painter.dart` | feat | `CustomPainter` que pinta trazos + line-art con `BlendMode.multiply` |
| `tinytalk/lib/features/mini_games/widgets/drawing_palette.dart` | refactor | Extrae `_ColorPalette`/`_GlassButton`/`_PanelReopenButton` de `free_draw_screen.dart` a widgets públicos reutilizables (`DrawingPalette`, `GlassButton`, `PanelReopenButton`) |
| `tinytalk/lib/features/mini_games/presentation/free_draw/free_draw_screen.dart` | refactor | Elimina ~330 líneas de widgets privados duplicados, consume los nuevos widgets compartidos |
| `tinytalk/lib/features/mini_games/presentation/free_draw/widgets/draw_painter.dart` | refactor | Mueve `_paintFor` a extensión `StrokePaint.toPaint()` en `free_draw.dart` para compartirla con `ColoringPainter` |
| `tinytalk/lib/features/mini_games/models/free_draw.dart` | refactor | Añade extensión `StrokePaint` sobre `DrawStroke` |
| `tinytalk/lib/app/constants/mini_game_data.dart` | feat | Registra entrada `coloring_book` en catálogo de mini-juegos |
| `tinytalk/lib/app/router/app_router.dart` / `app_routes.dart` | feat | Rutas `coloring_book` (galería) y `/coloring/:pageId` (canvas) |
| `tinytalk/lib/app/localization/app_language.dart` | feat/chore | Nueva copy `chooseADrawing` (ES/EN); reformateo de líneas largas (dart format) |
| `tinytalk/pubspec.yaml` | chore | Registra carpeta de assets `assets/images/coloring/` |
| `tinytalk/assets/images/coloring/olaf.png`, `frozen.webp` | feat | Assets line-art nuevos |
| `tinytalk/talos/metrics/timing.jsonl`, `talos/metrics/timing.jsonl` (raíz) | chore | Telemetría interna de sesión Talos, sin relación funcional |

## Impacto funcional
Desde la pantalla de Mini Juegos aparece nueva tarjeta "Colorea" (🖌️). Al entrar, el niño elige un dibujo (Olaf o Elsa) desde una galería en grid; al tocarlo abre el canvas donde puede pintar con dedo usando la misma paleta de colores/pinceles/tamaños que el dibujo libre, con el contorno del dibujo siempre visible encima del color.

## Impacto técnico
- Reutiliza el `freeDrawProvider` existente pero lo aísla por pantalla con `ProviderScope(overrides: [freeDrawProvider])`, evitando que el estado de color-book contamine el free-draw global.
- Nuevo modelo de dominio simple `ColoringPage` (id/títulos ES-EN/assetPath), sin capa de persistencia ni backend — datos estáticos en código, consistente con el resto de mini-juegos.
- Nueva ruta paramétrica `/coloring/:pageId` en `go_router`; contrato de navegación vía `AppRoutes.coloringPagePath(pageId)`.
- Composición gráfica: `ColoringPainter` dibuja fondo blanco, luego trazos, luego `paintImage` con `blendMode: BlendMode.multiply` — técnica dependiente de que el asset line-art sea fondo blanco/líneas negras.
- Deduplicación de UI: paleta de dibujo pasa de estar duplicada/privada en `free_draw_screen.dart` a un widget público compartido en `widgets/drawing_palette.dart`.

## Riesgos
- `orElse: () => coloringPages.first` en `coloring_canvas_screen.dart` oculta silenciosamente un `pageId` inválido en la URL (deep link roto navega a Olaf sin aviso).
- Asset `frozen.webp`: si el line-art no tiene fondo blanco puro, el `BlendMode.multiply` puede producir manchas visibles en vez de transparencia limpia.
- Ningún test añadido para el nuevo painter, provider override ni catálogo de páginas.

## Pruebas sugeridas
- [ ] Test widget: navegar Mini Juegos → Colorea → seleccionar Olaf → verificar canvas carga imagen y permite trazo.
- [ ] Test unitario `ColoringPainter`: verificar orden de capas (fondo blanco, trazos, line-art) y `shouldRepaint`.
- [ ] Caso edge: navegar directo a `/coloring/no-existe` y confirmar fallback a Olaf sin crash.
- [ ] Verificar aislamiento de estado: pintar en Colorea no debe afectar trazos guardados en free-draw ni viceversa.
- [ ] Verificar `frozen.webp` en dispositivo real (orientación landscape/portrait) para confirmar que el multiply no deja artefactos.

## Referencias
[[03-Implementación/Mini-Juegos]]
[[02-Arquitectura/Visión General]]

---
*Generado automáticamente · 2026-09-24 17:58*