---
name: mentoring-report
description: Genera un informe estructurado de mentoría/onboarding de un mentoreado, para pasarle a su manager. Lee las notas de ~/obsidian-vault/Mentorías/<nombre>/, pregunta el contexto necesario, redacta el informe en el estilo acordado y lo guarda en la carpeta del mentoreado.
argument-hint: "<nombre del mentoreado>"
disable-model-invocation: true
---

# Informe de Mentoría

Genera un informe de cierre o avance de mentoría para el mentoreado `$ARGUMENTS`.

## Step 1 — Leer las notas del mentoreado

Vault base: `~/obsidian-vault/`
Carpeta objetivo: `~/obsidian-vault/Mentorías/$ARGUMENTS/`

1. Listar todos los archivos `.md` de la carpeta.
2. Leer `_Perfil.md` si existe.
3. Leer todas las notas de sesión (archivos con fecha `YYYY-MM-DD` en el nombre), ordenadas cronológicamente. **No leer** archivos que ya sean informes (detectar por frontmatter `type: informe` o por nombre que contenga "Informe").
4. Si la carpeta no existe o tiene menos de 2 notas de sesión, comunicarlo al usuario y detener.

## Step 2 — Preguntar el contexto necesario

Con las notas leídas, hacer las siguientes preguntas **todas juntas en un solo mensaje**:

1. **¿A quién va dirigido el informe?** (nombre/rol del destinatario — ej: "su manager H")
2. **¿Es un informe de cierre o de avance?** (¿el proceso terminó o está en curso?)
3. **¿Cuál es tu evaluación general?** Pedirle al usuario que lo describa en 1–3 frases libres. No inferir esto de las notas — es la voz del mentor.
4. **¿Hubo condiciones o metodologías especiales** en el proceso? (ej: sin uso de IA, sin proyecto asignado, condiciones de contexto relevantes)
5. **¿Hay algo que NO incluir** o algún tema sensible que prefiera omitir?
6. **¿Hay PRs del mentoreado que quieras incluir como contexto?** (código entregado, reviews recibidos, etc.) Pegá los URLs si los tenés, o escribí "no".

Esperar la respuesta antes de continuar.

## Step 2.5 — Leer los PRs si se proporcionaron

Si el usuario proporcionó URLs de PRs en la pregunta 6:
- Por cada URL, ejecutar: `gh pr view <URL> --json title,body,reviews,comments`
- Resumir internamente el contenido relevante (título, descripción, comentarios de review, respuestas del mentoreado).
- Usar este contexto en Step 3 para enriquecer la sección "Evaluación del proceso", especialmente en lo relativo a calidad de código, receptividad al feedback y autonomía técnica.

## Step 2.6 — Análisis de avance del challenge (opcional)

Preguntar al mentor:

> "¿Querés incluir un análisis de avance del Healthcare API challenge en el informe? Si sí, pasame la ruta al repositorio del mentoreado."

Si el mentor responde con una ruta, ejecutar los siguientes pasos. Si dice "no" o no responde con una ruta, saltear este step por completo.

### A — Buscar informe previo (baseline)

1. Listar archivos `.md` en `~/obsidian-vault/Mentorías/$ARGUMENTS/` con frontmatter `type: mentoria`.
2. Excluir el informe que se está generando ahora.
3. Si existe al menos uno, tomar el más reciente por `date` en frontmatter. Buscar en él una sección "### Avance del challenge" y extraer la tabla de estados como baseline de la semana anterior.
4. Si no existe ninguno → **primera semana** → no hay baseline. Preguntar además:
   > "¿Cuál es el nivel de experiencia previa del mentoreado con migraciones y modelos en Laravel/PHP?"
   > Opciones: (a) Sin experiencia previa / (b) Algo de PHP u ORM pero sin Laravel / (c) Con experiencia en Laravel

### B — Escanear el repositorio

Explorar las siguientes rutas dentro de la ruta provista:

| Qué buscar | Dónde |
|---|---|
| Migraciones | `database/migrations/` |
| Modelos | `app/Models/`, `domain/` |
| Rutas API | `routes/api.php` |
| Controladores | `app/Http/Controllers/` |
| Recursos API | `app/Http/Resources/` |
| Form Requests | `app/Http/Requests/` |
| Acciones / lógica de dominio | `app/Actions/`, `domain/` |
| Notificaciones | `app/Notifications/` |
| Tests | `tests/Feature/`, `tests/Unit/` |

**Criterios de completitud por módulo:**

- **Migrations + Models** ✅ si existen migraciones y modelos para las cuatro entidades (doctors, clinics, patients, appointments). 🔄 si faltan algunas.
- **Patients CRUD** ✅ si existen rutas CRUD completas, `PatientController` con los 5 métodos y `PatientResource`. 🔄 si el controller existe pero faltan rutas o resource.
- **Clinics CRUD** ✅/🔄 — mismo criterio que Patients.
- **Doctors CRUD** ✅ si además incluye asignación de clínicas (relación presente en rutas/controller). 🔄 si hay CRUD básico pero falta la asignación.
- **Appointments** ✅ si existen rutas, controller, `FormRequest` con validaciones de negocio (overlap, pasado, clínica del doctor), y endpoint `GET /me/appointments`. 🔄 si el controller existe pero las validaciones están incompletas.
- **Authentication** ✅ si existen rutas de auth y middleware aplicado a las rutas de appointments. 🔄 si está parcialmente configurado.
- **Notifications** ✅ si existe al menos una clase en `app/Notifications/` referenciada desde el flujo de appointments.
- **Testing** ✅ si existen tests en `tests/Feature/` que cubran el módulo de appointments. 🔄 si hay tests pero parecen incompletos (pocos archivos o casos).

⏳ = no detectado.

### C — Calcular % y proyección

**Pesos relativos:**

| Módulo | Peso |
|---|---|
| Migrations + Models | 1.5 (sin exp.) / 1.0 (PHP sin Laravel) / 0.5 (con Laravel) |
| Patients CRUD | 1.0 |
| Clinics CRUD | 0.5 |
| Doctors CRUD | 0.5 |
| Appointments | 2.5 |
| Authentication | 1.0 |
| Notifications | 0.2 |
| Testing | 4.5 |

Los módulos 🔄 cuentan como **0.5 de su peso** completo.

**% de avance** = suma de pesos completados / peso total × 100

**Proyección:**
- **Primera semana:** usar pesos teóricos. Velocidad de referencia = ritmo de sesiones (frecuencia inferida de las notas) × capacidad estimada por sesión según experiencia.
- **Semanas siguientes:** calcular velocidad real = peso completado desde el baseline / sesiones transcurridas en esa semana (notas con fecha en los últimos 7 días). Proyectar semanas restantes = peso restante / velocidad_real.

### D — Validar con el mentor

Mostrar el estado detectado con el siguiente formato y esperar correcciones antes de continuar:

```
📊 Estado detectado en el repositorio:

| Módulo            | Estado | Detectado porque...                              |
|-------------------|--------|--------------------------------------------------|
| Migrations/Models | ✅     | migraciones + modelos para las 4 entidades       |
| Patients CRUD     | ✅     | PatientController + rutas + PatientResource      |
| Clinics CRUD      | 🔄     | ClinicController existe, falta Resource          |
| Doctors CRUD      | ⏳     | no detectado                                     |
| Appointments      | ⏳     | no detectado                                     |
| Authentication    | ⏳     | no detectado                                     |
| Notifications     | ⏳     | no detectado                                     |
| Testing           | ⏳     | no detectado                                     |

Progreso estimado: ~28%
Delta esta semana: Patients CRUD completado
Proyección: ~5 semanas al ritmo actual
```

Preguntar: **"¿Coincide con lo que viste en sesión? ¿Algún estado para corregir?"**

Esperar respuesta e incorporar las correcciones antes de pasar al Step 3.

## Step 3 — Construir el informe

Con las notas, las respuestas del usuario y el contexto de PRs (si aplica), redactar el informe en español con esta estructura:

```
## Informe de Mentoría — [Nombre real del mentoreado]

**Período:** [primera fecha de sesión] – [última fecha de sesión]
**Formato:** [N] sesiones individuales de entre [X] y [Y] minutos, de frecuencia [inferir: semanal / quincenal / variable]
**Contexto:** [1–2 líneas: rol del mentoreado, punto de partida, objetivo del proceso]

---

### Temario cubierto

[Párrafo introductorio si hay un hilo común a todas las sesiones — omitir si no lo hay]

| Período | Temas |
|---|---|
| [rango de fechas] | [temas de ese bloque, separados por punto] |
...

---

### Avance del challenge

[Incluir esta sección SOLO si se ejecutó el Step 2.6 y el mentor validó el estado]

| Módulo | Estado | Notas |
|---|---|---|
| Migrations + Models | [✅/🔄/⏳] | [observación opcional] |
| Patients CRUD | [✅/🔄/⏳] | |
| Clinics CRUD | [✅/🔄/⏳] | |
| Doctors CRUD | [✅/🔄/⏳] | |
| Appointments | [✅/🔄/⏳] | |
| Authentication | [✅/🔄/⏳] | |
| Notifications | [✅/🔄/⏳] | |
| Testing | [✅/🔄/⏳] | |

**Progreso estimado:** ~X% (X/8 módulos)
[Si no es la primera semana]: **Esta semana:** [lista de módulos completados en el período]
**Proyección:** ~X semanas para completar el challenge al ritmo actual

---

### Evaluación del proceso

[Secciones según lo que el usuario respondió en Step 2. Pueden ser 2–4 subsecciones con título en negrita.
Cada subsección: 2–4 líneas. Solo incluir lo que tiene respaldo en notas, PRs o en lo que dijo el mentor.
NO inventar observaciones.]

---

### Valoración general

[2–4 líneas síntesis. Voz del mentor, basada en su evaluación del Step 2.]
```

**Reglas de redacción:**
- Solo incluir en "Evaluación del proceso" lo que el mentor confirmó o lo que está en las notas/PRs.
- No inventar observaciones de actitud, calidad de preguntas ni evolución si no fue mencionado explícitamente.
- El "Temario cubierto" se construye exclusivamente desde las notas de sesión.
- Si hubo una pausa larga entre sesiones (>3 semanas), mencionarla en el período correspondiente de la tabla.
- Agrupar sesiones temáticamente cuando sea posible (no listar una fila por sesión).

Mostrar el borrador completo al usuario y preguntar: **"¿Hay algo que quieras ajustar antes de guardar?"**

Esperar respuesta antes de escribir.

## Step 4 — Guardar en Obsidian

Incorporar los ajustes del usuario. Guardar en:

```
~/obsidian-vault/Mentorías/$ARGUMENTS/[Nombre real] Informe [tipo].md
```

Donde `[tipo]` es "Onboarding [stack/área]" o "Mentoría [período]" según corresponda.

Frontmatter obligatorio:

```yaml
---
date: YYYY-MM-DD  ← fecha de hoy
type: mentoria
proyecto: —
persona: [nombre real]
tags: [informe, mentoria]
contexto: Informe de [cierre/avance] de [descripción breve] para [destinatario].
---
```

Si ya existe un archivo de informe en la carpeta, preguntar al usuario si quiere sobreescribir o crear uno nuevo.
