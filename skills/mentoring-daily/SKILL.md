---
name: mentoring-daily
description: Crea notas diarias de sesiones de mentoría de backend en Obsidian (Laravel/PHP). Reconstruye notas de días sin anotación a partir de PRs de GitHub y contexto del mentor. Invocar con /mentoring-daily cuando el mentor quiera registrar o reconstruir sesiones de un mentoreado para una fecha o rango de fechas.
argument-hint: "<nombre mentoreado> [fecha o rango]"
---

# Daily de Mentoría

Parámetros recibidos: `$ARGUMENTS`

Interpretar en lenguaje natural:
- **Persona**: nombre del mentoreado (puede ser nombre parcial)
- **Fecha / rango**: puede ser "hoy", "ayer", "1 de junio", "2026-06-01 al 2026-06-04", etc. → normalizar a `YYYY-MM-DD`

---

## Step 1 — Leer contexto existente

1. Leer `~/obsidian-vault/CLAUDE.md` para estructura del vault.
2. En `~/obsidian-vault/Mentorías/{persona}/`, listar todos los archivos `.md` con fecha en el nombre, ordenados descendente.
3. Leer las **2–3 notas más recientes** anteriores al rango pedido para entender estilo, nivel y estado del mentoreado.
4. Si ya existen archivos para alguna de las fechas del rango, leerlos (pueden estar vacíos o incompletos).

---

## Step 2 — Recopilar contexto del mentor

Hacer **todas** estas preguntas en un único mensaje:

1. **¿Qué días de ese rango hubo sesión?** (ej: "solo lunes y miércoles", "todos los días de lunes a jueves")
2. **¿Hay PRs o documentos relevantes?** Pegar URLs de GitHub PRs u otros artefactos. Escribir "no" si no hay.
3. **¿Hubo temas discutidos que no queden evidenciados en los PRs?** (algo de la daily, un concepto que costó, una pregunta notable)

Esperar respuesta antes de continuar.

---

## Step 3 — Obtener datos de PRs

Por cada PR de GitHub proporcionado, ejecutar en paralelo:

```bash
gh pr view <número> --repo <owner/repo> --json title,body,createdAt,mergedAt,commits,files,reviews,comments
gh api repos/<owner/repo>/pulls/<número>/comments --jq '[.[] | {author: .user.login, body: .body, path: .path, created_at: .created_at}]'
```

Extraer internamente:
- Fechas de commits → qué día se trabajó en qué
- Archivos modificados → qué áreas del código
- Comentarios de review del mentor → qué se señaló, qué se corrigió
- Respuestas del mentoreado en el PR → preguntas formuladas, actitud ante el feedback

---

## Step 4 — Identificar gaps y preguntar

Para cada día del rango **sin evidencia en PRs** (ni commits, ni review activity):

Preguntar en un mensaje único: *"Para [día X] no veo actividad en los PRs — ¿qué pasó ese día?"*

Si la respuesta es vaga ("terminando modelos"), anotarlo tal cual — no inventar detalle.

---

## Step 5 — Escribir las notas

Crear o sobreescribir un archivo `.md` por cada día con sesión, dentro de:

```
~/obsidian-vault/Mentorías/{persona}/{YYYY-MM-DD al YYYY-MM-DD}/
```

El nombre de la carpeta usa primera y última fecha del rango (o de la semana laboral).

### Cuándo usar cada formato

**Formato breve** — días sin PR activity o con poco contenido técnico sustantivo.

**Formato completo** — días con review de PR, temas técnicos concretos, o avances de peso.

---

### Formato breve

```
[1–2 párrafos describiendo qué se hizo o discutió.]

> **Nota:** Esta nota fue reconstruida a partir del historial de PRs. No hubo nota raw disponible.
```

---

### Formato completo

```
---
date: YYYY-MM-DD
type: mentoria
proyecto: —
persona: [nombre real]
tags: [stack técnico y temas — ej: laravel, actions, psr-12, dto]
contexto: [1 línea: qué fue el hito del día]
---

# Daily — DD de mes de YYYY — [Nombre]

## Resumen

[2–3 líneas. Qué se hizo, qué indicó el ritmo del mentoreado, nota general.]

> **Nota:** [solo si fue reconstruido — omitir si hubo sesión con nota raw]

## Temas tratados

### [Tema 1]
[Qué se vio, cómo lo abordó el mentoreado, qué quedó claro y qué no.]

### [Tema 2]
[...]

## Próximos pasos acordados

- [Acciones concretas para el mentoreado]
- [Temas a retomar o profundizar]
```

---

### Reglas de redacción

- No inventar observaciones de actitud o comprensión que no vengan de los PRs o de lo que dijo el mentor.
- Comentarios de review del mentor → sección "Temas tratados". Correcciones que hizo el mentoreado → evidencia de receptividad al feedback.
- Las preguntas que el mentoreado formula en los PRs revelan cómo está pensando en capas — registrarlas textualmente si son relevantes.
- Si un día no tuvo sesión, no crear archivo para ese día.
- Mantener frontmatter coherente con el resto de la carpeta (leer notas existentes en Step 1 para verificar convención).
- No mencionar revisores externos al mentor en las notas (solo los comentarios del mentor son relevantes).

---

## Step 6 — Confirmar

Listar los archivos creados/modificados con sus paths. No mostrar el contenido completo salvo que el mentor lo pida.

Preguntar: **"¿Querés ajustar algo?"**
