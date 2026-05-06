# 📚 Sistema de Biblioteca Digital — ReadFlow

> Diseño completo de base de datos para la plataforma **ReadFlow**: desde el modelo conceptual hasta el script SQL funcional.

---

## 📋 Tabla de contenido

1. [Descripción del proyecto](#descripción-del-proyecto)
2. [Modelo Conceptual (E-R)](#1-modelo-conceptual-e-r)
3. [Modelo Lógico](#2-modelo-lógico)
4. [Normalización hasta 3FN](#3-normalización-hasta-3fn)
5. [Modelo Físico](#4-modelo-físico)
6. [Script SQL](#5-script-sql)
7. [Consultas SQL](#6-consultas-sql)

---

## Descripción del proyecto

**ReadFlow** es una plataforma digital que permite gestionar libros, usuarios, préstamos y reseñas. Este repositorio contiene el diseño completo de su base de datos, cubriendo:

- Gestión de libros con ISBN único y control de disponibilidad
- Registro de usuarios con email único
- Control de préstamos por usuario
- Sistema de reseñas con calificación y comentario
- Clasificación de libros por categorías (relación N:M)

---

## 1. Modelo Conceptual (E-R)

El modelo conceptual identifica las **entidades**, sus **atributos** y las **relaciones** entre ellas.

### Entidades y atributos

| Entidad | Atributos | Clave primaria |
|---|---|---|
| **LIBRO** | ISBN, título, año, género, estado | ISBN |
| **USUARIO** | id_usuario, nombre, email, teléfono, fecha_registro | id_usuario |
| **PRÉSTAMO** | id_prestamo, fecha_prestamo, fecha_devolucion | id_prestamo |
| **RESEÑA** | id_resena, calificacion, comentario, fecha | id_resena |
| **CATEGORÍA** | id_categoria, nombre | id_categoria |

### Relaciones y cardinalidades

| Relación | Entidad A | Cardinalidad | Entidad B |
|---|---|---|---|
| asigna | LIBRO | 1 : N | PRÉSTAMO |
| darse cuenta | USUARIO | 1 : N | PRÉSTAMO |
| tiene | LIBRO | 1 : N | RESEÑA |
| escribe | USUARIO | 1 : N | RESEÑA |
| clasificado en | LIBRO | N : M | CATEGORÍA |

### Diagrama E-R

<img width="1251" height="739" alt="Diagrama_Logico" src="https://github.com/user-attachments/assets/8cec5f4c-85fa-475a-9dbb-5452e8a5f17c" />


---

## 2. Modelo Lógico

La conversión del modelo conceptual al lógico produce las siguientes tablas relacionales. Cada relación N:M se convierte en una **tabla intermedia**.

### Tablas resultantes

**usuario** (<u>id_usuario</u>, nombre, email*, teléfono, fecha_registro)

**libro** (<u>ISBN</u>, título, año, género, estado)

**prestamo** (<u>id_prestamo</u>, isbn_libro†, id_usuario†, fecha_prestamo, fecha_devolucion)

**resena** (<u>id_resena</u>, isbn_libro†, id_usuario†, calificacion, comentario, fecha)

**categoria** (<u>id_categoria</u>, nombre)

**libro_categoria** (<u>isbn_libro†</u>, <u>id_categoria†</u>)

> *Atributo con restricción UNIQUE · †Clave foránea (FK)

### Diagrama del modelo lógico (DrawSQL)

<img width="1308" height="602" alt="Captura de pantalla 2026-05-06 082847" src="https://github.com/user-attachments/assets/3fa6d1b3-75a8-4a28-ba60-19cf2af6bb6b" />



---

## 3. Normalización hasta 3FN

### Primera Forma Normal (1FN)
Todas las tablas cumplen 1FN porque:
- Cada columna contiene valores atómicos (un solo valor por celda).
- No existen grupos repetitivos.
- Cada tabla tiene una clave primaria definida.

### Segunda Forma Normal (2FN)
Todas las tablas cumplen 2FN porque:
- Están en 1FN.
- Todos los atributos no clave dependen **completamente** de la clave primaria.
- La tabla `libro_categoria` tiene PK compuesta (isbn_libro, id_categoria) y no tiene atributos adicionales que dependan solo de una parte de ella.

### Tercera Forma Normal (3FN)
Todas las tablas cumplen 3FN porque:
- Están en 2FN.
- No existen **dependencias transitivas**: ningún atributo no clave depende de otro atributo no clave.

| Tabla | 1FN | 2FN | 3FN |
|---|:---:|:---:|:---:|
| usuario | ✅ | ✅ | ✅ |
| libro | ✅ | ✅ | ✅ |
| prestamo | ✅ | ✅ | ✅ |
| resena | ✅ | ✅ | ✅ |
| categoria | ✅ | ✅ | ✅ |
| libro_categoria | ✅ | ✅ | ✅ |

---

## 4. Modelo Físico

El modelo físico define los tipos de datos, restricciones e índices concretos para su implementación en un motor de base de datos.

### Tabla `usuario`
| Campo | Tipo | Restricciones |
|---|---|---|
| id_usuario | INTEGER | PK, NOT NULL |
| nombre | VARCHAR(150) | NOT NULL |
| email | VARCHAR(150) | NOT NULL, UNIQUE |
| telefono | VARCHAR(20) | |
| fecha_registro | DATE | NOT NULL |

### Tabla `libro`
| Campo | Tipo | Restricciones |
|---|---|---|
| ISBN | VARCHAR(20) | PK, NOT NULL |
| titulo | VARCHAR(255) | NOT NULL |
| anio | INTEGER | |
| genero | VARCHAR(100) | |
| estado | VARCHAR(20) | NOT NULL, DEFAULT 'disponible', CHECK IN ('disponible','prestado') |

### Tabla `prestamo`
| Campo | Tipo | Restricciones |
|---|---|---|
| id_prestamo | INTEGER | PK, NOT NULL |
| isbn_libro | VARCHAR(20) | FK → libro.ISBN, NOT NULL |
| id_usuario | INTEGER | FK → usuario.id_usuario, NOT NULL |
| fecha_prestamo | DATE | NOT NULL |
| fecha_devolucion | DATE | |

### Tabla `resena`
| Campo | Tipo | Restricciones |
|---|---|---|
| id_resena | INTEGER | PK, NOT NULL |
| isbn_libro | VARCHAR(20) | FK → libro.ISBN, NOT NULL |
| id_usuario | INTEGER | FK → usuario.id_usuario, NOT NULL |
| calificacion | INTEGER | NOT NULL, CHECK BETWEEN 1 AND 5 |
| comentario | TEXT | |
| fecha | DATE | NOT NULL |

### Tabla `categoria`
| Campo | Tipo | Restricciones |
|---|---|---|
| id_categoria | INTEGER | PK, NOT NULL |
| nombre | VARCHAR(100) | NOT NULL |

### Tabla `libro_categoria`
| Campo | Tipo | Restricciones |
|---|---|---|
| isbn_libro | VARCHAR(20) | PK, FK → libro.ISBN |
| id_categoria | INTEGER | PK, FK → categoria.id_categoria |

---

## 5. Script SQL

El archivo [`biblioteca_readflow_sqlite.sql`](./biblioteca_readflow_sqlite.sql) contiene:

- Creación de las 6 tablas con todas sus restricciones
- Datos de prueba para cada tabla
- Las 3 consultas SQL del punto 6

Probado y funcional en **Programiz SQL Online Compiler** (SQLite).

---

## 6. Consultas SQL

### Consulta 1 — Libros disponibles
Lista todos los libros cuyo estado sea `'disponible'`.

```sql
SELECT ISBN, titulo, anio, genero
FROM libro
WHERE estado = 'disponible';
```

**Resultado esperado:**

| ISBN | titulo | anio | genero |
|---|---|---|---|
| 978-0-06-112008-4 | Cien años de soledad | 1967 | Novela |
| 978-0-7432-7356-5 | El alquimista | 1988 | Ficcion |

---

### Consulta 2 — Préstamos activos
Muestra los préstamos sin fecha de devolución, con nombre del usuario y título del libro.

```sql
SELECT
    p.id_prestamo,
    u.nombre         AS usuario,
    l.titulo         AS libro,
    p.fecha_prestamo,
    p.fecha_devolucion
FROM prestamo p
JOIN usuario u ON p.id_usuario = u.id_usuario
JOIN libro   l ON p.isbn_libro = l.ISBN
WHERE p.fecha_devolucion IS NULL;
```

**Resultado esperado:**

| id_prestamo | usuario | libro | fecha_prestamo | fecha_devolucion |
|---|---|---|---|---|
| 2 | Ana García | Cien años de soledad | 2024-11-10 | NULL |

---

### Consulta 3 — Reseñas con calificación ≥ 4
Muestra todas las reseñas bien calificadas, ordenadas de mayor a menor.

```sql
SELECT
    u.nombre         AS usuario,
    l.titulo         AS libro,
    r.calificacion,
    r.comentario,
    r.fecha
FROM resena r
JOIN usuario u ON r.id_usuario = u.id_usuario
JOIN libro   l ON r.isbn_libro = l.ISBN
WHERE r.calificacion >= 4
ORDER BY r.calificacion DESC;
```

**Resultado esperado:**

| usuario | libro | calificacion | comentario | fecha |
|---|---|---|---|---|
| Ana García | Cien años de soledad | 5 | Una obra maestra... | 2024-11-20 |
| María López | El principito | 5 | Un clasico que nunca... | 2024-11-16 |
| Luis Pérez | El alquimista | 4 | Muy inspirador... | 2024-11-22 |

---

## 🛠️ Herramientas utilizadas

| Herramienta | Uso |
|---|---|
| draw.io | Diagrama conceptual E-R |
| DrawSQL | Modelo lógico |
| Programiz SQL Online | Prueba del script SQL |
| GitHub | Control de versiones y entrega |
