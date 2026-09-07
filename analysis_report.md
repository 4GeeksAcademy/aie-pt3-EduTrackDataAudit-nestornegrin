

Analysis report · MD
EduTrack — Informe de Auditoría (Q3) — Esquema Normalizado v2
Preparado por: Analista de datos (externo) Esquema: students (8 filas) · courses (7 filas) · enrollments (16 filas), con enrollments.student_id → students.id y enrollments.course_id → courses.id Regla seguida: todas las consultas usan JOIN directo entre tablas; ninguna usa subconsultas.

0. Diagrama Entidad-Relación
Ver diagram.png en la raíz del repositorio.

students (1) — (N) enrollments: un estudiante puede tener muchas inscripciones; cada inscripción pertenece a un solo estudiante.
courses (1) — (N) enrollments: un curso puede tener muchas inscripciones; cada inscripción pertenece a un solo curso.
Como consecuencia, students y courses tienen una relación N:M, resuelta a través de la tabla asociativa enrollments (que además guarda atributos propios de la relación: fecha, % completado, aprobado, pago).
1. Consultas — INNER JOIN
1.1 Todas las inscripciones (estudiante, curso, % completado)
Resultado: 16 filas (ejemplo, primeras y últimas):

Estudiante	Curso	% Completado
Emily Watson	Intro to Python	85%
Emily Watson	Web Design Basics	60%
Klaus Weber	Intro to Python	92%
Klaus Weber	Data Analysis with SQL	78%
Lucia Fernandes	Web Design Basics	5%
Lucia Fernandes	Digital Marketing 101	3%
Marco Rossi	Advanced Python	95%
Marco Rossi	Intro to Python	88%
Yuki Nakamura	Data Analysis with SQL	45%
Yuki Nakamura	UI/UX Fundamentals	0%
Pierre Dubois	UI/UX Fundamentals	0%
Priya Sharma	Digital Marketing 101	70%
Priya Sharma	Intro to Python	55%
Pierre Dubois	Data Analysis with SQL	20%
Emily Watson	Advanced Python	40%
Lucia Fernandes	Advanced Python	0%
1.2 Estudiantes que aprobaron al menos un curso
Resultado: 6 filas (4 estudiantes distintos)

Estudiante	Email	Curso aprobado
Emily Watson	emily.watson@student.edutrack.com	Intro to Python
Klaus Weber	klaus.weber@student.edutrack.com	Intro to Python
Klaus Weber	klaus.weber@student.edutrack.com	Data Analysis with SQL
Marco Rossi	marco.rossi@student.edutrack.com	Advanced Python
Marco Rossi	marco.rossi@student.edutrack.com	Intro to Python
Priya Sharma	priya.sharma@student.edutrack.com	Digital Marketing 101
Hallazgo: Klaus Weber y Marco Rossi son los únicos que han aprobado 2 cursos cada uno; son los estudiantes con mejor desempeño de la plataforma.

1.3 % de completado medio por instructor (descendente)
Resultado:

Marta López — 66.14%
Carlos Vega — 40.00%
Lucia Prades — 36.50%
Pending assignment — 0.00%
Hallazgo: los cursos que aún no tienen instructor asignado ("Pending assignment" → UI/UX Fundamentals) tienen 0% de completado. Marta López es, con claridad, la instructora con mejores resultados.

2. Consultas — LEFT JOIN (datos faltantes)
2.1 Estudiantes sin ninguna inscripción
Resultado: 1 estudiante

Giulia Romano (giulia.romano@student.edutrack.com) — se registró pero nunca se apuntó a un curso.
2.2 Cursos sin ninguna inscripción
Resultado: 1 curso

Email Campaigns (Marketing) — está en catálogo pero nadie se ha apuntado.
Hallazgo: ambos son candidatos a revisión — Giulia Romano para un contacto de onboarding/reactivación, y "Email Campaigns" para evaluar si se archiva o se promociona antes de retirarlo.

3. Consultas — Agregación entre tablas
3.1 Estudiantes inscritos en más de un curso
Resultado: 7 de 7 estudiantes con inscripciones (todos los que tienen alguna inscripción están en más de un curso)

Estudiante	Cursos
Lucia Fernandes	3
Emily Watson	3
Marco Rossi	2
Klaus Weber	2
Priya Sharma	2
Pierre Dubois	2
Yuki Nakamura	2
3.2 Ingresos totales por categoría (precio ACTUAL del curso, courses.monthly_fee)
Resultado:

Programming: $409.93
Data: $179.97
Design: $169.96
Marketing: $59.98
Nota: estos importes coinciden con los de la auditoría anterior porque en este dataset el precio actual de cada curso es el mismo que se pagó históricamente — pero esta consulta usa courses.monthly_fee, no enrollments.monthly_fee_paid, por lo que reflejaría cualquier cambio de precio futuro.

3.3 Estudiantes inscritos actualmente por instructor
Resultado:

Marta López: 6 estudiantes
Carlos Vega: 3 estudiantes
Lucia Prades: 2 estudiantes
Pending assignment: 2 estudiantes
4. Consultas — Integridad de datos
4.1 Inscripciones con student_id inexistente
Resultado: 0 filas ✅ — no hay registros huérfanos por estudiante.

4.2 Inscripciones con course_id inexistente
Resultado: 0 filas ✅ — no hay registros huérfanos por curso.

Hallazgo: la integridad referencial es correcta; las claves foráneas (enrollments_student_id_fkey, enrollments_course_id_fkey) están funcionando como se espera y no hay inconsistencias que corregir.

5. Conclusiones
Categoría líder en ingresos: Programming ($409.93), impulsada por "Intro to Python" y "Advanced Python".
Mejor instructora: Marta López, con el promedio de completado más alto (66.14%) y la mayor base de estudiantes (6).
Riesgos de catálogo: un curso sin ninguna inscripción ("Email Campaigns") y una estudiante sin ninguna inscripción (Giulia Romano) — ambos casos accionables antes del reporting de Q3.
Calidad de datos: el esquema normalizado con claves foráneas eliminó por diseño los problemas de la v1 (cuentas de prueba, instructor NULL en enrollments); la comprobación de integridad confirma 0 registros huérfanos.





