# Changelog

Todos los cambios notables de este proyecto están documentados aquí.
El formato está basado en [Keep a Changelog](https://keepachangelog.com/es/1.0.0/)
y este proyecto adhiere a [Semantic Versioning](https://semver.org/lang/es/).

---

## [Unreleased] - 2026-09-24

### Agregado
- Nuevo minijuego "Sigue el Camino": el niño traza con el dedo un camino curvo entre dos personajes de la familia, con marcador animado, destellos de progreso y celebración al completar la ruta
- Nuevo minijuego "Dibuja Libre": lienzo de dibujo libre con selección de color, 4 estilos de pincel (lápiz, marcador, brocha, acuarela) y 3 tamaños de trazo
- Nuevo minijuego "Colorea": galería de dibujos para colorear (Olaf, Elsa) con lienzo dedicado, mismos pinceles y colores del dibujo libre, y línea de arte que respeta el color pintado debajo

### Refactorizado
- Paleta de colores, pinceles y tamaños del dibujo libre extraída a componente compartido (`DrawingPalette`), reutilizado por el nuevo minijuego de colorear
