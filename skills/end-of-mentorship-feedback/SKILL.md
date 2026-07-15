---
name: end-of-mentorship-feedback
description: Genera el reporte de cierre de mentoría para un mentoreado, respondiendo las 10 preguntas estándar de Light-it en español. Lee todas las notas del vault de Obsidian en Mentorías/NombreApellido y los informes de avance semanales para construir respuestas detalladas y basadas en evidencia. Usar cuando el mentor quiera completar el formulario de end of mentorship. Invocar con /end-of-mentorship-feedback NombreApellido.
argument-hint: "[Nombre Apellido del mentoreado]"
---

# End of Mentorship Feedback

## Workflow

### 1. Localizar las notas del mentoreado

Buscar la carpeta en Obsidian:
```bash
find ~/obsidian-vault/Mentorías/<Nombre Apellido> -type f -name "*.md" | sort
```

Si el nombre no coincide exactamente, hacer búsqueda flexible:
```bash
find ~/obsidian-vault/Mentorías -type d | grep -i "<nombre>"
```

### 2. Leer el material en este orden de prioridad

1. **Informe de cierre** (`*Informe Onboarding Backend.md` o similar) — visión global del período
2. **Informes de avance semanales** (`*Informe Avance.md` en cada carpeta semanal) — progreso semana a semana
3. **Notas diarias** — detalles concretos, anécdotas, ejemplos específicos

Leer todos en paralelo para eficiencia.

### 3. Responder las 10 preguntas

Ver las preguntas en `references/questions.md`.

**Reglas de redacción:**
- Responder **en español**
- Cada respuesta debe ser **específica y basada en evidencia** de las notas (nombres de PRs, fechas, módulos concretos, anécdotas)
- Evitar generalidades vacías ("es un buen estudiante") — siempre anclar en hechos observados
- Longitud por respuesta: 2–4 párrafos, proporcional a la cantidad de evidencia disponible
- Mencionar tanto fortalezas como áreas de mejora cuando sea relevante
- Tono: profesional, directo, constructivo

### 4. Identificar gaps y preguntar

Después de entregar las respuestas, revisar si hay preguntas donde la evidencia es escasa (especialmente interacción con el equipo, valores de la empresa). Si los hay, listar en qué áreas se necesita input adicional.

## Notas de contexto

- El vault de Obsidian está en `~/obsidian-vault/`
- La estructura de mentorías es: `~/obsidian-vault/Mentorías/<Nombre Apellido>/`
- Los informes de avance son el material más denso y estructurado; priorizarlos sobre notas diarias cuando el contexto es limitado
- Si el mentoreado tuvo restricción de IA durante el onboarding, mencionarlo en el contexto de la respuesta sobre growth mindset
- Las preguntas son las del formulario estándar de Light-it — responder todas, en el mismo orden

## Recursos

- `references/questions.md` — las 10 preguntas del formulario con notas de qué buscar en cada una
