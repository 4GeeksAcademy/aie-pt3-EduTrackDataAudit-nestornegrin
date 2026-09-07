
Queries · SQL
-- ============================================================
-- EduTrack v2 — Auditoría sobre el esquema normalizado (Q3)
-- Autor: Analista de datos externo
-- Todas las consultas usan JOIN directo entre tablas.
-- No se usan subconsultas en ningún punto de este archivo.
-- ============================================================
 
 
-- ------------------------------------------------------------
-- 0. CONFIGURACIÓN — verificación de la importación
-- ------------------------------------------------------------
SELECT * FROM students LIMIT 5;
SELECT * FROM courses LIMIT 5;
SELECT * FROM enrollments LIMIT 5;
 
 
-- ============================================================
-- 1. CONSULTAS — INNER JOIN
-- ============================================================
 
-- Q1. Todas las inscripciones: nombre completo del estudiante,
-- título del curso y % de completado
SELECT
    s.name AS student_name,
    c.title AS course_title,
    e.completion_percentage
FROM enrollments e
JOIN students s ON e.student_id = s.id
JOIN courses c ON e.course_id = c.id
ORDER BY e.id;
 
-- Q2. Estudiantes que han aprobado al menos un curso:
-- nombre, email y título del curso aprobado
SELECT
    s.name AS student_name,
    s.email,
    c.title AS course_title
FROM enrollments e
JOIN students s ON e.student_id = s.id
JOIN courses c ON e.course_id = c.id
WHERE e.passed = true
ORDER BY s.name;
 
-- Q3. % de completado medio por instructor, descendente
SELECT
    c.instructor_name AS instructor,
    ROUND(AVG(e.completion_percentage), 2) AS avg_completion
FROM enrollments e
JOIN courses c ON e.course_id = c.id
GROUP BY c.instructor_name
ORDER BY avg_completion DESC;
 
 
-- ============================================================
-- 2. CONSULTAS — LEFT JOIN (detección de datos faltantes)
-- ============================================================
 
-- Q4. Estudiantes sin ninguna inscripción (registrados, nunca se apuntaron)
SELECT
    s.id,
    s.name,
    s.email
FROM students s
LEFT JOIN enrollments e ON s.id = e.student_id
WHERE e.id IS NULL;
 
-- Q5. Cursos sin ninguna inscripción (en catálogo, nadie se ha apuntado)
SELECT
    c.id,
    c.title,
    c.category
FROM courses c
LEFT JOIN enrollments e ON c.id = e.course_id
WHERE e.id IS NULL;
 
 
-- ============================================================
-- 3. CONSULTAS — AGREGACIÓN ENTRE TABLAS
-- ============================================================
 
-- Q6. Número de cursos por estudiante; solo estudiantes con más de 1
SELECT
    s.name AS student_name,
    COUNT(e.id) AS total_courses
FROM students s
JOIN enrollments e ON s.id = e.student_id
GROUP BY s.id, s.name
HAVING COUNT(e.id) > 1
ORDER BY total_courses DESC;
 
-- Q7. Ingresos totales por categoría usando el precio ACTUAL del curso
-- (courses.monthly_fee), no el pago histórico de enrollments
SELECT
    c.category,
    SUM(c.monthly_fee) AS total_revenue
FROM enrollments e
JOIN courses c ON e.course_id = c.id
GROUP BY c.category
ORDER BY total_revenue DESC;
 
-- Q8. Cada instructor con el número de estudiantes actualmente
-- inscritos en sus cursos (distinct: un estudiante en 2 cursos del
-- mismo instructor cuenta una sola vez)
SELECT
    c.instructor_name AS instructor,
    COUNT(DISTINCT e.student_id) AS total_students
FROM enrollments e
JOIN courses c ON e.course_id = c.id
GROUP BY c.instructor_name
ORDER BY total_students DESC;
 
 
-- ============================================================
-- 4. CONSULTAS — INTEGRIDAD DE DATOS
-- ============================================================
 
-- Q9. Inscripciones huérfanas: student_id que no existe en students
SELECT
    e.id,
    e.student_id,
    e.course_id
FROM enrollments e
LEFT JOIN students s ON e.student_id = s.id
WHERE s.id IS NULL;
 
-- Q10. Inscripciones huérfanas: course_id que no existe en courses
SELECT
    e.id,
    e.student_id,
    e.course_id
FROM enrollments e
LEFT JOIN courses c ON e.course_id = c.id
WHERE c.id IS NULL;
 




