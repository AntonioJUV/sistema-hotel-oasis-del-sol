# 🏨 Sistema de Gestión de Reservas - Hotel Oasis del Sol

## 📋 Descripción del Proyecto
Sistema de base de datos relacional diseñado para la gestión automatizada de reservas, control de habitaciones, registro de huéspedes, consumos y administración de pagos para el Hotel Oasis del Sol.

## 🛠️ Tecnologías y Herramientas
* **Base de Datos:** SQL Server (SQL Server Management Studio)
* **Lenguaje:** T-SQL (DDL, DML, Vistas, Roles de Seguridad y Consultas Complejas)
* **Control de Versiones:** Git & GitHub

## ⚙️ Estructura del Sistema y Funcionalidades
El script implementa una arquitectura robusta orientada a la seguridad y optimización de datos:
* **Modelo de Supertipo y Subtipo:** Gestión jerárquica para la entidad `persona`, dividida en `trabajador` y `cliente`.
* **Control de Habitaciones y Stock:** Administración de estados (Disponible, Ocupado, Mantenimiento) y productos de minibar.
* **Proceso de Reservas y Pagos:** Registro de ingresos, cálculo de costos de alojamiento, consumos adicionales y emisión de comprobantes con IGV.
* **Seguridad:** Creación de roles personalizados (`Recurso_Recepcion`) y asignación de permisos específicos sobre las tablas clave.
* **Reportes Avanzados:** Vistas optimizadas y consultas complejas utilizando `JOIN`, subconsultas y agregaciones con `ROLLUP`.

## 📂 Contenido del Repositorio
* `HotelOasisDelSol_Script.sql`: Script completo que incluye la creación de la base de datos, tablas, relaciones (Foreign Keys), restricciones (Constraints), vistas, inserción de datos de prueba y consultas de verificación.

---
*Desarrollado como parte de la formación técnica en desarrollo de software.*