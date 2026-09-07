# EduTrack — Informe de Auditoría de `enrollments` (Q3)

**Preparado por:** Analista de datos (externo)
**Tabla analizada:** `enrollments` (17 filas originales → 16 filas tras la limpieza)
**Alcance:** `students` y `courses` no se modificaron; sirven solo de contexto.

---

## 1. Configuración de la base de datos

- El script `edutrack.sql` se importó correctamente en el SQL Editor de Supabase.
- Verificación de tablas y volumen de datos:

| Tabla | Filas |
|---|---|
| students | 10 |
| courses | 7 |
| enrollments | 17 (antes de la limpieza) |

---

## 2. Consultas — Lectura y filtrado

### 2.1 Inscripciones en 'Intro to Python'
Resultado: **5 inscripciones**

| Estudiante | Email | % Completado |
|---|---|---|
| Emily Watson | emily.watson@student.edutrack.com | 85% |
| Klaus Weber | klaus.weber@student.edutrack.com | 92% |
| Marco Rossi | marco.rossi@student.edutrack.com | 88% |
| James Miller | james.miller@test.com | 30% |
| Priya Sharma | priya.sharma@student.edutrack.com | 55% |

> Nota: la fila de James Miller es una cuenta de prueba (`@test.com`) que se elimina en la sección de corrección de datos (3.3).

### 2.2 Posibles abandonos (completion_percentage < 10)
Resultado: **4 inscripciones**

- Lucia Fernandes — Web Design Basics — 5%
- Lucia Fernandes — Digital Marketing 101 — 3%
- Yuki Nakamura — UI/UX Fundamentals — 0%
- Pierre Dubois — UI/UX Fundamentals — 0%

**Hallazgo:** Lucia Fernandes tiene dos inscripciones con avance casi nulo (5% y 3%), y ambas inscripciones a "UI/UX Fundamentals" están en 0% — coincide además con el curso que llegó sin instructor asignado (ver 2.3). Son los candidatos más claros a abandono temprano.

### 2.3 Inscripciones sin instructor (instructor IS NULL)
Resultado: **2 inscripciones**, ambas del curso "UI/UX Fundamentals"

- Yuki Nakamura — UI/UX Fundamentals
- Pierre Dubois — UI/UX Fundamentals

**Hallazgo:** confirma el aviso de operaciones — el lote del partner sin instructor corresponde íntegramente a "UI/UX Fundamentals" (el mismo curso que en el esquema de `courses` tiene `instructor_name = NULL`, es decir, un curso aún sin instructor asignado en el catálogo).

### 2.4 Top 5 con mayor % de completado que aún no han aprobado
Resultado:

1. Emily Watson — Web Design Basics — 60% (no aprobado)
2. Priya Sharma — Intro to Python — 55% (no aprobado)
3. Yuki Nakamura — Data Analysis with SQL — 45% (no aprobado)
4. Emily Watson — Advanced Python — 40% (no aprobado)
5. James Miller — Intro to Python — 30% (no aprobado) *(cuenta de prueba, se elimina)*

**Hallazgo:** Emily Watson y Priya Sharma tienen avance considerable (60% y 55%) sin haber aprobado — son buenas candidatas para seguimiento/refuerzo antes de darlas por perdidas.

### 2.5 Inscripciones del último año (ordenadas por fecha, descendente)
Resultado: **16 de 17 inscripciones** caen dentro de los 12 meses previos a la fecha de inscripción más reciente registrada (2025-03-05). La única fuera de rango es la de Marco Rossi en "Advanced Python" (2024-02-14).

| Fecha | Estudiante | Curso |
|---|---|---|
| 2025-03-05 | Emily Watson | Advanced Python |
| 2025-02-20 | Pierre Dubois | Data Analysis with SQL |
| 2025-01-10 | Priya Sharma | Intro to Python |
| 2024-12-01 | Priya Sharma | Digital Marketing 101 |
| 2024-11-05 | Pierre Dubois | UI/UX Fundamentals |
| 2024-10-11 | Yuki Nakamura | UI/UX Fundamentals |
| 2024-09-03 | Yuki Nakamura | Data Analysis with SQL |
| 2024-08-09 | Marco Rossi | Intro to Python |
| 2024-07-01 | Lucia Fernandes | Digital Marketing 101 |
| 2024-06-30 | Alex Chen | Web Design Basics *(cuenta de prueba)* |
| 2024-06-20 | Lucia Fernandes | Web Design Basics |
| 2024-05-22 | James Miller | Intro to Python *(cuenta de prueba)* |
| 2024-05-01 | Klaus Weber | Data Analysis with SQL |
| 2024-04-15 | Emily Watson | Web Design Basics |
| 2024-03-12 | Klaus Weber | Intro to Python |
| 2024-03-10 | Emily Watson | Intro to Python |

---

## 3. Consultas — Corrección de datos

### 3.1 INSERT del registro faltante
Se confirmó por correo pero nunca se registró: **Lucia Fernandes, inscrita en "Advanced Python" el 2025-04-01**. Se insertó con `id = 18`, `completion_percentage = 0`, `passed = false`, `monthly_fee_paid = 69.99`, `instructor = Carlos Vega`.
Resultado: **1 fila insertada** ✅ (verificada con `SELECT * WHERE id = 18`).

### 3.2 UPDATE de instructor NULL → 'Pending assignment'
Resultado: **2 filas actualizadas** (las mismas identificadas en 2.3 — Yuki Nakamura y Pierre Dubois, curso "UI/UX Fundamentals"), ahora con `instructor = 'Pending assignment'`.

### 3.3 DELETE de cuentas de prueba (@test.com)
El `SELECT` previo confirmó 2 filas afectadas antes de borrar:
- James Miller (james.miller@test.com) — Intro to Python
- Alex Chen (alex.chen@test.com) — Web Design Basics

Resultado: **2 filas eliminadas** ✅ (verificado: 0 cuentas `@test.com` restantes).

**Balance de filas:** 17 (original) + 1 (insertada) − 2 (eliminadas) = **16 inscripciones** tras la limpieza.

---

## 4. Consultas — Agregación e informe

*(calculadas sobre las 16 inscripciones ya corregidas)*

### 4.1 Inscripciones por categoría
Resultado:
- Programming: 7
- Design: 4
- Data: 3
- Marketing: 2

### 4.2 Promedio de % completado por curso (ascendente)
Resultado:
1. UI/UX Fundamentals — 0.00%
2. Web Design Basics — 32.50%
3. Digital Marketing 101 — 36.50%
4. Advanced Python — 45.00%
5. Data Analysis with SQL — 47.67%
6. Intro to Python — 80.00%

### 4.3 Cursos con más de 3 inscripciones (HAVING)
Resultado: **1 curso** cumple el criterio
- Intro to Python — 4 inscripciones

### 4.4 Ingresos totales por categoría (descendente)
Resultado:
- Programming: $409.93
- Data: $179.97
- Design: $169.96
- Marketing: $59.98

**Ingreso total (las 4 categorías): $819.84**

---

## 5. Conclusiones y recomendaciones

1. **Categoría con peor rendimiento:** Design, arrastrada por "UI/UX Fundamentals" (0% de completado promedio) — el curso coincide exactamente con el lote de inscripciones sin instructor. Recomendación: asignar instructor a "UI/UX Fundamentals" antes de invertir en captación para ese curso; probablemente la falta de instructor esté frenando el avance de los estudiantes.
2. **"Intro to Python" es el motor del catálogo:** es el único curso con más de 3 inscripciones y el que mejor promedio de completado tiene (80%). Es un buen candidato para escalar contenido o crear un curso de continuidad.
3. **Riesgo de abandono:** Lucia Fernandes concentra 2 de las 4 inscripciones con <10% de avance. Vale la pena un contacto proactivo antes del reporting de Q3.
4. **Calidad de datos:** Se detectaron y corrigieron 3 problemas de origen (cuentas de prueba sin depurar, un lote sin instructor por integración con el partner, y un registro que nunca llegó a persistirse). Se recomienda: (a) validar el dominio del email en el formulario/integración para evitar que entren cuentas de prueba a producción, y (b) añadir una constraint `NOT NULL` o un valor por defecto en `instructor` para que futuras cargas del partner no generen NULLs.
