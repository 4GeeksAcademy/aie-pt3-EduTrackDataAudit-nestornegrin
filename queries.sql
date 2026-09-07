-- ============================================================
-- EduTrack — Auditoría de la tabla `enrollments` (Q3)
-- Autor: Analista de datos externo
-- Proyecto Supabase: ejecutar en el SQL Editor, en este orden.
-- ============================================================
-- Antes de ejecutar cualquier UPDATE/DELETE, se incluye un
-- SELECT previo con la misma condición WHERE para confirmar
-- las filas afectadas (buena práctica de auditoría).
-- ============================================================


-- ------------------------------------------------------------
-- 0. CONFIGURACIÓN — verificación de la importación
-- ------------------------------------------------------------
SELECT * FROM enrollments LIMIT 5;

SELECT
    (SELECT COUNT(*) FROM students)    AS total_students,
    (SELECT COUNT(*) FROM courses)     AS total_courses,
    (SELECT COUNT(*) FROM enrollments) AS total_enrollments;


-- ============================================================
-- 1. CONSULTAS — LECTURA Y FILTRADO
-- (diagnóstico: se ejecutan ANTES de corregir los datos)
-- ============================================================

-- Q1. Inscripciones en 'Intro to Python'
SELECT student_name, student_email, completion_percentage
FROM enrollments
WHERE course_title = 'Intro to Python';

-- Q2. Posibles abandonos: completion_percentage < 10
SELECT id, student_name, course_title, completion_percentage
FROM enrollments
WHERE completion_percentage < 10;

-- Q3. Inscripciones sin instructor asignado (instructor IS NULL)
SELECT id, student_name, course_title, instructor
FROM enrollments
WHERE instructor IS NULL;

-- Q4. Top 5 con mayor completion_percentage que aún NO han aprobado
SELECT student_name, course_title, completion_percentage, passed
FROM enrollments
WHERE passed = false
ORDER BY completion_percentage DESC
LIMIT 5;

-- Q5. Inscripciones del último año, ordenadas por fecha descendente.
-- Nota: se usa como referencia la fecha de inscripción más reciente
-- registrada en la tabla (en vez de CURRENT_DATE) para que la consulta
-- siga siendo representativa aunque se ejecute mucho tiempo después
-- de creado el dataset.
SELECT id, student_name, course_title, enrollment_date
FROM enrollments
WHERE enrollment_date >= (SELECT MAX(enrollment_date) FROM enrollments) - INTERVAL '1 year'
ORDER BY enrollment_date DESC;


-- ============================================================
-- 2. CONSULTAS — CORRECCIÓN DE DATOS
-- ============================================================

-- Q6. INSERT del registro de inscripción faltante (confirmado por email,
-- nunca registrado en el sistema)
INSERT INTO enrollments (
    id, student_id, student_name, student_email,
    course_id, course_title, category, enrollment_date,
    completion_percentage, passed, monthly_fee_paid, instructor
) VALUES (
    18, 3, 'Lucia Fernandes', 'lucia.fernandes@student.edutrack.com',
    5, 'Advanced Python', 'Programming', '2025-04-01',
    0, false, 69.99, 'Carlos Vega'
);

-- Verificación
SELECT * FROM enrollments WHERE id = 18;

-- Q7. UPDATE de inscripciones con instructor NULL (lote del partner)
-- SELECT previo de confirmación:
SELECT id, student_name, course_title, instructor
FROM enrollments
WHERE instructor IS NULL;

UPDATE enrollments
SET instructor = 'Pending assignment'
WHERE instructor IS NULL;

-- Verificación
SELECT id, student_name, course_title, instructor
FROM enrollments
WHERE instructor = 'Pending assignment';

-- Q8. DELETE de inscripciones ligadas a cuentas de prueba (@test.com)
-- SELECT previo de confirmación:
SELECT id, student_name, student_email, course_title
FROM enrollments
WHERE student_email LIKE '%@test.com';

DELETE FROM enrollments
WHERE student_email LIKE '%@test.com';

-- Verificación (debe devolver 0)
SELECT COUNT(*) AS remaining_test_accounts
FROM enrollments
WHERE student_email LIKE '%@test.com';


-- ============================================================
-- 3. CONSULTAS — AGREGACIÓN E INFORME
-- (se ejecutan DESPUÉS de aplicar las correcciones anteriores)
-- ============================================================

-- Q9. Número de inscripciones por categoría
SELECT category, COUNT(*) AS total_enrollments
FROM enrollments
GROUP BY category
ORDER BY total_enrollments DESC;

-- Q10. Promedio de completion_percentage por curso, ascendente
SELECT course_title, ROUND(AVG(completion_percentage), 2) AS avg_completion
FROM enrollments
GROUP BY course_title
ORDER BY avg_completion ASC;

-- Q11. Cursos con más de 3 inscripciones (HAVING)
SELECT course_title, COUNT(*) AS total_enrollments
FROM enrollments
GROUP BY course_title
HAVING COUNT(*) > 3
ORDER BY total_enrollments DESC;

-- Q12. Ingresos totales por categoría, descendente
SELECT category, SUM(monthly_fee_paid) AS total_revenue
FROM enrollments
GROUP BY category
ORDER BY total_revenue DESC;
